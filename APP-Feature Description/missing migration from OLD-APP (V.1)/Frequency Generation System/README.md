# Frequency Generation System - Feature Documentation

**Feature Name:** Frequency Generation System  
**Status:** ⚪ Missing - Needs Migration  
**Priority:** High  
**Source:** OLD-APP (V.1)  
**Last Updated:** 2025-01-27

## 📋 Feature Overview

The Frequency Generation System creates various types of audio frequencies and beats for brainwave entrainment, including binaural beats, monaural beats, isochronic tones, bilateral stimulation, and advanced wave patterns.

### Description

The system generates frequencies using Web Audio API (in OLD-APP) or native audio generation (for React Native). It supports multiple frequency types with configurable parameters like pulse frequency, root frequency, sweep direction, and volume control.

### User Value

- **Brainwave Entrainment:** Helps users achieve desired mental states (relaxation, focus, sleep)
- **Customizable Frequencies:** Users can fine-tune frequency parameters
- **Multiple Types:** Supports various frequency generation methods
- **Smooth Transitions:** Automatic frequency sweeps for gradual state changes

---

## 🎯 Functional Requirements

### Core Requirements

#### Frequency Types
- [ ] Root frequency (single tone)
- [ ] Binaural beats (different frequencies in each ear)
- [ ] Monaural beats (same frequency in both ears)
- [ ] Isochronic tones (pulsing tones)
- [ ] Bilateral stimulation (alternating left/right)
- [ ] Advanced wave patterns (Shepard tone, flow patterns)

#### Frequency Parameters
- [ ] Pulse frequency (Hz) - beats per second
- [ ] Root frequency (Hz) - base frequency
- [ ] Start pulse frequency
- [ ] Target pulse frequency
- [ ] Start root frequency
- [ ] Target root frequency
- [ ] Sweep direction (up, down, consistent)
- [ ] Volume control (0-100)
- [ ] Fade in/out duration

#### Preset Frequencies
- [ ] Gamma preset (44 Hz) - high focus
- [ ] Beta preset (23 Hz) - active thinking
- [ ] Alpha preset (10 Hz) - relaxed awareness
- [ ] Theta preset (6 Hz) - deep meditation
- [ ] Delta preset (2 Hz) - deep sleep

**Klangwelten (Swift app):** Slot 2 (Frequenzen) in the Klangwelten sound drawer is implemented with these six presets (Alpha, Theta, Delta, Beta, Gamma, Stille/Silence). See `draft/PROPOSAL-KLANGWELTEN-FREQUENCY-DRAWER-OLD-APP-PARITY.md` and `AWAVE/Features/Klangwelten/FrequencyPresets.swift`.

### User Stories

- As a user, I want to add binaural beats to my session so that I can enhance my meditation experience
- As a user, I want to use preset frequencies so that I can quickly set up brainwave entrainment
- As a user, I want frequency sweeps so that my brain gradually transitions between states
- As a user, I want to control frequency volume so that it doesn't overpower other audio

### Acceptance Criteria

- [ ] All frequency types are supported
- [ ] Frequency generation is smooth and artifact-free
- [ ] Volume control works independently
- [ ] Frequency sweeps transition smoothly
- [ ] Presets apply correct parameters
- [ ] Multiple frequencies can play simultaneously

---

## 🏗️ Technical Specification

### Source Code Reference (OLD-APP)

**File:** `src/js/generator-frequency-noise.js`

```javascript
// Frequency types supported
session[phase].frequency.content = 
  "root" || "binaural" || "monaural" || "isochronic" || 
  "bilateral" || "molateral" || "shepard" || "isoflow" || 
  "bilawave" || "binawave" || "monawave" || "flowlateral"

// Frequency structure
function Frequency(content, volume, fadeIn, fadeOut, direction, 
                   startPulsFreq, targetPulsFreq, startRootFreq, 
                   targetRootFreq, ctx, osc, gainCH, pulsGain, 
                   pulsGainL, pulsGainR, merger, gain) {
  this.content = content;
  this.volume = volume;
  this.fadeIn = fadeIn;
  this.fadeOut = fadeOut;
  this.direction = direction;
  this.startPulsFreq = startPulsFreq;
  this.targetPulsFreq = targetPulsFreq;
  this.startRootFreq = startRootFreq;
  this.targetRootFreq = targetRootFreq;
  // Audio context objects
  this.ctx = ctx;
  this.osc = osc;
  this.gainCH = gainCH;
  this.pulsGain = pulsGain;
  this.pulsGainL = pulsGainL;
  this.pulsGainR = pulsGainR;
  this.merger = merger;
  this.gain = gain;
}
```

