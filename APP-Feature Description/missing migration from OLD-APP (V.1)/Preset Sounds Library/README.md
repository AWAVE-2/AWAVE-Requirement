# Preset Sounds Library - Feature Documentation

**Feature Name:** Preset Sounds Library  
**Status:** ⚪ Missing - Needs Migration  
**Priority:** High  
**Source:** OLD-APP (V.1)  
**Last Updated:** 2025-01-27

## 📋 Feature Overview

The Preset Sounds Library documents all preloaded audio files, preset configurations, and default session setups from OLD-APP (V.1). Each preset includes voice selection, nature sounds, music tracks, frequency settings, and audio wave configurations organized by category.

### Description

The OLD-APP (V.1) contains an extensive library of preset sound configurations that combine:
- **Voice Options:** Flo (Florian), Franca, Marion, Corinna
- **Nature Sounds:** Environmental audio (Wald, Ozean, Gebirgsbach, etc.)
- **Music Tracks:** Background music (Deep_Dreaming, Peaceful_Ambient, Zen_Garden, etc.)
- **Frequency Settings:** Brainwave entrainment (Gamma, Beta, Alpha, Theta, Delta)
- **Audio Wave Types:** Binaural, monaural, isochronic, bilateral, etc.

### User Value

- **Quick Start:** Users can immediately access pre-configured sound combinations
- **Category-Based:** Presets organized by use case (Sleep, Stress, Meditation, etc.)
- **Proven Combinations:** Tested audio configurations for specific goals
- **Consistency:** Standardized presets across the app

---

## 🎯 Preset Frequency Settings

### Frequency Presets (from content-database.js)

```javascript
const gammaPreset = 44;  // High focus, active thinking
const betaPreset  = 23;  // Active thinking, concentration
const alphaPreset = 10;  // Relaxed awareness, light meditation
const thetaPreset = 6;   // Deep meditation, creativity
const deltaPreset = 2;   // Deep sleep, healing

const freqTypePreset = "monaural";  // Default frequency type
```

### Frequency Types Available

- **root** - Single tone frequency
- **binaural** - Different frequencies in each ear
- **monaural** - Same frequency in both ears (default)
- **isochronic** - Pulsing tones
- **bilateral** - Alternating left/right stimulation
- **molateral** - Modified lateral stimulation
- **shepard** - Shepard tone illusion
- **isoflow** - Flowing isochronic pattern
- **bilawave** - Bilateral wave pattern
- **binawave** - Binaural wave pattern
- **monawave** - Monaural wave pattern
- **flowlateral** - Flowing lateral pattern

---

## 📁 Category-Based Preset Configurations

### 1. Schlafen (Sleep) Category

**Default Voice:** Franca (can be changed to Flo, Marion, or Corinna)

**Session Structure:**
- **Intro Phase:** Frequency 12 Hz → 12 Hz (monaural), 30s fade-in
- **Body Relaxation:** Frequency 12 Hz → 10 Hz
- **Thought Stopping:** Frequency 10 Hz → 9 Hz
- **Breathing:** Frequency 9 Hz → 8 Hz
- **Hypnosis:** Frequency 8 Hz → 4 Hz
- **Fantasy Journey:** Frequency 4 Hz → 4 Hz
  - Nature sounds assigned based on journey type:
    - Tibetische_Wanderung → Gebirgsbach
    - Ballonfahrt → Wald (volume: 20)
    - Tropische_Lagune → Wasserfall
    - Schlittenfahrt → Schneesturm
    - Herbstwald → Wald
    - Kristallhöhle → Hoehle
    - Meer → Ozean
- **Affirmation Intro:** Frequency 4 Hz → 4 Hz
- **Affirmations:** Frequency 4 Hz → 2 Hz, variable duration (5-20 min)
- **Silence Phase:** Frequency 2 Hz → 2 Hz, pink noise, 30-60 min duration

**Music:** Deep_Dreaming (random selection)

**Example Preset: "Entspannung" (Relaxation)**
- **Voice:** Flo (Florian)
- **Nature Sound:** Based on selected journey (e.g., Wald for Ballonfahrt)
- **Audio Wave:** Beta (23 Hz) → Alpha (10 Hz) → Theta (6 Hz) → Delta (2 Hz)
- **Music:** Deep_Dreaming
- **Frequency Type:** Monaural

