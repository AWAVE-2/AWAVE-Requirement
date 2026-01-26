# Database System - Technical Specification

## 🏗️ Architecture Overview

### Technology Stack

#### Backend Database
- **Supabase** - PostgreSQL database with real-time capabilities
  - Production URL: `https://api.dripin.ai`
  - REST API endpoint: `/rest/v1/`
  - Realtime endpoint: `wss://api.dripin.ai/realtime/v1/websocket`
  - Storage endpoint: `/storage/v1/`
  - Functions endpoint: `/functions/v1/`
  - Row-level security (RLS) enabled
  - Automatic API generation
  - Real-time subscriptions

#### Local Storage
- **AsyncStorage** - React Native key-value storage
  - Platform: iOS and Android
  - Persistence: Data survives app restarts
  - API: Async (promise-based)
  - Storage limit: Platform-dependent (typically 6MB+)

#### Storage Wrapper
- **storage utility** - localStorage-compatible synchronous API
  - In-memory cache for synchronous reads
  - Background writes to AsyncStorage
  - Initialization required on app startup
  - Web parity: 100% compatible with localStorage

#### State Management
- **React Context API** - Global state management
- **React Hooks** - Component-level state
- **TypeScript** - Type safety for all operations

---

## 📁 File Structure

```
src/
├── config/
│   └── productionConfig.ts              # Supabase client configuration
├── integrations/
│   └── supabase/
│       └── client.ts                    # Supabase client re-export
├── services/
│   ├── ProductionBackendService.ts      # Main database service
│   ├── AWAVEStorage.ts                  # Local storage service
│   ├── OfflineQueueService.ts           # Offline queue management
│   └── backendConstants.ts              # Database constants
├── utils/
│   └── storage.ts                       # localStorage-compatible wrapper
├── types/
│   └── database.ts                     # Database type definitions
└── hooks/
    └── useAsyncStorageBridge.ts         # AsyncStorage bridge
```

---

## 🔧 Database Schema

### Core Tables

#### user_profiles
**Purpose:** User account and profile information

**Columns:**
- `id` (UUID, Primary Key)
- `user_id` (UUID, Foreign Key → auth.users)
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

#### subscriptions
**Purpose:** Subscription and trial management

**Columns:**
- `id` (UUID, Primary Key)
- `user_id` (UUID, Foreign Key → auth.users)
- `stripe_customer_id` (TEXT, nullable)
- `stripe_subscription_id` (TEXT, nullable)
- `plan_type` (ENUM: 'free_trial' | 'monthly' | 'yearly')
- `status` (ENUM: 'active' | 'cancelled' | 'past_due' | 'expired' | 'trialing')
- `trial_start` (TIMESTAMPTZ, nullable)
- `trial_end` (TIMESTAMPTZ, nullable)
- `current_period_start` (TIMESTAMPTZ, nullable)
- `current_period_end` (TIMESTAMPTZ, nullable)
- `cancel_at_period_end` (BOOLEAN, default: false)
- `trial_days_remaining` (INTEGER)
- `auto_renew` (BOOLEAN, default: true)
- `selected_plan_price` (NUMERIC, nullable)
- `selected_plan_interval` (TEXT)
- `created_at` (TIMESTAMPTZ)
- `updated_at` (TIMESTAMPTZ)

**Indexes:**
- Primary key on `id`
- Unique constraint on `user_id`
- Index on `user_id` for lookups

**RLS Policies:**
- Users can read their own subscription
- Users can update their own subscription (limited fields)

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

#### custom_sound_sessions
**Purpose:** User-created custom sound mix configurations

**Columns:**
- `id` (UUID, Primary Key)
- `user_id` (UUID, Foreign Key → auth.users)
- `category_id` (TEXT, nullable)
- `title` (TEXT, nullable)
- `description` (TEXT, nullable)
- `tracks_config` (JSONB) - TracksConfig object
- `swiper_positions` (JSONB) - SwiperPositions object
- `created_at` (TIMESTAMPTZ)
- `updated_at` (TIMESTAMPTZ)
- `last_used` (TIMESTAMPTZ, nullable)

**Indexes:**
- Primary key on `id`
- Index on `user_id` for user queries
- Index on `last_used` for ordering

