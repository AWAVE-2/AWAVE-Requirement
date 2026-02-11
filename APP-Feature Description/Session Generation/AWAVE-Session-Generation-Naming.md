# AWAVE Session-Generierung & Benennungslogik

**Technische Dokumentation**
**App-ID:** `de.awave.app` | **Version:** 1.3 → Native iOS (Swift 5.9+)
**Stand:** Februar 2026

---

## Inhaltsverzeichnis

1. [Systemübersicht](#1-systemübersicht)
2. [Session-Datenmodell](#2-session-datenmodell)
3. [Session-Benennungslogik](#3-session-benennungslogik)
4. [ContentId-Schema (Audio-Auflösung)](#4-contentid-schema)
5. [Phasen-Benennungslogik](#5-phasen-benennungslogik)
6. [Topic-Konfigurationen & Phasensequenzen](#6-topic-konfigurationen)
7. [Fantasiereise-Benennungslogik](#7-fantasiereise-benennungslogik)
8. [Musik-Genre-Zuordnung](#8-musik-genre-zuordnung)
9. [Frequenz-Sweep-Konfigurationen](#9-frequenz-sweep-konfigurationen)
10. [Phasendauer & Variable Bereiche](#10-phasendauer)
11. [Probabilistik & Sonderfälle](#11-probabilistik)
12. [Vergleich: OLD-APP (JS) vs. Swift](#12-vergleich-old-app-vs-swift)
13. [Session Generator Konzept (3 Cases)](#13-session-generator-konzept)
14. [Audio-Dateipfad-Generierung (OLD-APP)](#14-audio-dateipfad-generierung)
15. [ContentId-Auflösung (iOS)](#15-contentid-auflösung-ios)
16. [Dateireferenzen](#16-dateireferenzen)

---

## 1. Systemübersicht

AWAVE generiert dynamische, mehrphasige Meditationssessions algorithmisch basierend auf einem gewählten **Topic** (Thema). Jede Session besteht aus einem Header (Index 0) und N Phasen (Index 1..N), wobei jede Phase bis zu 6 parallele Audiospuren enthält: Text, Music, Nature, Sound, Frequency und Noise.

```
┌─────────────────────────────────────────────────────────┐
│  SESSION HEADER (Index 0)                               │
│  name, duration, voice, topic, type, enableFreq         │
├──────────┬──────────┬──────────┬────────┬──────────────┤
│ PHASE 1  │ PHASE 2  │ PHASE 3  │  ...   │  PHASE N     │
│ (intro)  │ (body)   │ (breath) │        │  (silence)   │
│ ┌──────┐ │ ┌──────┐ │ ┌──────┐ │        │ ┌──────────┐ │
│ │ text │ │ │ text │ │ │ text │ │        │ │ no text  │ │
│ │music │ │ │music │ │ │music │ │        │ │ music    │ │
│ │nature│ │ │nature│ │ │nature│ │        │ │ nature   │ │
│ │ freq │ │ │ freq │ │ │ freq │ │        │ │ freq     │ │
│ │noise │ │ │noise │ │ │noise │ │        │ │ noise    │ │
│ │sound │ │ │sound │ │ │sound │ │        │ │ sound    │ │
│ └──────┘ │ └──────┘ │ └──────┘ │        │ └──────────┘ │
└──────────┴──────────┴──────────┴────────┴──────────────┘
```

Der `SessionGenerator` erzeugt Sessions deterministisch bei gegebenem Seed (via `RandomNumberGenerator`-Protokoll) oder randomisiert im Produktivbetrieb.

---

## 2. Session-Datenmodell

### 2.1 Session-Objekt (Swift)

```swift
public struct Session: Codable, Identifiable {
    public let id: String                   // UUID (automatisch generiert)
    public var name: String                 // "{TopicDisplayName} Session"
    public var duration: TimeInterval       // Summe aller Phasendauern
    public var voice: Voice                 // franca | flo | marion | corinna
    public var topic: String                // rawValue des SessionTopic-Enums
    public var type: SessionType            // .standard | .custom | .sos
    public var enableFrequency: Bool        // true (Standard)
    public var phases: [SessionPhase]       // Array aller Phasen
}
```

### 2.2 Session-Objekt (OLD-APP / JavaScript)

```javascript
session[0] = {
    id:        "AWAVE-Session",       // Statischer Identifier
    name:      "Eigene Session",      // Wird durch Generator überschrieben
    infoText:  "Bei dieser Session…", // Beschreibungstext
    duration:  60,                    // Gesamtdauer in Sekunden
    timer:     0,                     // Countdown während Playback
    voice:     "Franca",              // Ausgewählte Stimme
    version:   1.3,                   // App-Version
    livePhase: 0,                     // Aktuelle Phase bei Playback
    topic:     "user",                // Topic-Identifier
    type:      "guided",              // "guided" | "soundscape"
    enableFreq: true                  // Frequenzen aktiviert
};
```

### 2.3 Phasen-Datenmodell (Swift)

```swift
public struct SessionPhase: Codable, Identifiable {
    public let id: String               // UUID
    public var name: String             // Deutscher lokalisierter Name
    public var duration: TimeInterval   // Dauer in Sekunden
    public var text: MediaConfig?       // Voice/Speech-ContentId
    public var music: MediaConfig?      // Genre-Name
    public var nature: MediaConfig?     // Naturgeräusch-Name
    public var sound: MediaConfig?      // Spezialeffekte (z.B. Glockenspiel)
    public var frequency: FrequencyConfig?  // Binaurale/Isochrone Beats
    public var noise: NoiseConfig?      // Pink/White/Brown Noise
}

public struct MediaConfig: Codable {
    public var content: String          // ContentId oder Genre/Nature-Name
    public var volume: Float            // 0.0 – 1.0
    public var fadeIn: TimeInterval     // Einblendung in Sekunden
    public var fadeOut: TimeInterval    // Ausblendung in Sekunden
}
```

---

## 3. Session-Benennungslogik

### 3.1 Swift (Aktuelle Implementierung)

**Datei:** `SessionGenerator.swift`, Zeile 93

```swift
return Session(
    name: "\(topic.displayName) Session",
    ...
)
```

Die Session-Benennung folgt dem Schema:

```
"{TopicDisplayName} Session"
```

**Ergebnis-Tabelle aller Session-Namen:**

| Topic (rawValue)  | displayName      | Session-Name             |
|--------------------|------------------|--------------------------|
| `sleep`           | Schlaf           | **Schlaf Session**       |
| `dream`           | Traum            | **Traum Session**        |
| `obe`             | Astralreise      | **Astralreise Session**  |
| `stress`          | Ruhe             | **Ruhe Session**         |
| `healing`         | Heilung          | **Heilung Session**      |
| `angry`           | Wut              | **Wut Session**          |
| `sad`             | Traurigkeit      | **Traurigkeit Session**  |
| `depression`      | Depression       | **Depression Session**   |
| `trauma`          | Trauma           | **Trauma Session**       |
| `belief`          | Glaubenssätze    | **Glaubenssätze Session**|
| `meditation`      | Meditation       | **Meditation Session**   |

### 3.2 OLD-APP (Legacy JavaScript)

**Datei:** `generator-session-content.js`, Zeilen 900–912

```javascript
if (topic == "fantasy") {
    session[0].name = sessionTexts.fantasy[session[0].topic][0];
    session[0].infoText = introText + sessionTexts.fantasy[session[0].topic][1];
} else {
    let randomIndex = Math.floor(Math.random() * sessionTexts[session[0].topic].length);
    session[0].name     = sessionTexts[session[0].topic][randomIndex][0];
    session[0].infoText = introText + sessionTexts[session[0].topic][randomIndex][1];
}
```

In der alten App wurde der Session-Name aus einem Pool von vordefinierten Texten (`sessionTexts`) per Zufallsindex gewählt. Jeder Eintrag enthielt ein Tupel `[name, infoText]`. Die Fantasy-Topic-Benennung basierte zusätzlich auf dem gewählten Reise-Typ (z.B. "Tibetische Wanderung", "Ballonfahrt").

### 3.3 Unterschied Alt vs. Neu

| Aspekt            | OLD-APP (JS)                          | Swift (Aktuell)                     |
|-------------------|---------------------------------------|--------------------------------------|
| Namensquelle      | Zufällig aus Pool (`sessionTexts`)    | Deterministisch: `"{Topic} Session"` |
| Varianten pro Topic | Mehrere poetische Titel             | Genau 1 Format pro Topic            |
| Fantasy-Spezial   | Reise-spezifischer Name              | Kein Sonderfall, selbes Schema       |
| InfoText          | Zufälliger Beschreibungstext          | Nicht implementiert (noch)           |

---

## 4. ContentId-Schema (Audio-Auflösung)

### 4.1 Text-ContentId (Voice/Sprache)

```
{voice_prefix}/{topic_rawValue}/{stage}
```

**Aufbau:**
- `voice_prefix`: Kleingeschriebener Voice-Name (`franca`, `flo`, `marion`, `corinna`)
- `topic_rawValue`: Enum-rawValue (`sleep`, `dream`, `obe`, etc.)
- `stage`: Phasen-Stage-Identifier (`intro`, `body`, `breath`, etc.)

**Beispiele:**

| Voice   | Topic  | Stage      | ContentId                   |
|---------|--------|------------|-----------------------------|
| Franca  | sleep  | intro      | `franca/sleep/intro`        |
| Flo     | stress | regulation | `flo/stress/regulation`     |
| Marion  | trauma | vault      | `marion/trauma/vault`       |
| Corinna | obe    | alarm      | `corinna/obe/alarm`         |
| Franca  | sad    | comfort    | `franca/sad/comfort`        |

**Code (Swift):**
```swift
// SessionGenerator.swift, buildTextConfig()
let voicePrefix = voice.rawValue.lowercased()
let contentId = "\(voicePrefix)/\(topic.rawValue)/\(stage)"
```

### 4.2 Musik-ContentId

Musik verwendet **Genre-Namen** direkt als ContentId:

| Genre              | Verwendung                                |
|--------------------|-------------------------------------------|
| `Deep_Dreaming`    | sleep, dream, obe                         |
| `Peaceful_Ambient` | stress, healing, angry, sad, depression, trauma, belief |
| `Zen_Garden`       | meditation (zufällig)                     |
| `Solo_Piano`       | sad (Comfort-Pfad, 44% Wahrscheinlichkeit) |

### 4.3 Nature-ContentId

Naturgeräusche verwenden den `natureSoundName` aus dem `FantasyJourneyManager`:

```
Gebirgsbach | Wald | Wasserfall | Schneesturm | Hoehle | Ozean
```

### 4.4 Sound-ContentId

Spezialeffekte verwenden direkte Namen:

```
Glockenspiel   (nur bei OBE-Topic, Stage "alarm")
```

### 4.5 Noise-ContentId

Rauschfarben verwenden Dateinamen:

```
pink.mp3 | white.mp3 | brown.mp3 | grey.mp3 | blue.mp3 | violet.mp3
```

---

## 5. Phasen-Benennungslogik

Jede Phase erhält einen deutschen lokalisierten Namen basierend auf ihrem Stage-Identifier:

```swift
// SessionGenerator.swift, Zeilen 298–318
```

| Stage-Identifier  | Phasen-Name (DE)          | Beschreibung                        |
|--------------------|---------------------------|--------------------------------------|
| `intro`           | Einleitung                | Session-Eröffnung                   |
| `introComfort`    | Einleitung                | Trost-Eröffnung (SAD-Comfort)       |
| `body`            | Körperreise               | Progressive Muskelrelaxation etc.   |
| `thinkstop`       | Gedankenstopp             | Achtsamkeit / Gedankenstille        |
| `breath`          | Atemübung                 | Atemtechnik                         |
| `breath2`         | Atemübung                 | Zweite Atemtechnik (OBE)           |
| `hypnosis`        | Hypnose                   | Hypnose-Induktion                   |
| `fantasy`         | Fantasiereise             | Geführte Fantasiereise              |
| `frakt`           | Fraktalisierung           | Vertiefung/Fraktalisierung          |
| `regulation`      | Regulation                | Affektregulation                    |
| `comfort`         | Trost                     | Trostphase (SAD-Comfort)            |
| `introAff`        | Affirmations-Einleitung   | Überleitung zu Affirmationen        |
| `affirmation`     | Affirmationen             | Looping-Affirmationen               |
| `silence`         | Stille                    | Ruhephase / Schlafphase             |
| `exit`            | Ausleitung                | Session-Abschluss                   |
| `alarm`           | Wecker                    | Aufwach-Signal (OBE)                |
| `focus`           | Fokus                     | Fokus-/Konzentrationsphase          |
| `vault`           | Ressourcen-Tresor         | Tresorübung (Trauma, 75%)           |

---

## 6. Topic-Konfigurationen & Phasensequenzen

### 6.1 Vollständige Stage-Sequenzen

**Datei:** `SessionTopicConfig.swift`

Jedes Topic definiert eine feste Reihenfolge von Stages, die die Phasenstruktur der generierten Session bestimmen:

**SLEEP** (9 Phasen):
```
intro → body → thinkstop → breath → hypnosis → fantasy → introAff → affirmation → silence
```

**DREAM** (8 Phasen):
```
intro → body → thinkstop → breath → hypnosis → fantasy → affirmation → silence
```

**OBE / Astralreise** (12 Phasen):
```
intro → body → thinkstop → hypnosis → breath → frakt → breath2 → fantasy → introAff → affirmation → silence → alarm
```

**STRESS / Ruhe** (9 Phasen):
```
intro → body → thinkstop → hypnosis → breath → regulation → introAff → affirmation → exit
```

**HEALING / Heilung** (11 Phasen):
```
intro → body → thinkstop → hypnosis → breath → frakt → fantasy → regulation → introAff → affirmation → exit
```

**ANGRY / Wut** (8 Phasen):
```
thinkstop → body → breath → hypnosis → regulation → introAff → affirmation → exit
```

**SAD / Traurigkeit** (Probabilistisch – 2 Pfade):
- **Comfort-Pfad (44%):** `introComfort → comfort` (2 Phasen)
- **Guided-Pfad (56%):** `intro → regulation → introAff → affirmation → exit` (5 Phasen)

**DEPRESSION** (10 Phasen):
```
intro → body → thinkstop → hypnosis → breath → frakt → regulation → introAff → affirmation → exit
```

**TRAUMA** (12 Phasen):
```
intro → body → thinkstop → hypnosis → fantasy → breath → frakt → regulation → vault → introAff → affirmation → exit
```

**BELIEF / Glaubenssätze** (10 Phasen):
```
intro → body → thinkstop → hypnosis → breath → frakt → regulation → introAff → affirmation → exit
```

**MEDITATION** (8 Phasen):
```
intro → body → thinkstop → hypnosis → focus → affirmation → silence → exit
```

### 6.2 Topic-Enum Definition

```swift
public enum SessionTopic: String, CaseIterable, Sendable {
    case sleep, dream, obe, stress, healing, angry,
         sad, depression, trauma, belief, meditation
}
```

---

## 7. Fantasiereise-Benennungslogik

### 7.1 FantasyJourneyManager

**Datei:** `FantasyJourneyManager.swift`

Der `FantasyJourneyManager` ist ein `actor` (Thread-safe via Swift Concurrency) und verwaltet die Auswahl und Benennung von 7 Fantasiereisen:

```swift
enum Journey: String, CaseIterable, Sendable {
    case tibet    = "Tibetische_Wanderung"
    case balloon  = "Ballonfahrt"
    case tropical = "Tropische_Lagune"
    case sled     = "Schlittenfahrt"
    case forest   = "Herbstwald"
    case crystal  = "Kristallhoehle"
    case sea      = "Meer"
}
```

### 7.2 Journey → Naturgeräusch-Mapping

Jede Fantasiereise ist mit einem spezifischen Naturgeräusch und einer Lautstärke gekoppelt:

| Journey-Enum | rawValue (ContentId)       | Naturgeräusch  | Volume |
|-------------|----------------------------|----------------|--------|
| `.tibet`    | `Tibetische_Wanderung`     | `Gebirgsbach`  | 50%    |
| `.balloon`  | `Ballonfahrt`              | `Wald`         | 20%    |
| `.tropical` | `Tropische_Lagune`         | `Wasserfall`   | 50%    |
| `.sled`     | `Schlittenfahrt`           | `Schneesturm`  | 50%    |
| `.forest`   | `Herbstwald`               | `Wald`         | 50%    |
| `.crystal`  | `Kristallhoehle`           | `Hoehle`       | 50%    |
| `.sea`      | `Meer`                     | `Ozean`        | 50%    |

### 7.3 Auswahllogik

```
1. Letzte Reise wird gespeichert (lastJourney)
2. Letzte Reise wird aus dem Pool entfernt (Wiederholungsvermeidung)
3. 25% Wahrscheinlichkeit: Tropical wird bevorzugt ausgewählt
4. 75% Wahrscheinlichkeit: Zufällige Auswahl aus verbleibenden Reisen
```

### 7.4 Keyword-Matching (Symptom-Finder → Journey)

```swift
nonisolated static func journeyForKeyword(_ keyword: String) -> Journey? {
    let lower = keyword.lowercased()
    if lower.contains("tibet")                          { return .tibet }
    if lower.contains("ballon")                         { return .balloon }
    if lower.contains("tropi") || lower.contains("lagune") { return .tropical }
    if lower.contains("schlitten") || lower.contains("schnee") { return .sled }
    if lower.contains("wald") || lower.contains("herbst")  { return .forest }
    if lower.contains("höhle") || lower.contains("kristall") { return .crystal }
    if lower.contains("meer") || lower.contains("ozean")   { return .sea }
    return nil
}
```

---

## 8. Musik-Genre-Zuordnung

### 8.1 Topic → Genre-Mapping

```swift
// SessionTopicConfig.swift
func musicGenre(using rng: inout R) -> String
```

| Topic-Gruppe                                          | Musik-Genre        |
|-------------------------------------------------------|--------------------|
| sleep, dream, obe                                     | `Deep_Dreaming`    |
| stress, healing, angry, sad, depression, trauma, belief | `Peaceful_Ambient` |
| meditation (zufällig)                                 | `Peaceful_Ambient` ODER `Deep_Dreaming` ODER `Zen_Garden` |
| sad (Comfort-Pfad)                                    | `Solo_Piano`       |

### 8.2 Verfügbare Genres (Content-Library)

```
Solo_Piano | Solo_Guitar | Chillout_Lounge | LoFi_Mix
Zen_Garden | Harmonic_Choir | Peaceful_Ambient | Deep_Dreaming
```

### 8.3 Volume-Konfiguration pro Stage

| Kontext                   | Volume |
|---------------------------|--------|
| SAD Comfort-Pfad          | 40%    |
| Silence-Stage             | 30%    |
| Alle anderen Stages       | 100%   |

---

## 9. Frequenz-Sweep-Konfigurationen

### 9.1 Grundprinzip

Jede Phase hat eine Start- und Ziel-Pulsfrequenz (binaurale Beats in Hz). Der Sweep erfolgt linear über die Phasendauer. Die Root-Frequenz ist fest auf **220 Hz**.

### 9.2 Sweep-Tabelle pro Topic

**SLEEP:**
```
intro(12→12) → body(12→10) → thinkstop(10→9) → breath(9→8) → hypnosis(8→4)
→ fantasy(4→4) → introAff(4→4) → affirmation(4→2) → silence(2→2)
```

**DREAM:**
```
intro(12→12) → body(12→10) → thinkstop(10→9) → breath(9→8) → hypnosis(8→7)
→ fantasy(7→6) → affirmation(6→25) → silence(6→6)
```

**OBE:**
```
intro(12→12) → body(12→10) → thinkstop(10→8) → hypnosis(8→4) → breath(4→4)
→ frakt(8→8) → breath2(4→4) → fantasy(4→4) → introAff(4→4) → affirmation(4→4)
→ silence(4→3) → alarm(3→10)
```

**STRESS:**
```
intro(12→12) → body(12→10) → thinkstop(10→8) → hypnosis(8→6) → breath(6→6)
→ regulation(6→6) → introAff(6→6) → affirmation(6→6) → exit(6→10)
```

**HEALING:**
```
intro(12→12) → body(12→10) → thinkstop(10→8) → hypnosis(8→6) → breath(6→6)
→ frakt(6→4) → fantasy(4→3) → regulation(3→3) → introAff(3→3) → affirmation(3→3) → exit(3→10)
```

**SAD (Comfort):** `introComfort(12→9) → comfort(6→6)`
**SAD (Guided):** `intro(12→9) → regulation(9→6) → introAff(6→6) → affirmation(6→6) → exit(6→10)`

**ANGRY:**
```
thinkstop(12→10) → body(10→8) → breath(8→8) → hypnosis(8→5)
→ regulation(5→5) → introAff(5→5) → affirmation(5→5) → exit(5→9)
```

**DEPRESSION:**
```
intro(12→12) → body(12→10) → thinkstop(10→8) → hypnosis(8→6) → breath(6→6)
→ frakt(6→4) → regulation(4→4) → introAff(4→4) → affirmation(4→4) → exit(4→14)
```

**TRAUMA:**
```
intro(12→12) → body(12→10) → thinkstop(10→9) → hypnosis(9→7) → fantasy(7→6)
→ breath(6→6) → frakt(6→4) → regulation(4→4) → vault(4→4) → introAff(4→4)
→ affirmation(4→4) → exit(4→10)
```

**BELIEF:**
```
intro(12→12) → body(12→10) → thinkstop(10→9) → hypnosis(9→8) → breath(8→6)
→ frakt(6→4) → regulation(4→4) → introAff(4→4) → affirmation(4→4) → exit(4→12)
```

**MEDITATION:**
```
intro(12→12) → body(12→10) → thinkstop(10→8) → hypnosis(8→6) → focus(6→4)
→ affirmation(4→2) → silence(2→2) → exit(2→11)
```

### 9.3 Fade-In / Fade-Out Defaults

| Parameter      | Wert   |
|----------------|--------|
| FadeIn (intro) | 30 Sek |
| FadeOut (exit/silence) | 30 Sek |
| Standard       | 5 Sek  |
| Volume         | 60%    |
| Root-Frequenz  | 220 Hz |
| Typ            | Monaural |

---

## 10. Phasendauer & Variable Bereiche

### 10.1 Standard-Dauern pro Stage

| Stage          | Standarddauer  |
|----------------|----------------|
| intro          | 120 Sek (2 Min)  |
| introComfort   | 120 Sek (2 Min)  |
| body           | 180 Sek (3 Min)  |
| thinkstop      | 120 Sek (2 Min)  |
| breath / breath2 | 120 Sek (2 Min) |
| hypnosis       | 180 Sek (3 Min)  |
| fantasy        | 300 Sek (5 Min)  |
| frakt          | 120 Sek (2 Min)  |
| regulation     | 180 Sek (3 Min)  |
| comfort        | 300 Sek (5 Min)  |
| focus          | 180 Sek (3 Min)  |
| introAff       | 60 Sek (1 Min)   |
| vault          | 180 Sek (3 Min)  |
| exit           | 90 Sek (1,5 Min) |
| alarm          | 60 Sek (1 Min)   |

### 10.2 Variable Dauern (Randomisiert)

Bestimmte Stages haben variable Dauern, die innerhalb eines Bereichs randomisiert werden:

| Topic        | Stage        | Min (Min) | Max (Min) |
|-------------|-------------|-----------|-----------|
| sleep       | affirmation | 5         | 20        |
| sleep       | silence     | 30        | 60        |
| dream       | silence     | 15        | 40        |
| obe         | affirmation | 20        | 45        |
| obe         | silence     | 45        | 60        |
| stress      | affirmation | 3         | 6         |
| healing     | affirmation | 5         | 10        |
| angry       | affirmation | 5         | 10        |
| sad         | affirmation | 5         | 10        |
| depression  | affirmation | 3         | 6         |
| trauma      | affirmation | 5         | 10        |
| belief      | affirmation | 5         | 10        |
| meditation  | affirmation | 5         | 10        |
| meditation  | silence     | 5         | 10        |

---

## 11. Probabilistik & Sonderfälle

### 11.1 SAD-Topic: Zwei Pfade

```swift
let roll = Double.random(in: 0...1, using: &rng)
if roll < 0.44 {
    // Comfort-Pfad (44%): introComfort → comfort
    // Musik: Solo_Piano, Volume 40%
} else {
    // Guided-Pfad (56%): intro → regulation → introAff → affirmation → exit
    // Musik: Peaceful_Ambient
}
```

### 11.2 Trauma-Vault: Optionale Inklusion

```swift
// 75% Wahrscheinlichkeit, dass "vault" (Ressourcen-Tresor) inkludiert wird
if stage == "vault" {
    let roll = Double.random(in: 0...1, using: &rng)
    if roll > 0.75 { continue } // 25% Skip-Chance
}
```

### 11.3 Meditation-Affirmation: Optionale Inklusion

```swift
// 50% Wahrscheinlichkeit, dass Affirmation bei Meditation inkludiert wird
if topic == .meditation && stage == "affirmation" {
    let roll = Double.random(in: 0...1, using: &rng)
    if roll > 0.50 { continue } // 50% Skip-Chance
}
```

### 11.4 Fantasiereise: Tropical-Bevorzugung

```swift
// 25% Wahrscheinlichkeit für automatische Tropical-Wahl
if Double.random(in: 0...1) < 0.25 {
    return .tropical
}
```

---

## 12. Vergleich: OLD-APP (JS) vs. Swift

| Aspekt                  | OLD-APP (JavaScript)                    | Swift (Aktuell)                          |
|-------------------------|------------------------------------------|-----------------------------------------|
| **Einstiegspunkt**      | `generateSession(topic)`                | `SessionGenerator.generate(topic, voice, rng)` |
| **Thread-Safety**       | Single-threaded                         | Actor-isolated (`FantasyJourneyManager`) |
| **Randomisierung**      | `Math.random()` (nicht reproduzierbar)  | `RandomNumberGenerator`-Protokoll (seedbar) |
| **Reproduzierbarkeit**  | Keine                                   | Deterministisch bei gleichem Seed        |
| **Config-Lookup**       | `eval()` (unsicher)                     | Direkte Enums und Structs                |
| **Session-Name**        | Zufällig aus `sessionTexts`-Pool        | Deterministisch: `"{Topic} Session"`     |
| **Fantasy-Naming**      | Reise-spezifisch aus Pool               | Standard-Schema, keine Spezialbehandlung |
| **Infotext**            | Zufällig generiert                      | Nicht implementiert                      |
| **Content-Resolution**  | `getAudioSrc()` mit dynamischen Pfaden  | ContentId → Firestore Lookup             |
| **Musik-Zuordnung**     | Inline-Conditionals pro Topic           | `buildMusicConfig()` Funktion            |
| **Frequenz-Sweeps**     | `changeLastFreqTo()`                    | `buildFrequencyConfig()` + `StageFrequencyConfig` |
| **Topic-Routing**       | 13-case Switch (912 Zeilen)             | `SessionTopic` Enum (50 Zeilen)          |
| **Dateipfad-Generierung** | `getAudioSrc(dbItem)` → lokale MP3    | ContentId → Firestore → Remote URL       |
| **SAD-Branching**       | 44% Threshold                           | Identischer 44% Threshold               |

---

## 13. Session Generator Konzept (3 Cases)

Das Session Generator Konzept definiert drei übergeordnete Anpassungsmechanismen:

### Case 1: Manuelle Längenanpassung

Sessionlänge wird **vor dem Start** manuell am Timer verändert. Jede Phase wird **gleichmäßig** angepasst.

**Audio-Typ-Strategien:**

- **Repeater (Nature):** Loop-Audio passt sich durch Self-Crossfade an die neue Phasenlänge an.
- **Single-Audio (Text):** Bei kürzerer Phase: Speed bis max. 125%, Endpause, oder kürzere Audio aus Pool. Bei längerer Phase: Speed bis min. 80%, Endpause einfügen, oder längere Audio.
- **Audio-Pool (Affirmationen):** Intervalle werden angepasst. Fallback: Letztes Intervall kürzen → kürzere Audio suchen → Stille.
- **Sound-Generator (Frequenz + Rauschen):** Sweep-Werte werden automatisch auf die neue Dauer skaliert.

### Case 2: Modifikative Anpassung

Sessionlänge wird vor dem Start verändert; **Phasen werden entfernt oder ersetzt** (nicht nur skaliert).

Pro Topic existieren spezifische Reduktionsregeln:

- **AKE (OBE):** 12 Phasen im Maximum, Reduktion durch Entfernen optionaler Phasen
- **SCHLAF:** Reduktion von 7 auf minimal 3 Phasen
- **TRAUM:** Reduktion von 8 auf minimal 4 Phasen
- **HYPNOSE:** Reduktion von 8 auf minimal 4 Phasen
- **RUHE / MEDITATION:** Kompaktere Varianten mit 4-5 Phasen

### Case 3: Sensorbasierte Phasenkorrektur (Zukunftskonzept)

Dynamische Phasenkorrektur durch **Echtzeit-Sensordaten** (EEG, PPG, REM, Gyroskop).

**Sensor-Schwellenwerte:**

| Zustand                       | EEG µV | PPG (Puls) | REM    | Gyros  |
|-------------------------------|--------|------------|--------|--------|
| Panik                         | ≥ 100  | > 110      | > 200  | > 5    |
| Starker Stress/Angst          | ≥ 70   | 90–110     | > 200  | > 5    |
| Stress/Angst                  | ≥ 45   | 76–89      |        | 1–5    |
| Konzentration                 | ≥ 21   | 65–75      |        | 1–5    |
| Wachzustand                   | ≥ 15   | 60–65      |        | 1–5    |
| Leichte Entspannung           | ≥ 13   | 55–65      |        | < 1    |
| Tiefe Entspannung             | ≥ 10   | 55–65      |        | < 1    |
| Meditation                    | ≥ 8    | < 55       |        | < 1    |
| Hypnagog                      | ≥ 6    |            |        | < 1    |
| Leichter Schlaf N1            | ≥ 4    |            | ≥ 15   |        |
| Schlaf N2                     | ≥ 3    |            | ≤ 15   |        |
| Tiefschlaf N3                 | ≥ 2    |            |        |        |

**Adaptionsprinzip:**
```
A (IST-Zustand) → B (ZIEL-Zustand) → C (ERGEBNIS)
Wenn B erreicht → Phase C starten
Sonst → Phasen-Vertiefung
```

---

## 14. Audio-Dateipfad-Generierung (OLD-APP)

### 14.1 `getAudioSrc(dbItem)` Funktion

Die Legacy-App generiert Dateipfade dynamisch:

```
1. String aus Session-Config auslesen:
   session[phase].text.content → z.B. "Bodyscan_Kurz"

2. String in DB-Objekt umwandeln (content-database.js):
   eval("Bodyscan_Kurz") → contentDB-Objekt

3. Pfad konstruieren basierend auf Typ:
```

| Typ                       | Pfad-Schema                                    |
|---------------------------|------------------------------------------------|
| Nature / Noise / Sound    | `../path/audiofile.mp3`                        |
| Text (einzeln)            | `../path/{voicename}_{textname}.mp3`           |
| Text (Pool, mehrere)      | `../path/{voicename}_{textname}_{random}.mp3`  |
| Musik (immer Pool)        | `../path/{genre}_{random}.mp3`                 |

### 14.2 Randomisierung bei Pools

Um Redundanz zu vermeiden, wird sichergestellt, dass dieselbe Datei erst wiederkehrt, nachdem **mindestens 2/3 des Pools** abgespielt wurden.

---

## 15. ContentId-Auflösung (iOS)

### 15.1 Auflösungs-Kette

```
PlayerViewModel.preResolveSessionContentURLs()
    │
    ├── 1. soundRepository.getSound(byContentId: contentId)
    │       → Firestore Collection "sounds", Feld "contentId"
    │
    ├── 2. SessionContentMapping.soundId(for: contentId)
    │       → Fallback: Statisches Mapping ContentId → Firestore-Sound-ID
    │
    └── 3. soundRepository.getSounds(category:)
            → Kategorie-basierter Fallback (text/music/nature/sound)
```

### 15.2 Fehlgeschlagene Auflösung

Fehlgeschlagene Auflösungen werden geloggt:
```
AWAVELogger.audio.warning("Content not found: \(contentId)")
```

Ohne passende Firestore-Einträge spielen nur **Frequency** und ggf. **Noise** – der Nutzer hört dann „nur Wellen".

---

## 16. Dateireferenzen

### Swift (Aktuelle Implementierung)

| Datei | Pfad | Zeilen | Beschreibung |
|-------|------|--------|-------------|
| `SessionGenerator.swift` | `AWAVE/Services/` | 320 | Kern-Generierungslogik |
| `SessionTopicConfig.swift` | `AWAVE/Services/` | 387 | Topic-Konfigurationen, Frequenzen, Dauern |
| `FantasyJourneyManager.swift` | `AWAVE/Services/` | 96 | Fantasiereise-Auswahl & Naming |
| `CategorySessionGenerator.swift` | `AWAVE/Services/` | 34 | Batch-Generierung für Onboarding |
| `SessionContentMapping.swift` | `AWAVE/Services/` | 20 | ContentId → Firestore-ID Fallback |
| `Session.swift` | `AWAVEDomain/Entities/` | ~60 | Session & Phase Datenmodelle |
| `SessionGeneratorTests.swift` | `Tests/Services/` | 356 | 16 Testsuiten |

### OLD-APP (Legacy JavaScript)

| Datei | Pfad | Zeilen | Beschreibung |
|-------|------|--------|-------------|
| `generator-session-content.js` | `OLD-APP/src/js/` | 1012 | Kern-Session-Generierung |
| `generator-keywords.js` | `OLD-APP/src/js/` | 2656 | Symptom-Finder Keywords |
| `session-object.js` | `OLD-APP/src/js/` | 201 | Session/Phase Datenstrukturen |
| `content-database.js` | `OLD-APP/src/js/` | 2700+ | Voice-Content Metadaten |
| `generator-frequency-noise.js` | `OLD-APP/src/js/` | – | Frequenz/Noise-Generierung |
| `main.js` | `OLD-APP/src/js/` | – | App-Init, Player-Logik |
| `editor-live.js` | `OLD-APP/src/js/` | – | Live-Content-Änderung |

---

## Anhang: Stimmen (Voice Actors)

| Enum-Wert | Display-Name | ContentId-Prefix |
|-----------|-------------|------------------|
| `.franca`  | Franca      | `franca`         |
| `.flo`     | Flo         | `flo`            |
| `.marion`  | Marion      | `marion`         |
| `.corinna` | Corinna     | `corinna`        |

---

*Generiert aus: PRD v1.3, Basis-Dokumentation, Session Generator Konzept (PDF), Audiohosting-Dokumentation, OLD-APP Quellcode-Analyse, Swift Codebase-Analyse.*
