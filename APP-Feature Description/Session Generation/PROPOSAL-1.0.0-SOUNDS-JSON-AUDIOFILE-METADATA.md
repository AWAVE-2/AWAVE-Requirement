# Proposal: Using v1.0 Sounds JSON to Improve Audiofile Relation Metadata
l only — no code changes.  
**Context:** APP v1.0 (OLD-APP) is being replaced by the new Swift app. The file `OLD-APP/1.0.0_sounds.json` is intended as a bridge for metadata; this document proposes how it can improve the Swift app’s audiofile relation metadata and session generation.

**Status:** Proposa
**References:**  
`SESSION-GENERATOR-KERNLOGIK.md`, `docs/ANALYSIS-SESSION-GENERATOR-TEXT-SOUNDS-STATUS.md`, `docs/ANALYSIS-SESSION-GENERATOR-SOUND-REPETITION-PROPOSAL.md`, `OLD-APP/src/js/content-database.js`.

---

## 1. Current State of 1.0.0_sounds.json

- **File:** `OLD-APP/1.0.0_sounds.json`
- **Current content:** **Empty** (0 bytes). The file exists but contains no data.
- **Intended role:** A JSON export of v1.0 content/sound metadata that can be used to enrich the Swift app’s catalog and session logic without re-implementing v1 behaviour.

To make this proposal actionable, the file would need to be **populated** from one of:

1. **Export from v1 content-database.js** — Script that walks the `contentDB` instances (and any `topicSG` stage→module arrays) and outputs a single JSON (see suggested schema below).
2. **Export from v1 runtime** — If the old app can dump its content DB (after `generateAllFilePaths()` etc.) to JSON.
3. **Manual / semi-automated mapping** — Build the JSON from existing `sound_metadata.json` or Firestore by adding v1-specific fields (e.g. module name, topic, playtime per voice) where they can be inferred from path/name/category.

---

## 2. v1 (OLD-APP) Metadata Relevant to Session Generation

From `content-database.js` and `SESSION-GENERATOR-KERNLOGIK.md`:

### 2.1 contentDB structure (per “module”)

| Field     | Description | Use in Swift |
|----------|-------------|--------------|
| **name** | Internal ID / filename base (e.g. `Ballonfahrt`, `Einschlafen`) | Stable content identifier; maps to “module” in session generation. |
| **dbList** | Display name (e.g. “Einschlafen”, “Ballonfahrt”) | Title/label in UI. |
| **h1, h2** | Phase labels (e.g. “Einleitung”, “Affirmationen”) | Stage/category grouping. |
| **type** | `text` \| music \| nature \| sound | Maps to Swift `Sound.SoundCategory` and phase slots (text, music, nature, sound). |
| **category** | E.g. Einleitung, Atemtechnik, Traumreise, Affirmation | Content grouping; aligns with subcategory (e.g. “Affirmation > Einschlafen”). |
| **mix** | `"one"` \| `"loop"` | Single file vs multi-clip behaviour. |
| **counter** | 1 = one file; >1 = many numbered files (e.g. 40 affirmation clips) | Drives multi-clip queue (3-container) in v1; in Swift only affirmation stage uses ClipQueue. |
| **topic** | sleep, stress, trauma, obe, user, etc. | Links module to SessionTopic; used in topicSG[stage] and for filtering. |
| **playtime** | `{ Flo: sec, Franca: sec, Marion: sec, Corinna: sec }` | **Per-voice duration**; currently Swift has a single `duration` per sound. |
| **files** | Filled at runtime (paths or 3-container structure) | v1 playback; Swift uses Firestore/catalog URLs and ClipQueue for affirmation. |

### 2.2 Session generation in v1

- **topicSG** (e.g. `sleepSG`): For each **stage** (intro, body, thinkstop, breath, hypnosis, fantasy, introAff, affirmation, …) an **array of module names**.
- **createRandomPhase(topic, stage):** Picks one module name from `possibleContent[stage]` at random → `session[phase].text.content = moduleName`; duration from `eval(moduleName).playtime[voice]`.
- **Multi-clip:** Modules with `counter > 1` get shuffled file lists and 3-container rotation; many short clips fill one phase until `playtime[voice]` is reached.

So v1 has **explicit relation**: stage → list of modules → each module has name, topic, counter, playtime per voice, category.

---

## 3. Swift App Today: Gaps vs v1