**RLS Policies:**
- Users can read their own sessions
- Users can insert their own sessions
- Users can update their own sessions
- Users can delete their own sessions

---

#### notification_preferences
**Purpose:** User notification settings

**Columns:**
- `id` (UUID, Primary Key)
- `user_id` (UUID, Foreign Key → auth.users)
- `push_notifications` (BOOLEAN, default: true)
- `email_notifications` (BOOLEAN, default: true)
- `marketing_emails` (BOOLEAN, default: false)
- `reminder_notifications` (BOOLEAN, default: true)
- `achievement_notifications` (BOOLEAN, default: true)
- `trial_reminder_notifications` (BOOLEAN, default: true)
- `preferred_notification_time` (TEXT, nullable)
- `created_at` (TIMESTAMPTZ)
- `updated_at` (TIMESTAMPTZ)

**Indexes:**
- Primary key on `id`
- Unique constraint on `user_id`

**RLS Policies:**
- Users can read their own preferences
- Users can update their own preferences

---

#### app_usage_analytics
**Purpose:** Usage statistics and analytics

**Columns:**
- `id` (UUID, Primary Key)
- `user_id` (UUID, Foreign Key → auth.users)
- `date` (DATE)
- `total_session_time` (INTEGER) - Total seconds
- `sessions_started` (INTEGER)
- `sessions_completed` (INTEGER)
- `favorite_sounds_used` (JSONB, nullable) - FavoriteSoundsUsed object
- `features_used` (JSONB, nullable) - FeaturesUsed object
- `retention_score` (NUMERIC, nullable)
- `created_at` (TIMESTAMPTZ)

**Indexes:**
- Primary key on `id`
- Index on `user_id` for user queries
- Index on `date` for time-based queries
- Unique constraint on (`user_id`, `date`)

**RLS Policies:**
- Users can read their own analytics
- System can insert analytics (service role)

---

#### search_analytics
**Purpose:** Search query tracking

**Columns:**
- `id` (UUID, Primary Key)
- `user_id` (UUID, Foreign Key → auth.users, nullable)
- `search_query` (TEXT)
- `results_count` (INTEGER)
- `sos_triggered` (BOOLEAN, default: false)
- `created_at` (TIMESTAMPTZ)

**Indexes:**
- Primary key on `id`
- Index on `user_id` for user queries
- Index on `created_at` for time-based queries

**RLS Policies:**
- Users can read their own search analytics
- System can insert search analytics (service role)

---

#### notification_logs
**Purpose:** Notification delivery history

**Columns:**
- `id` (UUID, Primary Key)
- `user_id` (UUID, Foreign Key → auth.users)
- `notification_type` (TEXT)
- `message` (TEXT)
- `sent_at` (TIMESTAMPTZ)
- `created_at` (TIMESTAMPTZ)

**Indexes:**
- Primary key on `id`
- Index on `user_id` for user queries
- Index on `sent_at` for time-based queries

**RLS Policies:**
- Users can read their own notification logs
- System can insert notification logs (service role)

---

#### sos_config
**Purpose:** SOS feature configuration

**Columns:**
- `id` (UUID, Primary Key)
- `keywords` (TEXT[]) - Array of trigger keywords
- `title` (TEXT)
- `message` (TEXT)
- `image_url` (TEXT, nullable)
- `phone_number` (TEXT)
- `chat_link` (TEXT, nullable)
- `resources` (TEXT[], nullable)
- `active` (BOOLEAN, default: true)
- `created_at` (TIMESTAMPTZ)
- `updated_at` (TIMESTAMPTZ)

**Indexes:**
- Primary key on `id`
- Index on `active` for filtering

**RLS Policies:**
- Public read access (no authentication required)
- Admin-only write access

---

## 🔌 Services

### ProductionBackendService
**Location:** `src/services/ProductionBackendService.ts`  
**Type:** Static Service Class  
**Purpose:** Main database API service layer

#### Authentication Methods
- `signUp(email, password, firstName?, lastName?)` - User registration
- `signIn(email, password)` - User authentication
- `signOut()` - User sign out
- `getCurrentUser()` - Get current authenticated user
- `getSession()` - Get current session
- `updateEmail(email)` - Update user email
- `updatePassword(password)` - Update user password
- `setAuthSession(accessToken, refreshToken)` - Set session from tokens
- `resendVerificationEmail(email)` - Resend verification email

