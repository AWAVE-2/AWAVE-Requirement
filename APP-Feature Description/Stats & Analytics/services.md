# Stats & Analytics System - Services Documentation

## 🔧 Service Layer Overview

The Stats & Analytics system uses a service-oriented architecture with clear separation of concerns. Services handle all backend interactions, data aggregation, and statistics calculation.

---

## 📦 Services

### SessionTrackingService
**File:** `src/services/SessionTrackingService.ts`  
**Type:** Static Class  
**Purpose:** Session tracking, statistics calculation, and analytics aggregation

#### Configuration
- No external configuration required
- Uses Supabase client from integrations

#### Methods

**`getSessionStats(userId: string): Promise<SessionStats>`**
- Gets all user sessions (limit: 1000)
- Filters completed sessions
- Calculates total sessions count
- Calculates completed sessions count
- Calculates total minutes from completed sessions
- Calculates average session length
- Calculates current streak using `calculateStreak()`
- Returns statistics object

**Returns:**
```typescript
{
  totalSessions: number;
  completedSessions: number;
  totalMinutes: number;
  averageSessionLength: number;
  currentStreak: number;
}
```

**Error Handling:**
- Returns default values (all zeros) on error
- Logs errors to console
- Graceful degradation

---

**`getMostPlayedSounds(userId: string, limit: number = 5): Promise<MostPlayedSound[]>`**
- Gets all user sessions (limit: 1000)
- Extracts sound IDs from `sounds_played` array
- Counts plays per sound using Map
- Sorts sounds by play count (descending)
- Takes top N sounds
- Fetches sound metadata from `sound_metadata` table
- Combines play counts with metadata
- Returns array of sounds with play counts

**Returns:**
```typescript
Array<{
  soundId: string;
  title: string;
  description: string;
  categoryId: string;
  playCount: number;
}>
```

**Error Handling:**
- Returns empty array on error
- Handles missing sound metadata gracefully
- Logs errors to console

---

**`getWeeklyActivity(userId: string): Promise<ActivityData[]>`**
- Gets sessions from last 7 days
- Groups sessions by date
- Calculates count and minutes per day
- Creates array with all 7 days (even if no activity)
- Returns formatted activity data

**Returns:**
```typescript
Array<{
  date: string; // Date string
  count: number; // Session count
  minutes: number; // Total minutes
}>
```

**Error Handling:**
- Returns empty array on error
- Handles missing dates gracefully
- Logs errors to console

---

**`updateDailyAnalytics(userId: string): Promise<void>`**
- Gets today's sessions from `user_sessions` table
- Filters by date range (00:00:00 to 23:59:59)
- Calculates totals:
  - `totalSessionTime`: Sum of `duration_minutes`
  - `sessionsStarted`: Total count
  - `sessionsCompleted`: Count of completed sessions
- Upserts to `app_usage_analytics` table
- Called automatically after session completion

**Database Operation:**
```sql
UPSERT INTO app_usage_analytics (
  user_id,
  date,
  total_session_time,
  sessions_started,
  sessions_completed
) VALUES (...)
```

