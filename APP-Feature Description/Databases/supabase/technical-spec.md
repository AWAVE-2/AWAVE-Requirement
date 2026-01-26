# Supabase Integration - Technical Specification

## 🏗️ Architecture Overview

### Technology Stack

#### Backend
- **Supabase** - PostgreSQL database with real-time capabilities
  - Production URL: `https://api.dripin.ai`
  - REST API endpoint: `/rest/v1/`
  - Realtime endpoint: `wss://api.dripin.ai/realtime/v1/websocket`
  - Storage endpoint: `/storage/v1/`
  - Functions endpoint: `/functions/v1/`
  - Row-level security (RLS) enabled
  - Automatic API generation
  - Real-time subscriptions

#### Client Library
- **@supabase/supabase-js** - Official Supabase JavaScript client
  - Version: Latest stable
  - TypeScript support
  - Automatic type generation
  - React Native compatible

#### Storage Adapter
- **Custom AsyncStorage Adapter** - Isolated session storage
  - Key prefix: `awave.dev.supabase.`
  - Prevents conflicts with app storage
  - Automatic persistence
  - Secure token storage

#### State Management
- **React Context API** - Global state management
- **React Hooks** - Component-level state
- **React Query** - Server state management and caching
- **TypeScript** - Type safety for all operations

---

## 📁 File Structure

```
src/
├── config/
│   └── productionConfig.ts              # Supabase client configuration
├── integrations/
│   └── supabase/
│       ├── client.ts                    # Supabase client re-export
│       └── diagnostics.ts               # Connection diagnostics
├── services/
│   ├── ProductionBackendService.ts      # Main database service
│   ├── SupabaseAudioLibraryManager.ts   # Audio file management
│   └── backendConstants.ts              # Database constants
├── hooks/
│   └── useRealtimeSync.ts               # Real-time synchronization
├── types/
│   └── database.ts                     # Database type definitions
└── utils/
    └── errorHandler.ts                  # Error handling utilities
```

---

## 🔧 Supabase Client Configuration

### Client Initialization
**Location:** `src/config/productionConfig.ts`

```typescript
export const supabase: SupabaseClient = createClient(
  ENV_CONFIG.SUPABASE_URL,
  ENV_CONFIG.SUPABASE_ANON_KEY,
  {
    auth: {
      storage: isolatedStorage,
      autoRefreshToken: true,
      persistSession: true,
      detectSessionInUrl: false,
      flowType: 'pkce',
    },
    realtime: {
      params: {
        eventsPerSecond: 10,
      },
    },
    global: {
      headers: {
        'X-Client-Info': 'awave-advanced-react-native',
      },
    },
  },
);
```

### Configuration Details

#### Auth Configuration
- **storage:** Custom isolated storage adapter
- **autoRefreshToken:** Automatic token refresh before expiry
- **persistSession:** Session persists across app restarts
- **detectSessionInUrl:** Disabled (not needed for mobile)
- **flowType:** PKCE for secure authentication

#### Realtime Configuration
- **eventsPerSecond:** 10 (performance limit)
- **Automatic reconnection:** Enabled by default
- **Channel management:** Automatic cleanup

#### Global Headers
- **X-Client-Info:** Identifies client as React Native app

### Storage Adapter

```typescript
const isolatedStorage = {
  getItem: async (key: string): Promise<string | null> => {
    return await AsyncStorage.getItem(`awave.dev.supabase.${key}`);
  },
  setItem: async (key: string, value: string): Promise<void> => {
    await AsyncStorage.setItem(`awave.dev.supabase.${key}`, value);
  },
  removeItem: async (key: string): Promise<void> => {
    await AsyncStorage.removeItem(`awave.dev.supabase.${key}`);
  },
};
```

**Features:**
- Isolated from app storage (prefix: `awave.dev.supabase.`)
- Prevents session conflicts
- Secure token storage
- Async operations

---

## 🔌 Database Schema

### Core Tables

#### user_profiles
**Purpose:** User account and profile information

**Columns:**
- `id` (UUID, Primary Key)
- `user_id` (UUID, Foreign Key → auth.users, Unique)
- `first_name` (TEXT, nullable)
- `last_name` (TEXT, nullable)
- `display_name` (TEXT, nullable)
- `avatar_url` (TEXT, nullable)
- `timezone` (TEXT, nullable)
- `preferred_language` (TEXT, default: 'de')
- `onboarding_completed` (BOOLEAN, default: false)
- `onboarding_data` (JSONB, nullable)
- `onboarding_category_preference` (TEXT, nullable)
- `cached_sound_selection` (JSONB, nullable)
- `registration_flow_state` (TEXT, default: 'initial')
- `created_at` (TIMESTAMPTZ)
- `updated_at` (TIMESTAMPTZ)

