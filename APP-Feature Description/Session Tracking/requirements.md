# Session Tracking System - Functional Requirements

## 📋 Core Requirements

### 1. Session Lifecycle Management

#### Start Session
- [x] Session created automatically when audio playback begins
- [x] Session type determined from sound category (meditation, sleep, focus, custom)
- [x] User ID required for session creation
- [x] Sound IDs tracked in session
- [x] Category ID tracked in session
- [x] Device information captured (platform, version)
- [x] Session start timestamp recorded
- [x] Initial progress set to 0%
- [x] Session marked as incomplete initially
- [x] Metadata stored (sound title, favorite ID, source)
- [x] Prevents duplicate sessions (returns existing if already active)

#### Update Progress
- [x] Progress updated every 30 seconds during playback
- [x] Current playback time tracked
- [x] Total duration tracked
- [x] Progress percentage calculated (currentTime / totalDuration * 100)
- [x] Progress capped at 100%
- [x] Updated timestamp recorded
- [x] Works during background playback
- [x] Graceful error handling for failed updates

#### Complete Session
- [x] Session completed when playback ends
- [x] Session completed when player closes
- [x] Session completed on app termination
- [x] Duration calculated in seconds and converted to minutes
- [x] Session end timestamp recorded
- [x] Progress set to 100%
- [x] Session marked as completed
- [x] Daily analytics automatically updated
- [x] Graceful error handling

#### Cancel Session
- [x] Session can be cancelled if abandoned
- [x] Cancellation reason stored in metadata
- [x] Session end timestamp recorded
- [x] Session marked as incomplete
- [x] No analytics update for cancelled sessions
- [x] Graceful error handling

### 2. Session Types

#### Meditation Sessions
- [x] Default session type
- [x] Used for general meditation sounds
- [x] Tracked in session_type field

#### Sleep Sessions
- [x] Detected from category containing "sleep"
- [x] Tracked separately from meditation
- [x] Used for sleep-focused audio

#### Focus Sessions
- [x] Detected from category containing "focus"
- [x] Tracked separately from meditation
- [x] Used for focus and concentration audio

#### Custom Sessions
- [x] Support for user-defined session types
- [x] Flexible metadata storage
- [x] Tracked in session_type field

### 3. Progress Tracking

#### Real-Time Updates
- [x] Progress updates every 30 seconds
- [x] Automatic interval management
- [x] Interval cleanup on session end
- [x] Works during active playback only
- [x] Background update support

#### Progress Calculation
- [x] Percentage calculated from currentTime / totalDuration
- [x] Progress rounded to nearest integer
- [x] Progress capped at 100%
- [x] Handles zero duration gracefully
- [x] Handles invalid time values

### 4. Analytics & Statistics

#### Session Statistics
- [x] Total sessions count
- [x] Completed sessions count
- [x] Total minutes calculation
- [x] Average session length calculation
- [x] Current streak calculation
- [x] Statistics fetched on demand
- [x] Loading states handled
- [x] Error states handled

#### Streak Calculation
- [x] Consecutive days with completed sessions
- [x] Includes today and yesterday for continuity
- [x] Streak breaks if no activity today or yesterday
- [x] Counts unique dates (not session count)
- [x] Handles timezone correctly

#### Most Played Sounds
- [x] Counts plays per sound across all sessions
- [x] Sorts by play count descending
- [x] Limits results (default: 5)
- [x] Fetches sound metadata (title, description, category)
- [x] Handles missing metadata gracefully
- [x] Returns empty array if no sessions

### 5. Daily Analytics

#### Aggregation
- [x] Automatically aggregated after session completion
- [x] Calculates total session time for today
- [x] Counts sessions started today
- [x] Counts sessions completed today
- [x] Upserts to app_usage_analytics table
- [x] Date-based grouping (UTC)
- [x] Handles multiple sessions per day

#### Analytics Data
- [x] User ID stored
- [x] Date stored (YYYY-MM-DD format)
- [x] Total session time in minutes
- [x] Sessions started count
- [x] Sessions completed count
- [x] Automatic upsert (insert or update)

### 6. Weekly Activity

#### Data Retrieval
- [x] Fetches last 7 days of sessions
- [x] Groups sessions by date
- [x] Calculates session count per day
- [x] Calculates total minutes per day
- [x] Includes days with no activity (zero values)
- [x] Sorted chronologically
- [x] Formatted for chart display