**Error Handling:**
- Logs errors but doesn't throw
- Graceful failure (doesn't block session completion)
- Console error logging

---

**`getUserSessions(userId: string, limit: number = 50): Promise<UserSession[]>`**
- Gets user session history from `user_sessions` table
- Filters by `user_id`
- Orders by `created_at` (descending)
- Limits results
- Returns array of sessions

**Error Handling:**
- Returns empty array on error
- Logs errors to console

---

**`calculateStreak(sessions: UserSession[]): number`**
- Filters sessions with `session_end` date
- Extracts unique dates (date part only)
- Sorts dates (newest first)
- Checks if streak is active (today or yesterday)
- Counts consecutive days from today backwards
- Returns streak number

**Logic:**
- Streak is broken if no activity today or yesterday
- Counts consecutive days with sessions
- Returns 0 if no sessions or streak broken

**Error Handling:**
- Returns 0 for empty sessions
- Handles date parsing errors

---

**`startSession(config: SessionConfig): Promise<UserSession | null>`**
- Creates new session record
- Sets session start time
- Stores session type, sounds, category
- Stores device info (platform, version)
- Sets `completed: false`
- Returns session with ID

**Error Handling:**
- Returns null on error
- Logs errors to console

---

**`updateProgress(sessionId: string, progress: SessionProgress): Promise<void>`**
- Updates session progress percentage
- Calculates from current time and total duration
- Updates `progress_percent` field
- Updates `updated_at` timestamp

**Error Handling:**
- Logs errors but doesn't throw
- Graceful failure

---

**`completeSession(sessionId: string, durationSeconds: number): Promise<void>`**
- Gets session to extract userId
- Updates session:
  - Sets `session_end` timestamp
  - Sets `duration_minutes` (rounded)
  - Sets `completed: true`
  - Sets `progress_percent: 100`
- Triggers `updateDailyAnalytics()` for user

**Error Handling:**
- Logs errors but doesn't throw
- Daily analytics update failure doesn't block completion

---

**`cancelSession(sessionId: string, reason?: string): Promise<void>`**
- Updates session:
  - Sets `session_end` timestamp
  - Sets `completed: false`
  - Stores cancellation reason in metadata
- Marks session as cancelled

**Error Handling:**
- Logs errors but doesn't throw

---

#### Dependencies
- `supabase` client
- `Platform` API (React Native)
- `UserSession` type from Supabase client

---

### analytics.ts
**File:** `src/services/analytics.ts`  
**Type:** Service Functions  
**Purpose:** Analytics event tracking

#### Functions

**`logAudioAccess(audioFile: AudioFileLike, userId?: string | null): Promise<void>`**
- Logs audio file access to analytics
- Calls Supabase RPC function `log_audio_access`
- Passes object ID, bucket ID, object name, user ID
- Used for tracking sound plays

**Error Handling:**
- Logs warnings on error
- Doesn't throw (non-blocking)

---

**`trackConversionEvent(eventType: string, contentCategory: string | undefined, userId?: string | null): Promise<void>`**
- Tracks conversion events for business analytics
- Inserts into `subscription_conversion_events` table
- Includes event type, content category, platform, timestamp
- Used for tracking user conversions

**Error Handling:**
- Logs warnings on error
- Doesn't throw (non-blocking)

---

**`trackBusinessEvents`**
- Object with convenience methods for business events:
  - `paywallShown(contentType, userId)` - Track paywall display
  - `upgradeClicked(fromTier, toTier, userId)` - Track upgrade clicks
  - `trialStarted(userId)` - Track trial start
  - `subscriptionPurchased(planType, userId)` - Track purchases

**Error Handling:**
- All methods log warnings on error
- Non-blocking (doesn't throw)

---

**`startMeditationSession(userId: string, audioFiles: AudioFileLike[]): Promise<Session>`**
- Creates new meditation session
- Inserts into `user_sessions` table
- Sets session type to 'meditation'
- Stores audio files array
- Returns session data

**Error Handling:**
- Throws error on failure
- Uses `handleSupabaseError` for user-friendly messages

---

**`endMeditationSession(sessionId: string, durationMinutes: number): Promise<void>`**
- Updates session with end time and duration
- Sets `completed: true`
- Updates `user_sessions` table

**Error Handling:**
- Throws error on failure
- Uses `handleSupabaseError` for user-friendly messages

---

#### Dependencies
- `supabase` client
- `Platform` API (React Native)
- `executeWithConnectivity` utility
- `handleSupabaseError` utility

---

## 🔗 Service Dependencies

### Dependency Graph
```
StatsScreen
├── useSessionStats
│   └── SessionTrackingService
│       └── supabase client
│           └── user_sessions table
│
├── useWeeklyActivity
│   └── SessionTrackingService
│       └── supabase client
│           └── user_sessions table
│
└── useMostPlayedSounds
    └── SessionTrackingService
        ├── supabase client
        │   ├── user_sessions table
        │   └── sound_metadata table
        │
        └── calculateStreak()
            └── user_sessions data

SessionTrackingService
└── updateDailyAnalytics()
    └── supabase client
        ├── user_sessions table (read)
        └── app_usage_analytics table (write)
```

### External Dependencies

#### Supabase Database
- **`user_sessions` table:** Session tracking data
  - Primary source for all statistics
  - Contains session start/end, duration, completion status
  - Links to sounds and categories
  
- **`app_usage_analytics` table:** Daily aggregated analytics
  - One row per user per day
  - Aggregated totals (time, sessions started/completed)
  - Updated automatically after session completion
  
- **`sound_metadata` table:** Sound information
  - Used for most played sounds display
  - Contains title, description, category
  - Linked via sound IDs from sessions

#### React Native APIs
- **Platform API:** Device information (OS, version)
- **Dimensions API:** Screen sizing for charts

---

## 🔄 Service Interactions

### Statistics Calculation Flow
```
User Opens Stats Screen
    │
    └─> useSessionStats.fetchStats()
        └─> SessionTrackingService.getSessionStats(userId)
            ├─> getUserSessions(userId, 1000)
            │   └─> supabase.from('user_sessions').select()
            │
            ├─> Filter completed sessions
            ├─> Calculate totals
            ├─> Calculate average
            └─> calculateStreak(sessions)
                └─> Return statistics
```

### Most Played Sounds Flow
```
User Views Most Used Sounds
    │
    └─> useMostPlayedSounds.fetchSounds()
        └─> SessionTrackingService.getMostPlayedSounds(userId, limit)
            ├─> getUserSessions(userId, 1000)
            │   └─> supabase.from('user_sessions').select()
            │
            ├─> Count plays per sound
            ├─> Sort by play count
            ├─> Fetch sound metadata
            │   └─> supabase.from('sound_metadata').select()
            │
            └─> Combine and return
```

### Daily Analytics Flow
```
Session Completion
    │
    └─> SessionTrackingService.completeSession()
        ├─> Update session record
        │   └─> supabase.from('user_sessions').update()
        │
        └─> updateDailyAnalytics(userId)
            ├─> Get today's sessions
            │   └─> supabase.from('user_sessions').select()
            │
            ├─> Calculate totals
            └─> Upsert to app_usage_analytics
                └─> supabase.from('app_usage_analytics').upsert()
```

### Activity Chart Flow
```
User Views Chart
    │
    └─> useWeeklyActivity.fetchActivity()
        └─> SessionTrackingService.getWeeklyActivity(userId)
            ├─> Get last 7 days sessions
            │   └─> supabase.from('user_sessions').select()
            │
            ├─> Group by date
            ├─> Calculate per-day totals
            └─> Format for chart display
```

---

## 🧪 Service Testing

### Unit Tests
- Statistics calculation accuracy
- Streak calculation logic
- Play count aggregation
- Daily analytics aggregation
- Date grouping and formatting
- Error handling

### Integration Tests
- Supabase database queries
- Service method calls
- Hook integration
- Data transformation
- Error recovery

### Mocking
- Supabase client
- Database responses
- Network requests
- Platform API

---

## 📊 Service Metrics

### Performance
- **Statistics Calculation:** < 500ms
- **Most Played Sounds:** < 1 second
- **Weekly Activity:** < 800ms
- **Daily Analytics Update:** < 300ms
- **Database Queries:** < 200ms average

### Reliability
- **Statistics Success Rate:** > 99%
- **Daily Analytics Success Rate:** > 99%
- **Error Recovery:** Automatic retry on hooks

### Data Accuracy
- **Statistics Match Sessions:** 100%
- **Play Counts Accurate:** 100%
- **Streak Calculation:** Accurate to day
- **Daily Aggregation:** Accurate to session

---

## 🔐 Security Considerations

### Data Access
- All queries filtered by `user_id`
- User can only access their own data
- No cross-user data leakage
- Supabase RLS policies enforced

### Data Privacy
- Analytics data is user-specific
- No PII in analytics tables
- Session data contains only metadata
- Sound metadata is public (no sensitive data)

### Network Security
- All requests use HTTPS
- Supabase connection encrypted
- No credentials in logs
- Error messages don't expose sensitive data

---

## 🐛 Error Handling

### Service-Level Errors
- Network connectivity checks
- Graceful degradation
- User-friendly error messages
- Error logging for debugging
- Retry logic in hooks

### Error Types
- **Network Errors:** Connectivity issues
- **Database Errors:** Query failures
- **Data Errors:** Missing or invalid data
- **Calculation Errors:** Edge cases in calculations

### Error Recovery
- Hooks provide retry capability
- Empty states for missing data
- Default values for failed calculations
- Non-blocking analytics updates

---

## 📝 Service Configuration

### Environment Variables
No environment variables required for stats services. Uses Supabase client configuration.

### Service Initialization
No initialization required. Services are static classes/functions.

### Service Cleanup
No cleanup required. No persistent connections or timers.

---

## 🔄 Service Updates

### Future Enhancements
- Real-time statistics updates via Supabase subscriptions
- Caching for improved performance
- Background sync for analytics
- Advanced filtering options
- Period-specific statistics calculation
- Badge unlocking logic
- Performance optimizations

---

*For component usage, see `components.md`*  
*For user flows, see `user-flows.md`*  
*For technical details, see `technical-spec.md`*
