# Preset Sounds Library - Category Mapping

This document maps OLD-APP (V.1) preset configurations to current React Native app categories.

## 📊 Category Mapping Overview

| Current Category | OLD-APP Topics | Description |
|-----------------|----------------|-------------|
| **Schlafen** | `sleep`, `dream` | Sleep and dream-related sessions |
| **Stress (Ruhe)** | `stress` | Stress relief and relaxation |
| **Leichtigkeit (Im Fluss)** | `angry`, `sad`, `depression`, `trauma`, `belief`, `healing` | Emotional regulation and personal growth |

---

## 🛏️ Schlafen (Sleep) Category

### OLD-APP Topics: `sleep`, `dream`

### Default Configuration
- **Voice:** Franca (default, can be Flo, Marion, or Corinna)
- **Music:** Deep_Dreaming
- **Frequency Type:** Monaural
- **Frequency Progression:** 12 Hz → 10 Hz → 9 Hz → 8 Hz → 4 Hz → 2 Hz

### Preset Examples

#### 1. "Entspannung" (Relaxation)
- **Voice:** Flo (Florian)
- **Nature Sound:** Wald (Forest) - or auto-assigned based on journey
- **Music:** Deep_Dreaming
- **Frequency:** Beta (23 Hz) → Alpha (10 Hz) → Theta (6 Hz) → Delta (2 Hz)
- **Session Phases:**
  1. Intro (12 Hz → 12 Hz, 30s fade-in)
  2. Body Relaxation (12 Hz → 10 Hz)
  3. Thought Stopping (10 Hz → 9 Hz)
  4. Breathing (9 Hz → 8 Hz)
  5. Hypnosis (8 Hz → 4 Hz)
  6. Fantasy Journey (4 Hz → 4 Hz) + Nature Sound
  7. Affirmation Intro (4 Hz → 4 Hz)
  8. Affirmations (4 Hz → 2 Hz, 5-20 min)
  9. Silence (2 Hz → 2 Hz) + Pink Noise (30-60 min)

#### 2. "Tiefer Schlaf" (Deep Sleep)
- **Voice:** Franca
- **Nature Sound:** Ozean (Ocean)
- **Music:** Deep_Dreaming
- **Frequency:** Alpha (10 Hz) → Theta (6 Hz) → Delta (2 Hz)
- **Session Phases:** Similar to Entspannung, optimized for deep sleep

#### 3. "Schöne Träume" (Beautiful Dreams)
- **Voice:** Marion
- **Nature Sound:** Based on dream journey
- **Music:** Deep_Dreaming
- **Frequency:** 12 Hz → 10 Hz → 8 Hz → 7 Hz → 6 Hz → 25 Hz (affirmations)
- **Session Phases:** Dream-focused with longer fantasy phase

---

## 😌 Stress (Ruhe) Category

### OLD-APP Topic: `stress`

### Default Configuration
- **Voice:** Franca (default, can be Flo, Marion, or Corinna)
- **Music:** Peaceful_Ambient
- **Frequency Type:** Monaural
- **Frequency Progression:** 12 Hz → 10 Hz → 8 Hz → 6 Hz

### Preset Examples

#### 1. "Stressabbau" (Stress Relief)
- **Voice:** Franca
- **Nature Sound:** Optional (based on regulation journey)
- **Music:** Peaceful_Ambient
- **Frequency:** Beta (23 Hz) → Alpha (10 Hz) → Theta (6 Hz)
- **Session Phases:**
  1. Intro (12 Hz → 12 Hz, 30s fade-in)
  2. Body Relaxation (12 Hz → 10 Hz)
  3. Thought Stopping (10 Hz → 8 Hz)
  4. Hypnosis (8 Hz → 6 Hz)
  5. Breathing (6 Hz → 6 Hz)
  6. Regulation/Fantasy (6 Hz → 6 Hz) + Optional Nature
  7. Affirmation Intro (6 Hz → 6 Hz)
  8. Affirmations (6 Hz → 6 Hz, 3-6 min)
  9. Exit (6 Hz → 10 Hz, 30s fade-out)

#### 2. "Gelassenheit" (Serenity)
- **Voice:** Marion
- **Nature Sound:** Wald (Forest)
- **Music:** Peaceful_Ambient
- **Frequency:** Alpha (10 Hz) → Theta (6 Hz)
- **Session Phases:** Shorter, focused on calm

---

## 🌊 Leichtigkeit (Im Fluss) Category

### OLD-APP Topics: `angry`, `sad`, `depression`, `trauma`, `belief`, `healing`

### Default Configuration
- **Voice:** Franca (default, can be Flo, Marion, or Corinna)
- **Music:** Peaceful_Ambient (most), Solo_Piano (for sad)
- **Frequency Type:** Monaural
- **Frequency Progression:** Varies by sub-topic

### Preset Examples by Sub-Topic

