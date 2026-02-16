# Session Generation – Basis-Dokumentation (QWAVE / AWAVE)

**Note:** The canonical English version of this document is [base-documentation.md](base-documentation.md). This file is kept for reference only.

---

Diese Analyse basiert auf den bereitgestellten technischen Dokumenten, Code-Snippets und Konzeptzeichnungen für das Projekt QWAVE / OWOVE – MORE THAN MEDITATION. Es handelt sich um eine hochkomplexe, interaktive Audio-Plattform für geführte Meditationen und Klangwelten (Soundscapes).

---

## 1. Systemübersicht und Architektur

Das System ist darauf ausgelegt, dynamische Audiositzungen zu generieren, die aus mehreren synchronisierten Ebenen bestehen. Die Architektur unterscheidet zwischen verschiedenen Benutzerrollen: Patienten, Privatanwender, Therapeuten und Administratoren.

### Kernkomponenten der Audiomodule

Eine Sitzung besteht aus bis zu **sechs parallelen Audiospuren**, die in Phasen (Phase I bis IV+) unterteilt sind:

| Modul    | Beschreibung |
|----------|--------------|
| **Text** | Einleitungen, Affirmationen oder End-Texte (`.mp3`) |
| **Music** | Genre-basierte Hintergrundmusik (z. B. Piano, ZenGarden) |
| **Nature** | Naturgeräusche (z. B. Wald) |
| **Frequency** | Synthetisch erzeugte Frequenzen über Oszillatoren (keine Dateien) |
| **Noise** | Verschiedene Rauschfarben (White, Pink, Brown, Grey, Blue, Violet) |
| **Sound** | Akzentuierende Klänge wie Glocken oder Wecker im Intervall |

---

## 2. Technische Implementierung (Audio-Engine)

Die Anwendung nutzt eine Kombination aus standardmäßigen HTML5 `<audio>`-Elementen und der fortgeschrittenen **Web-Audio-API**.

### Dynamische Dateipfaderstellung (`getAudioSrc`)

Das System lädt Audio-Assets nicht statisch, sondern generiert Pfade dynamisch über die Funktion `getAudioSrc(dbItem)`:

- **Objekt-Mapping:** Strings aus der Konfiguration werden in DB-Objekte aus `content-database.js` umgewandelt.
- **Sprecher-Logik:** Bei Texten wird der Dateiname um den gewählten Sprechernamen ergänzt (z. B. `../path/voicename_textname.mp3`).
- **Randomisierung:** Bei Musik und Text-Pools wird eine Zufallszahl generiert. Um Redundanz zu vermeiden, wird sichergestellt, dass dieselbe Datei erst wiederkehrt, nachdem mindestens 2/3 des Pools abgespielt wurden.

### Player-Logik

- **Text-Player:** Arbeitet mit zwei Modi: `one` (einmaliges Abspielen) oder `loop` (Wiederholung mit variablen Delays zwischen Affirmationen).
- **Music-Player:** Unterstützt nahtlose Übergänge zwischen Phasen. Wenn zwei aufeinanderfolgende Phasen dasselbe Genre haben, läuft die Musik ohne Unterbrechung weiter.
- **Nature-Player:** Nutzt ein `timeupdate`-Event, um einen nahtlosen Loop mit einer Überlappung (`overlapTime`) von 2 Sekunden zu erzeugen.
- **Noise & Frequency:** Werden direkt über die Web-Audio-API moduliert. Ein `ChannelSplitter` ermöglicht die getrennte Bearbeitung von linkem und rechtem Kanal (z. B. für binaurale Beats).

---

## 3. Signalfluss-Analyse (Frequenzgenerator)

Die Dokumentation zum Frequenzgenerator zeigt komplexe Routing-Diagramme für verschiedene Signal-Typen:

- **Binaural/Monoaural:** Signale werden durch Root-Oszillatoren erzeugt, durch Sweep-Frequenzen moduliert und über Gain-Nodes an den Master-Ausgang geleitet.
- **Sync-Noise:** Rauschsignale (WAV-Samples) werden durch Filter (Bandpass) gejagt und mit LFOs (Low Frequency Oscillators) für rhythmische Effekte synchronisiert.

---

## 4. Sitzungssteuerung und UI-Logik

Die Steuerung erfolgt primär über die Datei `main.js` und das UI-Modul `editor-live.js`.

- **Session-Start:** Die Funktion `startSession()` triggert `startPhase(1)`, welche wiederum alle individuellen Player-Funktionen (`startTextPlayer`, `startMusicPlayer` usw.) aufruft.
- **Live-Modus:** Während einer laufenden Sitzung kann der Benutzer Content (z. B. das Musikgenre) ändern. Das System entscheidet je nach Typ, ob nur der betroffene Player oder die komplette Session neu gestartet wird.
- **Vorschau-Funktion:** Ermöglicht das Vorhören von Stimmen oder Klangwelten vor dem eigentlichen Start.