| Aspect | v1 (OLD-APP) | Swift app |
|--------|---------------|-----------|
| **Phase content** | One **module name** per phase (e.g. `Ballonfahrt`, `PMR`) | One **content ID** per phase (e.g. `franca/sleep/intro`, `franca/sleep/affirmation/v0`) |
| **Content ID source** | From content DB (module name) | Synthetic: `voice/topic/stage` or `…/stage/v0…v4`; mapping via `SessionContentMapping` (topic→theme, voice+theme→soundId/variants). |
| **Duration** | Per voice: `playtime[voice]` per module | Single `duration` per `Sound`; phase duration from `SessionGenerator.defaultStageDuration(stage)` or variable config, not from catalog. |
| **Multi-clip (counter > 1)** | Any module with counter > 1 → 3-container, many clips per phase | Only **affirmation** stage uses ClipQueue (subcategory “Affirmation > {theme}” + speaker). |
| **Stage → content** | stage → **list of modules** → random pick | stage → **fixed content ID pattern** (plus v0…v4 for some stages); no explicit “pool of modules” per stage. |
| **Topic / category on sound** | topic, category, h1, h2 on each module | Sound has category, subcategory, tags; no explicit “topic” or “stage” or “v1 module name”. |

So the Swift app does **not** have:

- A direct **audiofile ↔ v1 module** relation (e.g. which Firestore sound corresponds to “Ballonfahrt” or “Einschlafen” module).
- **Per-voice playtime** in catalog metadata (only one duration per sound).
- **Explicit “pool per stage”** for text (v1: many modules per stage; Swift: content ID + up to 5 variants per theme).
- Multi-clip behaviour for non-affirmation stages that had counter > 1 in v1.

---

## 4. How 1.0.0_sounds.json Can Improve Audiofile Relation Metadata

Assume `1.0.0_sounds.json` is populated with a v1-oriented export. Below is a **proposal** for schema and use — improvement only, no implementation detail.

### 4.1 Suggested JSON schema (per entry)

A minimal useful shape that bridges v1 and Swift:

```json
{
  "name": "Ballonfahrt",
  "dbList": "Ballonfahrt",
  "type": "text",
  "category": "Traumreise",
  "h1": "Fantasiereise",
  "h2": "Ballonfahrt",
  "topic": "balloon",
  "mix": "one",
  "counter": 1,
  "playtime": { "Flo": 649, "Franca": 627, "Marion": 707, "Corinna": 670 },
  "contentId": "text_Fantasiereise_Ballonfahrt_Ballonfahrt",
  "soundId": "text_Traumreise_Ballonfahrt_Ballonfahrt"
}
```

For multi-clip modules (e.g. affirmations):

```json
{
  "name": "Einschlafen",
  "type": "text",
  "category": "Affirmation",
  "topic": "sleep",
  "mix": "loop",
  "counter": 40,
  "playtime": { "Flo": 0, "Franca": 0, "Marion": 0, "Corinna": 0 },
  "contentId": "text_Affirmation_Einschlafen",
  "soundIds": ["text_Affirmation_Einschlafen_Franca_Einschlafen_1", "..." ]
}
```

Optional additions:

- **file_path** or **file_paths**: v1 path pattern (e.g. `text/Traumreise/Ballonfahrt/Ballonfahrt.mp3`) for matching to existing `sound_metadata.json` / Firestore.
- **stageHints**: array of stage names where this module can appear (e.g. `["fantasy"]`) if derived from topicSG.

### 4.2 Improvements enabled by this file

1. **contentId / soundId ↔ v1 module name**  
   - One place that says: “Module `Ballonfahrt` ↔ this contentId / these sound IDs.”  
   - Enables: Session generator or content resolver to **resolve v1 module names** (if ever used for backward compatibility or A/B) to catalog IDs.  
   - Enables: Analytics or “recently used” logic to work with **module names** as well as content IDs.

2. **Per-voice duration (playtime)**  
   - Stored in JSON per module.  
   - Can be used to:  
     - Enrich Firestore/catalog: e.g. add optional `durationPerVoice` on sound documents, or a separate lookup table.  
     - Session generator: optionally use **catalog** playtime for phase duration instead of only `defaultStageDuration(stage)` when a specific module/content is chosen.  
   - Keeps v1 behaviour (phase length = module length per voice) available without hardcoding in Swift.

3. **Topic and stage relation**  
   - **topic** links module to SessionTopic.  
   - **stageHints** (if present) link module to stages.  
   - Enables:  
     - Filtering sounds by topic/stage for “recently used” or “avoid same module” across sessions.  
     - Future “pool per stage” in Swift: e.g. load list of module names (or content IDs) per stage from this JSON and pick one (with exclusion logic as in the sound-repetition proposal).

4. **Counter and multi-clip**  
   - **counter** and **mix** identify “multi-clip” modules (e.g. affirmations).  
   - Swift can use this to:  
     - Decide which phases get a **ClipQueue** (not only those whose content ID contains `"affirmation"`).  
     - Optionally preload or resolve all related `soundIds` for that module so the phase uses only clips belonging to that module (v1-like) instead of “all affirmation clips for voice+theme.”

