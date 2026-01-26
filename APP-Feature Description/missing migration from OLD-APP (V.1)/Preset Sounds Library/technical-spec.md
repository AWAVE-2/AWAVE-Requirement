# Preset Sounds Library - Technical Specification

## 🏗️ Architecture

### Data Models

#### PresetSound Interface

```typescript
interface PresetSound {
  id: string;
  name: string;
  category: 'schlafen' | 'stress' | 'leichtigkeit' | 'meditation';
  description: string;
  
  // Voice Configuration
  voice: 'Flo' | 'Franca' | 'Marion' | 'Corinna';
  defaultVoice?: boolean; // If true, user can change
  
  // Audio Elements
  natureSound?: {
    id: string;
    name: string;
    volume: number; // 0-100
    autoAssign?: boolean; // Auto-assign based on journey
  };
  
  music: {
    id: string;
    name: string;
    category: 'Deep_Dreaming' | 'Peaceful_Ambient' | 'Zen_Garden' | 'Solo_Piano';
    volume: number; // 0-100
    random?: boolean; // Random selection from category
  };
  
  // Frequency Configuration
  frequency: {
    type: FrequencyType; // 'monaural' | 'binaural' | 'isochronic' | etc.
    progression: FrequencyPhase[]; // Array of frequency phases
    enabled: boolean; // Requires pro mode
  };
  
  // Session Structure
  sessionTemplate: {
    phases: PresetPhase[];
    totalDuration?: number; // Estimated duration in minutes
  };
}

interface FrequencyPhase {
  phaseName: string;
  startPulseFreq: number; // Hz
  targetPulseFreq: number; // Hz
  startRootFreq?: number; // Hz
  targetRootFreq?: number; // Hz
  fadeIn?: number; // seconds
  fadeOut?: number; // seconds
}

interface PresetPhase {
  name: string;
  type: 'intro' | 'body' | 'breath' | 'hypnosis' | 'fantasy' | 'affirmation' | 'silence' | 'exit';
  duration?: number; // seconds (or calculated from voice playtime)
  text?: {
    contentId: string;
    volume: number;
  };
  music?: {
    contentId: string;
    volume: number;
    fadeIn?: number;
    fadeOut?: number;
  };
  nature?: {
    contentId: string;
    volume: number;
    fadeIn?: number;
    fadeOut?: number;
  };
  frequency?: FrequencyPhase;
  noise?: {
    type: 'white' | 'pink' | 'brown' | 'grey' | 'blue' | 'violet';
    volume: number;
    fadeIn?: number;
    fadeOut?: number;
  };
}
```

### Preset Database Structure

```typescript
// Preset definitions
const presetSounds: PresetSound[] = [
  {
    id: 'entspannung',
    name: 'Entspannung',
    category: 'schlafen',
    description: 'Tiefe Entspannung mit Florian Stimme, Wald-Klängen und Beta-Alpha-Theta-Delta Progression',
    voice: 'Flo',
    natureSound: {
      id: 'wald',
      name: 'Wald',
      volume: 50,
      autoAssign: true
    },
    music: {
      id: 'deep_dreaming',
      name: 'Deep Dreaming',
      category: 'Deep_Dreaming',
      volume: 50,
      random: true
    },
    frequency: {
      type: 'monaural',
      progression: [
        { phaseName: 'intro', startPulseFreq: 23, targetPulseFreq: 23 }, // Beta
        { phaseName: 'body', startPulseFreq: 23, targetPulseFreq: 10 },  // Beta → Alpha
        { phaseName: 'breath', startPulseFreq: 10, targetPulseFreq: 6 }, // Alpha → Theta
        { phaseName: 'hypnosis', startPulseFreq: 6, targetPulseFreq: 2 }, // Theta → Delta
        { phaseName: 'silence', startPulseFreq: 2, targetPulseFreq: 2 }  // Delta
      ],
      enabled: true
    },
    sessionTemplate: {
      phases: [
        { type: 'intro', frequency: { startPulseFreq: 23, targetPulseFreq: 23 } },
        { type: 'body', frequency: { startPulseFreq: 23, targetPulseFreq: 10 } },
        { type: 'breath', frequency: { startPulseFreq: 10, targetPulseFreq: 6 } },
        { type: 'hypnosis', frequency: { startPulseFreq: 6, targetPulseFreq: 2 } },
        { type: 'silence', frequency: { startPulseFreq: 2, targetPulseFreq: 2 }, noise: { type: 'pink', volume: 50 } }
      ]
    }
  },
  // ... more presets
];
```

