# Stats & Analytics System - Feature Documentation

**Feature Name:** Stats & Analytics  
**Status:** Implemented (Swift / Firebase)  
**Priority:** High  
**Last Updated:** 2026-03

## 📋 Feature Overview

The Stats & Analytics system provides user statistics and progress tracking for meditation and audio sessions. **Data source:** Firestore `users/{userId}/playbackHistory` (session records) and **Firebase Analytics** (event stream, consent-gated). No Supabase.

### Description

The system tracks and displays:
- **Session statistics** — Total listening time, session count, current streak, longest streak, sessions this week, listening time this week, favorite category (from FirestoreSessionTracker.getStats).
- **Analytics events** — Firebase Analytics: screen views, session started/completed/abandoned/resumed, favorites, search, subscription, download, onboarding; all gated by AnalyticsConsentService (opt-in).
- **Stats UI** — Profile screen shows a stats section (StatsView) when the user is signed in; unauthenticated users see a blurred placeholder (ProfileBlurredStatsView).

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

### 6. Data sources (Swift)
- **Firestore** — `users/{userId}/playbackHistory` (session documents). FirestoreSessionTracker.getStats(userId) aggregates to UserStats (totalListeningTime, sessionCount, streaks, sessionsThisWeek, listeningTimeThisWeek, favoriteCategory).
- **Firebase Analytics** — Events (session lifecycle, screen views, favorites, etc.) when user has consented; see [Session Tracking](../Session%20Tracking/) technical-spec.

**Implemented vs mock (current iOS):**
- **Implemented:** Session-based stats (total time, session count, streaks, this week, favorite category) from Firestore via FirestoreSessionTracker.getStats; stats section on Profile (StatsView); analytics event logging (AnalyticsService + consent).
- **Not implemented / partial:** Dedicated full-screen Stats dashboard (e.g. week/month/year tabs, charts, most played sounds list) as in the legacy spec; achievement badges with real unlock logic; daily aggregation to a separate analytics table. These remain as product options; current baseline is Profile stats + Firestore playback history + Firebase Analytics events.

---

## 🏗️ Architecture

### Technology Stack
- **Backend:** Firestore (playbackHistory), Firebase Analytics (events)
- **Services:** FirestoreSessionTracker (SessionTrackingProtocol), AnalyticsService, AnalyticsConsentService
- **State:** SwiftUI; ProfileViewModel loads stats via sessionTracker.getStats(userId)

### Key Components (Swift)
- `ProfileView` / `ProfileViewModel` — Profile screen; loadStats() calls sessionTracker.getStats(userId); displays StatsView or ProfileBlurredStatsView
- `StatsView` — Displays UserStats (total listening time, session count, streaks, this week, favorite category)
- `ProfileBlurredStatsView` — Placeholder when not signed in (blurred StatsView)
- `AnalyticsService` — Event logging (consent-gated)
- `AnalyticsConsentService` — Opt-in persistence and Firebase setAnalyticsCollectionEnabled

---

## 📱 Screens

1. **Profile** — Contains stats section (StatsView) when signed in; data from FirestoreSessionTracker.getStats. No separate dedicated Stats tab in current iOS app.

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
- Firestore (`users/{userId}/playbackHistory` — session documents)
- Firebase Analytics (events; consent-gated)

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

- [Session Tracking](../Session%20Tracking/) — FirestoreSessionTracker, schema, AnalyticsService, consent

---

## 📝 Notes

- Stats are loaded from Firestore via FirestoreSessionTracker.getStats when the user opens Profile (signed-in).
- Analytics events are sent only when the user has granted analytics consent (onboarding toast; AnalyticsConsentService).
- A dedicated Stats screen with charts, period tabs, and most played sounds is not in the current iOS baseline; it can be added later and documented here.

---

*For detailed technical specifications, see `technical-spec.md`*  
*For user flow diagrams, see `user-flows.md`*  
*For component details, see `components.md`*  
*For service dependencies, see `services.md`*
