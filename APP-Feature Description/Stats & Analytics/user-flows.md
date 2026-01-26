# Stats & Analytics System - User Flows

## 🔄 Primary User Flows

### 1. View Statistics Dashboard Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Navigate to Stats Screen
   └─> Display StatsScreen
       └─> Show loading state
           └─> Fetch session statistics
               └─> Fetch activity data
                   └─> Fetch most played sounds
                       └─> Display all components

2. View Achievement Badges
   └─> Scroll horizontally through badges
       └─> See unlocked badges (with checkmark)
           └─> See locked badges (with progress)
               └─> Read badge descriptions

3. View Most Used Sounds
   └─> See top 5 sounds list
       └─> View play counts
           └─> Tap sound to play
               └─> Navigate to audio player

4. Select Time Period
   └─> Tap period tab (Week/Month/Year)
       └─> Update active tab
           └─> Filter statistics display
               └─> Update chart data
                   └─> Update summary stats labels

5. View Summary Statistics
   └─> See total minutes card
       └─> See total sessions card
           └─> See average session card
               └─> View period-specific labels

6. View Activity Chart
   └─> See bar chart for selected period
       └─> View Y-axis labels (minutes)
           └─> View X-axis labels (time periods)
               └─> See value labels on bars
```

**Success Path:**
- All data loads successfully
- Statistics display correctly
- Charts render properly
- User can interact with all components

**Error Paths:**
- Network error → Show error message with retry
- No data → Show empty states with helpful messages
- Loading timeout → Show error state

---

### 2. View Statistics from Profile Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Navigate to Profile Screen
   └─> Display ProfileScreen
       └─> Show StatsSummary component
           └─> Check authentication status
               ├─> Authenticated → Show stats
               └─> Not authenticated → Show blur overlay

2. View Quick Stats (Authenticated)
   └─> See weekly goal progress
       └─> See current streak
           └─> See unlocked badges count
               └─> See quick stats row
                   └─> Tap "View Details" button
                       └─> Navigate to StatsScreen

3. View Blurred Stats (Unauthenticated)
   └─> See blurred statistics
       └─> See lock icon overlay
           └─> Read sign-up prompt
               └─> Tap "Register Now" button
                   └─> Navigate to Auth Screen
```

**Success Path:**
- Authenticated users see full stats
- Unauthenticated users see sign-up prompt
- Navigation works correctly

**Error Paths:**
- Stats fetch fails → Show error state
- Authentication check fails → Show unauthenticated state

---

### 3. Session Completion Triggers Analytics Flow

```
System Event                   System Response
─────────────────────────────────────────────────────────
1. User Completes Session
   └─> SessionTrackingService.completeSession()
       └─> Update session record
           └─> Set completed = true
               └─> Set duration_minutes
                   └─> Trigger updateDailyAnalytics()

2. Daily Analytics Aggregation
   └─> Get today's sessions
       └─> Calculate totals
           ├─> Total session time
           ├─> Sessions started
           └─> Sessions completed
               └─> Upsert to app_usage_analytics
                   └─> Store daily aggregate

3. Statistics Update (Next View)
   └─> User opens Stats screen
       └─> Fetch updated statistics
           └─> Display new totals
               └─> Update charts
                   └─> Update badges (if applicable)
```

**Automatic Behavior:**
- Runs in background after session completion
- No user interaction required
- Transparent to user

---

### 4. Time Period Filtering Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. View Stats Screen (Default: Week)
   └─> Display week view
       └─> Show last 7 days data
           └─> Display "diese Woche" labels

2. Switch to Month View
   └─> Tap "Monat" tab
       └─> Update activeTab state
           └─> Filter statistics
               └─> Update chart data (4 weeks)
                   └─> Update labels to "diesen Monat"

3. Switch to Year View
   └─> Tap "Jahr" tab
       └─> Update activeTab state
           └─> Filter statistics
               └─> Update chart data (12 months)
                   └─> Update labels to "dieses Jahr"

4. Switch Back to Week View
   └─> Tap "Woche" tab
       └─> Restore week view
           └─> Display 7 days data