#### Chart Formatting
- [x] Week view: Last 7 days with day names
- [x] Month view: 4 weeks aggregated
- [x] Year view: 12 months (placeholder)
- [x] German day/month names
- [x] Minutes formatted for display

### 7. Session History

#### Retrieval
- [x] Fetches user sessions with limit
- [x] Sorted by creation time (newest first)
- [x] Filtered by user ID
- [x] Pagination support (limit parameter)
- [x] Returns empty array on error

#### Session Data
- [x] Session ID
- [x] User ID
- [x] Session type
- [x] Start timestamp
- [x] End timestamp
- [x] Duration in minutes
- [x] Progress percentage
- [x] Completion status
- [x] Sound IDs played
- [x] Category ID
- [x] Device information
- [x] Metadata

---

## 🎯 User Stories

### As a user, I want to:
- Have my meditation sessions automatically tracked so I can see my progress
- View my total meditation time so I know how much I've practiced
- See my current streak so I stay motivated to practice daily
- View my most played sounds so I know my preferences
- See my weekly activity so I can track my consistency
- Have accurate session duration so I can measure my practice time

### As a user viewing statistics, I want to:
- See my total sessions and completion rate
- View my average session length
- See my meditation streak
- View charts of my weekly activity
- See which sounds I play most often
- Filter statistics by time period (week, month, year)

### As a user during playback, I want to:
- Have my session tracked automatically without manual action
- Have progress updated in the background
- Have my session completed when I finish listening
- Not lose session data if the app closes unexpectedly

---

## ✅ Acceptance Criteria

### Session Creation
- [x] Session created within 1 second of playback start
- [x] Session type correctly determined from sound category
- [x] All required fields populated
- [x] No duplicate sessions created
- [x] Works for all session types

### Progress Updates
- [x] Progress updates every 30 seconds during playback
- [x] Progress percentage accurate within 1%
- [x] Updates work in background
- [x] No performance impact on playback
- [x] Graceful handling of errors

### Session Completion
- [x] Session completed within 1 second of playback end
- [x] Duration calculated accurately
- [x] Daily analytics updated automatically
- [x] Works on app close
- [x] Works on player close

### Statistics
- [x] Statistics load within 2 seconds
- [x] All metrics calculated correctly
- [x] Streak calculation accurate
- [x] Most played sounds sorted correctly
- [x] Weekly activity includes all 7 days

### Analytics
- [x] Daily analytics updated within 5 seconds of session completion
- [x] Aggregation calculations accurate
- [x] Multiple sessions per day handled correctly
- [x] Date grouping accurate (UTC)

---

## 🚫 Non-Functional Requirements

### Performance
- Session creation completes in < 1 second
- Progress updates complete in < 500ms
- Statistics retrieval completes in < 2 seconds
- Weekly activity retrieval completes in < 2 seconds
- No impact on audio playback performance

### Reliability
- Session data persisted reliably
- Progress updates retry on failure
- Analytics aggregation idempotent
- Graceful degradation on errors
- Background tracking continues during network issues

### Data Integrity
- No duplicate sessions created
- Progress percentage always 0-100%
- Duration always positive
- Timestamps always valid
- User ID always present

### Scalability
- Supports thousands of sessions per user
- Efficient queries with proper indexing
- Pagination for large result sets
- Aggregation optimized for performance

---

## 🔄 Edge Cases

### Network Issues
- [x] Session creation fails gracefully
- [x] Progress updates queued for retry
- [x] Session completion retries on failure
- [x] Statistics show cached data if available
- [x] Error messages user-friendly

### App Lifecycle
- [x] Session completed on app termination
- [x] Progress tracking stops on app background
- [x] Session resumed on app foreground
- [x] No data loss on unexpected close

### Invalid Data
- [x] Zero duration handled gracefully
- [x] Negative time values prevented
- [x] Missing sound metadata handled
- [x] Invalid session types rejected
- [x] Missing user ID prevented

### Multiple Sessions
- [x] Only one active session per user
- [x] Previous session completed before new one starts
- [x] No session conflicts
- [x] Clean session state management

### Data Consistency
- [x] Analytics match session data
- [x] Streak calculation accurate
- [x] Most played sounds counts correct
- [x] Weekly activity complete
- [x] No orphaned sessions

---

## 📊 Success Metrics

- Session creation success rate > 99%
- Progress update success rate > 95%
- Session completion success rate > 99%
- Statistics load time < 2 seconds
- Analytics accuracy > 99.9%
- Zero data loss on app termination
- Background tracking reliability > 98%