#### 1. "Weniger Angst" (Less Fear) - `trauma`
- **Voice:** Flo
- **Nature Sound:** Optional
- **Music:** Peaceful_Ambient
- **Frequency:** 12 Hz → 10 Hz → 9 Hz → 7 Hz → 6 Hz → 4 Hz
- **Session Phases:**
  1. Intro (12 Hz → 12 Hz, 30s fade-in)
  2. Body Relaxation (12 Hz → 10 Hz)
  3. Thought Stopping (10 Hz → 9 Hz)
  4. Hypnosis (9 Hz → 7 Hz)
  5. Fantasy (7 Hz → 6 Hz) + Optional Nature
  6. Breathing (6 Hz → 6 Hz)
  7. Regulation (4 Hz → 4 Hz)
  8. Affirmations (4 Hz → 4 Hz, 5-10 min)
  9. Exit (4 Hz → 10 Hz, 30s fade-out)

#### 2. "Weniger Wut" (Less Anger) - `angry`
- **Voice:** Franca
- **Nature Sound:** Optional
- **Music:** Peaceful_Ambient
- **Frequency:** 12 Hz → 10 Hz → 8 Hz → 8 Hz → 5 Hz → 5 Hz
- **Session Phases:**
  1. Thought Stopping (12 Hz → 10 Hz, 30s fade-in)
  2. Body Relaxation (10 Hz → 8 Hz)
  3. Breathing (8 Hz → 8 Hz)
  4. Hypnosis (8 Hz → 5 Hz)
  5. Regulation (5 Hz → 5 Hz)
  6. Affirmation Intro (5 Hz → 5 Hz)
  7. Affirmations (5 Hz → 5 Hz, 5-10 min)
  8. Exit (5 Hz → 9 Hz, 30s fade-out)

#### 3. "Weniger Traurigkeit" (Less Sadness) - `sad`
- **Voice:** Corinna
- **Nature Sound:** Optional
- **Music:** Solo_Piano (volume: 40)
- **Frequency:** 12 Hz → 9 Hz → 6 Hz
- **Session Phases:**
  1. Comfort Intro (12 Hz → 9 Hz, 30s fade-in) + Solo_Piano
  2. Comfort Phase (6 Hz → 6 Hz, 5-10 min) + Solo_Piano
  OR
  1. Intro (12 Hz → 9 Hz, 30s fade-in)
  2. Regulation (9 Hz → 6 Hz)
  3. Affirmation Intro (6 Hz → 6 Hz)
  4. Affirmations (6 Hz → 6 Hz, 5-10 min)
  5. Exit (6 Hz → 10 Hz, 30s fade-out)

#### 4. "Mehr Leichtigkeit" (More Lightness) - `healing`, `belief`
- **Voice:** Marion
- **Nature Sound:** Optional
- **Music:** Peaceful_Ambient
- **Frequency:** 12 Hz → 10 Hz → 8 Hz → 6 Hz → 4 Hz → 3 Hz
- **Session Phases:**
  1. Intro (12 Hz → 12 Hz, 30s fade-in)
  2. Body Relaxation (12 Hz → 10 Hz)
  3. Thought Stopping (10 Hz → 8 Hz)
  4. Hypnosis (8 Hz → 6 Hz)
  5. Breathing (6 Hz → 6 Hz)
  6. Fantasy/Regulation (6 Hz → 4 Hz → 3 Hz) + Optional Nature
  7. Affirmation Intro (3 Hz → 3 Hz)
  8. Affirmations (3 Hz → 3 Hz, 5-10 min)
  9. Exit (3 Hz → 10 Hz, 30s fade-out)

---

## 🧘 Meditation Category

### OLD-APP Topic: `meditation`

### Default Configuration
- **Voice:** Franca (default, can be Flo, Marion, or Corinna)
- **Music:** Peaceful_Ambient, Deep_Dreaming, or Zen_Garden (random)
- **Frequency Type:** Monaural
- **Frequency Progression:** 12 Hz → 10 Hz → 8 Hz → 6 Hz → 4 Hz → 2 Hz

### Preset Examples

#### 1. "Tiefe Meditation" (Deep Meditation)
- **Voice:** Marion
- **Nature Sound:** Optional
- **Music:** Zen_Garden
- **Frequency:** Beta (23 Hz) → Alpha (10 Hz) → Theta (6 Hz) → Delta (2 Hz)
- **Session Phases:**
  1. Intro (12 Hz → 12 Hz, 30s fade-in)
  2. Body Relaxation (12 Hz → 10 Hz)
  3. Thought Stopping (10 Hz → 8 Hz)
  4. Hypnosis (8 Hz → 6 Hz)
  5. Focus (6 Hz → 4 Hz)
  6. Affirmations (optional, 4 Hz → 10 Hz, 5-10 min)
  7. Silence (4 Hz → 2 Hz, 5-10 min)
  8. Exit (2 Hz → 11 Hz, 30s fade-out)

#### 2. "Achtsamkeit" (Mindfulness)
- **Voice:** Franca
- **Nature Sound:** None
- **Music:** Zen_Garden
- **Frequency:** Alpha (10 Hz) → Theta (6 Hz)
- **Session Phases:** Focused on awareness and presence

---

## 🎵 Music Category Mapping