```

**User Experience:**
- Instant tab switching
- Smooth data updates
- Clear period labels
- Consistent chart formatting

---

### 5. Most Played Sounds Interaction Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. View Most Used Sounds Section
   └─> Display top 5 sounds list
       └─> Show loading state
           └─> Fetch play counts
               └─> Fetch sound metadata
                   └─> Display sounds with ranks

2. View Sound Details
   └─> See sound title
       └─> See play count
           └─> See category icon
               └─> See rank number (#1, #2, etc.)

3. Play Sound from List
   └─> Tap sound item
       └─> Trigger onSoundPress callback
           └─> Navigate to audio player
               └─> Start playback
```

**Success Path:**
- Sounds load successfully
- Play counts are accurate
- Navigation to player works
- Playback starts correctly

**Error Paths:**
- No sounds → Show empty state
- Fetch fails → Show error message
- Sound metadata missing → Show fallback data

---

## 🔀 Alternative Flows

### Empty State Flow (New User)

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. New User Opens Stats Screen
   └─> Check for session data
       └─> No sessions found
           └─> Display empty states
               ├─> Most Used Sounds: "Start listening..."
               ├─> Chart: No data message
               └─> Statistics: Zero values
                   └─> Show encouraging messages
```

**User Experience:**
- Helpful empty state messages
- Clear call-to-action
- Encouragement to start first session

---

### Error Recovery Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Statistics Fetch Fails
   └─> Display error state
       └─> Show error message
           └─> Provide retry option
               └─> User taps retry
                   └─> Retry fetch
                       ├─> Success → Display data
                       └─> Failure → Show error again

2. Network Connectivity Issue
   └─> Detect offline state
       └─> Show connectivity error
           └─> Suggest checking connection
               └─> Auto-retry when online
```

**Error Handling:**
- Clear error messages
- Retry capability
- Offline detection
- Graceful degradation

---

### Achievement Badge Progress Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. View Locked Badge
   └─> See progress bar
       └─> See progress percentage
           └─> Read badge description
               └─> Understand requirements

2. Complete Badge Requirement
   └─> System detects completion
       └─> Update badge status
           └─> Unlock badge
               └─> Show checkmark indicator
                   └─> Update badge display
```

**Future Implementation:**
- Automatic badge unlocking
- Progress tracking
- Notification system

---

## 🔄 State Transitions

### Statistics Loading States

```
Initial → Loading → Success
   │         │
   │         └─> Error → Retry → Loading
   │
   └─> Empty (no data)
```

### Period Tab States

```
Week → Month → Year
  ↑       ↑       ↑
  └───────┴───────┘
    (can switch between)
```

### Authentication States

```
Unauthenticated → Authenticated
       │              │
       │              └─> Full Stats
       │
       └─> Blurred Stats + Sign-up Prompt
```

---

## 📊 Flow Diagrams

### Complete Stats Screen Journey

```
Profile Screen
    │
    ├─> Tap "View Details"
    │   └─> StatsScreen
    │       ├─> Achievement Badges (scroll)
    │       ├─> Most Used Sounds (view/play)
    │       ├─> Time Period Tabs (select)
    │       ├─> Summary Statistics (view)
    │       └─> Activity Chart (view)
    │
    └─> View Stats Summary
        └─> Quick Overview
            └─> Navigate to Details (if needed)
```

---

### Session to Statistics Flow

```
Audio Player
    │
    └─> Complete Session
        │
        └─> SessionTrackingService
            ├─> Update session record
            └─> updateDailyAnalytics()
                │
                └─> app_usage_analytics table
                    │
                    └─> User Opens Stats
                        │
                        └─> Fetch Statistics
                            │
                            └─> Display Updated Data
```

---

## 🎯 User Goals

### Goal: Track Progress
- **Path:** Open Stats → View Statistics → Check Period
- **Time:** < 5 seconds
- **Steps:** 2-3 taps

### Goal: See Achievements
- **Path:** Open Stats → Scroll Badges → View Progress
- **Time:** < 3 seconds
- **Steps:** 1-2 taps

### Goal: Find Favorite Sounds
- **Path:** Open Stats → View Most Used → Play Sound
- **Time:** < 5 seconds
- **Steps:** 2-3 taps

### Goal: Analyze Patterns
- **Path:** Open Stats → Select Period → View Chart
- **Time:** < 5 seconds
- **Steps:** 2 taps

---

*For component interactions, see `components.md`*  
*For service calls, see `services.md`*  
*For technical details, see `technical-spec.md`*