---

### 2. Stress Category

**Default Voice:** Franca

**Session Structure:**
- **Intro Phase:** Frequency 12 Hz → 12 Hz (monaural), 30s fade-in
- **Body Relaxation:** Frequency 12 Hz → 10 Hz
- **Thought Stopping:** Frequency 10 Hz → 8 Hz
- **Hypnosis:** Frequency 8 Hz → 6 Hz
- **Breathing:** Frequency 6 Hz → 6 Hz
- **Regulation/Fantasy:** Frequency 6 Hz → 6 Hz
  - Nature sounds assigned based on journey type
- **Affirmation Intro:** Frequency 6 Hz → 6 Hz
- **Affirmations:** Frequency 6 Hz → 6 Hz, short duration (3-6 min)
- **Exit Phase:** Frequency 6 Hz → 10 Hz, 30s fade-out

**Music:** Peaceful_Ambient (random selection)

**Example Preset: "Stressabbau"**
- **Voice:** Franca (default)
- **Nature Sound:** Optional (based on regulation journey)
- **Audio Wave:** Beta (23 Hz) → Alpha (10 Hz) → Theta (6 Hz)
- **Music:** Peaceful_Ambient
- **Frequency Type:** Monaural

---

### 3. Meditation Category

**Default Voice:** Franca

**Session Structure:**
- **Intro Phase:** Frequency 12 Hz → 12 Hz (monaural), 30s fade-in
- **Body Relaxation:** Frequency 12 Hz → 10 Hz
- **Thought Stopping:** Frequency 10 Hz → 8 Hz
- **Hypnosis:** Frequency 8 Hz → 6 Hz
- **Focus Phase:** Frequency 6 Hz → 4 Hz
- **Affirmations (optional):** Frequency 4 Hz → 10 Hz
- **Silence Phase:** Frequency 4 Hz → 2 Hz, 5-10 min duration
- **Exit Phase:** Frequency 2 Hz → 11 Hz, 30s fade-out

**Music:** Peaceful_Ambient, Deep_Dreaming, or Zen_Garden (random selection)

**Example Preset: "Tiefe Meditation"**
- **Voice:** Marion
- **Nature Sound:** None (or optional)
- **Audio Wave:** Beta (23 Hz) → Alpha (10 Hz) → Theta (6 Hz) → Delta (2 Hz)
- **Music:** Zen_Garden
- **Frequency Type:** Monaural

---

### 4. Leichtigkeit (Lightness/Ease) Category

**Maps to multiple topics in OLD-APP:**
- **Angry** (Wut) - Anger management
- **Sad** (Traurigkeit) - Grief and sadness
- **Depression** - Depression support
- **Trauma** - Trauma healing
- **Belief** - Self-confidence

**Common Structure:**
- **Intro Phase:** Frequency 12 Hz → 12 Hz
- **Body/Thought Stopping:** Frequency 12 Hz → 10 Hz → 8 Hz
- **Hypnosis:** Frequency 8 Hz → 6 Hz → 4 Hz
- **Regulation/Fantasy:** Frequency 4-6 Hz
- **Affirmations:** Frequency 4-6 Hz, variable duration
- **Exit Phase:** Frequency 4-10 Hz → 10-14 Hz

**Music:** Peaceful_Ambient (most cases)

---

## 🎵 Music Library Presets

### Music Categories

1. **Deep_Dreaming**
   - Used for: Sleep, Dream sessions
   - Characteristics: Deep, ambient, sleep-inducing

2. **Peaceful_Ambient**
   - Used for: Stress, Healing, Anger, Depression, Trauma, Belief
   - Characteristics: Calming, peaceful, meditative

3. **Zen_Garden**
   - Used for: Meditation sessions
   - Characteristics: Zen-like, minimalist, focused

4. **Solo_Piano**
   - Used for: Sad/Grief sessions
   - Characteristics: Emotional, comforting, gentle

---

## 🌿 Nature Sounds Library

### Available Nature Sounds

1. **Wald** (Forest)
   - Used with: Ballonfahrt, Herbstwald
   - Volume: 20-50 (default 50)

