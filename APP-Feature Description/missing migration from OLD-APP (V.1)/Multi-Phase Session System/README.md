# Multi-Phase Session System - Feature Documentation

**Feature Name:** Multi-Phase Session System  
**Status:** ⚪ Missing - Needs Migration  
**Priority:** High  
**Source:** OLD-APP (V.1)  
**Last Updated:** 2025-01-27

## 📋 Feature Overview

The Multi-Phase Session System allows users to create and manage complex meditation/audio sessions with multiple phases. Each phase can contain different audio elements (text/voiceover, music, nature sounds, sound effects, noise, and frequency generation) with individual timing, volume, and fade controls.

### Description

In OLD-APP (V.1), sessions are structured as arrays where:
- `session[0]` contains session configuration (name, duration, voice, topic, type, etc.)
- `session[1..n]` contains individual phases, each with:
  - Duration (seconds)
  - Text/voiceover content
  - Music background
  - Nature sounds
  - Sound effects
  - Noise (white, pink, brown, etc.)
  - Frequency/beats (binaural, monaural, isochronic, etc.)

### User Value

- **Flexible Session Creation:** Users can create complex, multi-phase meditation sessions
- **Precise Control:** Each phase can have different audio elements and timing
- **Professional Quality:** Supports advanced audio mixing and transitions
- **Session Sharing:** Sessions can be exported and shared as .awave files

---

## 🎯 Functional Requirements

### Core Requirements

#### Session Structure
- [ ] Session configuration object (session[0]) with metadata
- [ ] Multiple phase objects (session[1..n]) with audio elements
- [ ] Phase management (add, delete, reorder phases)
- [ ] Phase duration configuration
- [ ] Phase naming and descriptions

#### Audio Elements per Phase
- [ ] Text/voiceover content with volume, fade in/out, delays
- [ ] Music background with volume, fade in/out
- [ ] Nature sounds with volume, fade in/out
- [ ] Sound effects with volume and interval
- [ ] Noise generation (white, pink, brown, grey, blue, violet)
- [ ] Frequency generation (binaural, monaural, isochronic, etc.)

#### Phase Management
- [ ] Add new phase
- [ ] Delete phase
- [ ] Reorder phases (move before/after)
- [ ] Duplicate phase
- [ ] Edit phase properties

#### Session Playback
- [ ] Sequential phase playback
- [ ] Automatic phase transitions
- [ ] Phase timing and synchronization
- [ ] Live phase indicator
- [ ] Phase completion tracking

### User Stories

- As a user, I want to create a multi-phase meditation session so that I can have a structured meditation experience
- As a user, I want to add multiple phases to my session so that I can create complex audio journeys
- As a user, I want to reorder phases so that I can customize the flow of my session
- As a user, I want to set different durations for each phase so that I can control the pacing

### Acceptance Criteria

- [ ] Users can create sessions with multiple phases
- [ ] Each phase can have independent audio elements
- [ ] Phases play sequentially in order
- [ ] Phase transitions are smooth with fade in/out
- [ ] Session structure is saved and can be loaded
- [ ] Sessions can be exported and imported

---

## 🏗️ Technical Specification

### Source Code Reference (OLD-APP)

**File:** `src/js/session-object.js`

```javascript
// Session structure
var session = [{
  id: "AWAVE-Session",
  name: "Eigene Session",
  infoText: "Bei dieser Session handelt es sich um einen deiner persönlichen Favoriten.",
  duration: 60,
  timer: 0,
  voice: "Franca",
  version: version,
  livePhase: 0,
  topic: "user",
  type: "guided",
  enableFreq: true
}];

// Phase structure
function sessionPhase(name, h1, h2, duration, sleepCheck, text, music, nature, sound, noise, frequency) {
  this.name = name;
  this.h1 = h1;
  this.h2 = h2;
  this.duration = duration;
  this.sleepCheck = sleepCheck;
  this.text = new Text("noText", 50, 0, 0, 0, 0, 0, 0, "mute");
  this.music = new Music("noMusic", 50, 0, 0, "mute");
  this.nature = new Nature("noNature", 50, 0, 0, "mute");
  this.sound = new Sound("noSound", 50, 0);
  this.noise = new Noise("noNoise", 50, 0, 0, 0, 0, null, [], [], null, null, null, null, null, null, null);
  this.frequency = new Frequency("noFreq", 50, 0, 0, "down", 12, 12, 216, 216, null, [], [], null, null, null, null, null, "on");
}
```

