# Plan-Update: Einzigartige Sessions & Zeitberechnung

**Stand:** Februar 2026  
**Vorgaben:** Einzigartige Sound-Auswahl pro Slot, Ersetzen alter Sessions, Zeitberechnung prüfen, **individuelle Musik-Genres pro Kategorie/Slot**.

---

## 1. Einzigartige Sessions (5 Slots pro Kategorie)

- **Journey (Naturgeräusch):** Pro Batch 5 verschiedene Journeys wählen (z. B. `Journey.allCases.shuffled(using: &rng).prefix(5)`) und pro Slot an `SessionGenerator.generate(..., journey: journeys[i], ...)` übergeben. Dafür optionalen Parameter `journey: FantasyJourneyManager.Journey? = nil` in SessionGenerator ergänzen.
- **Musik:** **Für jede Kategorie individuelle Genres.** Jeder der 5 Slots soll ein anderes Genre aus dem für das Topic erlaubten Pool erhalten (nicht mehr ein festes Genre pro Topic).
  - Pro Topic einen **Genre-Pool** definieren (z. B. Sleep: `[Deep_Dreaming, Peaceful_Ambient, Zen_Garden]`, Stress: `[Peaceful_Ambient, Zen_Garden, Solo_Piano]` usw. – je nach Content-Library und Anforderung).
  - In **CategorySessionGenerator**: Für den Batch 5 verschiedene Genres aus dem Topic-Pool wählen (z. B. Shuffle mit Batch-RNG, dann erste 5) und pro Slot an SessionGenerator übergeben.
  - **SessionGenerator** um optionalen Parameter **`musicGenre: String? = nil`** erweitern: wenn gesetzt, dieses Genre nutzen; sonst wie bisher `topic.musicGenre(using: &rng)`.
  - Sicherstellen: Die 5 Sessions einer Kategorie haben unterschiedliche Musik-Genres (und unterschiedliche Journeys), sodass die Sound-Auswahl pro Slot eindeutig ist.
- **Ersetzen:** Alte Sessions bei „Neue Sessions generieren“ weiterhin per `deleteCategorySessions` + `saveCategorySessions` ersetzen; Fehlerbehandlung prüfen.

---

## 2. Zeitberechnung: Muss geprüft werden

- **Prüfumfang:**
  - Gesamtdauer: `Session.duration` = Summe Phasendauern (Sekunden); Quelle `SessionGenerator` und `PhaseDurationRange.randomDuration` (Minuten → Sekunden). Prüfen, ob irgendwo falsche Einheit oder Doppelzählung vorkommt.
  - Anzeige: `CategorySessionCard` / SchlafScreen Favoriten nutzen `Int(duration / 60)` (Trunkation). Prüfen, ob Rundung oder Format „X Min Y Sek“ / „X:XX“ gewünscht ist und ob die angezeigte Zeit mit der tatsächlichen Abspieldauer übereinstimmt.
  - Player: `SessionPlayerService.totalDuration` = `session.duration`; Slider/Progress in FullPlayerView. Prüfen, ob Fortschritt und Gesamtzeit konsistent sind.
- **Ergebnis:** Nach Prüfung konkrete Korrekturen (Rundung, Format, ggf. Berechnung) umsetzen.

---

## 3. Implementierungs-Reihenfolge (Kurz)

1. SessionGenerator: optionale Parameter `journey: Journey? = nil` und `musicGenre: String? = nil`; bei gesetztem Wert diese verwenden, sonst bisherige Logik.
2. CategorySessionGenerator:  
   - 5 verschiedene Journeys (shuffled) + 5 verschiedene Genres aus Topic-Pool (shuffled) erzeugen;  
   - pro Slot `SessionGenerator.generate(topic:voice:journey:musicGenre:using:)` mit den zugewiesenen Werten aufrufen.
3. Topic-Genre-Pools: In SessionTopicConfig (oder zentral) pro Topic einen Array von erlaubten Genres definieren; CategorySessionGenerator nutzt diesen Pool für die 5 Slots.
4. Zeitberechnung: Prüfung durchführen (Berechnung + Anzeige + Player), Befund dokumentieren, notwendige Anpassungen umsetzen.
5. Tests: Eindeutigkeit von Journey und Genre über die 5 Slots in CategorySessionGeneratorTests; SessionGenerator mit optionalen Parametern testen.
