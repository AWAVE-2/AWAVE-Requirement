# Preset Sounds Library - Functional Requirements

## 📋 Core Requirements

### 1. Preset Sound Structure

#### Preset Definition
- [ ] Each preset must include:
  - Voice selection (Flo, Franca, Marion, Corinna)
  - Nature sound (optional, based on category/journey)
  - Music track (Deep_Dreaming, Peaceful_Ambient, Zen_Garden, Solo_Piano)
  - Frequency settings (start/target pulse frequency, root frequency)
  - Frequency type (monaural, binaural, isochronic, etc.)
  - Audio wave progression (Beta → Alpha → Theta → Delta)

#### Preset Categories
- [ ] Schlafen (Sleep) presets
- [ ] Stress (Ruhe) presets
- [ ] Leichtigkeit (Im Fluss) presets
- [ ] Meditation presets

### 2. Voice Options

#### Available Voices
- [ ] Flo (Florian) - Male voice
- [ ] Franca - Female voice (default)
- [ ] Marion - Female voice
- [ ] Corinna - Female voice

#### Voice Functionality
- [ ] Voice selection affects content duration
- [ ] Voice-specific audio files must be loaded
- [ ] Voice can be changed per session
- [ ] Voice preference can be saved

### 3. Nature Sounds

#### Available Nature Sounds
- [ ] Wald (Forest)
- [ ] Ozean (Ocean)
- [ ] Gebirgsbach (Mountain Stream)
- [ ] Wasserfall (Waterfall)
- [ ] Schneesturm (Snowstorm)
- [ ] Hoehle (Cave)
- [ ] Strand (Beach)

#### Nature Sound Assignment
- [ ] Automatic assignment based on fantasy journey type
- [ ] Manual selection available
- [ ] Volume control (0-100)
- [ ] Fade in/out support

### 4. Music Tracks

#### Available Music Categories
- [ ] Deep_Dreaming - For sleep/dream sessions
- [ ] Peaceful_Ambient - For stress/healing sessions
- [ ] Zen_Garden - For meditation sessions
- [ ] Solo_Piano - For grief/sad sessions

#### Music Functionality
- [ ] Random selection from category
- [ ] Manual selection available
- [ ] Volume control (0-100)
- [ ] Fade in/out support
- [ ] Loop support

### 5. Frequency Settings

#### Frequency Presets
- [ ] Gamma: 44 Hz (high focus)
- [ ] Beta: 23 Hz (active thinking)
- [ ] Alpha: 10 Hz (relaxed awareness)
- [ ] Theta: 6 Hz (deep meditation)
- [ ] Delta: 2 Hz (deep sleep)

#### Frequency Progression
- [ ] Schlafen: 12 Hz → 10 Hz → 9 Hz → 8 Hz → 4 Hz → 2 Hz
- [ ] Stress: 12 Hz → 10 Hz → 8 Hz → 6 Hz
- [ ] Meditation: 12 Hz → 10 Hz → 8 Hz → 6 Hz → 4 Hz → 2 Hz
- [ ] Leichtigkeit: 12 Hz → 10 Hz → 8 Hz → 6 Hz → 4 Hz

### 6. Category-Specific Presets

#### Schlafen (Sleep) Presets
- [ ] "Entspannung" (Relaxation)
  - Voice: Flo (Florian)
  - Nature: Wald (or based on journey)
  - Music: Deep_Dreaming
  - Frequency: Beta (23 Hz) → Alpha (10 Hz) → Theta (6 Hz) → Delta (2 Hz)
  - Type: Monaural

- [ ] "Tiefer Schlaf" (Deep Sleep)
  - Voice: Franca (default)
  - Nature: Ozean
  - Music: Deep_Dreaming
  - Frequency: Alpha (10 Hz) → Theta (6 Hz) → Delta (2 Hz)
  - Type: Monaural

#### Stress (Ruhe) Presets
- [ ] "Stressabbau" (Stress Relief)
  - Voice: Franca
  - Nature: Optional
  - Music: Peaceful_Ambient
  - Frequency: Beta (23 Hz) → Alpha (10 Hz) → Theta (6 Hz)
  - Type: Monaural

- [ ] "Gelassenheit" (Serenity)
  - Voice: Marion
  - Nature: Wald
  - Music: Peaceful_Ambient
  - Frequency: Alpha (10 Hz) → Theta (6 Hz)
  - Type: Monaural

