# Session Tracking System - Feature Documentation

**Feature Name:** Session Tracking & Analytics  
**Status:** ✅ Complete  
**Priority:** High  
**Last Updated:** 2025-01-27

## 📋 Feature Overview

The Session Tracking system provides comprehensive tracking and analytics for user meditation and audio playback sessions. It captures session lifecycle events, progress updates, completion metrics, and generates insights for user statistics and analytics dashboards.

### Description

The session tracking system is built on Supabase and provides:
- **Session lifecycle management** - Start, progress, complete, and cancel sessions
- **Real-time progress tracking** - Periodic updates during playback
- **Analytics aggregation** - Daily, weekly, and lifetime statistics
- **Session history** - Complete session records with metadata
- **Streak calculation** - Consecutive days with completed sessions
- **Most played sounds** - Analytics on user preferences
- **Weekly activity charts** - Visual representation of usage patterns

### User Value

- **Progress visibility** - Users can see their meditation journey and statistics
- **Motivation** - Streaks and achievements encourage consistent practice
- **Insights** - Understand usage patterns and favorite sounds
- **Accountability** - Track completion rates and session duration
- **Personalization** - Data-driven recommendations based on usage

---

## 🎯 Core Features

### 1. Session Lifecycle Management
- Start session when audio playback begins
- Track session progress during playback
- Complete session when playback ends
- Cancel session if abandoned
- Automatic session completion on app close

### 2. Progress Tracking
- Real-time progress updates (every 30 seconds)
- Progress percentage calculation
- Current time and total duration tracking
- Background progress tracking support

### 3. Session Types
- **Meditation** - Default session type
- **Sleep** - Sleep-focused audio sessions
- **Focus** - Focus and concentration sessions
- **Custom** - User-defined session types

### 4. Analytics & Statistics
- **Total sessions** - Count of all sessions
- **Completed sessions** - Count of finished sessions
- **Total minutes** - Cumulative session duration
- **Average session length** - Mean duration per session
- **Current streak** - Consecutive days with sessions
- **Most played sounds** - Top sounds by play count

### 5. Daily Analytics
- Automatic aggregation of daily statistics
- Sessions started per day
- Sessions completed per day
- Total session time per day
- Stored in `app_usage_analytics` table

### 6. Weekly Activity
- Last 7 days activity data
- Session count per day
- Minutes per day
- Formatted for chart visualization
- Supports week, month, and year views

### 7. Session History
- Complete session records
- Filterable by date range
- Sortable by creation time
- Pagination support
- Metadata preservation

---

## 🏗️ Architecture

### Technology Stack
- **Backend:** Supabase Database
- **Tables:**
  - `user_sessions` - Session records
  - `app_usage_analytics` - Daily aggregated analytics
  - `sound_metadata` - Sound information for analytics
- **State Management:** React Hooks
- **Storage:** Supabase (cloud database)

### Key Components
- `SessionTrackingService` - Core session tracking service
- `useSessionTracking` - Hook for audio player integration
- `useSessionStats` - Hook for statistics display
- `useWeeklyActivity` - Hook for activity charts
- `useMostPlayedSounds` - Hook for sound analytics
- `useUserSessions` - Legacy hook for session management

---

## 📱 Integration Points

### Audio Player Integration
- Automatically starts session when playback begins
- Updates progress every 30 seconds during playback
- Completes session when playback ends or player closes
- Handles app background/foreground transitions

### Stats Screen Integration
- Displays session statistics
- Shows weekly activity charts
- Lists most played sounds
- Calculates and displays streaks

### Background Audio Support
- Session tracking continues in background
- Progress updates work during background playback
- Session completion on app termination

---

## 🔄 User Flows

### Primary Flows
1. **Start Session Flow** - Playback begins → Session created → Progress tracking starts
2. **Progress Update Flow** - Every 30 seconds → Progress updated → Database updated
3. **Complete Session Flow** - Playback ends → Session completed → Analytics updated
4. **Cancel Session Flow** - User abandons → Session cancelled → No analytics update

### Analytics Flows
- **Daily Aggregation** - Session completed → Calculate daily totals → Update analytics
- **Statistics Retrieval** - Stats screen opens → Fetch user stats → Display metrics
- **Activity Chart** - Chart renders → Fetch weekly data → Display visualization

---

## 🔐 Data Privacy

- All session data is user-specific
- Row-level security policies enforce data isolation
- No personal information stored in sessions
- Device information anonymized
- Analytics aggregated at user level

---

## 📊 Integration Points

### Related Features
- **Audio Player** - Session start/stop triggers
- **Stats & Analytics** - Data consumption for displays
- **Background Audio** - Continuous tracking support
- **User Profile** - Statistics display

### External Services
- Supabase Database (session storage)
- Supabase Analytics (aggregation)
- Sound Metadata Service (sound information)

---

## 🧪 Testing Considerations

### Test Cases
- Session creation on playback start
- Progress updates during playback
- Session completion on playback end
- Session cancellation on abandonment
- Daily analytics aggregation
- Statistics calculation
- Streak calculation
- Most played sounds calculation
- Weekly activity data retrieval

### Edge Cases
- Network connectivity issues during tracking
- App termination during active session
- Multiple simultaneous sessions (prevented)
- Invalid session data
- Missing sound metadata
- Empty session history

---

## 📚 Additional Resources

- [Supabase Database Documentation](https://supabase.com/docs/guides/database)
- [React Native Background Tasks](https://reactnative.dev/docs/background-tasks)

---

## 📝 Notes

- Sessions are automatically created when audio playback starts
- Progress updates occur every 30 seconds during active playback
- Daily analytics are aggregated automatically after session completion
- Streak calculation includes today and yesterday for continuity
- Most played sounds require sound metadata to be available
- Session cancellation does not count toward completion statistics

---

*For detailed technical specifications, see `technical-spec.md`*  
*For user flow diagrams, see `user-flows.md`*  
*For component details, see `components.md`*  
*For service dependencies, see `services.md`*