2. **Ozean** (Ocean)
   - Used with: Meer (beach journey)
   - Volume: 50 (default)

3. **Gebirgsbach** (Mountain Stream)
   - Used with: Tibetische_Wanderung
   - Volume: 50 (default)

4. **Wasserfall** (Waterfall)
   - Used with: Tropische_Lagune
   - Volume: 50 (default)

5. **Schneesturm** (Snowstorm)
   - Used with: Schlittenfahrt
   - Volume: 50 (default)

6. **Hoehle** (Cave)
   - Used with: Kristallhöhle
   - Volume: 50 (default)

7. **Strand** (Beach)
   - Used with: Island fantasies
   - Volume: 50 (default)

---

## 🎤 Voice Options

### Available Voices

1. **Flo** (Florian)
   - Male voice
   - Playtime varies per content (see content-database.js)

2. **Franca**
   - Female voice (default)
   - Playtime varies per content

3. **Marion**
   - Female voice
   - Playtime varies per content

4. **Corinna**
   - Female voice
   - Playtime varies per content

### Voice Selection Logic

- Default: Franca
- User can change voice in session editor
- Voice affects content duration (different playtimes per voice)
- Voice is remembered during session generation (`rememberVoice`)

---

## 📊 Preset Sound Mapping to Current Categories

### Current Category: Schlafen (Sleep)
**OLD-APP Topic:** `sleep`, `dream`

**Preset Configurations:**
- **Voice:** Flo, Franca, Marion, or Corinna
- **Nature Sound:** Based on fantasy journey (Wald, Ozean, Gebirgsbach, etc.)
- **Audio Wave:** Beta (23 Hz) → Alpha (10 Hz) → Theta (6 Hz) → Delta (2 Hz)
- **Music:** Deep_Dreaming
- **Frequency Type:** Monaural
- **Duration:** Variable (can be extended to 8 hours for silence phase)

### Current Category: Stress (Ruhe)
**OLD-APP Topic:** `stress`

**Preset Configurations:**
- **Voice:** Flo, Franca, Marion, or Corinna
- **Nature Sound:** Optional (based on regulation journey)
- **Audio Wave:** Beta (23 Hz) → Alpha (10 Hz) → Theta (6 Hz)
- **Music:** Peaceful_Ambient
- **Frequency Type:** Monaural
- **Duration:** Shorter sessions (no silence phase)

### Current Category: Leichtigkeit (Im Fluss)
**OLD-APP Topics:** `angry`, `sad`, `depression`, `trauma`, `belief`, `healing`

**Preset Configurations:**
- **Voice:** Flo, Franca, Marion, or Corinna
- **Nature Sound:** Optional (based on journey type)
- **Audio Wave:** Beta (23 Hz) → Alpha (10 Hz) → Theta (6 Hz) → Delta (2-4 Hz)
- **Music:** Peaceful_Ambient (most), Solo_Piano (for sad)
- **Frequency Type:** Monaural
- **Duration:** Variable based on topic

---

## 🎯 Example Preset: "Entspannung" (Relaxation)

Based on user requirement, this preset should be configured as:

**Configuration:**
- **Voice:** Flo (Florian)
- **Nature Sound:** Wald (Forest) - or based on selected journey
- **Audio Wave:** Beta (23 Hz) → Alpha (10 Hz) → Theta (6 Hz) → Delta (2 Hz)
- **Music:** Deep_Dreaming or Peaceful_Ambient
- **Frequency Type:** Monaural
- **Category:** Schlafen (Sleep) or Stress

**Session Phases:**
1. Intro (12 Hz → 12 Hz)
2. Body Relaxation (12 Hz → 10 Hz)
3. Thought Stopping (10 Hz → 9 Hz)
4. Breathing (9 Hz → 8 Hz)
5. Hypnosis (8 Hz → 4 Hz)
6. Fantasy/Regulation (4 Hz → 4 Hz) + Nature Sound
7. Affirmations (4 Hz → 2 Hz)
8. Silence (2 Hz → 2 Hz) + Pink Noise

---

## 📁 Audio File Structure

### File Path Format