| Music Category | Used In | Characteristics |
|----------------|---------|----------------|
| **Deep_Dreaming** | Schlafen, Dream | Deep, ambient, sleep-inducing |
| **Peaceful_Ambient** | Stress, Healing, Anger, Depression, Trauma, Belief | Calming, peaceful, meditative |
| **Zen_Garden** | Meditation | Zen-like, minimalist, focused |
| **Solo_Piano** | Sad, Grief | Emotional, comforting, gentle |

---

## 🌿 Nature Sound Mapping

| Nature Sound | Used With | Volume |
|--------------|-----------|--------|
| **Wald** (Forest) | Ballonfahrt, Herbstwald | 20-50 (default 50) |
| **Ozean** (Ocean) | Meer (beach journey) | 50 (default) |
| **Gebirgsbach** (Mountain Stream) | Tibetische_Wanderung | 50 (default) |
| **Wasserfall** (Waterfall) | Tropische_Lagune | 50 (default) |
| **Schneesturm** (Snowstorm) | Schlittenfahrt | 50 (default) |
| **Hoehle** (Cave) | Kristallhöhle | 50 (default) |
| **Strand** (Beach) | Island fantasies | 50 (default) |

---

## 🎤 Voice Mapping

| Voice | Gender | Default For | Characteristics |
|-------|--------|-------------|-----------------|
| **Flo** (Florian) | Male | Custom/Entspannung | Deep, calming |
| **Franca** | Female | Default | Warm, soothing |
| **Marion** | Female | Meditation/Leichtigkeit | Clear, gentle |
| **Corinna** | Female | Sad/Grief | Comforting, empathetic |

---

## 📋 Complete Preset List

### Schlafen (Sleep) Presets
1. Entspannung (Flo, Wald, Deep_Dreaming, Beta→Alpha→Theta→Delta)
2. Tiefer Schlaf (Franca, Ozean, Deep_Dreaming, Alpha→Theta→Delta)
3. Schöne Träume (Marion, Journey-based, Deep_Dreaming, 12→10→8→7→6→25)
4. Einschlafen (Any voice, Optional nature, Deep_Dreaming, Beta→Delta)

### Stress (Ruhe) Presets
1. Stressabbau (Franca, Optional, Peaceful_Ambient, Beta→Alpha→Theta)
2. Gelassenheit (Marion, Wald, Peaceful_Ambient, Alpha→Theta)
3. Innere Ruhe (Any voice, Optional, Peaceful_Ambient, Beta→Alpha)
4. Runterkommen (Any voice, Optional, Peaceful_Ambient, Beta→Theta)

### Leichtigkeit (Im Fluss) Presets
1. Weniger Angst (Flo, Optional, Peaceful_Ambient, 12→10→9→7→6→4)
2. Weniger Wut (Franca, Optional, Peaceful_Ambient, 12→10→8→5)
3. Weniger Traurigkeit (Corinna, Optional, Solo_Piano, 12→9→6)
4. Mehr Leichtigkeit (Marion, Optional, Peaceful_Ambient, 12→10→8→6→4→3)
5. Selbstvertrauen (Any voice, Optional, Peaceful_Ambient, 12→10→9→8→6→4)
6. Heilung (Any voice, Optional, Peaceful_Ambient, 12→10→8→6→4→3)

### Meditation Presets
1. Tiefe Meditation (Marion, Optional, Zen_Garden, Beta→Alpha→Theta→Delta)
2. Achtsamkeit (Franca, None, Zen_Garden, Alpha→Theta)
3. Gedankenstille (Any voice, None, Zen_Garden, 10→8)

---

## 🔄 Migration Mapping

### Current App → OLD-APP Mapping

**Current Category: Schlafen**
- Maps to: `sleep`, `dream` topics
- Default presets: Entspannung, Tiefer Schlaf, Schöne Träume
- Music: Deep_Dreaming
- Frequency: Beta → Alpha → Theta → Delta

**Current Category: Stress (Ruhe)**
- Maps to: `stress` topic
- Default presets: Stressabbau, Gelassenheit
- Music: Peaceful_Ambient
- Frequency: Beta → Alpha → Theta

**Current Category: Leichtigkeit (Im Fluss)**
- Maps to: `angry`, `sad`, `depression`, `trauma`, `belief`, `healing` topics
- Default presets: Weniger Angst, Weniger Wut, Weniger Traurigkeit, Mehr Leichtigkeit
- Music: Peaceful_Ambient (most), Solo_Piano (for sad)
- Frequency: Varies by sub-topic

---

## 📝 Implementation Notes

1. **Preset Selection:** Users should be able to select presets from category screens
2. **Customization:** All presets should be customizable (voice, nature, music, frequency)
3. **Auto-Assignment:** Nature sounds can be auto-assigned based on journey type
4. **Voice Duration:** Voice selection affects content duration (different playtimes)
5. **Frequency Progression:** Frequency settings follow brainwave entrainment principles
6. **Music Randomization:** Music can be randomized from category or manually selected

---

*Last Updated: 2025-01-27*