#### Leichtigkeit (Im Fluss) Presets
- [ ] "Weniger Angst" (Less Fear)
  - Voice: Flo
  - Nature: Optional
  - Music: Peaceful_Ambient
  - Frequency: Beta (23 Hz) → Alpha (10 Hz) → Theta (6 Hz) → Delta (4 Hz)
  - Type: Monaural

- [ ] "Weniger Wut" (Less Anger)
  - Voice: Franca
  - Nature: Optional
  - Music: Peaceful_Ambient
  - Frequency: Beta (23 Hz) → Alpha (10 Hz) → Theta (6 Hz)
  - Type: Monaural

- [ ] "Weniger Traurigkeit" (Less Sadness)
  - Voice: Corinna
  - Nature: Optional
  - Music: Solo_Piano
  - Frequency: Alpha (10 Hz) → Theta (6 Hz)
  - Type: Monaural

- [ ] "Mehr Leichtigkeit" (More Lightness)
  - Voice: Marion
  - Nature: Optional
  - Music: Peaceful_Ambient
  - Frequency: Theta (6 Hz) → Alpha (10 Hz)
  - Type: Monaural

#### Meditation Presets
- [ ] "Tiefe Meditation" (Deep Meditation)
  - Voice: Marion
  - Nature: Optional
  - Music: Zen_Garden
  - Frequency: Beta (23 Hz) → Alpha (10 Hz) → Theta (6 Hz) → Delta (2 Hz)
  - Type: Monaural

- [ ] "Achtsamkeit" (Mindfulness)
  - Voice: Franca
  - Nature: None
  - Music: Zen_Garden
  - Frequency: Alpha (10 Hz) → Theta (6 Hz)
  - Type: Monaural

### 7. Audio File Management

#### File Structure
- [ ] Voice-specific text files: `text/{category}/{name}/{voice}_{name}.mp3`
- [ ] Music files: `music/{category}/{name}/{name}.mp3`
- [ ] Nature files: `nature/{category}/{name}/{name}.mp3`
- [ ] Sound effect files: `sound/{category}/{name}/{name}.mp3`

#### File Loading
- [ ] Lazy loading of audio files
- [ ] Caching of frequently used files
- [ ] Preloading of preset files
- [ ] Error handling for missing files

### 8. Preset Selection UI

#### Preset Browser
- [ ] List of available presets per category
- [ ] Preset preview (voice, nature, music, frequency)
- [ ] Quick selection buttons
- [ ] Custom preset creation

#### Preset Details
- [ ] Display all preset components
- [ ] Show frequency progression
- [ ] Show estimated duration
- [ ] Show voice options

### 9. Preset Customization

#### Custom Presets
- [ ] Users can create custom presets
- [ ] Save custom presets to favorites
- [ ] Share custom presets
- [ ] Edit existing presets

#### Preset Modification
- [ ] Change voice
- [ ] Change nature sound
- [ ] Change music track
- [ ] Adjust frequency settings
- [ ] Adjust volume levels

---

## 🎯 User Stories

- As a user, I want to select a preset sound for "Entspannung" so that I can quickly start a relaxation session
- As a user, I want to see which voice, nature sound, and frequency settings are in a preset so that I know what I'm selecting
- As a user, I want to change the voice in a preset so that I can use my preferred voice
- As a user, I want presets organized by category so that I can find relevant presets quickly
- As a user, I want to create custom presets so that I can save my favorite combinations

---

## ✅ Acceptance Criteria

- [ ] All presets from OLD-APP are available
- [ ] Presets are organized by category (Schlafen, Stress, Leichtigkeit)
- [ ] Each preset shows voice, nature sound, music, and frequency settings
- [ ] Users can select and use presets immediately
- [ ] Presets can be customized
- [ ] Custom presets can be saved
- [ ] Audio files load correctly for each preset
- [ ] Voice selection works for all presets
- [ ] Frequency settings apply correctly
- [ ] Nature sounds and music play as configured

---

## 📝 Notes

- Preset configurations are based on OLD-APP session generation logic
- Frequency progressions follow brainwave entrainment principles
- Voice selection affects content duration (different playtimes per voice)
- Nature sounds are automatically assigned based on fantasy journey type
- Music selection can be randomized or manual
- All presets use monaural frequency type by default
- Pro mode may be required for frequency generation

---

*Last Updated: 2025-01-27*
