# Stats & Analytics System - Technical Specification

## 🏗️ Architecture Overview

### Technology Stack

#### Backend
- **Supabase Database** - Primary data storage
  - `user_sessions` table - Session tracking data
  - `app_usage_analytics` table - Daily aggregated analytics
  - `sound_metadata` table - Sound information for most played sounds

#### State Management
- **React Hooks** - Custom hooks for data fetching
  - `useSessionStats` - Session statistics
  - `useWeeklyActivity` - Activity chart data
  - `useMostPlayedSounds` - Most played sounds
- **React Context API** - `AuthContext` for user authentication
- **React State** - Local component state

#### Services Layer
- `SessionTrackingService` - Session tracking and statistics
- `analytics.ts` - Analytics event tracking

#### UI Components
- Custom React Native components
- Glass morphism effects
- Custom chart components

---

## 📁 File Structure

```
src/
├── screens/
│   ├── StatsScreen.tsx              # Main stats dashboard
│   └── ProfileScreen.tsx            # Profile with stats summary
├── components/
│   └── stats/
│       ├── BadgeDisplay.tsx         # Achievement badges
│       ├── SummaryStats.tsx         # Quick stats cards
│       ├── MeditationChart.tsx       # Activity bar chart
│       ├── MostUsedSounds.tsx        # Top sounds list
│       ├── TimePeriodTabs.tsx        # Period selector
│       ├── StatsSummary.tsx          # Profile summary card
│       ├── HealthStats.tsx           # Health integration (future)
│       └── MoodTracker.tsx           # Mood tracking (future)
├── hooks/
│   ├── useSessionStats.ts           # Session statistics hook
│   ├── useWeeklyActivity.ts         # Activity data hook
│   └── useMostPlayedSounds.ts       # Most played sounds hook
├── services/
│   ├── SessionTrackingService.ts    # Session tracking service
│   └── analytics.ts                 # Analytics events
└── integrations/
    └── supabase/
        └── client.ts                # Supabase client
```

---

## 🔧 Components

### StatsScreen
**Location:** `src/screens/StatsScreen.tsx`

**Purpose:** Main statistics dashboard displaying all analytics

**Props:** None

**State:**
- `activeTab: 'week' | 'month' | 'year'` - Selected time period

**Features:**
- Achievement badges display
- Most used sounds list
- Time period tabs
- Summary statistics cards
- Meditation activity chart
- Scrollable layout
- Loading states
- Error handling

**Dependencies:**
- `BadgeDisplay` component
- `MostUsedSounds` component
- `TimePeriodTabs` component
- `SummaryStats` component
- `MeditationChart` component
- `useSessionStats` hook
- `useWeeklyActivity` hook
- `useUnifiedTheme` hook

---

### BadgeDisplay Component
**Location:** `src/components/stats/BadgeDisplay.tsx`

**Purpose:** Display achievement badges with progress tracking

**Props:**
```typescript
interface BadgeDisplayProps {
  badges: AchievementBadge[];
}

interface AchievementBadge {
  id: string;
  name: string;
  description: string;
  icon: LucideIcon;
  unlocked: boolean;
  progress?: number; // 0-100 for locked badges
  color: string;
}
```

**Features:**
- Horizontal scrollable badge list
- Unlocked badge indicators (checkmark)
- Progress bars for locked badges
- Color-coded badges
- Icon display
- Responsive card layout

**Dependencies:**
- `useTheme` hook
- `LucideCompat` icons
- `solidBackgrounds` utility

---

### SummaryStats Component
**Location:** `src/components/stats/SummaryStats.tsx`

**Purpose:** Display quick statistics overview cards

**Props:**
```typescript
interface SummaryStatsProps {
  totalMinutes: number;
  totalSessions: number;
  averageSession: number;
  period: string;
}
```

**Features:**
- Three stat cards (Total Time, Sessions, Average)
- Period-specific labels
- Icon display for each stat
- Time formatting (hours and minutes)
- Glass morphism styling

**Dependencies:**
- `useTheme` hook
- `GlassMorphism` component
- `LucideCompat` icons

---

### MeditationChart Component
**Location:** `src/components/stats/MeditationChart.tsx`

**Purpose:** Display bar chart for meditation activity

**Props:**
```typescript
interface MeditationChartProps {
  data: ChartData[];
  period: string;
}

interface ChartData {
  name: string;
  minutes: number;
}
```

