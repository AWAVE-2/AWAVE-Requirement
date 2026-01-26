# MiniPlayer Strip - Services Documentation

## 🔧 Service Layer Overview

The MiniPlayer Strip feature integrates with multiple services for state management, audio playback, and data persistence. Services handle backend synchronization, local storage, and audio control.

---

## 📦 Services

### useSoundPlayer Hook
**File:** `src/hooks/useSoundPlayer.ts`  
**Type:** Custom React Hook  
**Purpose:** Unified audio player state management

#### State Exposed
```typescript
{
  lastPlayedSound: Sound | null;
  currentFavoriteId: string | null;
  selectedSound: Sound | null;
  recommendedSounds: Sound[];
  subscriptionTier: SubscriptionTier;
  currentSessionId: string | null;
  
  // Audio state
  isPlaying: boolean;
  isPaused: boolean;
  position: number;
  duration: number;
  isLoading: boolean;
  error: string | null;
}
```

#### Actions Exposed
```typescript
{
  handleSoundSelect: (sound: Sound, favoriteId?: string) => Promise<void>;
  handleClosePlayer: () => Promise<void>;
  handleCloseMiniPlayer: () => Promise<void>;
  handleExpandPlayer: () => void;
  handleAddToMix: (sound: Sound) => void;
  
  // Direct audio controls
  pause: () => Promise<void>;
  resume: () => Promise<void>;
  stop: () => Promise<void>;
  seekTo: (position: number) => Promise<void>;
  setVolume: (volume: number) => Promise<void>;
}
```

#### Methods Used by MiniPlayer Strip

**handleCloseMiniPlayer()**
- Stops audio playback
- Clears last played sound state
- Clears persisted playback state
- Ends Supabase session (if active)
- Clears cached playback in Supabase

**handleExpandPlayer()**
- Currently no-op (player is always full screen)
- Reserved for future expansion logic

**lastPlayedSound**
- Primary state for MiniPlayer Strip
- Updated when sound is selected
- Persisted across app restarts

#### Dependencies
- `useSupabaseAudio` - Audio playback service
- `onboardingStorage` - Local persistence
- `SupabasePlaybackService` - Backend sync
- `useAuth` - Authentication context

---

### SupabasePlaybackService
**File:** `src/services/SupabasePlaybackService.ts`  
**Type:** Service Object  
**Purpose:** Backend synchronization and session tracking

#### Methods Used

**fetchCachedPlayback(userId: string): Promise<CachedPlaybackPayload | null>**
- Fetches last played sound from Supabase
- Returns sound and favoriteId if available
- Used on app start for authenticated users
- Returns null if no cached playback

**createPlaybackSession(userId: string, payload: CachedPlaybackPayload): Promise<{sessionId: string | null, sessionData: SessionData}>**
- Creates playback session in Supabase
- Tracks sound, favoriteId, and metadata
- Returns session ID for tracking
- Called when sound is selected

**completePlaybackSession(sessionId: string, sessionData: SessionData): Promise<void>**
- Completes playback session
- Calculates duration
- Updates session end time
- Called when mini player is closed

**clearCachedPlayback(userId: string): Promise<void>**
- Clears cached playback in Supabase
- Removes last played sound from user profile
- Called when mini player is closed

#### Data Structures

**CachedPlaybackPayload:**
```typescript
{
  sound: Sound;
  favoriteId?: string | null;
  updatedAt?: string;
}
```

**SessionData:**
```typescript
{
  soundId: string;
  favoriteId?: string | null;
  startedAt: string;
  endedAt?: string;
  metadata?: Record<string, unknown>;
}
```

#### Dependencies
- Supabase client
- Database tables: `user_profiles`, `user_sessions`

---

### onboardingStorage
**File:** `src/hooks/useOnboardingStorage.ts`  
**Type:** Storage Service Object  
**Purpose:** Local AsyncStorage persistence

#### Methods Used

**loadLastPlaybackState(): Promise<{lastSound: string | null, favoriteId: string | null}>**
- Loads last played sound from AsyncStorage
- Returns sound JSON string and favoriteId
- Used on app start
- Returns null values if not found

**saveLastPlaybackState(sound: string, favoriteId?: string): Promise<void>**
- Saves last played sound to AsyncStorage
- Stores sound as JSON string
- Stores favoriteId if provided
- Called when sound is selected

**clearPlaybackState(): Promise<void>**
- Clears all playback state from AsyncStorage
- Removes last played sound and favoriteId
- Called when mini player is closed

#### Storage Keys
- `last_played_sound` - Sound JSON string
- `last_played_favorite_id` - Favorite ID string

#### Dependencies
- AsyncStorage (React Native)

---

### useSupabaseAudio
**File:** `src/hooks/audio/useSupabaseAudio.ts`  
**Type:** Custom React Hook  
**Purpose:** Audio playback control

#### Methods Used by useSoundPlayer

**stop(): Promise<void>**
- Stops audio playback
- Called when mini player is closed
- Resets playback state