### Components Needed

- `SessionEditor.tsx` - Main session editing interface
- `PhaseList.tsx` - List of phases in session
- `PhaseEditor.tsx` - Individual phase editing
- `PhaseAudioControls.tsx` - Audio element controls per phase
- `PhaseTimeline.tsx` - Visual timeline of phases
- `SessionPlaybackController.tsx` - Playback management

### Services Needed

- `SessionPhaseService.ts` - Already exists, needs extension
- `MultiPhasePlaybackService.ts` - New service for phase playback
- `SessionStorageService.ts` - Session persistence
- `SessionImportExportService.ts` - Import/export functionality

### Hooks Needed

- `useSessionPhases.ts` - Phase management hook
- `useMultiPhasePlayback.ts` - Playback control hook
- `usePhaseEditor.ts` - Phase editing hook

### Data Models

```typescript
interface SessionConfig {
  id: string;
  name: string;
  description?: string;
  duration: number;
  voice: "Flo" | "Franca" | "Marion" | "Corinna";
  version: number;
  livePhase: number;
  topic: string;
  type: "guided" | "soundscape";
  enableFreq: boolean;
}

interface SessionPhase {
  id: string;
  name: string;
  headline1?: string;
  headline2?: string;
  duration: number;
  sleepCheck?: boolean;
  text?: PhaseAudioElement;
  music?: PhaseAudioElement;
  nature?: PhaseAudioElement;
  sound?: PhaseAudioElement;
  noise?: PhaseNoiseElement;
  frequency?: PhaseFrequencyElement;
}

interface Session {
  config: SessionConfig;
  phases: SessionPhase[];
}
```

---

## 🔄 User Flows

### Primary Flow: Create Multi-Phase Session

1. User opens session editor
2. User creates new session
3. System creates default phase
4. User configures phase audio elements
5. User adds additional phases
6. User configures each phase
7. User saves session
8. System stores session locally/backend

### Alternative Flow: Edit Existing Session

1. User opens saved session
2. User selects phase to edit
3. User modifies phase properties
4. User saves changes
5. System updates session

### Alternative Flow: Reorder Phases

1. User opens session editor
2. User selects phase
3. User moves phase before/after another
4. System updates phase order
5. User saves session

---

## 🎨 UI/UX Specifications

### Visual Design

- Phase list with expandable items
- Visual timeline showing phase durations
- Color-coded audio elements
- Drag-and-drop for phase reordering
- Volume sliders for each audio element

### Interactions

- Tap to expand/collapse phase
- Swipe to delete phase
- Drag to reorder phases
- Sliders for volume control
- Buttons for add/delete phase

### Platform-Specific Notes

- **iOS:** Use native drag-and-drop APIs
- **Android:** Use RecyclerView with drag-and-drop

---

## 📱 Platform Compatibility

- **iOS:** ⚠️ Partial - Basic session structure exists, needs phase management UI
- **Android:** ⚠️ Partial - Same as iOS

### Version Requirements

- iOS: 13.0+
- Android: API 21+

---

## 🔗 Related Features

- [Frequency Generation System](../Frequency%20Generation%20System/)
- [Noise Generation System](../Noise%20Generation%20System/)
- [Session Import Export](../Session%20Import%20Export/)
- [Content Database](../Content%20Database/)
- [Session Phase Editor](../Session%20Phase%20Editor/)

---

## 📚 Additional Resources

- OLD-APP Source: `src/js/session-object.js`
- OLD-APP Phase Management: `src/js/editor-phase.js`
- Current Implementation: `src/services/SessionPhaseService.ts`

---

## 📝 Notes

- Current `SessionPhaseService.ts` has basic phase structure but needs UI and full phase management
- Phase playback requires coordination with audio services
- Session format should maintain compatibility with OLD-APP for import/export
- Consider performance for sessions with many phases (>10)

---

*Migration Priority: High*
*Estimated Complexity: High*
*Dependencies: Frequency Generation, Noise Generation, Audio Services*
