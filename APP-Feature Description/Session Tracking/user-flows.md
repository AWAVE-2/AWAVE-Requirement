# Session Tracking System - User Flows

## 🔄 Primary User Flows

### 1. Session Start Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User opens Audio Player
   └─> AudioPlayerEnhanced mounts
       └─> Audio playback initialized

2. User clicks Play button
   └─> Audio playback starts
       └─> isPlaying becomes true
           └─> useEffect detects playback start
               └─> Check if userId exists
                   ├─> No userId → Skip session creation
                   └─> userId exists → Continue
                       └─> Check if session already active
                           ├─> Active → Return existing session
                           └─> Not active → Continue
                               └─> Determine session type
                                   ├─> Category contains "sleep" → 'sleep'
                                   ├─> Category contains "focus" → 'focus'
                                   └─> Default → 'meditation'
                                       └─> SessionTrackingService.startSession()
                                           └─> Supabase: INSERT into user_sessions
                                               ├─> Error → Log error, return null
                                               └─> Success → Return session data
                                                   └─> Store session ID and start time
                                                       └─> Session tracking active
```

**Success Path:**
- Session created successfully
- Session ID stored
- Progress tracking ready

**Error Paths:**
- No userId → Session not created (silent)
- Network error → Session creation fails (logged)
- Database error → Session creation fails (logged)

---

### 2. Progress Update Flow

```
System Event                   System Response
─────────────────────────────────────────────────────────
1. Playback Active
   └─> useEffect sets up interval (30 seconds)
       └─> setInterval callback
           └─> Every 30 seconds
               └─> Check if session active
                   ├─> No session → Skip
                   └─> Session active → Continue
                       └─> Get current playback time
                           └─> Get total duration
                               └─> Calculate progress percentage
                                   └─> progressPercent = (currentTime / totalDuration) * 100
                                       └─> Cap at 100%
                                           └─> SessionTrackingService.updateProgress()
                                               └─> Supabase: UPDATE user_sessions
                                                   ├─> Error → Log error (silent)
                                                   └─> Success → Progress updated
```

**Automatic Behavior:**
- Runs every 30 seconds during playback
- No user interaction required
- Works in background
- Silent error handling

---

### 3. Session Completion Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Playback Ends (Natural)
   └─> Audio reaches end
       └─> isPlaying becomes false
           └─> useEffect cleanup triggered
               └─> Check if session active
                   ├─> No session → Skip
                   └─> Session active → Continue
                       └─> Calculate duration
                           └─> durationSeconds = (Date.now() - sessionStartTime) / 1000
                               └─> SessionTrackingService.completeSession()
                                   └─> Fetch session to get userId
                                       └─> Supabase: UPDATE user_sessions
                                           ├─> Set session_end timestamp
                                           ├─> Set duration_minutes
                                           ├─> Set progress_percent to 100
                                           ├─> Set completed to true
                                           └─> Update updated_at
                                               └─> Trigger daily analytics update
                                                   └─> SessionTrackingService.updateDailyAnalytics()
                                                       └─> Calculate today's totals
                                                           └─> Supabase: UPSERT app_usage_analytics
                                                               └─> Session completed
```

**Alternative: Player Close**
```
2. User Closes Player
   └─> closePlayer() called
       └─> Check if session active
           └─> Calculate duration
               └─> SessionTrackingService.completeSession()
                   └─> [Same flow as above]
                       └─> Close player UI
```

**Alternative: App Termination**
```
3. App Terminates
   └─> useEffect cleanup on unmount
       └─> Check if session active
           └─> Calculate duration
               └─> SessionTrackingService.completeSession()
                   └─> [Same flow as above]
```

**Success Path:**
- Session completed successfully
- Duration recorded
- Analytics updated
- Session marked as completed

**Error Paths:**
- Network error → Completion fails (logged)
- Database error → Completion fails (logged)
- Analytics update fails → Session still completed

---