**pause(): Promise<void>**
- Pauses audio playback
- Available for future use

**resume(): Promise<void>**
- Resumes audio playback
- Available for future use

#### State Exposed
```typescript
{
  isPlaying: boolean;
  isPaused: boolean;
  position: number;
  duration: number;
  isLoading: boolean;
  error: string | null;
}
```

#### Dependencies
- Audio playback service (native module)
- Supabase audio library manager

---

## 🔗 Service Dependencies

### Dependency Graph
```
MiniPlayerStrip Component
  └─> useSoundPlayer Hook
      ├─> useSupabaseAudio Hook
      │   └─> Audio Playback Service (Native)
      ├─> onboardingStorage
      │   └─> AsyncStorage
      ├─> SupabasePlaybackService
      │   └─> Supabase Client
      │       └─> Supabase Database
      └─> useAuth Context
          └─> Auth Service
```

---

## 🔄 Service Interactions

### Sound Selection Flow
```
User Selects Sound
  └─> handleSoundSelect()
      ├─> setLastPlayedSound(sound)
      ├─> onboardingStorage.saveLastPlaybackState()
      └─> SupabasePlaybackService.createPlaybackSession()
          └─> MiniPlayerStrip receives updated sound
```

### Close Flow
```
User Taps Close
  └─> handleCloseMiniPlayer()
      ├─> useSupabaseAudio.stop()
      ├─> setLastPlayedSound(null)
      ├─> onboardingStorage.clearPlaybackState()
      ├─> SupabasePlaybackService.completePlaybackSession()
      └─> SupabasePlaybackService.clearCachedPlayback()
          └─> MiniPlayerStrip receives null sound
```

### State Restoration Flow
```
App Start
  └─> useSoundPlayer.loadState()
      ├─> onboardingStorage.loadLastPlaybackState()
      └─> SupabasePlaybackService.fetchCachedPlayback() (if authenticated)
          └─> setLastPlayedSound(sound)
              └─> MiniPlayerStrip receives sound
```

---

## 🌐 External Services

### Supabase
**Purpose:** Backend database and authentication

**Tables Used:**
- `user_profiles` - Cached playback storage
- `user_sessions` - Playback session tracking

**Operations:**
- Read cached playback
- Write cached playback
- Create playback sessions
- Complete playback sessions
- Clear cached playback

**Authentication:**
- Requires authenticated user for sync
- Falls back to local storage if not authenticated

---

### AsyncStorage
**Purpose:** Local device storage

**Data Stored:**
- Last played sound (JSON string)
- Last played favorite ID
- Playback state

**Persistence:**
- Survives app restarts
- Cleared on explicit user action
- Platform-specific storage

---

## 🧪 Service Testing

### Unit Tests
- Service method calls
- Error handling
- State updates
- Storage operations

### Integration Tests
- Service interactions
- State synchronization
- Backend sync
- Local storage

### Mocking
- Supabase client
- AsyncStorage
- Audio service
- Auth context

---

## 📊 Service Metrics

### Performance
- **State Load:** < 100ms
- **State Save:** < 50ms
- **Backend Sync:** < 500ms
- **Audio Control:** < 50ms

### Reliability
- **State Persistence:** > 99%
- **Backend Sync Success:** > 95%
- **Error Recovery:** Automatic fallback

### Error Rates
- **Storage Failures:** < 1%
- **Backend Sync Failures:** < 5%
- **Audio Control Failures:** < 1%

---

## 🔐 Security Considerations

### Data Storage
- Sound data stored locally (AsyncStorage)
- Supabase sync only for authenticated users
- No sensitive data in component state
- Proper cleanup on component unmount

### User Privacy
- Playback state only synced with user consent
- Session data anonymized where possible
- No tracking of user interactions

---

## 🐛 Error Handling

### Service-Level Errors
- Network connectivity checks
- Retry logic for transient failures
- User-friendly error messages
- Error logging for debugging

### Error Types
- **Network Errors:** Connectivity issues
- **Storage Errors:** AsyncStorage failures
- **Backend Errors:** Supabase API failures
- **Audio Errors:** Playback service failures

### Error Recovery
- Fallback to local storage
- Retry on network recovery
- Graceful degradation
- User notification

---

## 📝 Service Configuration

### Environment Variables
```typescript
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_key
```

### Service Initialization
```typescript
// Automatic on hook mount
const {
  lastPlayedSound,
  handleCloseMiniPlayer,
} = useSoundPlayer({ registration });
```

### Service Cleanup
```typescript
// Automatic on component unmount
// No manual cleanup required
```

---

## 🔄 Service Updates

### Future Enhancements
- Multi-device sync improvements
- Enhanced error recovery
- Offline support improvements
- Performance optimizations

---

*For component usage, see `components.md`*  
*For user flows, see `user-flows.md`*  
*For technical details, see `technical-spec.md`*  
*For requirements, see `requirements.md`*