**Features:**
- Bar chart visualization
- Y-axis labels with minute values
- X-axis labels with time periods
- Value labels on bars
- Responsive sizing
- Empty state handling
- Period-specific titles

**Dependencies:**
- `useTheme` hook
- `GlassMorphism` component
- `Dimensions` API

---

### MostUsedSounds Component
**Location:** `src/components/stats/MostUsedSounds.tsx`

**Purpose:** Display top most played sounds

**Props:**
```typescript
interface MostUsedSoundsProps {
  onSoundPress?: (sound: Sound) => void;
  limit?: number; // Default: 5
}
```

**Features:**
- Top N sounds list
- Play count display
- Rank indicators (#1, #2, etc.)
- Category icons
- Play button
- Empty state
- Loading state
- Error handling

**Dependencies:**
- `useMostPlayedSounds` hook
- `useTheme` hook
- `EnhancedCard` component
- `AnimatedButton` component
- `Icon` component

---

### TimePeriodTabs Component
**Location:** `src/components/stats/TimePeriodTabs.tsx`

**Purpose:** Time period selector tabs

**Props:**
```typescript
interface TimePeriodTabsProps {
  activeTab: string;
  onTabChange: (tab: string) => void;
}
```

**Features:**
- Three tabs (Week, Month, Year)
- Active tab highlighting
- Interactive touch feedback
- Glass morphism styling

**Dependencies:**
- `useTheme` hook
- `GlassMorphism` component
- `InteractiveTouchableOpacity` component

---

### StatsSummary Component
**Location:** `src/components/stats/StatsSummary.tsx`

**Purpose:** Profile screen statistics summary card

**Props:**
```typescript
interface StatsSummaryProps {
  onViewDetails: () => void;
}
```

**Features:**
- Weekly goal progress
- Current streak display
- Unlocked badges count
- Quick stats row (sessions, average, growth)
- View details button
- Authentication-gated content
- Blur overlay for unauthenticated users
- Sign-up prompt

**Dependencies:**
- `useAuth` context
- `useTheme` hook
- `useNavigation` hook
- `EnhancedCard` component
- `BlurView` component (iOS)
- `LinearGradient` component

---

## 🔌 Services

### SessionTrackingService
**Location:** `src/services/SessionTrackingService.ts`

**Class:** Static service class

**Methods:**

**`getSessionStats(userId: string): Promise<SessionStats>`**
- Gets all user sessions
- Calculates total sessions, completed sessions
- Calculates total minutes
- Calculates average session length
- Calculates current streak
- Returns statistics object

**`getMostPlayedSounds(userId: string, limit: number): Promise<MostPlayedSound[]>`**
- Gets all user sessions
- Counts plays per sound
- Sorts by play count
- Fetches sound metadata
- Returns top N sounds with metadata

**`getWeeklyActivity(userId: string): Promise<ActivityData[]>`**
- Gets sessions from last 7 days
- Groups by date
- Calculates count and minutes per day
- Returns array of daily activity

**`updateDailyAnalytics(userId: string): Promise<void>`**
- Gets today's sessions
- Calculates totals (time, started, completed)
- Upserts to `app_usage_analytics` table
- Called automatically after session completion

**`getUserSessions(userId: string, limit: number): Promise<UserSession[]>`**
- Gets user session history
- Orders by creation date (newest first)
- Limits results

**`calculateStreak(sessions: UserSession[]): number`**
- Calculates consecutive days with sessions
- Checks for today or yesterday activity
- Counts consecutive days
- Returns streak number

---

### analytics.ts
**Location:** `src/services/analytics.ts`

**Purpose:** Analytics event tracking

**Functions:**

**`logAudioAccess(audioFile, userId): Promise<void>`**
- Logs audio file access
- Calls Supabase RPC function
- Tracks for analytics

**`trackConversionEvent(eventType, contentCategory, userId): Promise<void>`**
- Tracks conversion events
- Stores in `subscription_conversion_events` table
- Includes platform and timestamp

**`trackBusinessEvents`**
- Object with business event methods:
  - `paywallShown()`
  - `upgradeClicked()`
  - `trialStarted()`
  - `subscriptionPurchased()`

---

## 🪝 Hooks

### useSessionStats
**Location:** `src/hooks/useSessionStats.ts`

**Purpose:** Fetch and manage session statistics

**Returns:**
```typescript
{
  stats: SessionStatsData;
  isLoading: boolean;
  error: string | null;
  refresh: () => Promise<void>;
}

interface SessionStatsData {
  totalMinutes: number;
  totalSessions: number;
  averageSession: number;
  currentStreak: number;
}
```

**Features:**
- Fetches statistics from SessionTrackingService
- Supports period filtering (week, month, year, all)
- Automatic refresh on mount
- Loading and error states
- Manual refresh capability

**Dependencies:**
- `useAuth` context
- `SessionTrackingService`

---

### useWeeklyActivity
**Location:** `src/hooks/useWeeklyActivity.ts`

**Purpose:** Fetch activity data for charts

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

interface ActivityData {
  name: string;
  minutes: number;
}
```

**Features:**
- Fetches weekly activity from SessionTrackingService
- Formats data for week view (7 days)
- Aggregates for month view (4 weeks)
- Formats for year view (12 months - mock data)
- Loading and error states

**Dependencies:**
- `useAuth` context
- `SessionTrackingService`

---

### useMostPlayedSounds
**Location:** `src/hooks/useMostPlayedSounds.ts`

**Purpose:** Fetch most played sounds

**Returns:**
```typescript
{
  sounds: MostPlayedSound[];
  isLoading: boolean;
  error: string | null;
  refresh: () => Promise<void>;
}

interface MostPlayedSound {
  soundId: string;
  title: string;
  description: string;
  categoryId: string;
  playCount: number;
}
```

**Features:**
- Fetches most played sounds from SessionTrackingService
- Configurable limit (default: 5)
- Loading and error states
- Automatic refresh on mount

**Dependencies:**
- `useAuth` context
- `SessionTrackingService`

---

## 🔐 Data Models

### UserSession
```typescript
interface UserSession {
  id: string;
  user_id: string;
  session_start: string;
  session_end?: string;
  session_type: 'meditation' | 'sleep' | 'focus' | 'custom';
  sounds_played: string[];
  category_id?: string;
  duration_minutes?: number;
  completed: boolean;
  progress_percent: number;
  device_info: {
    platform: string;
    version: string;
  };
  metadata?: Record<string, unknown>;
  created_at: string;
  updated_at: string;
}
```

### AppUsageAnalytics
```typescript
interface AppUsageAnalytics {
  user_id: string;
  date: string; // YYYY-MM-DD
  total_session_time: number; // minutes
  sessions_started: number;
  sessions_completed: number;
}
```

### SessionStats
```typescript
interface SessionStats {
  totalSessions: number;
  completedSessions: number;
  totalMinutes: number;
  averageSessionLength: number;
  currentStreak: number;
}
```

---

## 🌐 API Integration

### Supabase Database Tables

**`user_sessions`**
- Stores all user meditation sessions
- Tracks start/end times, duration, completion status
- Links to sounds and categories
- Used for statistics calculation

**`app_usage_analytics`**
- Daily aggregated analytics
- One row per user per day
- Tracks total time, sessions started, sessions completed
- Updated automatically after session completion

**`sound_metadata`**
- Sound information (title, description, category)
- Used for most played sounds display
- Linked via sound IDs from sessions

---

## 📱 Platform-Specific Notes

### iOS
- BlurView for unauthenticated overlay
- Native performance optimizations

### Android
- Fallback blur effect (semi-transparent overlay)
- Same functionality as iOS

---

## 🧪 Testing Strategy

### Unit Tests
- Statistics calculation accuracy
- Streak calculation logic
- Time formatting
- Data aggregation
- Chart data formatting

### Integration Tests
- SessionTrackingService methods
- Hook data fetching
- Component rendering with data
- Error handling

### E2E Tests
- Complete stats screen flow
- Period filtering
- Achievement badge display
- Most played sounds interaction
- Chart visualization

---

## 🐛 Error Handling

### Error Types
- Network errors
- Database query failures
- Missing user data
- Invalid session data
- Empty states

### Error Messages
- User-friendly German messages
- Clear action guidance
- Retry options where applicable
- Helpful empty state messages

---

## 📊 Performance Considerations

### Optimization
- Efficient database queries with limits
- Memoized calculations
- Lazy loading of chart data
- Cached statistics (future)
- Optimized chart rendering

### Monitoring
- Statistics load time
- Chart rendering performance
- Database query performance
- Memory usage

---

*For component details, see `components.md`*  
*For service dependencies, see `services.md`*  
*For user flows, see `user-flows.md`*
