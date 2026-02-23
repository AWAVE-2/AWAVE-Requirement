# Session Generator – Core Logic & Audio Assembly

## 1. Overview

The session generator builds a **session** from multiple **phases**. Each phase corresponds to a module from the content DB (e.g. “Ballonfahrt”, “Gelassenheitsatmung_478”). **Audio files** per module (including multiple short clips, e.g. 3-second files) are assembled and played via the content DB and a **3-container logic**.

---

## 2. Flow: From Topic to Session

### 2.1 Entry

- **generator-session-content.js**: The user selects a **topic** (e.g. `sleep`, `stress`, `fantasy`) or the **symptom finder** sets it via `findTopic(input)` (**generator-keywords.js**).
- `startSessionGenerator(topic)` → after a short loading time `generateSession(topic)`.

### 2.2 Building the Session

- **session-object.js**: `session` is an array. `session[0]` = configuration (name, voice, topic). From `session[1]` onward come the **phases**.
- **generator-session-content.js**: `generateSession(topic)` contains a large `switch(topic)`. For each topic a **fixed sequence of stages** is defined, e.g. for `sleep`:

  ```
  intro → body → thinkstop → breath → hypnosis → fantasy → introAff → affirmation → silence
  ```

- Each stage is filled with **one** phase via:

  ```js
  createRandomPhase(topic, "intro");
  createRandomPhase(topic, "body");
  // ...
  ```

---

## 3. Core Function: `createRandomPhase(topic, stage)`

```javascript
// generator-session-content.js, ~lines 124–141
function createRandomPhase(topic, stage) {
    createPhase();                                    // New empty phase appended to session[]
    const possibleContent = eval(topic+"SG");          // e.g. sleepSG, stressSG
    var randomIndex = Math.floor(Math.random() * possibleContent[stage].length);
    // Special logic: don't repeat same fantasy twice in a row (lastFantasy)
    session[session.length - 1].text.content = possibleContent[stage][randomIndex];  // e.g. "Tibetische_Wanderung"
    session[session.length - 1].duration = eval(session[session.length - 1].text.content).playtime[session[0].voice];
}
```

- **topic + "SG"**: The matching **session generator object** is loaded (e.g. `sleepSG`, `stressSG` from **content-database.js**).
- **possibleContent[stage]** is an **array of module names** (strings), e.g. `sleepSG.intro = ["Schlaf_Session"]`, `sleepSG.body = ["PMR", "Bodyscan_Lang", ...]`.
- **One random** name is chosen and written to `session[phase].text.content`.
- **Duration**: The name is resolved with `eval(...)` as a **global contentDB object**; `playtime[voice]` returns the duration in **seconds** for the selected voice (Flo, Franca, Marion, Corinna).

This fixes **which module** runs in this phase and **how long** the phase lasts. The actual **audio files** come from that module in the content DB.

---

## 4. Content DB: Modules and Categories

### 4.1 Structure (content-database.js)

Each module is a **contentDB** object:

```javascript
function contentDB(name, dbList, h1, h2, type, category, mix, counter, topic, files, playtime) {
    this.name     = name;      // e.g. "Ballonfahrt"
    this.category = category;  // e.g. "Traumreise"
    this.type     = type;      // e.g. "text"
    this.counter = counter;   // Number of audio files (1 = single file, >1 = name_1.mp3, name_2.mp3, ...)
    this.files   = files;      // initially [], filled in generateAllFilePaths()
    this.playtime = playtime;  // { Flo: 649, Franca: 627, Marion: 707, Corinna: 670 } in seconds
}
```

- **counter = 1**: A single file per module:  
  `type/category/name/name.mp3`  
  (e.g. `text/Fantasiereise/Ballonfahrt/Ballonfahrt.mp3`).
- **counter > 1**: Multiple **numbered** files:  
  `name_1.mp3`, `name_2.mp3`, … `name_counter.mp3`  
  → typical for **affirmations** or other modules made of many short clips (e.g. 3-second files).