**Indexes:**
- Primary key on `id`
- Unique constraint on `user_id`
- Index on `user_id` for lookups

**RLS Policies:**
- Users can read their own profile
- Users can update their own profile
- Users can insert their own profile

---

#### user_sessions
**Purpose:** Audio playback session tracking

**Columns:**
- `id` (UUID, Primary Key)
- `user_id` (UUID, Foreign Key → auth.users)
- `session_start` (TIMESTAMPTZ)
- `session_end` (TIMESTAMPTZ, nullable)
- `duration_minutes` (INTEGER, nullable)
- `sounds_played` (JSONB, nullable) - Array of SessionSoundsPlayed
- `session_type` (ENUM: 'meditation' | 'sleep' | 'focus' | 'custom')
- `completed` (BOOLEAN, default: false)
- `device_info` (JSONB, nullable) - DeviceInfo object
- `created_at` (TIMESTAMPTZ)

**Indexes:**
- Primary key on `id`
- Index on `user_id` for user queries
- Index on `created_at` for ordering

**RLS Policies:**
- Users can read their own sessions
- Users can insert their own sessions
- Users can update their own sessions

---

#### user_favorites
**Purpose:** User's favorite sound mixes

**Columns:**
- `id` (UUID, Primary Key)
- `user_id` (UUID, Foreign Key → auth.users)
- `sound_id` (TEXT, nullable)
- `title` (TEXT, nullable)
- `description` (TEXT, nullable)
- `image_url` (TEXT, nullable)
- `tracks` (JSONB, nullable) - Array of FavoriteTrack
- `date_added` (TIMESTAMPTZ, nullable)
- `last_used` (TIMESTAMPTZ, nullable)
- `use_count` (INTEGER, default: 0)
- `is_public` (BOOLEAN, default: false)
- `category_id` (TEXT, nullable)

**Indexes:**
- Primary key on `id`
- Index on `user_id` for user queries
- Index on `last_used` for ordering

**RLS Policies:**
- Users can read their own favorites
- Users can insert their own favorites
- Users can update their own favorites
- Users can delete their own favorites

---

#### sound_metadata
**Purpose:** Audio file catalog and metadata

**Columns:**
- `id` (UUID, Primary Key)
- `sound_id` (TEXT, Unique)
- `category_id` (TEXT)
- `title` (TEXT)
- `description` (TEXT, nullable)
- `keywords` (TEXT[], default: [])
- `tags` (TEXT[], default: [])
- `search_weight` (INTEGER, default: 0)
- `file_url` (TEXT, nullable)
- `file_path` (TEXT, nullable)
- `bucket_id` (TEXT, nullable)
- `storage_path` (TEXT, nullable)
- `file_size` (BIGINT, nullable)
- `file_hash` (TEXT, nullable)
- `duration` (INTEGER, nullable) - Duration in seconds
- `format` (TEXT, nullable)
- `bitrate` (INTEGER, nullable)
- `sample_rate` (INTEGER, nullable)
- `channels` (INTEGER, nullable)
- `processed` (BOOLEAN, default: false)
- `waveform_data` (JSONB, nullable) - WaveformData object
- `spectrogram_url` (TEXT, nullable)
- `is_public` (BOOLEAN, default: true)
- `download_count` (INTEGER, default: 0)
- `play_count` (INTEGER, default: 0)
- `created_at` (TIMESTAMPTZ)
- `updated_at` (TIMESTAMPTZ)

**Indexes:**
- Primary key on `id`
- Unique constraint on `sound_id`
- Index on `category_id` for filtering
- Index on `search_weight` for ordering
- Full-text search index on `title`, `keywords`, `tags`

**RLS Policies:**
- Public read access (no authentication required)
- Admin-only write access

---

## 🔄 Real-Time Subscriptions

### Subscription Setup
**Location:** `src/hooks/useRealtimeSync.ts`

```typescript
export function useRealtimeSync(options: RealtimeSyncOptions) {
  const queryClient = useQueryClient();
  const { userId, enableFavorites, enableSessions, ... } = options;

  useEffect(() => {
    if (!userId) return;

    const channels: any[] = [];

    // Subscribe to user favorites changes
    if (enableFavorites) {
      const favoritesChannel = supabase
        .channel('user_favorites_sync')
        .on(
          'postgres_changes',
          {
            event: '*',
            schema: 'public',
            table: 'user_favorites',
            filter: `user_id=eq.${userId}`,
          },
          (payload) => {
            queryClient.invalidateQueries({ queryKey: ['favorites', userId] });
          },
        )
        .subscribe();

      channels.push(favoritesChannel);
    }

    // ... more subscriptions

    return () => {
      channels.forEach((channel) => {
        supabase.removeChannel(channel);
      });
    };
  }, [userId, ...]);
}
```