### 4. Session Cancellation Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User Abandons Session
   └─> cancelSession() called
       └─> Check if session active
           ├─> No session → Return
           └─> Session active → Continue
               └─> Stop progress tracking
                   └─> SessionTrackingService.cancelSession()
                       └─> Supabase: UPDATE user_sessions
                           ├─> Set session_end timestamp
                           ├─> Set completed to false
                           ├─> Set metadata.cancelled to true
                           ├─> Set metadata.cancel_reason (if provided)
                           └─> Update updated_at
                               └─> Session cancelled
                                   └─> No analytics update
```

**Use Cases:**
- User stops playback early
- User switches to different sound
- User closes app without completing

---

### 5. Statistics View Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User navigates to Stats Screen
   └─> StatsScreen mounts
       └─> Multiple hooks initialize
           │
           ├─> useSessionStats hook
           │   └─> Check if user authenticated
           │       ├─> No user → Set empty stats
           │       └─> User exists → Continue
           │           └─> Set loading state
           │               └─> SessionTrackingService.getSessionStats()
           │                   └─> Fetch all user sessions
           │                       └─> Calculate statistics
           │                           ├─> Total sessions
           │                           ├─> Completed sessions
           │                           ├─> Total minutes
           │                           ├─> Average session length
           │                           └─> Current streak
           │                               └─> Update stats state
           │                                   └─> Set loading to false
           │
           ├─> useWeeklyActivity hook
           │   └─> Check if user authenticated
           │       ├─> No user → Set empty data
           │       └─> User exists → Continue
           │           └─> Set loading state
           │               └─> SessionTrackingService.getWeeklyActivity()
           │                   └─> Fetch last 7 days sessions
           │                       └─> Group by date
           │                           └─> Calculate count and minutes per day
           │                               └─> Format for charts
           │                                   └─> Update activity state
           │                                       └─> Set loading to false
           │
           └─> useMostPlayedSounds hook
               └─> Check if user authenticated
                   ├─> No user → Set empty list
                   └─> User exists → Continue
                       └─> Set loading state
                           └─> SessionTrackingService.getMostPlayedSounds()
                               └─> Fetch all user sessions
                                   └─> Count sound plays
                                       └─> Sort by play count
                                           └─> Fetch sound metadata
                                               └─> Combine with play counts
                                                   └─> Update sounds state
                                                       └─> Set loading to false
                                                           └─> Display statistics
```

**Success Path:**
- All data loaded successfully
- Statistics displayed
- Charts rendered
- Most played sounds listed

**Error Paths:**
- Network error → Show error state
- No sessions → Show empty state
- Missing metadata → Handle gracefully

---

### 6. Time Period Filter Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User clicks Time Period Tab
   └─> TimePeriodTabs component
       └─> onTabChange callback
           └─> Update activeTab state
               └─> StatsScreen re-renders
                   └─> useSessionStats hook
                       └─> Period filter applied
                           ├─> 'all' → Use all stats
                           └─> Other periods → Filter stats
                               └─> (Currently uses all data)
                                   └─> Update displayed stats
                                       └─> useWeeklyActivity hook
                                           └─> Get active data based on period
                                               ├─> 'week' → weekData
                                               ├─> 'month' → monthData
                                               └─> 'year' → yearData
                                                   └─> Update chart display
```

**Current Implementation:**
- Week, month, year tabs available
- Week view uses last 7 days data
- Month view uses aggregated week data
- Year view uses placeholder data

---

## 🔀 Alternative Flows

### Background Playback Flow

```
System Event                   System Response
─────────────────────────────────────────────────────────
1. App Goes to Background
   └─> AppState changes to 'background'
       └─> Audio playback continues (if configured)
           └─> Session tracking continues
               └─> Progress updates continue
                   └─> Interval still active
                       └─> Updates sent to database
                           └─> App Returns to Foreground
                               └─> Session tracking resumes normally
```

**Features:**
- Background tracking supported
- Progress updates work in background
- Session completion on app termination

---

### Multiple Sessions Prevention Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User starts new playback
   └─> Session creation attempted
       └─> Check if session already active
           ├─> No active session → Create new session
           └─> Active session exists → Return existing session
               └─> Log warning
                   └─> Use existing session
                       └─> No duplicate created
```

**Prevention:**
- Only one active session per user
- Existing session returned if active
- No session conflicts

---

### Analytics Aggregation Flow