### Services Needed

#### PresetSoundService

```typescript
class PresetSoundService {
  // Get all presets for a category
  getPresetsByCategory(category: string): PresetSound[];
  
  // Get preset by ID
  getPresetById(id: string): PresetSound | null;
  
  // Apply preset to session
  applyPresetToSession(presetId: string, session: Session): Session;
  
  // Get available voices
  getAvailableVoices(): Voice[];
  
  // Get available nature sounds
  getAvailableNatureSounds(): NatureSound[];
  
  // Get available music tracks
  getAvailableMusicTracks(category?: string): MusicTrack[];
  
  // Create custom preset
  createCustomPreset(preset: Partial<PresetSound>): PresetSound;
  
  // Save custom preset
  saveCustomPreset(preset: PresetSound): void;
  
  // Load custom presets
  loadCustomPresets(): PresetSound[];
}
```

### Components Needed

#### PresetSoundSelector.tsx
- Display list of presets per category
- Show preset details (voice, nature, music, frequency)
- Allow preset selection
- Quick preview functionality

#### PresetSoundCard.tsx
- Display individual preset
- Show preset name, category, description
- Display voice, nature sound, music icons
- Show frequency progression visualization

#### PresetSoundDetails.tsx
- Detailed view of preset configuration
- All components listed
- Frequency progression chart
- Estimated duration
- Customization options

#### PresetSoundCustomizer.tsx
- Customize preset components
- Change voice, nature sound, music
- Adjust frequency settings
- Save as custom preset

### Hooks Needed

#### usePresetSounds.ts
```typescript
function usePresetSounds(category?: string) {
  const presets = useMemo(() => 
    category 
      ? PresetSoundService.getPresetsByCategory(category)
      : PresetSoundService.getAllPresets(),
    [category]
  );
  
  return {
    presets,
    selectPreset: (id: string) => PresetSoundService.getPresetById(id),
    applyPreset: (id: string, session: Session) => 
      PresetSoundService.applyPresetToSession(id, session)
  };
}
```

#### usePresetCustomization.ts
```typescript
function usePresetCustomization(presetId: string) {
  const preset = useMemo(() => 
    PresetSoundService.getPresetById(presetId),
    [presetId]
  );
  
  const [customPreset, setCustomPreset] = useState(preset);
  
  const updateVoice = (voice: Voice) => {
    setCustomPreset({ ...customPreset, voice });
  };
  
  const updateNatureSound = (natureSound: NatureSound) => {
    setCustomPreset({ ...customPreset, natureSound });
  };
  
  const updateMusic = (music: MusicTrack) => {
    setCustomPreset({ ...customPreset, music });
  };
  
  const saveCustomPreset = () => {
    PresetSoundService.saveCustomPreset(customPreset);
  };
  
  return {
    preset: customPreset,
    updateVoice,
    updateNatureSound,
    updateMusic,
    saveCustomPreset
  };
}
```

### Audio File Management

#### File Path Resolution

```typescript
class AudioFileResolver {
  // Resolve voice-specific text file
  resolveTextFile(
    category: string,
    contentName: string,
    voice: string
  ): string {
    return `text/${category}/${contentName}/${voice}_${contentName}.mp3`;
  }
  
  // Resolve music file
  resolveMusicFile(
    category: string,
    musicName: string
  ): string {
    return `music/${category}/${musicName}/${musicName}.mp3`;
  }
  
  // Resolve nature sound file
  resolveNatureFile(
    category: string,
    natureName: string
  ): string {
    return `nature/${category}/${natureName}/${natureName}.mp3`;
  }
  
  // Resolve sound effect file
  resolveSoundFile(
    category: string,
    soundName: string
  ): string {
    return `sound/${category}/${soundName}/${soundName}.mp3`;
  }
}
```