---

## 5. Zukunftskonzept: Der adaptive Algorithmus

Ein wesentlicher Teil der Unterlagen befasst sich mit dem „Session Generator Konzept“, das drei Szenarien der Anpassung vorsieht:

| Case   | Methode       | Beschreibung |
|--------|---------------|--------------|
| Case 1 | Manuell       | Sessionlänge wird vorab eingestellt; Phasen passen sich gleichmäßig an. |
| Case 2 | Modifikativ   | Phasen können während der Planung entfernt oder ersetzt werden. |
| Case 3 | Sensor-Messung | Dynamische Phasenkorrektur durch Echtzeit-Daten (EEG, RPG, REM, Gyroskop). |

Dieses Konzept deutet auf eine **bio-adaptive Feedback-Schleife** hin, bei der die Meditation auf den mentalen und physischen Zustand des Nutzers reagiert.

---

## Zusammenfassung der Analyse

QWAVE ist ein technologisch ambitioniertes System, das über einfache Meditations-Apps hinausgeht. Durch die Web-Audio-API bietet es audiophile Präzision bei der Frequenztherapie. Die algorithmische Dateiverwaltung stellt sicher, dass Inhalte auch bei häufiger Nutzung abwechslungsreich bleiben. Das Herzstück der Innovation liegt in der geplanten Sensorkoppelung, um die Audiospuren in Echtzeit an die Gehirnwellen oder Schlafphasen des Nutzers anzupassen.

---

## Content-IDs für iOS Session-Playback

In der nativen iOS-App (Swift) werden Session-Phasen über **Content-IDs** aufgelöst: `PlayerViewModel.preResolveSessionContentURLs` sammelt alle Content-IDs aus den Phasen und ruft `soundRepository.getSound(byContentId: contentId)` auf. Firestore-Dokumente in der Collection `sounds` müssen dafür ein Feld **`contentId`** mit exakt folgenden Werten haben (wie sie der `SessionGenerator` ausgibt):

| Ebene   | Schema / Beispiele | Herkunft im Code |
|---------|--------------------|------------------|
| **Text** | `voice/topic/stage`, z. B. `franca/sleep/intro` | `SessionGenerator.buildTextConfig`: `"\(voicePrefix)/\(topic.rawValue)/\(stage)"` |
| **Musik** | Genre, z. B. `Deep_Dreaming`, `Peaceful_Ambient`, `Solo_Piano`, `Zen_Garden` | `SessionGenerator.buildMusicConfig`; Topic `musicGenre(using:)` bzw. SAD `Solo_Piano` |
| **Natur** | Namen aus FantasyJourneyManager, z. B. `Gebirgsbach`, `Wald`, `Wasserfall`, `Ozean`, `Hoehle`, `Schneesturm` | `FantasyJourneyManager.Journey.natureSoundName` |
| **Sound** | z. B. `Glockenspiel` | `SessionGenerator.buildSoundConfig` (nur für Stage `alarm` bei Topic OBE) |
| **Noise** | Dateiname, z. B. `pink.mp3`, `white.mp3` | `NoiseType.audioFileName` (Phase.noise.type) |

**Auflösungsreihenfolge (Stand Refactoring 2026):** (1) `getSound(byContentId:)`, (2) `SessionContentMapping.soundId(for:)`. Es gibt **keinen** kategoriebasierten Fallback mehr („erster Sound der Kategorie“), damit jede Session nur Inhalte aus der Audio-Bibliothek mit passendem `contentId` lädt und nicht immer derselbe Demo-Track. Fehlgeschlagene Auflösungen werden geloggt (`AWAVELogger.audio.warning`). Ohne passende Firestore-`contentId`-Einträge oder SessionContentMapping spielen nur Frequency und ggf. Noise.

**Mixer-Anzeige:** Die aus der Bibliothek aufgelösten Tracks werden im Mixer mit dem **Anzeigenamen** (`Sound.title`) angezeigt (z. B. „Wald“, „Ambient“, „Franca – Einleitung“), nicht mit Dateiname oder Content-ID. Dafür liefert `preResolveSessionContentURLs` neben den URLs eine Map `contentId → displayName` und PhasePlayer übergibt diesen Namen an die Audio-Engine.

### Schlafscreen und Session-Generator (iOS)

- **Hero-Kachel „Besser Schlafen“:** Ein Tap öffnet den **Hauptplayer** (Full-Player), nicht den Session-Generator. Der Full-Player wird als `fullScreenCover` präsentiert.
- **Session-Generator:** Wird nur über „Neue Sessions generieren“ (im Sessions-Block der Kategorie) oder einen separaten Einstieg geöffnet, nicht über die Hero-Kachel. Generierte Sessions haben mindestens 3 Phasen (SessionGenerator-Garantie).

---

## Referenz: Audiomodule und Dateistruktur

### Übersicht Audiomodule

