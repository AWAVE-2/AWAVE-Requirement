# Session Tracking System - Technical Specification

## 🏗️ Architecture Overview

### Technology Stack

#### Backend
- **Supabase Database** - Primary data storage
  - `user_sessions` table - Session records
  - `app_usage_analytics` table - Daily aggregated analytics
  - `sound_metadata` table - Sound information for analytics
  - Row-level security policies
  - Automatic timestamp management

#### State Management
- **React Hooks** - Component state management
  - `useSessionTracking` - Session lifecycle hook
  - `useSessionStats` - Statistics hook
  - `useWeeklyActivity` - Activity data hook
  - `useMostPlayedSounds` - Sound analytics hook
  - `useUserSessions` - Legacy session hook

#### Services Layer
- `SessionTrackingService` - Core session tracking service (static class)
- `ProductionBackendService` - Backend integration layer
- `AudioService` - Audio playback integration

---

## 📁 File Structure

```
src/
├── services/
│   ├── SessionTrackingService.ts      # Core session tracking service
│   └── ProductionBackendService.ts    # Backend integration
├── hooks/
│   ├── useSessionTracking.ts           # Session lifecycle hook
│   ├── useSessionStats.ts              # Statistics hook
│   ├── useWeeklyActivity.ts            # Weekly activity hook
│   ├── useMostPlayedSounds.ts          # Most played sounds hook
│   └── useUserSessions.ts              # Legacy session hook
├── components/
│   ├── AudioPlayerEnhanced.tsx         # Audio player with session tracking
│   └── stats/
│       ├── SummaryStats.tsx             # Statistics display
│       ├── MeditationChart.tsx         # Activity chart
│       └── MostUsedSounds.tsx          # Most played sounds
└── screens/
    └── StatsScreen.tsx                 # Statistics screen
```

---

## 🔧 Services

### SessionTrackingService
**Location:** `src/services/SessionTrackingService.ts`

**Type:** Static Class

**Purpose:** Core session tracking and analytics service

#### Methods

**`startSession(config: SessionConfig): Promise<UserSession | null>`**
- Creates a new session record
- Stores user ID, session type, sound IDs, category ID
- Captures device information (platform, version)
- Sets initial progress to 0%
- Marks session as incomplete
- Returns session data with ID or null on error

