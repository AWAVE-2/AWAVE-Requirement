# Session Tracking System - Services Documentation

## 🔧 Service Layer Overview

The session tracking system uses a service-oriented architecture with clear separation of concerns. Services handle all database interactions, session lifecycle management, analytics aggregation, and data retrieval.

---

## 📦 Services

### SessionTrackingService
**File:** `src/services/SessionTrackingService.ts`  
**Type:** Static Class  
**Purpose:** Core session tracking and analytics service

#### Configuration
```typescript
interface SessionConfig {
  userId: string;
  sessionType: 'meditation' | 'sleep' | 'focus' | 'custom';
  soundIds?: string[];
  categoryId?: string;
  metadata?: Record<string, unknown>;
}

interface SessionProgress {
  currentTime: number;
  totalDuration: number;
  progressPercent: number;
}
```

#### Methods

**`startSession(config: SessionConfig): Promise<UserSession | null>`**
- Creates a new session record in `user_sessions` table
- Stores user ID, session type, sound IDs, category ID
- Captures device information (platform, version)
- Sets initial progress to 0%
- Marks session as incomplete
- Stores metadata (sound title, favorite ID, source)
- Returns session data with ID or null on error
- Prevents duplicate sessions (returns existing if active)

**`updateProgress(sessionId: string, progress: SessionProgress): Promise<void>`**
- Updates session progress in database
- Calculates progress percentage from currentTime / totalDuration
- Caps progress at 100%
- Updates `updated_at` timestamp
- Silent error handling (logs but doesn't throw)
- Works during background playback

**`completeSession(sessionId: string, durationSeconds: number): Promise<void>`**
- Completes a session
- Fetches session to get user ID
- Calculates duration in minutes
- Sets progress to 100%
- Marks session as completed
- Records session end timestamp
- Updates `updated_at` timestamp
- Triggers daily analytics update automatically
- Error handling with logging

**`cancelSession(sessionId: string, reason?: string): Promise<void>`**
- Cancels an active session
- Records cancellation reason in metadata
- Marks session as incomplete
- Records session end timestamp
- Updates `updated_at` timestamp
- Does not trigger analytics update
- Error handling with logging

**`getUserSessions(userId: string, limit: number = 50): Promise<UserSession[]>`**
- Retrieves user's session history
- Sorted by creation time (newest first)
- Limited by count parameter
- Filtered by user ID
- Returns empty array on error

**`getSessionStats(userId: string): Promise<SessionStats>`**
- Calculates comprehensive session statistics
- Total sessions count
- Completed sessions count
- Total minutes (sum of all completed sessions)
- Average session length (total minutes / completed sessions)
- Current streak (consecutive days with sessions)
- Returns default values on error

**`getMostPlayedSounds(userId: string, limit: number = 5): Promise<MostPlayedSound[]>`**
- Counts sound plays across all user sessions
- Aggregates plays from `sounds_played` array
- Sorts by play count descending
- Limits results to top N sounds
- Fetches sound metadata (title, description, category)
- Combines play counts with metadata
- Returns empty array on error or no sessions

**`getWeeklyActivity(userId: string): Promise<WeeklyActivity[]>`**
- Fetches last 7 days of sessions
- Groups sessions by date
- Calculates session count per day
- Calculates total minutes per day
- Includes days with no activity (zero values)
- Returns formatted data for chart display
- Sorted chronologically

**`updateDailyAnalytics(userId: string): Promise<void>`** (private)
- Aggregates today's sessions
- Calculates total session time
- Counts sessions started
- Counts sessions completed
- Upserts to `app_usage_analytics` table
- Called automatically after session completion
- Handles multiple sessions per day

#### Error Handling
- All methods use try-catch blocks
- Errors logged to console with `[SessionTracking]` prefix
- Methods return null or empty arrays on error
- No exceptions thrown to calling code
- Graceful degradation

#### Dependencies
- `supabase` client
- `Platform` API (React Native)
- `UserSession` type from Supabase

---

### ProductionBackendService
**File:** `src/services/ProductionBackendService.ts`  
**Type:** Service Class  
**Purpose:** Backend integration layer

#### Session Methods

**`startSession(userId, sessionType, soundsConfig): Promise<Session>`**
- Creates session via Supabase
- Stores device information
- Returns session data

**`endSession(sessionId, userId, durationMinutes): Promise<Session>`**
- Completes session
- Updates duration
- Marks as completed

**`getUserSessions(userId, limit): Promise<Session[]>`**
- Retrieves user sessions
- Sorted by creation time

#### Dependencies
- `supabase` client
- `TABLES` constants

---

### AudioService
**File:** `src/services/AudioService.ts`  
**Type:** Service Class  
**Purpose:** Audio playback with session integration

#### Session Methods

**`createSession(userId, name, tracks): Promise<string | null>`**
- Creates custom audio session
- Stores track configuration
- Returns session ID

**`loadSession(sessionId): Promise<Session>`**
- Loads saved session
- Retrieves track configuration
- Returns session data

**`updateSession(sessionId, updateData): Promise<void>`**
- Updates session data
- Handles progress updates

**`deleteSession(sessionId): Promise<void>`**
- Deletes session
- Cleanup operation

#### Dependencies
- `supabase` client
- Audio playback services

---

## 🔗 Service Dependencies

### Dependency Graph
```
AudioPlayerEnhanced
├── SessionTrackingService
│   ├── supabase client
│   │   ├── user_sessions table
│   │   ├── app_usage_analytics table
│   │   └── sound_metadata table
│   └── Platform API
│
StatsScreen
├── useSessionStats
│   └── SessionTrackingService.getSessionStats()
├── useWeeklyActivity
│   └── SessionTrackingService.getWeeklyActivity()
└── useMostPlayedSounds
    └── SessionTrackingService.getMostPlayedSounds()
```

### External Dependencies

#### Supabase
- **Database API:** Session storage and retrieval
- **Row-Level Security:** User data isolation
- **Real-time API:** (Future: real-time session updates)

#### React Native
- **Platform API:** Device information
- **AppState API:** Background/foreground detection

---

## 🔄 Service Interactions

### Session Lifecycle Flow
```
User starts playback
    │
    └─> AudioPlayerEnhanced detects playback start
        └─> SessionTrackingService.startSession()
            └─> Supabase: INSERT into user_sessions
                └─> Returns session ID
                    │
                    └─> AudioPlayerEnhanced stores session ID
                        │
                        └─> Every 30 seconds
                            └─> SessionTrackingService.updateProgress()
                                └─> Supabase: UPDATE user_sessions
                                    │
                                    └─> Playback ends
                                        └─> SessionTrackingService.completeSession()
                                            ├─> Supabase: UPDATE user_sessions
                                            └─> SessionTrackingService.updateDailyAnalytics()
                                                └─> Supabase: UPSERT app_usage_analytics
```

### Statistics Retrieval Flow
```
StatsScreen mounts
    │
    ├─> useSessionStats hook
    │   └─> SessionTrackingService.getSessionStats()
    │       └─> Supabase: SELECT from user_sessions
    │           └─> Calculate statistics
    │               └─> Return stats data
    │
    ├─> useWeeklyActivity hook
    │   └─> SessionTrackingService.getWeeklyActivity()
    │       └─> Supabase: SELECT from user_sessions (last 7 days)
    │           └─> Group by date
    │               └─> Return activity data
    │
    └─> useMostPlayedSounds hook
        └─> SessionTrackingService.getMostPlayedSounds()
            ├─> Supabase: SELECT from user_sessions
            │   └─> Count sound plays
            └─> Supabase: SELECT from sound_metadata
                └─> Combine with play counts
                    └─> Return most played sounds
```

### Analytics Aggregation Flow
```
Session completed
    │
    └─> SessionTrackingService.completeSession()
        └─> SessionTrackingService.updateDailyAnalytics()
            ├─> Supabase: SELECT from user_sessions (today)
            │   └─> Calculate totals
            │       ├─> Total session time
            │       ├─> Sessions started
            │       └─> Sessions completed
            └─> Supabase: UPSERT into app_usage_analytics
                └─> Store daily aggregates
```

---

## 🧪 Service Testing

### Unit Tests
- Session creation logic
- Progress calculation
- Statistics calculation
- Streak calculation
- Most played sounds aggregation
- Weekly activity grouping

### Integration Tests
- Supabase database operations
- Session lifecycle flow
- Analytics aggregation
- Error handling
- Background tracking

### Mocking
- Supabase client
- Platform API
- Network requests
- Database responses

---

## 📊 Service Metrics

### Performance
- **Session Creation:** < 1 second
- **Progress Update:** < 500ms
- **Session Completion:** < 1 second
- **Statistics Retrieval:** < 2 seconds
- **Weekly Activity:** < 2 seconds
- **Most Played Sounds:** < 2 seconds

### Reliability
- **Session Creation Success Rate:** > 99%
- **Progress Update Success Rate:** > 95%
- **Session Completion Success Rate:** > 99%
- **Analytics Accuracy:** > 99.9%

### Error Rates
- **Network Errors:** < 1%
- **Database Errors:** < 0.5%
- **Invalid Data Errors:** < 0.1%

---

## 🔐 Security Considerations

### Data Privacy
- Row-level security policies enforce user isolation
- Users can only access their own sessions
- No personal information in session data
- Device information anonymized

### Data Validation
- User ID validation (required, UUID format)
- Session type validation (enum check)
- Progress percentage validation (0-100)
- Duration validation (positive numbers)
- Timestamp validation

### Network Security
- All requests use HTTPS
- Supabase connection encrypted
- No credentials in session data
- Secure token management

---

## 🐛 Error Handling

### Service-Level Errors
- Network connectivity checks
- Retry logic for transient failures
- Graceful degradation
- Error logging for debugging
- User-friendly error messages

### Error Types
- **Network Errors:** Connectivity issues
- **Database Errors:** Query failures, constraint violations
- **Validation Errors:** Invalid data
- **Authentication Errors:** User not authenticated
- **Data Errors:** Missing or invalid data

---

## 📝 Service Configuration

### Database Tables
- `user_sessions` - Session records
- `app_usage_analytics` - Daily analytics
- `sound_metadata` - Sound information

### Environment Variables
- `SUPABASE_URL` - Supabase project URL
- `SUPABASE_ANON_KEY` - Supabase anonymous key

### Service Initialization
```typescript
// Services are static classes, no initialization required
// Supabase client initialized at app startup
```

---

## 🔄 Service Updates

### Future Enhancements
- Real-time session updates via Supabase Realtime
- Session export functionality
- Advanced analytics (monthly, yearly)
- Session sharing capabilities
- Session templates
- Session notes and reflections

---

*For component usage, see `components.md`*  
*For user flows, see `user-flows.md`*  
*For technical details, see `technical-spec.md`*
