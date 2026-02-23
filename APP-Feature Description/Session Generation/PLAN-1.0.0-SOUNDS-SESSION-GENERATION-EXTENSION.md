# Plan: Session Generation Extension with 1.0.0_sounds.json

**References:** [PROPOSAL-1.0.0-SOUNDS-JSON-AUDIOFILE-METADATA.md](PROPOSAL-1.0.0-SOUNDS-JSON-AUDIOFILE-METADATA.md), SESSION-GENERATOR-KERNLOGIK.md, ANALYSIS-SESSION-GENERATOR-SOUND-REPETITION-PROPOSAL.md.

---

## 1. Goal

Extend session generation so that when `1.0.0_sounds.json` is present in the app bundle and populated with v1-style metadata, the generator can:

- Use **stage pools**: pick a module per stage from metadata (topic + stageHints) instead of only synthetic `voice/topic/stage/vN`.
- Use **per-voice duration**: set phase duration from `playtime[voice]` when a module is chosen from the pool.
- Respect **recent-session exclusion** when picking from the pool (avoid repeating content IDs from the last session).

When the file is missing or empty, behaviour is unchanged (synthetic content IDs and existing duration logic).

---

## 2. Implemented Components

### 2.1 SoundsMetadataLoader and model

- **File:** `AWAVE/AWAVE/Services/SoundsMetadataLoader.swift`
- **SoundsMetadataEntry (Codable):** name, dbList, type, category, h1, h2, topic, mix, counter, playtime (per-voice seconds), contentId, soundId, soundIds, stageHints, file_path, file_paths. All optional so partial JSON is supported.
- **SoundsMetadataLoader:** Loads from `Bundle.main` resource `1.0.0_sounds.json`; caches; returns `[]` when file missing or invalid. Methods:
  - `loadEntries()` → `[SoundsMetadataEntry]`
  - `entriesForStage(topic:stage:)` → entries where `topic` matches and `stageHints` contains stage
  - `durationSeconds(entry:voice:)` → `TimeInterval?` from playtime
  - `isMultiClip(entry:)` → counter > 1 (for future ClipQueue use)
  - `clearCache()` for tests

### 2.2 SessionGenerator integration

- **generate(..., exclusion: RecentSessionFingerprint? = nil):** New optional parameter so pool picks can avoid last session’s content IDs.
- **pickFromSoundsMetadataIfAvailable(topic:voice:stage:exclusion:rng:):** For each text stage (not silence/alarm), asks loader for `entriesForStage(topic, stage)`. If non-empty, picks one (prefer contentId not in exclusion), returns `(contentId, durationSeconds)`.
- **buildPhase(..., textContentIdOverride: String? = nil, durationOverride: TimeInterval? = nil):** When overrides are set, uses them for text content and phase duration; otherwise keeps existing buildTextConfig and defaultStageDuration/variableDuration.
- **Flow:** In the phase loop, call `pickFromSoundsMetadataIfAvailable`; if it returns a contentId, pass it and optional duration into `buildPhase`; otherwise buildPhase uses synthetic ID and existing duration logic.

### 2.3 Call sites

- **PlayerViewModel.regenerateCurrentSession:** Passes `exclusion` into `SessionGenerator.generate(..., exclusion: exclusion, using: &rng)`.
- **CategorySessionGenerator.generateSingleSession** and **generateSingleSessionForSearch:** Pass `exclusion` into `generate(..., exclusion: exclusion, ...)`.
- **CategorySessionGenerator.generateSessions** (both overloads): Pass `exclusion` into `generate(..., exclusion: exclusion, ...)` so pool picks in the 5-session batch avoid the last session’s text content IDs when 1.0.0_sounds.json is used.

### 2.4 Mixer settings

- Volume and fadeIn/fadeOut for all slots (text, music, nature, frequency, noise, sound) are determined by **stage** in `SessionGenerator` (hardcoded per slot).
- When content comes from the pool (1.0.0_sounds.json), the **text** slot uses the same stage-based defaults as synthetic content; no per-entry mixer overrides are applied.
- Optional per-entry text mixer (e.g. textVolume, textFadeIn, textFadeOut in JSON) and use of `mix` for multi-clip are **deferred** (see [PROPOSAL-SESSION-GENERATION-MIXER-LOGIC.md](docs/PROPOSAL-SESSION-GENERATION-MIXER-LOGIC.md) §4.2, §4.3).

---

## 3. Behaviour Summary

| Scenario | Behaviour |
|----------|-----------|
| **1.0.0_sounds.json missing or empty** | Unchanged: synthetic `voice/topic/stage/vN`, defaultStageDuration / durationRange. |
| **File present, no entries for (topic, stage)** | Same as above for that stage. |
| **File present, entries for (topic, stage)** | One entry chosen (prefer not in exclusion); phase gets `contentId` from entry and duration from `playtime[voice]` when > 0. |

Topic matching uses `entry.topic == topic.rawValue` (lowercased). Stage matching uses `entry.stageHints.contains(stage)`; entries without `stageHints` are not used for pools.

---

## 4. Optional / Future (not implemented)

- **Multi-clip (counter > 1) for non-affirmation stages:** `SoundsMetadataLoader.isMultiClip(entry)` is available; using it to drive ClipQueue for phases whose content comes from a multi-clip module would require resolver and player changes (resolve by soundIds for that module, pass clip URLs per phase).
- **Bundling 1.0.0_sounds.json:** Add the file (e.g. from OLD-APP export or empty `[]`) to the app target’s Copy Bundle Resources so `Bundle.main.url(forResource: "1.0.0_sounds", withExtension: "json")` finds it. Until then, loader returns `[]` and behaviour is unchanged.
- **SessionContentMapping from JSON:** Proposal suggests generating/validating SessionContentMapping from this file; left to tooling or a later step.

---

## 5. Files touched

- **New:** `AWAVE/AWAVE/Services/SoundsMetadataLoader.swift`
- **Modified:** `AWAVE/AWAVE/Services/SessionGenerator.swift` (exclusion param, pickFromSoundsMetadataIfAvailable, buildPhase overrides), `AWAVE/AWAVE/Features/Player/PlayerViewModel.swift` (pass exclusion), `AWAVE/AWAVE/Services/CategorySessionGenerator.swift` (pass exclusion in single-session flows), `AWAVE/AWAVE.xcodeproj/project.pbxproj` (add SoundsMetadataLoader.swift to app target).