| Modul     | Verwendung / Datei |
|-----------|---------------------|
| sound     | Systemsound zum Bluetooth-Click-DeBug; Demo der ausgewählten Stimme (`js/main.js`); `AWAVE.html` |
| frequency | `js/generator-frequency-noise.js` |

### Phasen-Matrix (Geführte Meditation vs. Klangwelt)

- **Geführte Meditation:** Text, Music, Nature, Sound, Noise, Frequency (Phase I–IV+).
- **Klangwelt / Soundscape:** Kein Text; ansonsten gleiche Spuren (Music, Nature, Sound, Noise, Frequency).

### Start einer Session (`js/main.js`)

```
startSession() → startPhase(1)
```

`startPhase(phase)` steuert zuerst das Verhalten der einzelnen Player über die Phasendauer (Fade-In, Fade-Out usw.) und ruft dann auf:

- `startTextPlayer(phase)`
- `startMusicPlayer(phase)`
- `startNaturePlayer(phase)`
- `startSoundPlayer(phase)`
- `startFrequency(phase)` (Web-Audio-API, Oszillatoren)
- `startNoise(phase)` (siehe `generator-frequency-noise.js`)

### Content-Änderung im Livebetrieb (`js/editor-live.js`)

- **Je nach Case** nur Neustart des jeweiligen Players: `startTextPlayer`, `startMusicPlayer`, `startNaturePlayer` …
- **Automatischer Neustart der kompletten Session** bei:
  - Case 1: Session enthält nur 1 Phase
  - Case 2: Timer wurde verändert
  - Case 3: Neue Frequenz ausgewählt
  - Case 4: Neues Rauschen ausgewählt
  - Case 5: Neuer Sound ausgewählt  
  → Aufruf: `startSession()`

### Text-Player (`js/main.js`)

- Übergabe der `src` an das Audio-Element mit `getAudioSrc()`; Abspielen mit `startTextPlayer(phase)`.
- **Case 1:** `textChoice.mix == "one"` – Länge der Audiodatei bestimmt die Phasenlänge.
- **Case 2:** `textChoice.mix == "loop"` – Solange der Timer der Phase noch nicht abgelaufen ist, wird mit `onended` zeitversetzt eine weitere Audiodatei mit `getAudioSrc()` aus `session[phase].text.content` abgerufen.

### Music-Player (`js/main.js`)

- `getAudioSrc()` + `startMusicPlayer(phase)`.
- **Case 1:** `thisPhase === nextPhase` – Gleiches Genre → Musik wird am Ende der Phase nicht beendet, sondern fortgesetzt.
- **Case 2:** Sonst wird am Ende des Songs mit `onended` erneut `startMusicPlayer(phase)` aufgerufen, sofern der Timer noch nicht abgelaufen ist.

### Nature-Player (`js/main.js`)

- `getAudioSrc()` + `startNaturePlayer(phase)`.
- Solange Timer der Phase und Session noch nicht abgelaufen sind: Audio in Endlosschleife überlappend wiedergegeben.

### Sound-Player (`js/main.js`)

- `getAudioSrc()` + `startSoundPlayer(phase)`.
- Konfigurationen: 1× am Anfang der Phase; 1× am Ende der Phase; Anfang und Ende; im Intervall.

### Noise-Player (`js/generator-frequency-noise.js`)

- Kein HTML `<audio>`-Element; Web-Audio-API mit Splitter, Bandpass-Filter usw.
- Statische Übergabe der `src` in `switch (session[phase].noise.content) { … }`.
- Aufruf: `startNoise(phase)`; Abspielen in Endlosschleife.

### Dateipfad `getAudioSrc()` – Konfiguration → Dateipfad

1. Auslesen des Strings aus der konfigurierten Session:  
   `session[phase].text.content` bzw. `music.content`, `nature.content`, `noise.content`, `sound.content`.
2. Umwandlung des Strings in ein Objekt (in `js/content-database.js`):  
   `eval("string")` → DB-Objekt `dbItem`.
3. `dbItem` liefert u. a. Anzahl der Songs pro Musikgenre, Länge der Text-Audiodateien pro Sprecher, Abspielverhalten (`"one"` / `"loop"`).

| Fall              | Ergebnis |
|-------------------|----------|
| Nature / Noise / Sound | `return "../path/audiofile.mp3";` |
| Text (einzelne Datei)  | Pfad inkl. Sprechernamen: `../path/voicename_textname.mp3` |
| Text (mehrere Dateien) | Wie zuvor + Zufallsnummer; gleiche Nummer frühestens wieder nach 2/3 des Pools: `../path/voicename_textname_45.mp3` |
| Musik (immer mehrere)  | Wie Text (mehrere), ohne Sprecher: `../path/musikgenre_123.mp3` |

---

*Quellen: Session Generator Konzept, Audiohosting.indd, technische Dokumentation Cordova/Web-App.*