```
{type}/{category}/{name}/{name}.mp3
{type}/{category}/{name}/{name}_{number}.mp3  (for multiple files)
```

**Types:**
- `text` - Voice/guided meditation files
- `music` - Background music
- `nature` - Nature sounds
- `sound` - Sound effects (bells, chimes, etc.)

**Categories:**
- Text: Einleitung, Atemtechnik, Körperentspannung, Gedankenstille, Traumreise, Hypnose, Affirmation
- Music: Deep_Dreaming, Peaceful_Ambient, Zen_Garden, Solo_Piano
- Nature: Wald, Ozean, Gebirgsbach, Wasserfall, Schneesturm, Hoehle, Strand
- Sound: Glocke, Gong, Klangschale, Alarm, Glockenspiel, etc.

**Voice-Specific Files:**
- Text files include voice in path: `{type}/{category}/{name}/{voice}_{name}.mp3`
- Example: `text/Einleitung/Affirmationen/Flo_Affirmationen.mp3`

---

## 🔄 Session Generation Logic

### Default Session Configuration

```javascript
session[0] = {
  id: "AWAVE-Session",
  name: "Eigene Session",
  infoText: "Bei dieser Session handelt es sich um einen deiner persönlichen Favoriten.",
  duration: 60,  // minutes
  timer: 0,
  voice: "Franca",  // Default voice
  version: 1.3,
  livePhase: 0,
  topic: "user",  // or "sleep", "stress", "meditation", etc.
  type: "guided",  // or "soundscape"
  enableFreq: true  // Frequency generation enabled
}
```

### Phase Configuration

Each phase contains:
- **Text:** Guided meditation content (with voice-specific duration)
- **Music:** Background music track
- **Nature:** Nature sound
- **Sound:** Sound effects (bells, chimes)
- **Noise:** Color noise (white, pink, brown, etc.)
- **Frequency:** Brainwave entrainment settings

---

## 📝 Migration Requirements

### Data to Migrate

1. **Content Database**
   - All text content items with voice-specific playtimes
   - Music tracks and categories
   - Nature sounds and categories
   - Sound effects and categories

2. **Preset Configurations**
   - Frequency presets (Gamma, Beta, Alpha, Theta, Delta)
   - Default frequency type (monaural)
   - Session generation templates per topic

3. **Audio Files**
   - All voice-specific audio files
   - Music tracks
   - Nature sounds
   - Sound effects

4. **Voice Options**
   - Flo (Florian)
   - Franca
   - Marion
   - Corinna

### Mapping to Current App

**Current Categories:**
- Schlafen → OLD-APP: `sleep`, `dream`
- Stress (Ruhe) → OLD-APP: `stress`
- Leichtigkeit (Im Fluss) → OLD-APP: `angry`, `sad`, `depression`, `trauma`, `belief`, `healing`

**Preset Sound Structure:**
- Each preset should include: Voice, Nature Sound, Music, Frequency Settings
- Presets should be selectable per category
- Presets should be customizable by users

---

## 🔗 Related Features

- [Content Database](../Content%20Database/)
- [Frequency Generation System](../Frequency%20Generation%20System/)
- [Multi-Phase Session System](../Multi-Phase%20Session%20System/)
- [Multiple Voice Options](../Multiple%20Voice%20Options/)

---

## 📚 Source Code References

- **Content Database:** `src/js/content-database.js` (1926 lines)
- **Session Generator:** `src/js/generator-session-content.js`
- **Frequency Presets:** `src/js/content-database.js` (lines 946-952)
- **Voice Options:** `src/js/main.js` (line 53)
- **Default Session:** `src/js/session-object.js` (line 2)

---

## 📝 Notes

- Preset sounds are dynamically generated based on topic selection
- Voice selection affects content duration (different playtimes per voice)
- Nature sounds are automatically assigned based on fantasy journey type
- Frequency settings follow a progression pattern (Beta → Alpha → Theta → Delta)
- Music selection is randomized from available tracks per category
- All presets use monaural frequency type by default
- Pro mode required for frequency generation (`enableFreq: true`)

---

*Migration Priority: High*
*Estimated Complexity: Medium*
*Dependencies: Content Database, Frequency Generation, Audio Services*
