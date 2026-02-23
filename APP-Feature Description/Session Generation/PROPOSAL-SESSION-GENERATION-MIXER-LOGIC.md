# Proposal: Session Generation — Mixer Settings Logic

**Status:** Proposal  
**References:** [PLAN-1.0.0-SOUNDS-SESSION-GENERATION-EXTENSION.md](../PLAN-1.0.0-SOUNDS-SESSION-GENERATION-EXTENSION.md), [PROPOSAL-1.0.0-SOUNDS-JSON-AUDIOFILE-METADATA.md](PROPOSAL-1.0.0-SOUNDS-JSON-AUDIOFILE-METADATA.md), [ANALYSIS-SESSION-GENERATOR-SOUND-REPETITION-PROPOSAL.md](ANALYSIS-SESSION-GENERATOR-SOUND-REPETITION-PROPOSAL.md), `SessionGenerator.swift`, `SoundsMetadataLoader.swift`.

---

## 1. Review of PLAN-1.0.0-SOUNDS-SESSION-GENERATION-EXTENSION

The plan extends session generation so that when `1.0.0_sounds.json` is present and populated:

- **Stage pools:** For each text stage, entries are selected by `topic` + `stageHints`; one entry is picked per phase (with optional exclusion of the last session’s content IDs).
- **Per-voice duration:** Phase duration is taken from `playtime[voice]` when a module is chosen from the pool.
- **Content ID:** The chosen entry’s `contentId` is used as the text slot’s content; otherwise the synthetic `voice/topic/stage/vN` pattern is used.

The plan does **not** specify:

- How **mixer settings** (volume, fadeIn, fadeOut) for the text slot—or any other slot—should behave when content comes from the pool.
- Use of the **`mix`** field (`"one"` | `"loop"`) from the JSON.
- Any per-entry mixer metadata (e.g. optional volume/fade overrides in the JSON).

---

## 2. Current Mixer Logic (SessionGenerator)

Mixer settings for session phases are determined entirely inside `SessionGenerator` and are **stage-based and hardcoded**. There is no input from `1.0.0_sounds.json` for volume or fades.

### 2.1 Text slot

- **Source:** `buildPhase` → when `textContentIdOverride` is set (pool pick), it builds `MediaConfig(content: contentId, volume: …, fadeIn: …, fadeOut: …)` with the **same** stage-based defaults as synthetic content.
- **Logic:**
  - `volume`: `stage == "affirmation" ? 0.6 : 0.8`
  - `fadeIn`: `stage == "intro" || stage == "introComfort" ? 5 : 2`
  - `fadeOut`: `stage == "exit" ? 5 : 2`
- So **pool-sourced content and synthetic content use identical mixer values** for the text slot; the only difference is `content` and (when available) phase duration.

### 2.2 Other slots (music, nature, frequency, noise, sound)

- **Music:** `buildMusicConfig` — volume by `isSadComfort` (0.4), `stage == "silence"` (0.3), else 1.0; fadeIn/fadeOut 10 for intro/silence/exit, else 3.
- **Nature:** `buildNatureConfig` — `journey.natureSoundName`, `journey.natureVolume`, fade 5/5.
- **Frequency:** `buildFrequencyConfig` — volume 0.6, fades from `freqConfig` or 5/5.
- **Noise:** `buildNoiseConfig` — only for silence; volume 0.3, fadeIn 0.3, fadeOut 10.
- **Sound (alarm):** `buildSoundConfig` — only for OBE alarm; content `"Glockenspiel"`, volume 0.7, fade 2/2.

None of these use `SoundsMetadataLoader` or any field from `1.0.0_sounds.json`.

### 2.3 `mix` in 1.0.0_sounds.json

- **Schema:** `SoundsMetadataEntry` has `var mix: String?` (v1: `"one"` | `"loop"`).
- **Usage:** **Not used** in session generation. In v1, `mix` drives single-file vs multi-clip playback (phase length from file vs loop until phase timer). The plan’s “Optional / Future” section defers multi-clip (counter > 1) for non-affirmation stages; when that is implemented, `mix` could drive whether a phase uses ClipQueue or a single file.

---

## 3. Gaps and Inconsistencies

| Area | Current behaviour | Gap |
|------|-------------------|-----|
| **Text mixer when content from pool** | Same stage-based volume/fade as synthetic content. | No way to override per-module (e.g. quieter narration for a specific module) without code change. |
| **`mix` field** | Loaded in `SoundsMetadataEntry` but never read in `SessionGenerator`. | When multi-clip is extended, `mix` (and `counter`) should drive single-file vs ClipQueue per phase. |
| **Exclusion in batch generation** | `CategorySessionGenerator.generateSessions` (both overloads) does **not** pass `exclusion` to `SessionGenerator.generate`. | Pool picks in the 5-session batch do not avoid the last session’s text content IDs; only single-session and regenerate flows use exclusion. |
| **Single source of defaults** | Text/music/nature/frequency/noise/sound defaults are scattered across `buildPhase` and several `build*Config` helpers. | Harder to document, test, or override from metadata; no single place for “stage → default mixer” for text. |

---

## 4. Proposed Changes

### 4.1 (Recommended) Use exclusion in batch session generation