### Integration with Existing Services

#### Integration Points

1. **ContentDatabaseService**
   - Get content items by category
   - Get voice-specific playtimes
   - Get content metadata

2. **FrequencyGenerationService**
   - Apply frequency settings from preset
   - Generate frequency progression
   - Handle frequency type (monaural, binaural, etc.)

3. **SessionPhaseService**
   - Create phases from preset template
   - Apply phase configurations
   - Set phase durations

4. **AudioService**
   - Load audio files for preset
   - Handle voice-specific files
   - Manage audio playback

### Database Schema

#### Preset Sounds Table

```sql
CREATE TABLE preset_sounds (
  id UUID PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  category VARCHAR(50) NOT NULL,
  description TEXT,
  voice VARCHAR(50) NOT NULL,
  nature_sound_id UUID REFERENCES nature_sounds(id),
  nature_sound_volume INTEGER DEFAULT 50,
  music_id UUID REFERENCES music_tracks(id),
  music_volume INTEGER DEFAULT 50,
  frequency_type VARCHAR(50) NOT NULL,
  frequency_enabled BOOLEAN DEFAULT true,
  session_template JSONB NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE custom_preset_sounds (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  preset_id UUID REFERENCES preset_sounds(id),
  customizations JSONB NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);
```

### API Endpoints

#### Preset Sounds API

```typescript
// Get presets by category
GET /api/preset-sounds?category=schlafen

// Get preset by ID
GET /api/preset-sounds/:id

// Apply preset to session
POST /api/preset-sounds/:id/apply
Body: { sessionId: string }

// Create custom preset
POST /api/preset-sounds/custom
Body: { preset: PresetSound }

// Get user's custom presets
GET /api/preset-sounds/custom
```

### Storage Requirements

#### Audio Files

- **Text Files (Voice-Specific):**
  - Format: `text/{category}/{name}/{voice}_{name}.mp3`
  - Estimated: 100+ files × 4 voices = 400+ files
  - Size: ~5-15 MB per file = 2-6 GB total

- **Music Files:**
  - Format: `music/{category}/{name}/{name}.mp3`
  - Estimated: 20+ tracks
  - Size: ~10-30 MB per file = 200-600 MB total

- **Nature Sounds:**
  - Format: `nature/{category}/{name}/{name}.mp3`
  - Estimated: 10+ sounds
  - Size: ~5-15 MB per file = 50-150 MB total

- **Sound Effects:**
  - Format: `sound/{category}/{name}/{name}.mp3`
  - Estimated: 20+ sounds
  - Size: ~1-5 MB per file = 20-100 MB total

**Total Estimated Storage:** 2.3-6.9 GB

### Performance Considerations

1. **Lazy Loading:** Load audio files only when needed
2. **Caching:** Cache frequently used presets and audio files
3. **Preloading:** Preload preset configurations (not audio files)
4. **Compression:** Use compressed audio formats (MP3, AAC)
5. **Streaming:** Stream audio files from CDN/storage
6. **Background Downloads:** Download preset audio files in background

### Platform-Specific Implementation

#### iOS
- Use AVFoundation for audio playback
- Native audio file management
- Background audio support

#### Android
- Use MediaPlayer or ExoPlayer
- Native audio file management
- Background audio support

---

## 🔗 Related Services

- ContentDatabaseService
- FrequencyGenerationService
- SessionPhaseService
- AudioService
- SessionStorageService

---

## 📚 Source Code References

- OLD-APP Content Database: `src/js/content-database.js`
- OLD-APP Session Generator: `src/js/generator-session-content.js`
- OLD-APP Frequency Presets: `src/js/content-database.js` (lines 946-952)
- OLD-APP Voice Options: `src/js/main.js` (line 53)

---

*Last Updated: 2025-01-27*