#### Profile Methods
- `getUserProfile(userId)` - Get user profile
- `createUserProfile(userId, profileData)` - Create user profile
- `updateUserProfile(userId, updates)` - Update user profile

#### Session Methods
- `startSession(userId, sessionType, soundsConfig?)` - Start session
- `endSession(sessionId, userId, durationMinutes)` - End session
- `getUserSessions(userId)` - Get user sessions

#### Favorite Methods
- `getUserFavorites(userId)` - Get user favorites
- `addFavorite(userId, favoriteData)` - Add favorite
- `removeFavorite(favoriteId, userId)` - Remove favorite
- `updateFavoriteUsage(favoriteId, userId, currentUseCount)` - Update usage

#### Sound Metadata Methods
- `getSoundMetadata()` - Get all sound metadata
- `searchSounds(keyword)` - Search sounds by keyword
- `getAllSoundMetadata()` - Get all metadata (alias)

#### Subscription Methods
- `getUserSubscription(userId)` - Get user subscription
- `createSubscription(userId, planType)` - Create subscription
- `checkTrialDaysRemaining(userId)` - Check trial days (RPC)

#### Custom Sound Session Methods
- `getCustomSoundSessions(userId)` - Get custom sessions
- `createCustomSoundSession(userId, sessionData)` - Create session
- `updateCustomSoundSession(sessionId, userId, updates)` - Update session
- `deleteCustomSoundSession(sessionId, userId)` - Delete session
- `loadCustomSoundSessions(userId)` - Load sessions (alias)
- `saveCustomSoundSession(session)` - Save session (alias)
- `deleteCustomSoundSessions(userId)` - Delete all sessions

#### Notification Methods
- `getNotificationPreferences(userId)` - Get preferences
- `updateNotificationPreferences(userId, preferences)` - Update preferences

#### Analytics Methods
- `logSearchAnalytics(userId, query, resultsCount, sosTriggered)` - Log search

#### Audio Storage Methods
- `getSignedAudioUrl(category, soundId, ttlSeconds?)` - Get signed URL
- `getPublicAudioUrl(category, soundId)` - Get public URL

#### Business Logic Methods
- `checkRegistrationStatus(userId)` - Check registration (RPC)
- `checkUserNeedsRegistration(userId)` - Check needs registration (RPC)
- `getActiveSOSConfig()` - Get active SOS config

#### Real-time Methods
- `subscribeToProfileChanges(userId, callback)` - Subscribe to profile
- `subscribeToSubscriptionChanges(userId, callback)` - Subscribe to subscription

#### Testing Methods
- `healthCheck()` - Health check
- `testPublicAccess()` - Test public access
- `testAuthenticatedAccess(userId)` - Test authenticated access

---

### AWAVEStorage
**Location:** `src/services/AWAVEStorage.ts`  
**Type:** Static Service Class  
**Purpose:** Local storage abstraction layer

#### Methods
- `setOnboardingCompleted(value)` - Set onboarding status
- `getOnboardingCompleted()` - Get onboarding status
- `setOnboardingProfile(profile)` - Set onboarding profile
- `getOnboardingProfile()` - Get onboarding profile
- `setLastPlayedSound(sound)` - Set last played sound
- `getLastPlayedSound()` - Get last played sound
- `setMixerTracks(tracks)` - Set mixer tracks
- `getMixerTracks()` - Get mixer tracks
- `setFavorites(favorites)` - Set favorites (local cache)
- `getFavorites()` - Get favorites (local cache)
- `setPrivacyPreferences(preferences)` - Set privacy preferences
- `getPrivacyPreferences()` - Get privacy preferences
- `setSelectedCategory(categoryId)` - Set selected category
- `getSelectedCategory()` - Get selected category
- `setOrderedCategories(categories)` - Set ordered categories
- `getOrderedCategories()` - Get ordered categories
- `setSessionData(sessionData)` - Set session data
- `getSessionData()` - Get session data
- `setAudioSettings(settings)` - Set audio settings
- `getAudioSettings()` - Get audio settings
- `setMultipleItems(items)` - Batch set
- `getMultipleItems(keys)` - Batch get
- `clearAllData()` - Clear all data
- `migrateFromLocalStorage(localStorageData)` - Migration utility