### Subscription Features
- **Filter by user_id:** User-specific data only
- **Event types:** INSERT, UPDATE, DELETE
- **Cache invalidation:** React Query cache updated automatically
- **Error handling:** Graceful failure handling
- **Cleanup:** Automatic channel removal on unmount

### Supported Subscriptions
1. **user_favorites** - Favorite changes
2. **user_sessions** - Session updates
3. **subscriptions** - Subscription status changes
4. **custom_sound_sessions** - Custom mix updates
5. **user_profiles** - Profile updates
6. **sound_metadata** - Global sound updates

---

## 💾 Storage Integration

### Storage Bucket Configuration
**Bucket Name:** `awave-audio`

**Configuration:**
- Public access for free content
- Signed URLs for premium content
- File size limit: 100MB per file
- Allowed MIME types: `audio/mpeg`, `audio/mp3`, `audio/wav`, `audio/ogg`, `audio/m4a`, `audio/aac`

### Storage Operations

#### Get Public URL
```typescript
const { data: { publicUrl } } = supabase
  .storage
  .from('awave-audio')
  .getPublicUrl(filePath);
```

#### Get Signed URL
```typescript
const { data: { signedUrl } } = await supabase
  .storage
  .from('awave-audio')
  .createSignedUrl(filePath, 3600); // 1 hour TTL
```

#### Upload File
```typescript
const { data, error } = await supabase
  .storage
  .from('awave-audio')
  .upload(filePath, fileContent, {
    contentType: 'audio/mpeg',
    upsert: true,
  });
```

### SupabaseAudioLibraryManager
**Location:** `src/services/SupabaseAudioLibraryManager.ts`

**Features:**
- Audio file download management
- Local cache optimization
- Progress tracking
- Metadata synchronization
- Real-time metadata updates

---

## 🔐 Security Implementation

### Row-Level Security (RLS)
- All user tables have RLS policies
- Users can only access their own data
- Public read access for `sound_metadata` and `sos_config`
- Admin-only write access for system tables

### Token Storage
- Supabase session tokens stored in isolated storage
- Storage key prefix: `awave.dev.supabase.`
- Automatic token refresh enabled
- PKCE flow for secure authentication

### Network Security
- All requests use HTTPS
- Token transmission encrypted
- No credentials in logs
- Secure storage adapter

---

## 🌐 API Integration

### Supabase REST API
- Base URL: `https://api.dripin.ai/rest/v1/`
- Authentication: Bearer token (JWT)
- Content-Type: `application/json`
- Error handling: Standard Supabase error format

### Supabase Realtime
- WebSocket URL: `wss://api.dripin.ai/realtime/v1/websocket`
- Events: INSERT, UPDATE, DELETE
- Channel subscriptions per table
- Automatic reconnection

### Supabase Storage
- Base URL: `https://api.dripin.ai/storage/v1/`
- Bucket: `awave-audio`
- Signed URLs with TTL (max 1 hour)
- Public URLs for public files

### Supabase Functions
- Base URL: `https://api.dripin.ai/functions/v1/`
- Functions:
  - `getSignedAudioUrl` - Signed URL generation
  - `calculate_trial_days_remaining` - Trial calculation
  - `user_needs_registration` - Registration check

---

## 📱 Platform-Specific Notes

### iOS
- AsyncStorage uses NSUserDefaults
- Secure storage for tokens
- Background writes supported
- WebSocket connections maintained in background

### Android
- AsyncStorage uses SharedPreferences
- Secure storage for tokens
- Background writes supported
- WebSocket connections maintained in background

---

## 🧪 Testing Strategy

### Unit Tests
- Service method calls
- Error handling
- Data validation
- Type checking
- Subscription setup/teardown

### Integration Tests
- Supabase API calls
- Real-time subscriptions
- Storage operations
- RLS policy enforcement
- Token refresh

### E2E Tests
- Complete data flows
- Real-time synchronization
- Offline/online transitions
- Error scenarios
- Performance testing

---

## 🐛 Error Handling

### Error Types
- Network errors
- Database errors
- RLS policy violations
- Storage errors
- Authentication errors
- Validation errors

### Error Recovery
- Automatic retry for transient failures
- Queue operations when offline
- Graceful degradation
- User-friendly error messages
- Error logging for debugging

---

## 📊 Performance Considerations

### Optimization
- Indexed database queries
- Batch operations for efficiency
- Connection pooling
- Efficient JSONB storage
- Cache-first reads
- Real-time subscription limits

### Monitoring
- Query performance
- Storage usage
- Real-time subscription health
- Connection state
- Error rates

---

*For component details, see `components.md`*  
*For service dependencies, see `services.md`*  
*For user flows, see `user-flows.md`*
