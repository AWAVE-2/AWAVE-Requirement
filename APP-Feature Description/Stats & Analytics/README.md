# Stats & Analytics System - Feature Documentation

**Feature Name:** Stats & Analytics  
**Status:** ✅ Complete  
**Priority:** High  
**Last Updated:** 2025-01-27

## 📋 Feature Overview

The Stats & Analytics system provides comprehensive user statistics, progress tracking, and insights for meditation and audio sessions. It enables users to visualize their meditation journey through detailed analytics, achievement badges, and activity charts.

### Description

The Stats & Analytics system tracks and displays:
- **Session Statistics** - Total minutes, sessions, averages, and streaks
- **Achievement Badges** - Gamification with unlockable achievements
- **Activity Charts** - Visual representation of meditation activity over time
- **Most Used Sounds** - Top played sounds based on usage data
- **Time Period Analysis** - Week, month, and year views
- **Daily Analytics** - Automatic aggregation of daily session data

### User Value

- **Progress Tracking** - Visualize meditation journey and growth
- **Motivation** - Achievement badges and streaks encourage consistency
- **Insights** - Understand usage patterns and favorite sounds
- **Goal Setting** - Track progress toward weekly goals
- **Engagement** - Gamification elements increase user retention

---

## 🎯 Core Features

### 1. Session Statistics
- Total meditation minutes
- Total sessions completed
- Average session length
- Current streak (consecutive days)
- Time period filtering (week, month, year)

### 2. Achievement Badges
- Unlockable achievements with progress tracking
- Visual badge display with icons
- Progress indicators for locked badges
- Multiple achievement categories:
  - First session
  - Streak achievements (3, 7, 30 days)
  - Time-based achievements (60 minutes, 30-minute sessions)
  - Activity-based achievements (night owl, early bird, explorer)

### 3. Activity Charts
- **Week View** - Daily meditation minutes for last 7 days
- **Month View** - Weekly aggregates for last 4 weeks
- **Year View** - Monthly aggregates for 12 months
- Interactive bar charts with time labels
- Responsive design for different screen sizes

### 4. Most Used Sounds
- Top 5 most played sounds
- Play count display
- Direct playback from stats screen
- Category icons and descriptions
- Empty state for new users

### 5. Summary Statistics
- Quick stats overview cards
- Period-specific summaries
- Visual icons for each metric
- Glass morphism design

### 6. Daily Analytics Aggregation
- Automatic daily aggregation after session completion
- Tracks total session time, sessions started, sessions completed
- Stored in `app_usage_analytics` table
- Background processing

---

## 🏗️ Architecture

### Technology Stack
- **Backend:** Supabase Database
- **Services:** SessionTrackingService
- **State Management:** React Hooks (useSessionStats, useWeeklyActivity, useMostPlayedSounds)
- **Charts:** Custom React Native components
- **Storage:** Supabase `user_sessions` and `app_usage_analytics` tables

### Key Components
- `StatsScreen` - Main statistics dashboard
- `SummaryStats` - Quick stats overview
- `BadgeDisplay` - Achievement badges
- `MeditationChart` - Activity visualization
- `MostUsedSounds` - Top sounds list
- `TimePeriodTabs` - Period selection
- `StatsSummary` - Profile screen summary card

---

## 📱 Screens

1. **StatsScreen** (`/stats`) - Main statistics dashboard with all analytics
2. **ProfileScreen** - Contains `StatsSummary` component for quick overview

---

## 🔄 User Flows

### Primary Flows
1. **View Statistics** - Navigate to Stats → View all analytics → Filter by period
2. **View Achievements** - Scroll badges → See progress → Unlock achievements
3. **View Activity Chart** - Select time period → View chart → Analyze trends
4. **View Top Sounds** - See most played sounds → Play directly from list

### Data Flow
- Session completion → Daily analytics update → Stats refresh → UI update
- User opens Stats screen → Fetch session data → Calculate statistics → Display

---

## 📊 Integration Points

### Related Features
- **Session Tracking** - Source of all session data
- **Audio Player** - Tracks sound plays for "Most Used" feature
- **Profile** - Displays stats summary card
- **Authentication** - User-specific statistics

### External Services
- Supabase Database (`user_sessions` table)
- Supabase Database (`app_usage_analytics` table)
- Supabase Database (`sound_metadata` table)

---

## 🧪 Testing Considerations

### Test Cases
- Statistics calculation accuracy
- Time period filtering
- Achievement badge unlocking
- Chart data visualization
- Most played sounds ranking
- Daily analytics aggregation
- Empty states for new users
- Error handling for network failures

### Edge Cases
- No session data (new users)
- Incomplete sessions
- Network connectivity issues
- Large datasets (performance)
- Time zone handling
- Session cancellation

---

## 📚 Additional Resources

- [Session Tracking Service Documentation](../Session Tracking/)
- [Supabase Database Schema](../../SYSTEM_DESIGN_COMPATIBILITY_ANALYSIS.md)

---

## 📝 Notes

- Statistics are calculated in real-time from session data
- Daily analytics are automatically aggregated after session completion
- Achievement badges are currently mock data (TODO: implement real badge logic)
- Time period filtering for statistics is partially implemented (week/month/year views use same data)
- Chart data is formatted for week view; month/year views need full implementation

---

*For detailed technical specifications, see `technical-spec.md`*  
*For user flow diagrams, see `user-flows.md`*  
*For component details, see `components.md`*  
*For service dependencies, see `services.md`*
