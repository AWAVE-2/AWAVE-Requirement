# Session-Generator Content-IDs – Katalog-Abgleich

**Zweck:** Liste der Content-IDs, die der Session-Generator ausgibt. Firestore Collection `sounds` bzw. `sound_metadata.json` (Feld `content_id` → Firestore `contentId`) müssen für Session-Playback passende Einträge haben. Ohne Abdeckung spielt die App für diese Spur nur Frequency/Noise (kein kategoriebasierter Fallback mehr).

**Stand:** Refactoring Session-Generierung / Audio-Library-Anbindung (2026).

---

## App UI categories and SessionTopic

The app exposes **3 categories** on Home and Category Detail: **Schlaf**, **Ruhe**, **Im Fluss** (from `OnboardingCategory`: sleep, calm, flow). Session generation for these uses `CategorySessionGenerator.mapToSessionTopic`: Schlaf → `SessionTopic.sleep`, Ruhe → `SessionTopic.stress`, Im Fluss → `SessionTopic.meditation`. Content IDs use topic raw values (e.g. `franca/sleep/intro`, `marion/stress/body`, `flo/meditation/...`). `SessionContentMapping` maps these to catalog themes and sound IDs.

---

## Text (Stimme/Topic/Stage)

- **Schema:** `{voice}/{topic}/{stage}` oder `{voice}/{topic}/{stage}/v{variant}`
- **Beispiele:** `franca/sleep/intro`, `marion/stress/body`, `flo/meditation/breath`, `corinna/sad/comfort`, `franca/sleep/intro/v0`
- **Code:** `SessionGenerator.buildTextConfig` (Voice: franca, flo, marion, corinna; Topics/Stages aus `SessionTopic`)

---

## Musik (Genre)

- **Schema:** Genre-String aus Topic oder SAD-Comfort
- **Werte:** u. a. `Ambient`, `Chillout`, `Deep_Dreaming`, `Peaceful_Ambient`, `Solo_Piano`, `Zen_Garden`, `Guitar`, `LoFi`, `Piano`, `Choir` (abhängig von Topic und `musicGenre(using:)`)
- **Sonderfall SAD (Comfort):** `Solo_Piano`
- **Code:** `SessionGenerator.buildMusicConfig`

---

## Natur (Fantasy Journey)

- **Schema:** Name des Natur-Sounds aus Journey
- **Werte:** `Gebirgsbach`, `Wald`, `Wasserfall`, `Schneesturm`, `Hoehle`, `Ozean` (siehe `FantasyJourneyManager.Journey.natureSoundName`)
- **Code:** `SessionGenerator.buildNatureConfig` (nur Stages fantasy, hypnosis, regulation)

---

## Sound (Effekte)

- **Schema:** Effekt-Name
- **Werte:** `Glockenspiel` (OBE alarm-Stage)
- **Code:** `SessionGenerator.buildSoundConfig`

---

## Noise

- **Schema:** Dateiname des Rauschtyps
- **Werte:** z. B. `pink.mp3`, `white.mp3` (über `NoiseType.audioFileName`)
- **Code:** Phase.noise.type

---

## Katalog-Check

- In `sound_metadata.json`: Für alle vom Generator genutzten Werte `content_id` setzen (oder über Migration aus Pfad/Name ableiten).
- Firestore: Nach Migration müssen `sounds`-Dokumente das Feld `contentId` mit exakt diesen Werten haben.
- Optional: `SessionContentMapping.soundId(for:)` für Content-IDs befüllen, die noch nicht in Firestore als `contentId` existieren.

## Einzigartige Text-Sessions

- Der Generator erzeugt pro Slot unterschiedliche Text-Content-IDs mit Variant-Suffix: `{voice}/{topic}/{stage}/v0` … `/v4`.
- **SessionContentResolver** fällt bei fehlendem Treffer im Katalog auf die Basis-Content-ID (ohne `/vN`) zurück, damit die Wiedergabe nicht abbricht.
- Für **wirklich einzigartige Text-Sessions** (unterschiedliche Sprachdateien pro Session) sollten pro voice/topic/stage mehrere Varianten (v0…v4) im Katalog vorhanden oder in SessionContentMapping auf unterschiedliche Dokumente/Dateien abgebildet sein. Ohne diese Einträge werden alle fünf Sessions auf dieselbe Basis-Datei aufgelöst.