- **Change:** In `CategorySessionGenerator`, in both `generateSessions` overloads, obtain `RecentSessionFingerprintStore.shared.getFingerprint()` once per batch and pass it as `exclusion` into every `SessionGenerator.generate(..., exclusion: exclusion, using: &sessionRng)` call.
- **Effect:** When `1.0.0_sounds.json` is used, pool picks for all 5 sessions will prefer content IDs not in the last session’s fingerprint, consistent with single-session and regenerate flows.
- **Risk:** Low; same parameter already used elsewhere; batch still gets variety via journey/genre/variant index.

### 4.2 (Optional) Optional per-entry text mixer in 1.0.0_sounds.json

- **Schema extension:** Add optional fields to the JSON entry (or to a separate “mixer” object per entry), e.g.:
  - `textVolume: Float?` (0–1)
  - `textFadeIn: TimeInterval?` (seconds)
  - `textFadeOut: TimeInterval?` (seconds)
- **Loader:** In `SoundsMetadataLoader`, either extend `SoundsMetadataEntry` with these fields or add a small struct returned together with the entry (e.g. `MixerOverrides?`).
- **SessionGenerator:** When building a phase with `textContentIdOverride` from the pool, pass the **chosen entry** (or its mixer overrides) into `buildPhase`. In `buildPhase`, when creating the text `MediaConfig`, if the chosen entry has non-nil overrides, use them; otherwise keep current stage-based defaults.
- **Effect:** Enables per-module text volume/fade without changing stage logic for synthetic content or other slots.
- **Scope:** Proposal only; implement when product requires per-module mixer control.

### 4.3 (Future) Use `mix` when extending multi-clip beyond affirmation

- When implementing “multi-clip for non-affirmation stages” (plan §4), use the chosen pool entry’s `mix` and `counter`:
  - `mix == "loop"` and `counter > 1` → phase can use ClipQueue with that module’s `soundIds`.
  - `mix == "one"` or `counter == 1` → single file; phase duration from `playtime[voice]` as today.
- No change to current mixer **settings** (volume/fade); `mix` only affects playback mode and clip selection.

### 4.4 (Optional) Centralize stage-based text mixer defaults

- Introduce a small type or enum (e.g. `StageTextMixerDefaults`) used by both:
  - synthetic text path (`buildTextConfig`), and
  - pool text path (in `buildPhase` when `textContentIdOverride` is set).
- Defaults (volume, fadeIn, fadeOut) per stage live in one place; optional overrides from JSON (4.2) can be applied on top.
- **Effect:** Clearer, testable, and easier to extend with metadata-driven overrides later.

---

## 5. Summary Table

| Change | Type | Effect |
|--------|------|--------|
| Pass `exclusion` in batch `generateSessions` | Bugfix / parity | Pool picks in 5-session batch avoid last session’s text content IDs when 1.0.0_sounds.json is used. |
| Optional `textVolume` / `textFadeIn` / `textFadeOut` in JSON + use in buildPhase | Enhancement | Per-module text mixer when content comes from pool; fallback to current stage defaults. |
| Use `mix` (and `counter`) when adding multi-clip for non-affirmation | Future | Correct single-file vs ClipQueue behaviour per pool entry. |
| Centralize stage-based text mixer defaults | Refactor | Single source of truth for text slot defaults; easier to add JSON overrides. |

---

## 6. Do We Need to Update Firestore, Database, Metadata, Tests?

For the **recommended change (4.1 only)** — pass `exclusion` in batch `generateSessions`:

| Area | Update needed? | Notes |
|------|----------------|--------|
| **Firestore** | No | Session and SessionPhase structure (phases with text/music/nature/sound/frequency/noise as today) are unchanged. Same Codable encoding to `users/{uid}/sessions` and `users/{uid}/categorySessions/.../sessions`. |
| **Database** | No | No separate database; session persistence is Firestore only. No schema or migration. |
| **Metadata (1.0.0_sounds.json)** | No | No new fields or schema change. We only pass an existing parameter into the generator. |
| **Tests** | Optional but recommended | Existing tests do not pass or assert on `exclusion` for the batch path; they will still pass. Add or extend a test to verify that batch generation passes `exclusion` when available (e.g. in CategorySessionGeneratorTests: after storing a fingerprint, generate a batch and assert behaviour consistent with exclusion). |

If **4.2** (optional per-entry text mixer in JSON) is implemented later:

| Area | Update needed? | Notes |
|------|----------------|--------|
| **Firestore** | No | Session/phase/MediaConfig shape unchanged; we only set volume/fade from JSON when building the phase. |
| **Database** | No | — |
| **Metadata** | Yes | Add optional fields to 1.0.0_sounds.json (e.g. textVolume, textFadeIn, textFadeOut) and to SoundsMetadataEntry; any export/tooling that produces the JSON. |
| **Tests** | Yes | SoundsMetadataLoader (new fields), SessionGenerator (use overrides when building phase from pool; fallback to stage defaults). |

---

## 7. Recommendation

1. **Do now:** Implement **4.1** (exclusion in batch `generateSessions`) so that mixer-slot content selection (pool picks) is consistent across all session generation entry points.
2. **Document in plan:** Add a short “Mixer settings” subsection to PLAN-1.0.0-SOUNDS-SESSION-GENERATION-EXTENSION stating that volume/fade for all slots remain stage-based and that optional per-entry text mixer overrides (and use of `mix` for multi-clip) are deferred as in §4.2 and §4.3.
3. **Later, if needed:** Implement optional per-entry text mixer in JSON (4.2) and centralize text defaults (4.4); when extending multi-clip, use `mix` (4.3).