---

### OfflineQueueService
**Location:** `src/services/OfflineQueueService.ts`  
**Type:** Static Service Class  
**Purpose:** Offline operation queue management

#### Configuration
- `QUEUE_KEY = 'offline_action_queue'`
- `MAX_RETRIES = 3`

#### Methods
- `addToQueue(action, table, data)` - Add operation to queue
- `processQueue()` - Process all queued operations
- `processQueueIfOnline()` - Process if online
- `getQueueStatus()` - Get queue statistics
- `clearQueue()` - Clear entire queue
- `setupNetworkListener()` - Setup network listener
- `initialize()` - Initialize service

#### Operation Types
- `create` - Insert operation
- `update` - Update operation
- `delete` - Delete operation

---

### storage utility
**Location:** `src/utils/storage.ts`  
**Type:** Synchronous Storage API  
**Purpose:** localStorage-compatible wrapper

#### Methods
- `initStorage()` - Initialize storage (load cache)
- `isStorageInitialized()` - Check initialization
- `storage.setItem(key, value)` - Set item (sync)
- `storage.getItem(key)` - Get item (sync)
- `storage.removeItem(key)` - Remove item (sync)
- `storage.clear()` - Clear all (sync)
- `storage.key(index)` - Get key at index
- `storage.length` - Get item count

#### Helpers
- `storageHelpers.getJSON<T>(key)` - Get as JSON
- `storageHelpers.setJSON<T>(key, value)` - Set as JSON
- `storageHelpers.getBoolean(key)` - Get as boolean
- `storageHelpers.setBoolean(key, value)` - Set as boolean
- `storageHelpers.getNumber(key)` - Get as number
- `storageHelpers.setNumber(key, value)` - Set as number

#### Debug Utilities
- `storageDebug.getCachedKeys()` - Get all keys
- `storageDebug.getPendingWrites()` - Get pending writes
- `storageDebug.getCacheSnapshot()` - Get cache snapshot
- `storageDebug.waitForWrites(timeoutMs)` - Wait for writes

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

## 🔄 State Management

### Database State
- Managed by Supabase client
- Automatic session refresh
- Real-time subscriptions for live updates
- Connection state tracking

### Local Storage State
- In-memory cache for synchronous access
- Background persistence to AsyncStorage
- Cache invalidation on app restart
- Initialization on app startup

### Offline Queue State
- Stored in AsyncStorage
- Processed when online
- Retry logic with exponential backoff
- Status tracking

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
- Signed URLs with TTL
- Public URLs for public files

### Supabase Functions
- Base URL: `https://api.dripin.ai/functions/v1/`
- Functions: `getSignedAudioUrl`, `calculate_trial_days_remaining`, `user_needs_registration`

---

## 📱 Platform-Specific Notes

### iOS
- AsyncStorage uses NSUserDefaults
- Storage limit: ~6MB
- Background writes supported
- Secure storage for tokens

### Android
- AsyncStorage uses SharedPreferences
- Storage limit: ~6MB
- Background writes supported
- Secure storage for tokens

---

## 🧪 Testing Strategy

### Unit Tests
- Service method calls
- Data validation
- Error handling
- Type checking

### Integration Tests
- Supabase API calls
- Local storage operations
- Offline queue processing
- Synchronization

### E2E Tests
- Complete data flows
- Offline/online transitions
- Error scenarios
- Performance testing

---

## 🐛 Error Handling

### Error Types
- Network errors
- Database errors
- Storage errors
- Validation errors
- Authentication errors

### Error Recovery
- Automatic retry for transient failures
- Queue operations when offline
- Graceful degradation
- User-friendly error messages

---

## 📊 Performance Considerations

### Optimization
- Indexed database queries
- Batch operations for efficiency
- Connection pooling
- Efficient JSONB storage
- Cache-first reads

### Monitoring
- Query performance
- Storage usage
- Queue processing time
- Synchronization latency

---

*For component details, see `components.md`*  
*For service dependencies, see `services.md`*  
*For user flows, see `user-flows.md`*
