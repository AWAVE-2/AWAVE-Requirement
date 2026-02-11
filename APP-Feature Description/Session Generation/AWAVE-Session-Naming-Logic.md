# AWAVE Session-Benennungslogik

**Technische Dokumentation: Naming-Algorithmus**
**Stand:** Februar 2026

---

## Inhaltsverzeichnis

1. [Problem & Zielsetzung](#1-problem--zielsetzung)
2. [OLD-APP Namenslogik (JavaScript)](#2-old-app-namenslogik)
3. [Vollständiger Namens-Pool aus OLD-APP](#3-vollständiger-namens-pool)
4. [Intro-Text-Generierung (OLD-APP)](#4-intro-text-generierung)
5. [Aktuelle Swift-Implementierung (Defizit)](#5-aktuelle-swift-implementierung)
6. [Vorgeschlagener Swift-Algorithmus: SessionNameGenerator](#6-swift-algorithmus-sessionnamesgenerator)
7. [Integration in SessionGenerator.swift](#7-integration-in-sessiongenerator)
8. [Fantasy-Benennungslogik (Sonderfall)](#8-fantasy-benennungslogik)
9. [Wiederholungsvermeidung](#9-wiederholungsvermeidung)
10. [Test-Strategie](#10-test-strategie)

---

## 1. Problem & Zielsetzung

### Aktuelles Problem

Die aktuelle Swift-Implementierung generiert **immer denselben Session-Namen** pro Topic:

```swift
// SessionGenerator.swift, Zeile 93
name: "\(topic.displayName) Session"
// → Immer "Schlaf Session", immer "Traum Session", etc.
```

Das bedeutet: Jede Schlaf-Session heißt "Schlaf Session", jede Stress-Session heißt "Ruhe Session". Es gibt keine Variation. Das widerspricht dem Konzept der alten App, wo jede neu generierte Session einen einzigartigen, poetischen Namen erhielt.

### Zielsetzung

Jede neu generierte Session soll einen **einzigartigen, topic-spezifischen deutschen Namen** erhalten. Das Naming soll:

- Aus einem kuratierten Pool von ~150 Namen schöpfen (Parität mit OLD-APP)
- Wiederholungen vermeiden (erst nach 2/3 des Pools wiederholen)
- Einen passenden `infoText` (Beschreibung) zum Namen liefern
- Fantasy-Sessions mit reise-spezifischen Namen versehen
- Testbar sein (via seeded RNG)

---

## 2. OLD-APP Namenslogik (JavaScript)

### 2.1 Architektur

**Dateien:**
- `OLD-APP/src/js/generator-session-text.js` (441 Zeilen) – Enthält alle `sessionTexts`
- `OLD-APP/src/js/generator-session-content.js` (Zeilen 881–912) – Selektionslogik

### 2.2 Datenstruktur

```javascript
var sessionTexts = {
    angry:      [ ["Name A", "InfoText A"], ["Name B", "InfoText B"], ... ],
    belief:     [ ["Name A", "InfoText A"], ... ],
    depression: [ ... ],
    dream:      [ ... ],
    healing:    [ ... ],
    meditation: [ ... ],
    obe:        [ ... ],
    sad:        [ ... ],
    sleep:      [ ... ],
    stress:     [ ... ],
    trauma:     [ ... ],
    user:       [ ["Eigene Session", "..."] ],
    fantasy: {
        balloon:  ["Fantasiereise: Ballonfahrt", "..."],
        forest:   ["Fantasiereise: Waldwanderung", "..."],
        tibet:    ["Fantasiereise: Tibetische Wanderung", "..."],
        tropical: ["Fantasiereise: Tropische Lagune", "..."],
        snow:     ["Fantasiereise: Schlittenfahrt", "..."],
        beach:    ["Fantasiereise: Am Meer", "..."],
        crystal:  ["Fantasiereise: Kristallhöhle", "..."]
    }
};
```

### 2.3 Selektionslogik

```javascript
// Für Fantasy: Fester Name basierend auf Reise-Typ
if (topic == "fantasy") {
    session[0].name = sessionTexts.fantasy[session[0].topic][0];
    session[0].infoText = introText + sessionTexts.fantasy[session[0].topic][1];
}
// Für alle anderen Topics: Zufällige Auswahl aus Pool
else {
    let randomIndex = Math.floor(Math.random() * sessionTexts[topic].length);
    session[0].name     = sessionTexts[topic][randomIndex][0];
    session[0].infoText = introText + sessionTexts[topic][randomIndex][1];
}
```

### 2.4 Statistik

| Topic       | Anzahl Namen | Größter Pool |
|-------------|-------------|-------------|
| angry       | 23          | ★           |
| meditation  | 20          |             |
| belief      | 17          |             |
| trauma      | 17          |             |
| dream       | 15          |             |
| depression  | 13          |             |
| obe         | 13          |             |
| sad         | 11          |             |
| sleep       | 11          |             |
| healing     | 10          |             |
| stress      | 10          |             |
| **Gesamt**  | **160**     |             |
| fantasy     | 7 (statisch)|             |

---

## 3. Vollständiger Namens-Pool aus OLD-APP

### SLEEP (11 Namen)

| # | Name | InfoText |
|---|------|----------|
| 1 | Sanft ins Land der Träume gleiten | Diese geführte Meditation hilft dir, einen ruhigen und erholsamen Schlaf zu finden... |
| 2 | Tief und erholsam schlafen | Genieße tiefen und erholsamen Schlaf... |
| 3 | Durchschlafen und erfrischt erwachen | Durchschlafen und erfrischt erwachen... |
| 4 | Die Kunst des ruhigen Schlafes | Erlebe die Kunst des ruhigen Schlafes... |
| 5 | Entspannt einschlafen, tief durchschlafen | Finde tiefen und erholsamen Schlaf... |
| 6 | Deine Reise zur erholsamen Nacht | Begib dich auf deine Reise zur erholsamen Nacht... |
| 7 | Mit Gelassenheit durch die Nacht | Mit Gelassenheit die Nacht erleben... |
| 8 | Einschlafen mit Achtsamkeit | Erlange einen tiefen Schlaf mit Achtsamkeit... |
| 9 | Der Weg zu einem friedlichen Schlaf | Finde den Weg zu einem friedlichen Schlaf... |
| 10 | Mit Meditation zum gesunden Schlaf | Entdecke, wie Meditation zu gesundem Schlaf führt... |
| 11 | Der Weg zum erholsamen Schlaf | Erfahre mit dieser geführten Meditation, wie du einen erholsamen Schlaf findest... |

### DREAM (15 Namen)

| # | Name | InfoText |
|---|------|----------|
| 1 | Die Weisheit der Träume | Tauche ein in die faszinierende Welt deiner Träume... |
| 2 | Mit Achtsamkeit in Traumwelten eintauchen | Erforsche die faszinierenden Traumwelten durch Achtsamkeit... |
| 3 | Deine Träume als Wegweiser | Nutze deine Träume als wertvolle Wegweiser... |
| 4 | Kreatives Träumen: Eine geführte Meditation | Erwecke deine kreative Seite durch geführtes Träumen... |
| 5 | Die Magie der Nacht: Eine Reise ins Traumreich | Entdecke die Magie der Nacht in einer Reise ins Traumreich... |
| 6 | Die Kunst des Träumens | Meistere die Kunst des Träumens... |
| 7 | Deine Träume: Ein Paradies der Fantasie | Tauche ein in das Paradies deiner Fantasie... |
| 8 | Träume zum Leben erwecken | Erwecke deine Träume zum Leben... |
| 9 | Innere Welten erschaffen: Eine geführte Traumreise | Schaffe deine eigenen inneren Welten... |
| 10 | Deine Nacht, deine Träume: Eine meditative Reise | Entdecke die Schönheit deiner Nacht und deiner Träume... |
| 11 | Traumwelten gestalten | Gestalte deine eigenen Traumwelten... |
| 12 | Schöne Träume | Genieße eine Nacht voller schöner Träume... |
| 13 | Träume erschaffen | Erschaffe deine Träume aktiv... |
| 14 | Deine Traumreise | Begib dich auf deine eigene Traumreise... |
| 15 | Traumzauber | Entdecke den Zauber deiner Träume... |

### OBE (13 Namen)

| # | Name | InfoText |
|---|------|----------|
| 1 | Astralreisen: Das innere Universum | Tauche ein in das faszinierende Abenteuer der Astralreisen... |
| 2 | Die Magie der Astralreisen | Erlebe die Magie der Astralreisen... |
| 3 | Mit Achtsamkeit zum Astralreich | Entdecke das Astralreich mit innerer Achtsamkeit... |
| 4 | Deine spirituelle Reise | Begib dich auf deine einzigartige spirituelle Reise... |
| 5 | Die Geheimnisse des Astralreisens | Enthülle die Geheimnisse des Astralreisens... |
| 6 | Die Tore zum Astralreich öffnen | Öffne die Tore zum faszinierenden Astralreich... |
| 7 | Meditation zur Astralprojektion | Erforsche die Kunst der Astralprojektion... |
| 8 | Die Freiheit des Astralreisens | Erlebe die Freiheit des Astralreisens... |
| 9 | Die kosmische Reise | Begib dich auf eine kosmische Reise... |
| 10 | Dein Weg zu höherem Bewusstsein | Dein Weg zu höherem Bewusstsein beginnt hier... |
| 11 | Der Pfad zur Erleuchtung | Tauche ein in das Astralreich und finde deinen Weg... |
| 12 | Deine innere Galaxie | Erforsche mit dieser geführten Meditation deine innere Galaxie... |
| 13 | Der goldene Schlüssel zum Astralreisen | Finde mit diesem goldenen Schlüssel zur Astralreise... |

### STRESS (10 Namen)

| # | Name | InfoText |
|---|------|----------|
| 1 | Stress abbauen: Eine meditative Reise | Entdecke einen effektiven Weg zum Stressabbau... |
| 2 | Innere Ruhe in stressigen Zeiten | Finde innere Ruhe in stressigen Zeiten... |
| 3 | Entspannung gegen den Stress | Der Weg zu innerer Gelassenheit... |
| 4 | Gelassenheit im Stress des Alltags | Finde deine Gelassenheit... |
| 5 | Stress bewältigen mit Achtsamkeit | Bewältige Stress durch Achtsamkeit... |
| 6 | Deine innere Oase der Ruhe | Entdecke deine innere Oase der Ruhe... |
| 7 | Stressfrei durch Meditation | Tauche ein in die Welt der Meditation... |
| 8 | Die Macht der Entspannung | Erlebe die transformative Kraft der Entspannung... |
| 9 | Mit Ruhe und Klarheit gegen Stress | Gewinne Ruhe und Klarheit... |
| 10 | Innere Balance in hektischen Zeiten | Finde innere Balance in turbulenten Zeiten... |

### HEALING (10 Namen)

| # | Name | InfoText |
|---|------|----------|
| 1 | Heilung für Körper und Geist | Erfahre tiefe Heilung für Körper und Geist... |
| 2 | Ganzheitliche Heilung erleben | Erlebe ganzheitliche Heilung... |
| 3 | Die Kraft der Selbstheilung aktivieren | Aktiviere die natürliche Kraft der Selbstheilung... |
| 4 | Heilung durch Achtsamkeit | Erlebe Heilung durch Achtsamkeit... |
| 5 | Körperliche und emotionale Heilung | Finde körperliche und emotionale Heilung... |
| 6 | Die Reise zur inneren Heilung | Begib dich auf die Reise zur inneren Heilung... |
| 7 | Heilung und Harmonie im Einklang | Erreiche Heilung und Harmonie... |
| 8 | Heilung von alten Wunden | Starte deine Reise zur Heilung von alten Wunden... |
| 9 | Mit Meditation zu innerer Heilung | Entdecke, wie Meditation zur inneren Heilung führt... |
| 10 | Heilung und Transformation | Erlebe die transformative Kraft der Heilung... |

### ANGRY (23 Namen)

| # | Name | InfoText |
|---|------|----------|
| 1 | Die Macht der Gelassenheit | Hilft dir, innere Wut in Gelassenheit zu verwandeln... |
| 2 | Wut in Frieden verwandeln | Transformiere deine Wut in inneren Frieden... |
| 3 | Mit Achtsamkeit gegen Ärger und Frust | Achtsamkeitsübung gegen Ärger und Frust... |
| 4 | Frust loslassen | Lasse deinen Frust los und finde innere Ruhe... |
| 5 | Deine innere Ruhe | Entdecke deine innere Ruhe und Balance... |
| 6 | Der Weg zur inneren Harmonie | Finde den Weg zur inneren Harmonie... |
| 7 | Wut bewältigen | Bewältige deine Wut effektiv... |
| 8 | Ärger loslassen | Lasse deinen Ärger los und finde inneren Frieden... |
| 9 | Frust abbauen | Baue deinen Frust ab und finde innere Ruhe... |
| 10 | Emotionale Balance | Finde deine emotionale Balance... |
| 11 | Ärger in Ruhe verwandeln | Verwandle deinen Ärger in innere Ruhe... |
| 12 | Mit Meditation gegen Wut | Nutze die Kraft der Meditation gegen Wut... |
| 13 | Frieden finden | Finde inneren Frieden mit dieser Meditation... |
| 14 | Emotionskontrolle | Erlange Emotionskontrolle... |
| 15 | Frust besiegen | Besiege deinen Frust... |
| 16 | Innerer Frieden | Entdecke den Weg zum inneren Frieden... |
| 17 | Vergebung und Frieden | Fördert Vergebung und inneren Frieden... |
| 18 | Innerer Frieden durch Vergebung | Finde inneren Frieden durch Vergebung... |
| 19 | Heilung durch Vergebung | Erfahre Heilung durch den Akt der Vergebung... |
| 20 | Versöhnung und Ruhe | Finde Versöhnung und innere Ruhe... |
| 21 | Frieden durch Loslassen | Erlange inneren Frieden durch das Loslassen... |
| 22 | Vergebung und Gelassenheit | Erreiche Gelassenheit durch Vergebung... |
| 23 | Frieden finden durch Vergebung | Finde inneren Frieden durch Vergebung... |

### SAD (11 Namen)

| # | Name | InfoText |
|---|------|----------|
| 1 | Heilung in der Trauer finden | Entdecke einen Weg zur inneren Heilung und Trost... |
| 2 | Mit Achtsamkeit durch die Traurigkeit | Unterstützt dich, deine Emotionen zu akzeptieren... |
| 3 | Lichtblicke | Entdecke Lichtblicke in Zeiten der Traurigkeit... |
| 4 | Deine Reise zur inneren Ruhe | Begib dich auf deine Reise zur inneren Ruhe... |
| 5 | Loslassen und Trost finden | Erfahre, wie du durch Loslassen Trost findest... |
| 6 | Eine neue Hoffnung | Entdecke eine neue Hoffnung inmitten der Traurigkeit... |
| 7 | Die Transformation der Traurigkeit | Erfahre die Transformation der Traurigkeit... |
| 8 | Trauer in Liebe transformieren | Transformiere Trauer in Liebe... |
| 9 | Mit Mitgefühl durch Traurigkeit gehen | Gehe mit Mitgefühl durch Zeiten der Traurigkeit... |
| 10 | Heilung und Trost in Zeiten der Trauer | Finde Heilung und Trost in Zeiten der Trauer... |
| 11 | Friedliches Loslassen | Erlebe friedliches Loslassen... |

### DEPRESSION (13 Namen)

| # | Name | InfoText |
|---|------|----------|
| 1 | Eine neue Hoffnung | Finde einen Weg aus der Dunkelheit... |
| 2 | Ressourcen aktivieren | Entdecke deine inneren Stärken... |
| 3 | Depression überwinden: Ein meditativer Weg | Ein meditativer Weg... |
| 4 | Deine innere Stärke | Durchbreche die Dunkelheit der Depression... |
| 5 | Der Weg zur seelischen Balance | Begib dich auf eine Reise zur seelischen Balance... |
| 6 | Die innere Transformation | Erfahre eine innere Transformation... |
| 7 | Die Sonne in dir: Eine Reise zur Heilung | Entdecke die Sonne in dir... |
| 8 | Den inneren Akku aufladen | Schaffe Raum für inneren Frieden und neue Energie... |
| 9 | Vom Tiefpunkt zur inneren Stärke | Transformation von einem Tiefpunkt hin zu innerer Stärke... |
| 10 | Die Kraft des Neuanfangs | Entdecke die transformative Kraft des Neuanfangs... |
| 11 | Deine innere Flamme entfachen | Entfache erneut deine innere Flamme... |
| 12 | Motiviert und gestärkt: Dein Weg nach oben | Finde neue Motivation und innere Stärke... |
| 13 | Vom Tiefpunkt zum Gipfel | Erlebe eine meditative Reise von der Dunkelheit zur Spitze... |

### TRAUMA (17 Namen)

| # | Name | InfoText |
|---|------|----------|
| 1 | Die Angst besiegen | Schritt für Schritt die Ängste überwinden... |
| 2 | Innere Ruhe gegen Angst | Finde innere Ruhe als Antwort auf deine Ängste... |
| 3 | Die Angst loslassen | Lass die Angst los und finde inneren Frieden... |
| 4 | Ängste in Gelassenheit verwandeln | Verwandle deine Ängste in Gelassenheit... |
| 5 | Eine Reise zu innerer Stärke | Begib dich auf eine Reise zu deiner inneren Stärke... |
| 6 | Mit Achtsamkeit gegen die Angst | Nutze die Kraft der Achtsamkeit... |
| 7 | Die Kraft der Gedanken: Angst bewältigen | Entdecke die transformative Kraft deiner Gedanken... |
| 8 | Angstfrei leben: Ein meditativer Weg | Die transformative Kraft der Meditation... |
| 9 | Sanfte Schritte zur Sicherheit | Schreite behutsam zu innerer Sicherheit... |
| 10 | Die Vergangenheit heilen | Führt dich auf den Pfad zu innerer Sicherheit... |
| 11 | Der Weg zur inneren Ruhe | Dieser Weg führt dich zur inneren Ruhe... |
| 12 | Innere Sicherheit gewinnen | Gewinne innere Sicherheit... |
| 13 | Die Kraft der Gelassenheit | Entdecke die transformative Kraft der Gelassenheit... |
| 14 | Die Quelle der inneren Kraft | Finde die Quelle deiner inneren Kraft... |
| 15 | Schutz und Geborgenheit spüren | Schenkt dir Schutz und Geborgenheit... |
| 16 | Deine innere Ruhequelle | Entdecke deine innere Ruhequelle... |
| 17 | Mutig und sicher durchs Leben gehen | Stärkt deinen Mut und deine Sicherheit... |

### BELIEF (17 Namen)

| # | Name | InfoText |
|---|------|----------|
| 1 | Selbstvertrauen stärken | Gewinne ein starkes Selbstvertrauen... |
| 2 | Dein Weg zur Einzigartigkeit | Leitet dich auf dem Weg zu deiner Einzigartigkeit... |
| 3 | Die Motivation der Einzigartigkeit | Erwecke die Motivation deiner Einzigartigkeit... |
| 4 | Die Kraft der Selbstliebe | Entdecke die transformative Kraft der Selbstliebe... |
| 5 | Selbstvertrauen entdecken | Tauche in die Reise zum Selbstvertrauen ein... |
| 6 | Selbstvertrauen und Motivation | Finde die Synergie von Selbstvertrauen und Motivation... |
| 7 | Die Magie der Einzigartigkeit | Entdecke die magische Kraft deiner Einzigartigkeit... |
| 8 | Mit Meditation zur Selbstakzeptanz | Erfahre tiefe Selbstakzeptanz... |
| 9 | Die Quelle der Stärke | Finde die Quelle deiner inneren Stärke... |
| 10 | Deine Einzigartigkeit wecken | Wecke deine Einzigartigkeit... |
| 11 | Motivation durch Einzigartigkeit | Erwecke deine Motivation durch Einzigartigkeit... |
| 12 | Selbstvertrauen stärken | Stärkt dein Selbstvertrauen... |
| 13 | Einzigartig motiviert | Sei einzigartig motiviert... |
| 14 | Selbstvertrauen finden | Finde dein Selbstvertrauen... |
| 15 | Motivation entfachen | Entfache deine Motivation... |
| 16 | Einzigartig sein | Entdecke deine Einzigartigkeit... |
| 17 | Selbst, motiviert, einzigartig | Sei selbstbewusst, motiviert und einzigartig... |

### MEDITATION (20 Namen)

| # | Name | InfoText |
|---|------|----------|
| 1 | Tiefe Entspannung: Eine geführte Meditation | Erfahre eine tiefe Entspannung... |
| 2 | Innere Ruhe finden: Dein meditativer Weg | Finde deine innere Ruhe... |
| 3 | Die Kraft der Meditation entfesseln | Entfessele die transformative Kraft... |
| 4 | Achtsamkeit im Hier und Jetzt | Erlebe Achtsamkeit im Hier und Jetzt... |
| 5 | Deine Reise zur inneren Harmonie | Begib dich auf deine Reise zur inneren Harmonie... |
| 6 | Mit Meditation zu innerem Frieden | Finde mit Meditation deinen inneren Frieden... |
| 7 | Die Stille in dir | Entdecke die Stille in dir... |
| 8 | Die Kunst der Achtsamkeit | Meistere die Kunst der Achtsamkeit... |
| 9 | Dein Weg zur Klarheit | Finde deinen Weg zur Klarheit... |
| 10 | Die Macht der Stille | Entdecke die transformative Macht der Stille... |
| 11 | Innere Balance | Finde deine innere Balance... |
| 12 | Die Weisheit der Meditation | Entdecke die tiefe Weisheit der Meditation... |
| 13 | Innerer Frieden | Finde inneren Frieden... |
| 14 | Achtsam Jetzt | Sei achtsam im Hier und Jetzt... |
| 15 | Klarheit finden | Finde Klarheit... |
| 16 | Tiefe Ruhe | Erfahre tiefe Ruhe... |
| 17 | Gelassenheit | Erlebe Gelassenheit... |
| 18 | Kreatives Selbst | Entdecke dein kreatives Selbst... |
| 19 | Harmonie spüren | Spüre die tiefe Harmonie in dir selbst... |
| 20 | Bewusst Sein | Entdecke das tiefe Bewusstsein in dir... |

### FANTASY (7 statische Namen)

| Journey-Key | Session-Name | InfoText |
|-------------|-------------|----------|
| balloon | Fantasiereise: Ballonfahrt | Schwebend in einem Ballon über duftenden Wiesen... |
| forest | Fantasiereise: Waldwanderung | Erlebe eine herbstliche Traumreise durch einen malerischen Wald... |
| tibet | Fantasiereise: Tibetische Wanderung | Tauche ein in eine faszinierende Wanderung durch Tibet... |
| tropical | Fantasiereise: Tropische Lagune | Schwerelos im klaren Wasser, umgeben von exotischer Natur... |
| snow | Fantasiereise: Schlittenfahrt | Erlebe eine winterliche Schlittenfahrt in den Bergen... |
| beach | Fantasiereise: Am Meer | Am endlosen Strand erlebst du die Harmonie von Wind, Wellen und Sonne... |
| crystal | Fantasiereise: Kristallhöhle | In einer geheimnisvollen Kristallhöhle erlebst du die Energie... |

---

## 4. Intro-Text-Generierung (OLD-APP)

Die alte App generierte einen zweiteiligen InfoText:

```
[Topic-spezifischer Intro-Satz] + [Zufälliger Pool-InfoText]
```

### Topic-spezifische Intro-Sätze

| Topic       | Intro-Satz |
|-------------|-----------|
| angry       | "Diese geführte Meditation beginnt mit einer Routine um deine Gedanken zu beruhigen. Anschließend werden wir gezielt deine Wut transformieren: " |
| belief      | "Diese geführte Meditation beginnt mit unserer bewährten Entspannungsroutine. Anschließend werden wir dein Selbstvertrauen stärken: " |
| depression  | "...Anschließend werden wir achtsam deinen inneren Akku aufladen: " |
| dream       | "...Anschließend wirst du sanft ins Land der Träume begleitet: " |
| fantasy     | "...Anschließend begibst du dich auf eine Reise in deine Fantasie: " |
| meditation  | "...Anschließend wirst du achtsam in eine tiefe Meditation begleitet: " |
| obe         | "...Anschließend wirst du gezielt auf deine Astralreise vorbereitet: " |
| healing     | "...Anschließend wirst du deine Selbstheilungskräfte aktivieren: " |
| sad         | *(kein Intro-Satz – leerer String)* |
| sleep       | "...Anschließend wirst du sanft und schnell Einschlafen: " |
| stress      | "...Anschließend wirst du sanft zu innerer Ruhe finden: " |
| trauma      | "...Anschließend kannst du in einem geschützten Rahmen neuem Mut finden: " |

---

## 5. Aktuelle Swift-Implementierung (Defizit)

```swift
// SessionGenerator.swift, Zeile 93 – AKTUELL
return Session(
    name: "\(topic.displayName) Session",   // ← Immer gleich!
    ...
)
```

**Problem:** Keine Variation, kein InfoText, keine Wiederholungsvermeidung.

---

## 6. Vorgeschlagener Swift-Algorithmus: SessionNameGenerator

### 6.1 Neues File: `SessionNameGenerator.swift`

```swift
import Foundation

// MARK: - Session Name Entry

/// Represents a session name with its associated description text.
struct SessionNameEntry: Sendable {
    let name: String
    let infoText: String
}

// MARK: - Session Name Generator

/// Generates unique, varied session names per topic.
/// Uses a round-robin pool with 2/3 depletion rule to avoid repetitions.
actor SessionNameGenerator {

    /// Singleton for app-wide usage
    static let shared = SessionNameGenerator()

    /// Tracks recently used indices per topic to avoid repetition.
    /// Key: topic rawValue, Value: Set of recently used indices.
    private var recentlyUsed: [String: Set<Int>] = [:]

    /// Select a random name for a topic, avoiding recent repetitions.
    func generateName(for topic: SessionTopic) -> SessionNameEntry {
        var rng = SystemRandomNumberGenerator()
        return generateName(for: topic, using: &rng)
    }

    /// Testable version with injectable RNG.
    func generateName<R: RandomNumberGenerator>(
        for topic: SessionTopic,
        using rng: inout R
    ) -> SessionNameEntry {
        let pool = Self.namePool(for: topic)
        guard !pool.isEmpty else {
            return SessionNameEntry(
                name: "\(topic.displayName) Session",
                infoText: ""
            )
        }

        let topicKey = topic.rawValue
        var used = recentlyUsed[topicKey] ?? []

        // Reset when 2/3 of pool has been used (matches OLD-APP behavior)
        let threshold = max(1, (pool.count * 2) / 3)
        if used.count >= threshold {
            used.removeAll()
        }

        // Find available indices
        let allIndices = Set(0..<pool.count)
        var available = allIndices.subtracting(used)
        if available.isEmpty {
            available = allIndices
            used.removeAll()
        }

        // Random selection from available
        let selectedIndex = available.randomElement(using: &rng)!

        // Track usage
        used.insert(selectedIndex)
        recentlyUsed[topicKey] = used

        return pool[selectedIndex]
    }

    /// Generate a name for a fantasy session based on journey type.
    func generateFantasyName(
        for journey: FantasyJourneyManager.Journey
    ) -> SessionNameEntry {
        return Self.fantasyName(for: journey)
    }

    /// Generate the full infoText with topic-specific intro prefix.
    static func buildInfoText(
        for topic: SessionTopic,
        poolInfoText: String
    ) -> String {
        let intro = topicIntroText(for: topic)
        if intro.isEmpty { return poolInfoText }
        return intro + poolInfoText
    }

    /// Reset tracking (e.g., on app launch or test setup).
    func resetHistory() {
        recentlyUsed.removeAll()
    }

    // MARK: - Topic Intro Texts

    private static func topicIntroText(for topic: SessionTopic) -> String {
        let base = "Diese geführte Meditation beginnt mit unserer bewährten Entspannungsroutine. "
        switch topic {
        case .angry:
            return "Diese geführte Meditation beginnt mit einer Routine um deine Gedanken zu beruhigen. Anschließend werden wir gezielt deine Wut transformieren: "
        case .belief:
            return base + "Anschließend werden wir dein Selbstvertrauen stärken: "
        case .depression:
            return base + "Anschließend werden wir achtsam deinen inneren Akku aufladen: "
        case .dream:
            return base + "Anschließend wirst du sanft ins Land der Träume begleitet: "
        case .meditation:
            return base + "Anschließend wirst du achtsam in eine tiefe Meditation begleitet: "
        case .obe:
            return base + "Anschließend wirst du gezielt auf deine Astralreise vorbereitet: "
        case .healing:
            return base + "Anschließend wirst du deine Selbstheilungskräfte aktivieren: "
        case .sad:
            return ""
        case .sleep:
            return base + "Anschließend wirst du sanft und schnell Einschlafen: "
        case .stress:
            return base + "Anschließend wirst du sanft zu innerer Ruhe finden: "
        case .trauma:
            return base + "Anschließend kannst du in einem geschützten Rahmen neuem Mut finden: "
        }
    }

    // MARK: - Fantasy Names (Static per Journey)

    private static func fantasyName(
        for journey: FantasyJourneyManager.Journey
    ) -> SessionNameEntry {
        switch journey {
        case .balloon:
            return SessionNameEntry(
                name: "Fantasiereise: Ballonfahrt",
                infoText: "Schwebend in einem Ballon über duftenden Wiesen..."
            )
        case .forest:
            return SessionNameEntry(
                name: "Fantasiereise: Waldwanderung",
                infoText: "Erlebe eine herbstliche Traumreise durch einen malerischen Wald..."
            )
        case .tibet:
            return SessionNameEntry(
                name: "Fantasiereise: Tibetische Wanderung",
                infoText: "Tauche ein in eine faszinierende Wanderung durch Tibet..."
            )
        case .tropical:
            return SessionNameEntry(
                name: "Fantasiereise: Tropische Lagune",
                infoText: "Schwerelos im klaren Wasser, umgeben von exotischer Natur..."
            )
        case .sled:
            return SessionNameEntry(
                name: "Fantasiereise: Schlittenfahrt",
                infoText: "Erlebe eine winterliche Schlittenfahrt in den Bergen..."
            )
        case .sea:
            return SessionNameEntry(
                name: "Fantasiereise: Am Meer",
                infoText: "Am endlosen Strand erlebst du die Harmonie von Wind, Wellen und Sonne..."
            )
        case .crystal:
            return SessionNameEntry(
                name: "Fantasiereise: Kristallhöhle",
                infoText: "In einer geheimnisvollen Kristallhöhle erlebst du die Energie..."
            )
        }
    }

    // MARK: - Name Pools

    static func namePool(for topic: SessionTopic) -> [SessionNameEntry] {
        switch topic {
        case .sleep:
            return [
                SessionNameEntry(name: "Sanft ins Land der Träume gleiten", infoText: "Diese geführte Meditation hilft dir, einen ruhigen und erholsamen Schlaf zu finden."),
                SessionNameEntry(name: "Tief und erholsam schlafen", infoText: "Genieße tiefen und erholsamen Schlaf."),
                SessionNameEntry(name: "Durchschlafen und erfrischt erwachen", infoText: "Durchschlafen und erfrischt erwachen."),
                SessionNameEntry(name: "Die Kunst des ruhigen Schlafes", infoText: "Erlebe die Kunst des ruhigen Schlafes."),
                SessionNameEntry(name: "Entspannt einschlafen, tief durchschlafen", infoText: "Finde tiefen und erholsamen Schlaf."),
                SessionNameEntry(name: "Deine Reise zur erholsamen Nacht", infoText: "Begib dich auf deine Reise zur erholsamen Nacht."),
                SessionNameEntry(name: "Mit Gelassenheit durch die Nacht", infoText: "Mit Gelassenheit die Nacht erleben."),
                SessionNameEntry(name: "Einschlafen mit Achtsamkeit", infoText: "Erlange einen tiefen Schlaf mit Achtsamkeit."),
                SessionNameEntry(name: "Der Weg zu einem friedlichen Schlaf", infoText: "Finde den Weg zu einem friedlichen Schlaf."),
                SessionNameEntry(name: "Mit Meditation zum gesunden Schlaf", infoText: "Entdecke, wie Meditation zu gesundem Schlaf führt."),
                SessionNameEntry(name: "Der Weg zum erholsamen Schlaf", infoText: "Erfahre, wie du einen erholsamen Schlaf findest."),
            ]
        case .dream:
            return [
                SessionNameEntry(name: "Die Weisheit der Träume", infoText: "Tauche ein in die faszinierende Welt deiner Träume."),
                SessionNameEntry(name: "Mit Achtsamkeit in Traumwelten eintauchen", infoText: "Erforsche die faszinierenden Traumwelten durch Achtsamkeit."),
                SessionNameEntry(name: "Deine Träume als Wegweiser", infoText: "Nutze deine Träume als wertvolle Wegweiser."),
                SessionNameEntry(name: "Kreatives Träumen", infoText: "Erwecke deine kreative Seite durch geführtes Träumen."),
                SessionNameEntry(name: "Die Magie der Nacht", infoText: "Entdecke die Magie der Nacht in einer Reise ins Traumreich."),
                SessionNameEntry(name: "Die Kunst des Träumens", infoText: "Meistere die Kunst des Träumens."),
                SessionNameEntry(name: "Deine Träume: Ein Paradies der Fantasie", infoText: "Tauche ein in das Paradies deiner Fantasie."),
                SessionNameEntry(name: "Träume zum Leben erwecken", infoText: "Erwecke deine Träume zum Leben."),
                SessionNameEntry(name: "Innere Welten erschaffen", infoText: "Schaffe deine eigenen inneren Welten."),
                SessionNameEntry(name: "Deine Nacht, deine Träume", infoText: "Entdecke die Schönheit deiner Nacht und deiner Träume."),
                SessionNameEntry(name: "Traumwelten gestalten", infoText: "Gestalte deine eigenen Traumwelten."),
                SessionNameEntry(name: "Schöne Träume", infoText: "Genieße eine Nacht voller schöner Träume."),
                SessionNameEntry(name: "Träume erschaffen", infoText: "Erschaffe deine Träume aktiv."),
                SessionNameEntry(name: "Deine Traumreise", infoText: "Begib dich auf deine eigene Traumreise."),
                SessionNameEntry(name: "Traumzauber", infoText: "Entdecke den Zauber deiner Träume."),
            ]
        case .obe:
            return [
                SessionNameEntry(name: "Astralreisen: Das innere Universum", infoText: "Tauche ein in das faszinierende Abenteuer der Astralreisen."),
                SessionNameEntry(name: "Die Magie der Astralreisen", infoText: "Erlebe die Magie der Astralreisen."),
                SessionNameEntry(name: "Mit Achtsamkeit zum Astralreich", infoText: "Entdecke das Astralreich mit innerer Achtsamkeit."),
                SessionNameEntry(name: "Deine spirituelle Reise", infoText: "Begib dich auf deine einzigartige spirituelle Reise."),
                SessionNameEntry(name: "Die Geheimnisse des Astralreisens", infoText: "Enthülle die Geheimnisse des Astralreisens."),
                SessionNameEntry(name: "Die Tore zum Astralreich öffnen", infoText: "Öffne die Tore zum faszinierenden Astralreich."),
                SessionNameEntry(name: "Meditation zur Astralprojektion", infoText: "Erforsche die Kunst der Astralprojektion."),
                SessionNameEntry(name: "Die Freiheit des Astralreisens", infoText: "Erlebe die Freiheit des Astralreisens."),
                SessionNameEntry(name: "Die kosmische Reise", infoText: "Begib dich auf eine kosmische Reise."),
                SessionNameEntry(name: "Dein Weg zu höherem Bewusstsein", infoText: "Dein Weg zu höherem Bewusstsein beginnt hier."),
                SessionNameEntry(name: "Der Pfad zur Erleuchtung", infoText: "Finde deinen Weg zu höherem Bewusstsein."),
                SessionNameEntry(name: "Deine innere Galaxie", infoText: "Erforsche deine innere Galaxie."),
                SessionNameEntry(name: "Der goldene Schlüssel zum Astralreisen", infoText: "Finde den goldenen Schlüssel zur Astralreise."),
            ]
        case .stress:
            return [
                SessionNameEntry(name: "Stress abbauen", infoText: "Entdecke einen effektiven Weg zum Stressabbau."),
                SessionNameEntry(name: "Innere Ruhe in stressigen Zeiten", infoText: "Finde innere Ruhe in stressigen Zeiten."),
                SessionNameEntry(name: "Entspannung gegen den Stress", infoText: "Der Weg zu innerer Gelassenheit."),
                SessionNameEntry(name: "Gelassenheit im Alltag", infoText: "Finde deine Gelassenheit."),
                SessionNameEntry(name: "Stress bewältigen mit Achtsamkeit", infoText: "Bewältige Stress durch Achtsamkeit."),
                SessionNameEntry(name: "Deine innere Oase der Ruhe", infoText: "Entdecke deine innere Oase der Ruhe."),
                SessionNameEntry(name: "Stressfrei durch Meditation", infoText: "Tauche ein in die Welt der Meditation."),
                SessionNameEntry(name: "Die Macht der Entspannung", infoText: "Erlebe die transformative Kraft der Entspannung."),
                SessionNameEntry(name: "Mit Ruhe und Klarheit gegen Stress", infoText: "Gewinne Ruhe und Klarheit."),
                SessionNameEntry(name: "Innere Balance in hektischen Zeiten", infoText: "Finde innere Balance in turbulenten Zeiten."),
            ]
        case .healing:
            return [
                SessionNameEntry(name: "Heilung für Körper und Geist", infoText: "Erfahre tiefe Heilung für Körper und Geist."),
                SessionNameEntry(name: "Ganzheitliche Heilung erleben", infoText: "Erlebe ganzheitliche Heilung."),
                SessionNameEntry(name: "Die Kraft der Selbstheilung aktivieren", infoText: "Aktiviere die natürliche Kraft der Selbstheilung."),
                SessionNameEntry(name: "Heilung durch Achtsamkeit", infoText: "Erlebe Heilung durch Achtsamkeit."),
                SessionNameEntry(name: "Körperliche und emotionale Heilung", infoText: "Finde körperliche und emotionale Heilung."),
                SessionNameEntry(name: "Die Reise zur inneren Heilung", infoText: "Begib dich auf die Reise zur inneren Heilung."),
                SessionNameEntry(name: "Heilung und Harmonie im Einklang", infoText: "Erreiche Heilung und Harmonie."),
                SessionNameEntry(name: "Heilung von alten Wunden", infoText: "Starte deine Reise zur Heilung von alten Wunden."),
                SessionNameEntry(name: "Mit Meditation zu innerer Heilung", infoText: "Entdecke, wie Meditation zur inneren Heilung führt."),
                SessionNameEntry(name: "Heilung und Transformation", infoText: "Erlebe die transformative Kraft der Heilung."),
            ]
        case .angry:
            return [
                SessionNameEntry(name: "Die Macht der Gelassenheit", infoText: "Hilft dir, innere Wut in Gelassenheit zu verwandeln."),
                SessionNameEntry(name: "Wut in Frieden verwandeln", infoText: "Transformiere deine Wut in inneren Frieden."),
                SessionNameEntry(name: "Mit Achtsamkeit gegen Ärger und Frust", infoText: "Achtsamkeitsübung gegen Ärger und Frust."),
                SessionNameEntry(name: "Frust loslassen", infoText: "Lasse deinen Frust los und finde innere Ruhe."),
                SessionNameEntry(name: "Deine innere Ruhe", infoText: "Entdecke deine innere Ruhe und Balance."),
                SessionNameEntry(name: "Der Weg zur inneren Harmonie", infoText: "Finde den Weg zur inneren Harmonie."),
                SessionNameEntry(name: "Wut bewältigen", infoText: "Bewältige deine Wut effektiv."),
                SessionNameEntry(name: "Ärger loslassen", infoText: "Lasse deinen Ärger los und finde inneren Frieden."),
                SessionNameEntry(name: "Frust abbauen", infoText: "Baue deinen Frust ab und finde innere Ruhe."),
                SessionNameEntry(name: "Emotionale Balance", infoText: "Finde deine emotionale Balance."),
                SessionNameEntry(name: "Ärger in Ruhe verwandeln", infoText: "Verwandle deinen Ärger in innere Ruhe."),
                SessionNameEntry(name: "Mit Meditation gegen Wut", infoText: "Nutze die Kraft der Meditation gegen Wut."),
                SessionNameEntry(name: "Frieden finden", infoText: "Finde inneren Frieden."),
                SessionNameEntry(name: "Emotionskontrolle", infoText: "Erlange Emotionskontrolle."),
                SessionNameEntry(name: "Frust besiegen", infoText: "Besiege deinen Frust."),
                SessionNameEntry(name: "Innerer Frieden", infoText: "Entdecke den Weg zum inneren Frieden."),
                SessionNameEntry(name: "Vergebung und Frieden", infoText: "Fördert Vergebung und inneren Frieden."),
                SessionNameEntry(name: "Innerer Frieden durch Vergebung", infoText: "Finde inneren Frieden durch Vergebung."),
                SessionNameEntry(name: "Heilung durch Vergebung", infoText: "Erfahre Heilung durch den Akt der Vergebung."),
                SessionNameEntry(name: "Versöhnung und Ruhe", infoText: "Finde Versöhnung und innere Ruhe."),
                SessionNameEntry(name: "Frieden durch Loslassen", infoText: "Erlange inneren Frieden durch das Loslassen."),
                SessionNameEntry(name: "Vergebung und Gelassenheit", infoText: "Erreiche Gelassenheit durch Vergebung."),
                SessionNameEntry(name: "Frieden finden durch Vergebung", infoText: "Finde inneren Frieden durch Vergebung."),
            ]
        case .sad:
            return [
                SessionNameEntry(name: "Heilung in der Trauer finden", infoText: "Entdecke einen Weg zur inneren Heilung und Trost."),
                SessionNameEntry(name: "Mit Achtsamkeit durch die Traurigkeit", infoText: "Unterstützt dich, deine Emotionen zu akzeptieren."),
                SessionNameEntry(name: "Lichtblicke", infoText: "Entdecke Lichtblicke in Zeiten der Traurigkeit."),
                SessionNameEntry(name: "Deine Reise zur inneren Ruhe", infoText: "Begib dich auf deine Reise zur inneren Ruhe."),
                SessionNameEntry(name: "Loslassen und Trost finden", infoText: "Erfahre, wie du durch Loslassen Trost findest."),
                SessionNameEntry(name: "Eine neue Hoffnung", infoText: "Entdecke eine neue Hoffnung inmitten der Traurigkeit."),
                SessionNameEntry(name: "Die Transformation der Traurigkeit", infoText: "Erfahre die Transformation der Traurigkeit."),
                SessionNameEntry(name: "Trauer in Liebe transformieren", infoText: "Transformiere Trauer in Liebe."),
                SessionNameEntry(name: "Mit Mitgefühl durch Traurigkeit", infoText: "Gehe mit Mitgefühl durch Zeiten der Traurigkeit."),
                SessionNameEntry(name: "Heilung und Trost in Zeiten der Trauer", infoText: "Finde Heilung und Trost in Zeiten der Trauer."),
                SessionNameEntry(name: "Friedliches Loslassen", infoText: "Erlebe friedliches Loslassen."),
            ]
        case .depression:
            return [
                SessionNameEntry(name: "Eine neue Hoffnung", infoText: "Finde einen Weg aus der Dunkelheit."),
                SessionNameEntry(name: "Ressourcen aktivieren", infoText: "Entdecke deine inneren Stärken."),
                SessionNameEntry(name: "Depression überwinden", infoText: "Ein meditativer Weg."),
                SessionNameEntry(name: "Deine innere Stärke", infoText: "Durchbreche die Dunkelheit der Depression."),
                SessionNameEntry(name: "Der Weg zur seelischen Balance", infoText: "Begib dich auf eine Reise zur seelischen Balance."),
                SessionNameEntry(name: "Die innere Transformation", infoText: "Erfahre eine innere Transformation."),
                SessionNameEntry(name: "Die Sonne in dir", infoText: "Entdecke die Sonne in dir."),
                SessionNameEntry(name: "Den inneren Akku aufladen", infoText: "Schaffe Raum für inneren Frieden und neue Energie."),
                SessionNameEntry(name: "Vom Tiefpunkt zur inneren Stärke", infoText: "Transformation von einem Tiefpunkt hin zu innerer Stärke."),
                SessionNameEntry(name: "Die Kraft des Neuanfangs", infoText: "Entdecke die transformative Kraft des Neuanfangs."),
                SessionNameEntry(name: "Deine innere Flamme entfachen", infoText: "Entfache erneut deine innere Flamme."),
                SessionNameEntry(name: "Motiviert und gestärkt", infoText: "Finde neue Motivation und innere Stärke."),
                SessionNameEntry(name: "Vom Tiefpunkt zum Gipfel", infoText: "Von der Dunkelheit zur Spitze."),
            ]
        case .trauma:
            return [
                SessionNameEntry(name: "Die Angst besiegen", infoText: "Schritt für Schritt die Ängste überwinden."),
                SessionNameEntry(name: "Innere Ruhe gegen Angst", infoText: "Finde innere Ruhe als Antwort auf deine Ängste."),
                SessionNameEntry(name: "Die Angst loslassen", infoText: "Lass die Angst los und finde inneren Frieden."),
                SessionNameEntry(name: "Ängste in Gelassenheit verwandeln", infoText: "Verwandle deine Ängste in Gelassenheit."),
                SessionNameEntry(name: "Eine Reise zu innerer Stärke", infoText: "Begib dich auf eine Reise zu deiner inneren Stärke."),
                SessionNameEntry(name: "Mit Achtsamkeit gegen die Angst", infoText: "Nutze die Kraft der Achtsamkeit."),
                SessionNameEntry(name: "Die Kraft der Gedanken", infoText: "Entdecke die transformative Kraft deiner Gedanken."),
                SessionNameEntry(name: "Angstfrei leben", infoText: "Die transformative Kraft der Meditation."),
                SessionNameEntry(name: "Sanfte Schritte zur Sicherheit", infoText: "Schreite behutsam zu innerer Sicherheit."),
                SessionNameEntry(name: "Die Vergangenheit heilen", infoText: "Führt dich auf den Pfad zu innerer Sicherheit."),
                SessionNameEntry(name: "Der Weg zur inneren Ruhe", infoText: "Dieser Weg führt dich zur inneren Ruhe."),
                SessionNameEntry(name: "Innere Sicherheit gewinnen", infoText: "Gewinne innere Sicherheit."),
                SessionNameEntry(name: "Die Kraft der Gelassenheit", infoText: "Entdecke die transformative Kraft der Gelassenheit."),
                SessionNameEntry(name: "Die Quelle der inneren Kraft", infoText: "Finde die Quelle deiner inneren Kraft."),
                SessionNameEntry(name: "Schutz und Geborgenheit spüren", infoText: "Schenkt dir Schutz und Geborgenheit."),
                SessionNameEntry(name: "Deine innere Ruhequelle", infoText: "Entdecke deine innere Ruhequelle."),
                SessionNameEntry(name: "Mutig und sicher durchs Leben gehen", infoText: "Stärkt deinen Mut und deine Sicherheit."),
            ]
        case .belief:
            return [
                SessionNameEntry(name: "Selbstvertrauen stärken", infoText: "Gewinne ein starkes Selbstvertrauen."),
                SessionNameEntry(name: "Dein Weg zur Einzigartigkeit", infoText: "Leitet dich auf dem Weg zu deiner Einzigartigkeit."),
                SessionNameEntry(name: "Die Motivation der Einzigartigkeit", infoText: "Erwecke die Motivation deiner Einzigartigkeit."),
                SessionNameEntry(name: "Die Kraft der Selbstliebe", infoText: "Entdecke die transformative Kraft der Selbstliebe."),
                SessionNameEntry(name: "Selbstvertrauen entdecken", infoText: "Tauche in die Reise zum Selbstvertrauen ein."),
                SessionNameEntry(name: "Selbstvertrauen und Motivation", infoText: "Finde die Synergie von Selbstvertrauen und Motivation."),
                SessionNameEntry(name: "Die Magie der Einzigartigkeit", infoText: "Entdecke die magische Kraft deiner Einzigartigkeit."),
                SessionNameEntry(name: "Mit Meditation zur Selbstakzeptanz", infoText: "Erfahre tiefe Selbstakzeptanz."),
                SessionNameEntry(name: "Die Quelle der Stärke", infoText: "Finde die Quelle deiner inneren Stärke."),
                SessionNameEntry(name: "Deine Einzigartigkeit wecken", infoText: "Wecke deine Einzigartigkeit."),
                SessionNameEntry(name: "Motivation durch Einzigartigkeit", infoText: "Erwecke deine Motivation durch Einzigartigkeit."),
                SessionNameEntry(name: "Einzigartig motiviert", infoText: "Sei einzigartig motiviert."),
                SessionNameEntry(name: "Selbstvertrauen finden", infoText: "Finde dein Selbstvertrauen."),
                SessionNameEntry(name: "Motivation entfachen", infoText: "Entfache deine Motivation."),
                SessionNameEntry(name: "Einzigartig sein", infoText: "Entdecke deine Einzigartigkeit."),
                SessionNameEntry(name: "Selbst, motiviert, einzigartig", infoText: "Sei selbstbewusst, motiviert und einzigartig."),
            ]
        case .meditation:
            return [
                SessionNameEntry(name: "Tiefe Entspannung", infoText: "Erfahre eine tiefe Entspannung."),
                SessionNameEntry(name: "Innere Ruhe finden", infoText: "Finde deine innere Ruhe."),
                SessionNameEntry(name: "Die Kraft der Meditation entfesseln", infoText: "Entfessele die transformative Kraft."),
                SessionNameEntry(name: "Achtsamkeit im Hier und Jetzt", infoText: "Erlebe Achtsamkeit im Hier und Jetzt."),
                SessionNameEntry(name: "Deine Reise zur inneren Harmonie", infoText: "Begib dich auf deine Reise zur inneren Harmonie."),
                SessionNameEntry(name: "Mit Meditation zu innerem Frieden", infoText: "Finde mit Meditation deinen inneren Frieden."),
                SessionNameEntry(name: "Die Stille in dir", infoText: "Entdecke die Stille in dir."),
                SessionNameEntry(name: "Die Kunst der Achtsamkeit", infoText: "Meistere die Kunst der Achtsamkeit."),
                SessionNameEntry(name: "Dein Weg zur Klarheit", infoText: "Finde deinen Weg zur Klarheit."),
                SessionNameEntry(name: "Die Macht der Stille", infoText: "Entdecke die transformative Macht der Stille."),
                SessionNameEntry(name: "Innere Balance", infoText: "Finde deine innere Balance."),
                SessionNameEntry(name: "Die Weisheit der Meditation", infoText: "Entdecke die tiefe Weisheit der Meditation."),
                SessionNameEntry(name: "Innerer Frieden", infoText: "Finde inneren Frieden."),
                SessionNameEntry(name: "Achtsam Jetzt", infoText: "Sei achtsam im Hier und Jetzt."),
                SessionNameEntry(name: "Klarheit finden", infoText: "Finde Klarheit."),
                SessionNameEntry(name: "Tiefe Ruhe", infoText: "Erfahre tiefe Ruhe."),
                SessionNameEntry(name: "Gelassenheit", infoText: "Erlebe Gelassenheit."),
                SessionNameEntry(name: "Kreatives Selbst", infoText: "Entdecke dein kreatives Selbst."),
                SessionNameEntry(name: "Harmonie spüren", infoText: "Spüre die tiefe Harmonie in dir selbst."),
                SessionNameEntry(name: "Bewusst Sein", infoText: "Entdecke das tiefe Bewusstsein in dir."),
            ]
        }
    }
}
```

---

## 7. Integration in SessionGenerator.swift

### Änderung in `generate()` (Zeile 92–100)

**Vorher:**
```swift
return Session(
    name: "\(topic.displayName) Session",
    ...
)
```

**Nachher:**
```swift
// Name generator is actor-isolated (SessionNameGenerator.shared)
let nameEntry = await SessionNameGenerator.shared.generateName(for: topic)

return Session(
    name: nameEntry.name,
    infoText: SessionNameGenerator.buildInfoText(
        for: topic,
        poolInfoText: nameEntry.infoText
    ),
    duration: totalDuration,
    voice: voice,
    topic: topic.rawValue,
    type: .standard,
    enableFrequency: true,
    phases: phases
)
```

### Hinweis: Session-Model erweitern

Das `Session`-Struct benötigt ein neues Feld `infoText`:

```swift
public struct Session: Codable, Identifiable {
    public let id: String
    public var name: String
    public var infoText: String     // ← NEU
    public var duration: TimeInterval
    // ...
}
```

---

## 8. Fantasy-Benennungslogik (Sonderfall)

Fantasy-Sessions verwenden **statische, journey-spezifische Namen** (keine Randomisierung):

```swift
// In SessionGenerator.generate(), wenn Fantasy erkannt wird:
if hasFantasyStage {
    let nameEntry = await SessionNameGenerator.shared.generateFantasyName(for: journey)
    session.name = nameEntry.name
    session.infoText = nameEntry.infoText
}
```

| Journey     | Name                                | InfoText                                          |
|-------------|-------------------------------------|---------------------------------------------------|
| `.balloon`  | Fantasiereise: Ballonfahrt          | Schwebend in einem Ballon über duftenden Wiesen... |
| `.forest`   | Fantasiereise: Waldwanderung        | Herbstliche Traumreise durch einen Wald...        |
| `.tibet`    | Fantasiereise: Tibetische Wanderung | Faszinierende Wanderung durch Tibet...            |
| `.tropical` | Fantasiereise: Tropische Lagune     | Schwerelos im klaren Wasser...                    |
| `.sled`     | Fantasiereise: Schlittenfahrt       | Winterliche Schlittenfahrt in den Bergen...        |
| `.sea`      | Fantasiereise: Am Meer              | Harmonie von Wind, Wellen und Sonne...            |
| `.crystal`  | Fantasiereise: Kristallhöhle        | Geheimnisvolle Kristallhöhle...                   |

---

## 9. Wiederholungsvermeidung

### 9.1 2/3-Regel (wie OLD-APP)

Der Algorithmus verwendet die gleiche Logik wie die `getAudioSrc()`-Funktion der alten App:

```
Pool-Größe: 11 (z.B. Sleep)
Threshold:  floor(11 * 2/3) = 7

Ablauf:
  Session 1 → Index 4 (verwendet)  → recentlyUsed = {4}
  Session 2 → Index 8 (verwendet)  → recentlyUsed = {4, 8}
  Session 3 → Index 1 (verwendet)  → recentlyUsed = {4, 8, 1}
  ...
  Session 7 → Index 6 (verwendet)  → recentlyUsed = {4, 8, 1, 0, 3, 9, 6}
  Session 8 → RESET! 2/3 erreicht  → recentlyUsed = {}
  Session 8 → Index 2 (verwendet)  → recentlyUsed = {2}
```

### 9.2 Persistenz

Der `SessionNameGenerator` ist ein `actor` (Singleton). Der Tracking-State lebt im Speicher und wird bei App-Neustart zurückgesetzt. Für persistente Wiederholungsvermeidung über App-Neustarts hinweg kann optional UserDefaults verwendet werden:

```swift
// Optional: Persistenz über UserDefaults
private func persistHistory() {
    let encoded = recentlyUsed.mapValues { Array($0) }
    UserDefaults.standard.set(encoded, forKey: "sessionNameHistory")
}

private func loadHistory() {
    guard let stored = UserDefaults.standard.dictionary(forKey: "sessionNameHistory") as? [String: [Int]] else { return }
    recentlyUsed = stored.mapValues { Set($0) }
}
```

---

## 10. Test-Strategie

```swift
// SessionNameGeneratorTests.swift

func testUniqueNamesAcrossMultipleGenerations() async {
    let generator = SessionNameGenerator()
    var names: [String] = []

    for _ in 0..<20 {
        let entry = await generator.generateName(for: .sleep)
        names.append(entry.name)
    }

    // Keine direkt aufeinanderfolgenden Duplikate
    for i in 1..<names.count {
        XCTAssertNotEqual(names[i], names[i - 1],
            "Consecutive duplicate: \(names[i])")
    }
}

func testAllTopicsHaveNames() async {
    let generator = SessionNameGenerator()
    for topic in SessionTopic.allCases {
        let entry = await generator.generateName(for: topic)
        XCTAssertFalse(entry.name.isEmpty, "Empty name for \(topic)")
        XCTAssertFalse(entry.name.contains("Session"),
            "Still using old pattern for \(topic): \(entry.name)")
    }
}

func testDeterministicWithSeed() async {
    let generator = SessionNameGenerator()
    var rng1 = SeededRandomNumberGenerator(seed: 42)
    var rng2 = SeededRandomNumberGenerator(seed: 42)

    let name1 = await generator.generateName(for: .meditation, using: &rng1)
    await generator.resetHistory()
    let name2 = await generator.generateName(for: .meditation, using: &rng2)

    XCTAssertEqual(name1.name, name2.name)
}

func testFantasyNamesAreJourneySpecific() async {
    let generator = SessionNameGenerator()
    for journey in FantasyJourneyManager.Journey.allCases {
        let entry = await generator.generateFantasyName(for: journey)
        XCTAssertTrue(entry.name.hasPrefix("Fantasiereise:"),
            "Fantasy name should start with 'Fantasiereise:' but got: \(entry.name)")
    }
}
```

---

*Generiert aus: OLD-APP/src/js/generator-session-text.js, OLD-APP/src/js/generator-session-content.js, SessionGenerator.swift, SessionTopicConfig.swift, FantasyJourneyManager.swift.*