**`updateProgress(sessionId: string, progress: SessionProgress): Promise<void>`**
- Updates session progress percentage
- Calculates percentage from currentTime / totalDuration
- Caps progress at 100%
- Updates timestamp
- Silent error handling (logs but doesn't throw)

**`completeSession(sessionId: string, durationSeconds: number): Promise<void>`**
- Completes a session
- Calculates duration in minutes
- Sets progress to 100%
- Marks session as completed
- Records session end timestamp
- Triggers daily analytics update
- Error handling with logging

**`cancelSession(sessionId: string, reason?: string): Promise<void>`**
- Cancels an active session
- Records cancellation reason in metadata
- Marks session as incomplete
- Records session end timestamp
- Does not trigger analytics update

**`getUserSessions(userId: string, limit: number): Promise<UserSession[]>`**
- Retrieves user's session history
- Sorted by creation time (newest first)
- Limited by count parameter
- Returns empty array on error

**`getSessionStats(userId: string): Promise<SessionStats>`**
- Calculates session statistics
- Total sessions count
- Completed sessions count
- Total minutes
- Average session length
- Current streak
- Returns default values on error

**`getMostPlayedSounds(userId: string, limit: number): Promise<MostPlayedSound[]>`**
- Counts sound plays across all sessions
- Sorts by play count descending
- Fetches sound metadata
- Returns top N sounds
- Returns empty array on error

**`getWeeklyActivity(userId: string): Promise<WeeklyActivity[]>`**
- Fetches last 7 days of sessions
- Groups by date
- Calculates count and minutes per day
- Includes days with no activity
- Returns formatted data for charts

**`updateDailyAnalytics(userId: string): Promise<void>`** (private)
- Aggregates today's sessions
- Calculates total time, started count, completed count
- Upserts to app_usage_analytics table
- Called automatically after session completion

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

#### Error Handling
- All methods use try-catch blocks
- Errors logged to console
- Methods return null or empty arrays on error
- No exceptions thrown to calling code
- Graceful degradation

---

## 🪝 Hooks

### useSessionTracking
**Location:** `src/hooks/useSessionTracking.ts`

**Purpose:** Session lifecycle management hook for audio player

**Options:**
```typescript
interface UseSessionTrackingOptions {
  userId: string | null;
  sessionType?: 'meditation' | 'sleep' | 'focus' | 'custom';
  autoStart?: boolean;
}
```

**Returns:**
```typescript
{
  startSession: (soundIds?, categoryId?) => Promise<UserSession | null>;
  completeSession: () => Promise<void>;
  cancelSession: (reason?) => Promise<void>;
  updateProgress: (currentTime, totalDuration) => Promise<void>;
  startProgressTracking: (getCurrentTime, getTotalDuration) => void;
  stopProgressTracking: () => void;
  getCurrentSession: () => UserSession | null;
  isSessionActive: () => boolean;
}
```

**Features:**
- Session lifecycle management
- Progress tracking with intervals
- Automatic cleanup on unmount
- Prevents duplicate sessions
- Ref-based state management

---

### useSessionStats
**Location:** `src/hooks/useSessionStats.ts`

**Purpose:** Fetch and display session statistics

**Parameters:**
- `period: 'week' | 'month' | 'year' | 'all'` - Time period filter

**Returns:**
```typescript
{
  stats: {
    totalMinutes: number;
    totalSessions: number;
    averageSession: number;
    currentStreak: number;
  };
  isLoading: boolean;
  error: string | null;
  refresh: () => Promise<void>;
}
```

**Features:**
- Automatic data fetching
- Loading and error states
- Manual refresh capability
- Period filtering (currently uses all data)

---

### useWeeklyActivity
**Location:** `src/hooks/useWeeklyActivity.ts`

**Purpose:** Fetch weekly activity data for charts

**Returns:**
```typescript
{
  weekData: ActivityData[];
  monthData: ActivityData[];
  yearData: ActivityData[];
  isLoading: boolean;
  error: string | null;
  refresh: () => Promise<void>;
}
```

**Features:**
- Last 7 days data
- Formatted for week, month, year views
- German day/month names
- Includes zero-value days
- Loading and error states

---

### useMostPlayedSounds
**Location:** `src/hooks/useMostPlayedSounds.ts`

**Purpose:** Fetch most played sounds analytics

**Parameters:**
- `limit: number` - Maximum number of sounds (default: 5)

**Returns:**
```typescript
{
  sounds: MostPlayedSound[];
  isLoading: boolean;
  error: string | null;
  refresh: () => Promise<void>;
}
```

**Features:**
- Play count calculation
- Sound metadata fetching
- Sorted by play count
- Loading and error states

---

### useUserSessions
**Location:** `src/hooks/useUserSessions.ts`

**Purpose:** Legacy session management hook

**Returns:**
```typescript
{
  startSession: (sessionType) => Promise<Session | null>;
  endSession: (sessionId, sounds_played) => Promise<Session | null>;
}
```

**Features:**
- Basic session start/end
- Daily analytics update
- Device information capture
- Legacy compatibility

---

## 🗄️ Database Schema

### user_sessions Table

```sql
CREATE TABLE user_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  session_start TIMESTAMPTZ NOT NULL,
  session_end TIMESTAMPTZ,
  session_type TEXT NOT NULL CHECK (session_type IN ('meditation', 'sleep', 'focus', 'custom')),
  sounds_played JSONB DEFAULT '[]',
  category_id TEXT,
  device_info JSONB,
  metadata JSONB,
  completed BOOLEAN DEFAULT false,
  progress_percent INTEGER DEFAULT 0,
  duration_minutes INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Indexes:**
- `idx_user_sessions_user_id` - User ID lookup
- `idx_user_sessions_created_at` - Time-based queries
- `idx_user_sessions_type` - Session type filtering

**Row-Level Security:**
- Users can only access their own sessions
- INSERT, SELECT, UPDATE, DELETE policies

---

### app_usage_analytics Table

```sql
CREATE TABLE app_usage_analytics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  date DATE NOT NULL,
  total_session_time INTEGER DEFAULT 0,
  sessions_started INTEGER DEFAULT 0,
  sessions_completed INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, date)
);
```

**Indexes:**
- `idx_app_usage_analytics_user_id` - User ID lookup
- `idx_app_usage_analytics_date` - Date-based queries
- `idx_app_usage_analytics_user_date` - Composite index

**Row-Level Security:**
- Users can view and insert their own analytics
- Service role can manage all analytics

---

## 🔄 State Management

### Session State (useSessionTracking)
```typescript
{
  sessionRef: UserSession | null;
  startTimeRef: number;
  progressIntervalRef: ReturnType<typeof setInterval> | null;
}
```

### Statistics State (useSessionStats)
```typescript
{
  stats: SessionStatsData;
  isLoading: boolean;
  error: string | null;
}
```

### Activity State (useWeeklyActivity)
```typescript
{
  weekData: ActivityData[];
  monthData: ActivityData[];
  yearData: ActivityData[];
  isLoading: boolean;
  error: string | null;
}
```

---

## 🌐 API Integration

### Supabase Database Operations

**Session Operations:**
- `supabase.from('user_sessions').insert()` - Create session
- `supabase.from('user_sessions').update()` - Update session
- `supabase.from('user_sessions').select()` - Query sessions
- `supabase.from('user_sessions').delete()` - Delete session (future)

**Analytics Operations:**
- `supabase.from('app_usage_analytics').upsert()` - Update daily analytics
- `supabase.from('app_usage_analytics').select()` - Query analytics

**Sound Metadata:**
- `supabase.from('sound_metadata').select()` - Fetch sound information

---

## 📱 Platform-Specific Notes

### iOS
- Device info: `Platform.OS = 'ios'`
- Version: `Platform.Version` (string)
- Background tracking supported

### Android
- Device info: `Platform.OS = 'android'`
- Version: `Platform.Version` (number)
- Background tracking supported

### Background Playback
- Sessions continue tracking in background
- Progress updates work during background playback
- Session completion on app termination

---

## 🧪 Testing Strategy

### Unit Tests
- Session creation logic
- Progress calculation
- Streak calculation
- Statistics calculation
- Most played sounds sorting

### Integration Tests
- Supabase database operations
- Session lifecycle flow
- Analytics aggregation
- Error handling

### E2E Tests
- Complete session flow
- Progress updates
- Statistics display
- Weekly activity charts

---

## 🐛 Error Handling

### Error Types
- Network errors
- Database errors
- Invalid session data
- Missing sound metadata
- User not authenticated

### Error Messages
- User-friendly error messages
- Console logging for debugging
- Graceful degradation
- No UI blocking errors

---

## 📊 Performance Considerations

### Optimization
- Efficient database queries with indexes
- Pagination for large result sets
- Cached statistics where possible
- Debounced progress updates (30s interval)
- Batch analytics updates

### Monitoring
- Session creation success rate
- Progress update success rate
- Statistics load time
- Analytics aggregation time
- Database query performance

---

## 🔐 Security Considerations

### Data Privacy
- Row-level security policies
- User-specific data isolation
- No personal information in sessions
- Device info anonymized

### Data Validation
- User ID validation
- Session type validation
- Progress percentage validation (0-100)
- Duration validation (positive numbers)

---

*For component details, see `components.md`*  
*For service dependencies, see `services.md`*  
*For user flows, see `user-flows.md`*