### Components Needed

- `FrequencyControls.tsx` - Frequency type and parameter controls
- `FrequencyPresets.tsx` - Preset frequency selector
- `FrequencyVisualization.tsx` - Visual representation of frequency
- `FrequencySlider.tsx` - Parameter adjustment sliders

### Services Needed

- `SoundGenerationService.ts` - Already exists, needs frequency extension
- `FrequencyGeneratorService.ts` - New native service for frequency generation
- `BinauralBeatsService.ts` - Binaural beat generation
- `IsochronicTonesService.ts` - Isochronic tone generation

### Hooks Needed

- `useFrequencyGenerator.ts` - Frequency generation hook
- `useFrequencyPresets.ts` - Preset management hook
- `useFrequencyControls.ts` - Control interface hook

### Data Models

```typescript
type FrequencyType = 
  | "root" 
  | "binaural" 
  | "monaural" 
  | "isochronic" 
  | "bilateral" 
  | "molateral" 
  | "shepard" 
  | "isoflow" 
  | "bilawave" 
  | "binawave" 
  | "monawave" 
  | "flowlateral";

interface FrequencyConfig {
  type: FrequencyType;
  volume: number; // 0-100
  fadeIn?: number; // seconds
  fadeOut?: number; // seconds
  direction: "up" | "down" | "consistent";
  startPulsFreq: number; // Hz
  targetPulsFreq: number; // Hz
  startRootFreq: number; // Hz
  targetRootFreq: number; // Hz
}

interface FrequencyPreset {
  name: string;
  pulseFreq: number;
  rootFreq: number;
  type: FrequencyType;
  description: string;
}
```

### Native Module Requirements

For React Native, frequency generation requires native modules:

**iOS:**
- AVFoundation for audio generation
- AudioUnit framework for real-time audio processing

**Android:**
- AudioTrack or OpenSL ES for audio generation
- Native audio processing

---

## 🔄 User Flows

### Primary Flow: Add Frequency to Phase

1. User opens phase editor
2. User selects frequency tab
3. User chooses frequency type
4. User sets parameters (or selects preset)
5. User adjusts volume
6. User saves phase
7. System generates frequency during playback

### Alternative Flow: Use Preset

1. User opens frequency controls
2. User selects preset (e.g., Alpha)
3. System applies preset parameters
4. User can adjust volume if needed
5. User saves

---

## 🎨 UI/UX Specifications

### Visual Design

- Frequency type selector (dropdown or buttons)
- Parameter sliders for fine-tuning
- Preset buttons with visual indicators
- Frequency visualization (waveform or spectrum)
- Volume control slider

### Interactions

- Tap to select frequency type
- Drag sliders for parameter adjustment
- Tap preset to apply
- Long press preset for details

### Platform-Specific Notes

- **iOS:** Use native audio generation APIs
- **Android:** Use AudioTrack or OpenSL ES

---

## 📱 Platform Compatibility

- **iOS:** ❌ Not Supported - Needs native implementation
- **Android:** ❌ Not Supported - Needs native implementation

### Version Requirements

- iOS: 13.0+ (for AVFoundation)
- Android: API 21+ (for AudioTrack)

---

## 🔗 Related Features

- [Multi-Phase Session System](../Multi-Phase%20Session%20System/)
- [Noise Generation System](../Noise%20Generation%20System/)
- [Preset Frequency Settings](../Preset%20Frequency%20Settings/)
- [Major Audioplayer](../../Major%20Audioplayer/)

---

## 📚 Additional Resources

- OLD-APP Source: `src/js/generator-frequency-noise.js`
- Current Implementation: `src/services/SoundGenerationService.ts` (partial)
- Web Audio API Documentation
- React Native Audio Libraries

---

## 📝 Notes

- Frequency generation is computationally intensive
- Requires native implementation for React Native (Web Audio API not available)
- Consider using existing libraries like `react-native-audio` or custom native modules
- Performance optimization critical for smooth playback
- Battery consumption should be monitored

---

*Migration Priority: High*
*Estimated Complexity: Very High*
*Dependencies: Native Audio Modules, Audio Services*