**Category** is only the semantic grouping (e.g. “Traumreise”, “Affirmation”, “Atemtechnik”). **Assembly** of audio is done via `files` and the 3-container logic.

---

## 5. How Audio Files (Including 3-Second Clips) Are Assembled in a Category

### 5.1 Populating `files` (content-database.js, `generateAllFilePaths()`)

- For each module with **counter = 1**:  
  one entry: `type/category/name/name.mp3`.
- For **counter > 1**:  
  entries: `type/category/name/name_1.mp3` … `name_counter.mp3`.

Then (only when counter > 1):

1. **Shuffle** the array (Fisher–Yates).
2. **Split into 3 containers**:
   - `contentTriple = floor(count / 3)`, remainder `contentTripleRest`.
   - The shuffled list is distributed across **3 buckets** (roughly one third each).
   - Structure:  
     `files = [ [0, current playback pool], [1, Container1], [2, Container2], [3, Container3] ]`.

So the “3” refers to **3 containers** for random selection, not 3 seconds of length. If a module has e.g. 40 clips of 3 seconds each, that’s 40 files distributed across these 3 containers.

### 5.2 Playback: `getAudioSrc(dbItem)` (main.js)

- **files.length === 1**: Single file; path is prefixed with voice (e.g. `Franca_`) and returned.
- **files.length > 1** (3-container setup):
  - A random entry is always taken from **files[0][1]** (the current pool) and removed (`splice`).
  - When this pool is **empty**, it is refilled from the **next container**:
    - Previously 1 → refill from container 2  
    - Previously 2 → refill from container 3  
    - Previously 3 → refill from container 1  
  - So the three containers rotate (1 → 2 → 3 → 1 …). This avoids the same short file repeating too soon; clips (e.g. 3-second files) are spread across the **category/module** (e.g. an affirmations category) and played one after another.

The **total duration** of a phase comes from the module’s `playtime[voice]`; playback runs until the phase ends (player/phase timer). So as many clips from the module are played in sequence until the phase duration is reached.

---

## 6. Role of the Files You Mentioned

| File | Role |
|------|------|
| **generator-session-text.js** | **Text only**: Session titles (`sessionTitle`) and descriptions (`sessionTexts`) per topic. No audio logic. |
| **generator-session-content.js** | **Core**: Topic → stages → `createRandomPhase(topic, stage)` → choice from `topicSG[stage]`, setting `text.content` (module name) and `duration` from `playtime[voice]`. |
| **generator-keywords.js** | **Symptom finder**: Keywords per topic; `findTopic(userText)` returns the topic for the generator. |
| **generator-frequency-noise.js** | Binaural/isochronic tones and noise per phase; **no** voice/clip files. |
| **session-object.js** | **Structure**: `session[]`, `sessionPhase`, `createPhase()`; no content logic. |
| **content-database.js** | **Content DB**: contentDB constructor, all modules (name, category, counter, playtime), **topicSG** objects (sleepSG, stressSG, …) with stages and module names; `generateAllFilePaths()` fills `files` and builds the 3-container structure. |
| **main.js** | **Playback**: `getAudioSrc(dbItem)` picks the next clip from `dbItem.files` (single file or 3-container rotation). |

**“3-second files”** in a category are technically: modules with **counter > 1** (many numbered files). Whether each is exactly 3 seconds long is not defined in the code; the **total length** of the phase is `playtime[voice]`. **Assembly** within the category works by:

1. **Generator**: Choosing the module (and thus the category) via `createRandomPhase(topic, stage)` and `topicSG[stage]`.
2. **Content DB**: Assigning files to the module (counter, paths, 3 containers).
3. **Playback**: Rotating through the 3 containers in `getAudioSrc()` until the phase duration has elapsed.

This completes the description of the session generator’s core logic and how audio files (including many short clips like 3-second files) are assembled per category.