5. **Single source for “v1 module ↔ catalog”**  
   - One JSON file that documents and drives the relation between v1 content DB and the new catalog.  
   - Reduces reliance on hardcoded `SessionContentMapping` for every new module; can generate or validate mapping from this file.  
   - Helps migration and testing: ensure every v1 module has at least one corresponding sound in the new app.

---

## 5. Relation to Session Generation Logic

- **Session generator** (Swift): Today it does **not** use v1 module names; it uses `voice/topic/stage` and optionally `stage/v0…v4`, then `SessionContentMapping` and `SoundRepository.getSound(byContentId:)`.  
- **1.0.0_sounds.json** does **not** replace that flow. It **enriches** it:
  - **Mapping:** Can be used to build or validate `contentId` / `soundId` for each v1 module so that “module name” and “content ID” stay in sync.  
  - **Duration:** Phase duration can optionally take per-voice playtime from this file when a concrete module/content is known.  
  - **Pools and variety:** If Swift later adds “pool per stage” (list of content IDs or module names per stage), this JSON can be the source for that list and for topic/stage filters.  
  - **Multi-clip:** Counter and soundIds per module can drive which phases get ClipQueue and which sound IDs belong to that phase.

So the file supports **better metadata and more precise behaviour** (duration, multi-clip, stage pools) without reintroducing the full v1 stack.

---

## 6. Migration Consideration (v1 Replaced by Swift)

- v1 is being **replaced**; the goal is **not** to re-implement v1 in Swift, but to **reuse v1’s relation metadata** where it adds value.  
- **Proposed use of 1.0.0_sounds.json:**  
  - **One-time or periodic:** Populate the JSON from v1 content-database (and optionally topicSG) or from a v1 export.  
  - **Consumption in Swift:**  
    - Optional: Load at build time or from bundle and use for mapping (contentId/soundId ↔ module name), per-voice playtime, and stage/topic hints.  
    - Or: Use the JSON only in tooling (e.g. generate/validate `SessionContentMapping`, or seed Firestore with `durationPerVoice` / topic / stage).  
  - No requirement to keep the old app running; the JSON is a **snapshot** of v1 metadata for the benefit of the new app.

---

## 7. Summary of Proposed Improvements

| Improvement | How 1.0.0_sounds.json helps |
|-------------|------------------------------|
| **Stable module ↔ catalog relation** | Each entry has name (v1 module), contentId, soundId(s); single source of truth for “which catalog item(s) implement this module.” |
| **Per-voice duration** | playtime per voice in JSON; can feed catalog or phase duration logic so it matches v1 where desired. |
| **Topic and stage** | topic (and optional stageHints) enable filtering and “pool per stage” without hardcoding in Swift. |
| **Multi-clip (counter > 1)** | counter and soundIds list identify which content gets ClipQueue and which files belong to one “module.” |
| **Less hardcoded mapping** | SessionContentMapping (or Firestore) can be generated/validated from this file; new modules add one JSON entry. |
| **Session variety / “recently used”** | With stage→module pools and topic on each module, Swift can implement “avoid last session’s modules” using this metadata. |

---

## 8. Next Steps (Proposal Only)

1. **Populate 1.0.0_sounds.json**  
   - Implement an export from v1 `content-database.js` (and topicSG if available) into the suggested schema, or derive from existing `sound_metadata.json` + path/name rules.  
   - Validate JSON (required fields, enums for type/category/topic).

2. **Decide consumption**  
   - Bundle in app and load at runtime for mapping/duration/pools, **or** use only in scripts to generate SessionContentMapping / Firestore seeds.  
   - Prefer one path to avoid drift (e.g. “JSON is source; Swift reads bundle” or “JSON is source; build step writes Swift/Firestore”).

3. **Extend Swift metadata only where needed**  
   - Add optional fields (e.g. `durationPerVoice`, `v1ModuleName`, `topic`) to catalog/Firestore only if product requires them.  
   - Use 1.0.0_sounds.json to fill those fields and to drive ClipQueue and phase-duration behaviour where agreed.

4. **Session generator**  
   - Keep current content ID and SessionContentMapping flow; optionally add a layer that uses this JSON for per-voice duration, stage pools, and multi-clip detection so that audiofile relation metadata is consistent and session generation can improve without re-implementing v1.

This proposal limits scope to **improving audiofile relation metadata** using a v1-derived JSON; it does not prescribe full parity with v1 session generation or changing the existing Swift architecture beyond what that metadata enables.