```
System Event                   System Response
─────────────────────────────────────────────────────────
1. Session Completed
   └─> SessionTrackingService.completeSession()
       └─> SessionTrackingService.updateDailyAnalytics()
           └─> Get today's date (UTC)
               └─> Supabase: SELECT from user_sessions
                   └─> Filter by user_id and today's date
                       └─> Calculate totals
                           ├─> Total session time (sum of duration_minutes)
                           ├─> Sessions started (count)
                           └─> Sessions completed (count of completed=true)
                               └─> Supabase: UPSERT app_usage_analytics
                                   ├─> If record exists → UPDATE
                                   └─> If new → INSERT
                                       └─> Analytics updated
```

**Automatic Behavior:**
- Runs after every session completion
- Aggregates all sessions for today
- Idempotent operation (safe to retry)

---

## 🚨 Error Flows

### Network Error Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Attempt Session Operation
   └─> Network request fails
       └─> Error caught in try-catch
           └─> Error logged to console
               └─> Method returns null or empty array
                   └─> Component handles gracefully
                       ├─> Session creation → No session created
                       ├─> Progress update → Update skipped (silent)
                       ├─> Statistics → Show error state
                       └─> Activity data → Show error state
```

**Error Handling:**
- All errors logged
- Graceful degradation
- No UI blocking
- User-friendly error messages

---

### Invalid Data Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Invalid Session Data
   └─> Validation fails
       └─> Error caught
           └─> Error logged
               └─> Default values returned
                   ├─> Statistics → Zero values
                   ├─> Activity → Empty array
                   └─> Most played → Empty array
                       └─> UI displays empty state
```

**Validation:**
- User ID required
- Session type must be valid enum
- Progress percentage 0-100
- Duration must be positive

---

## 🔄 State Transitions

### Session States

```
No Session → Starting → Active → Completing → Completed
     │          │         │          │            │
     │          │         │          │            └─> Analytics Updated
     │          │         │          │
     │          │         │          └─> Cancelled (incomplete)
     │          │         │
     │          │         └─> Progress Updates (every 30s)
     │          │
     │          └─> Error → No Session
     │
     └─> Error → No Session
```

### Statistics States

```
Loading → Success
   │        │
   │        └─> Data Displayed
   │
   └─> Error → Error State
           │
           └─> Retry Available
```

---

## 📊 Flow Diagrams

### Complete Session Lifecycle

```
Audio Player Opens
    │
    ├─> User clicks Play
    │   └─> Session Created
    │       └─> Progress Tracking Starts (30s interval)
    │           │
    │           ├─> Every 30 seconds
    │           │   └─> Progress Updated
    │           │
    │           └─> Playback Ends
    │               └─> Session Completed
    │                   └─> Analytics Updated
    │
    ├─> User closes Player
    │   └─> Session Completed
    │       └─> Analytics Updated
    │
    └─> App Terminates
        └─> Session Completed
            └─> Analytics Updated
```

---

### Statistics Display Flow

```
Stats Screen Opens
    │
    ├─> Fetch Session Statistics
    │   └─> Calculate totals, averages, streak
    │       └─> Display SummaryStats
    │
    ├─> Fetch Weekly Activity
    │   └─> Get last 7 days
    │       └─> Group by date
    │           └─> Display MeditationChart
    │
    └─> Fetch Most Played Sounds
        └─> Count plays, fetch metadata
            └─> Display MostUsedSounds
```

---

## 🎯 User Goals

### Goal: Track Meditation Progress
- **Path:** Automatic session tracking
- **Time:** Transparent to user
- **Steps:** Play audio → Session tracked automatically

### Goal: View Statistics
- **Path:** Stats Screen
- **Time:** < 2 seconds
- **Steps:** Open Stats → View metrics

### Goal: See Activity Patterns
- **Path:** Weekly Activity Chart
- **Time:** < 2 seconds
- **Steps:** Open Stats → View chart

### Goal: Discover Favorite Sounds
- **Path:** Most Played Sounds
- **Time:** < 2 seconds
- **Steps:** Open Stats → View list

---

*For component interactions, see `components.md`*  
*For service calls, see `services.md`*  
*For technical details, see `technical-spec.md`*
