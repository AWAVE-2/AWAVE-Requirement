# Stats & Analytics System - Components Inventory

## 📱 Screens

### StatsScreen
**File:** `src/screens/StatsScreen.tsx`  
**Route:** `/stats`  
**Purpose:** Main statistics dashboard displaying all analytics

**Props:** None

**State:**
- `activeTab: 'week' | 'month' | 'year'` - Selected time period

**Components Used:**
- `BadgeDisplay` - Achievement badges
- `MostUsedSounds` - Top sounds list
- `TimePeriodTabs` - Period selector
- `SummaryStats` - Quick statistics
- `MeditationChart` - Activity visualization
- `SafeAreaView` - Safe area handling
- `ScrollView` - Scrollable content

**Hooks Used:**
- `useSessionStats` - Session statistics
- `useWeeklyActivity` - Activity chart data
- `useUnifiedTheme` - Theme styling

**Features:**
- Achievement badges display
- Most used sounds list
- Time period filtering
- Summary statistics cards
- Meditation activity chart
- Scrollable layout
- Loading states
- Error handling

**User Interactions:**
- Scroll through badges
- Tap period tabs
- View statistics
- View chart data
- Tap sounds to play

---

### ProfileScreen (Stats Integration)
**File:** `src/screens/ProfileScreen.tsx`  
**Route:** `/profile`  
**Purpose:** Profile screen with stats summary

**Components Used:**
- `StatsSummary` - Statistics summary card

**Features:**
- Quick stats overview
- Navigation to detailed stats
- Authentication-gated content

---

## 🧩 Components

### BadgeDisplay
**File:** `src/components/stats/BadgeDisplay.tsx`  
**Type:** Display Component

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
  progress?: number;
  color: string;
}
```

**State:** None (stateless)

**Components Used:**
- `ScrollView` - Horizontal scrolling
- `View` - Badge cards
- `Check` icon - Unlock indicator
- `Icon` - Badge icons

**Features:**
- Horizontal scrollable badge list
- Unlocked badge indicators (checkmark)
- Progress bars for locked badges
- Color-coded badges
- Icon display
- Responsive card layout
- Locked badge opacity

**Badge States:**
- **Unlocked:** Full color, checkmark indicator
- **Locked:** Reduced opacity, progress bar

**User Interactions:**
- Scroll horizontally through badges
- View badge details
- See progress for locked badges

---

### SummaryStats
**File:** `src/components/stats/SummaryStats.tsx`  
**Type:** Statistics Display Component

**Props:**
```typescript
interface SummaryStatsProps {
  totalMinutes: number;
  totalSessions: number;
  averageSession: number;
  period: string;
}
```

**State:** None (stateless)

**Components Used:**
- `GlassMorphism` - Card styling
- `Clock` icon - Total time icon
- `Calendar` icon - Sessions icon
- `TrendingUp` icon - Average icon

**Features:**
- Three stat cards in grid
- Period-specific labels
- Icon display for each stat
- Time formatting (hours and minutes)
- Glass morphism styling
- Responsive layout

**Stat Cards:**
1. **Total Time** - Total meditation minutes
2. **Sessions** - Total sessions count
3. **Average** - Average session length

**User Interactions:**
- View statistics
- Read period labels

---

### MeditationChart
**File:** `src/components/stats/MeditationChart.tsx`  
**Type:** Chart Visualization Component

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

**State:** None (stateless)

**Components Used:**
- `GlassMorphism` - Chart container
- `View` - Chart elements
- `Text` - Labels

**Features:**
- Bar chart visualization
- Y-axis labels with minute values
- X-axis labels with time periods
- Value labels on bars
- Responsive sizing
- Empty state handling
- Period-specific titles
- Dynamic bar heights

**Chart Elements:**
- Y-axis: Minute scale (0 to max)
- X-axis: Time period labels
- Bars: Proportional to data values
- Labels: Value display on each bar

**User Interactions:**
- View chart data
- Read values
- Compare periods

---

### MostUsedSounds
**File:** `src/components/stats/MostUsedSounds.tsx`  
**Type:** List Display Component

**Props:**
```typescript
interface MostUsedSoundsProps {
  onSoundPress?: (sound: Sound) => void;
  limit?: number; // Default: 5
}
```

**State:** Managed by `useMostPlayedSounds` hook

**Components Used:**
- `EnhancedCard` - Container card
- `FlatList` - Sound list
- `AnimatedButton` - Sound items
- `Icon` - Category and play icons
- `ActivityIndicator` - Loading state

**Features:**
- Top N sounds list
- Play count display
- Rank indicators (#1, #2, etc.)
- Category icons
- Play button
- Empty state
- Loading state
- Error handling
- Scrollable list

**List Items:**
- Rank number
- Category icon
- Sound title
- Play count
- Play button

**User Interactions:**
- View sound list
- Tap sound to play
- Scroll through sounds

---

### TimePeriodTabs
**File:** `src/components/stats/TimePeriodTabs.tsx`  
**Type:** Tab Selector Component

**Props:**
```typescript
interface TimePeriodTabsProps {
  activeTab: string;
  onTabChange: (tab: string) => void;
}
```

**State:** None (stateless)

**Components Used:**
- `GlassMorphism` - Tab container
- `InteractiveTouchableOpacity` - Tab buttons

**Features:**
- Three tabs (Week, Month, Year)
- Active tab highlighting
- Interactive touch feedback
- Glass morphism styling
- Responsive layout

**Tabs:**
- **Woche** (Week) - 7 days view
- **Monat** (Month) - 4 weeks view
- **Jahr** (Year) - 12 months view

**User Interactions:**
- Tap tab to switch period
- See active tab highlight

---

### StatsSummary
**File:** `src/components/stats/StatsSummary.tsx`  
**Type:** Summary Card Component

**Props:**
```typescript
interface StatsSummaryProps {
  onViewDetails: () => void;
}
```

**State:** None (stateless, uses mock data)

**Components Used:**
- `EnhancedCard` - Card containers
- `LinearGradient` - Gradient backgrounds
- `BlurView` - Blur overlay (iOS)
- `Icon` - Various icons
- `TouchableOpacity` - Buttons

**Features:**
- Weekly goal progress
- Current streak display
- Unlocked badges count
- Quick stats row (sessions, average, growth)
- View details button
- Authentication-gated content
- Blur overlay for unauthenticated users
- Sign-up prompt

**Sections:**
1. **Weekly Goal Card** - Progress bar and percentage
2. **Streak Card** - Current streak days
3. **Achievements Card** - Unlocked/total badges
4. **Quick Stats Row** - Sessions, average, growth
5. **Action Button** - View details or sign up

**User Interactions:**
- View quick stats
- Tap "View Details" to navigate
- Tap "Register Now" (unauthenticated)

---

### HealthStats (Future)
**File:** `src/components/stats/HealthStats.tsx`  
**Type:** Health Integration Component

**Status:** Placeholder for future implementation

**Purpose:** Display health-related statistics (HealthKit integration)

---

### MoodTracker (Future)
**File:** `src/components/stats/MoodTracker.tsx`  
**Type:** Mood Tracking Component

**Status:** Placeholder for future implementation

**Purpose:** Track and display mood data

---

## 🔗 Component Relationships

### StatsScreen Component Tree
```
StatsScreen
├── SafeAreaView
│   └── ScrollView
│       ├── BadgeDisplay
│       │   └── ScrollView (horizontal)
│       │       └── BadgeCard[] (multiple)
│       │           ├── Icon
│       │           ├── Text (name)
│       │           ├── Text (description)
│       │           ├── ProgressBar (if locked)
│       │           └── Check (if unlocked)
│       │
│       ├── MostUsedSounds
│       │   ├── EnhancedCard
│       │   │   ├── Header (Icon + Text)
│       │   │   └── FlatList
│       │   │       └── SoundItem[] (multiple)
│       │   │           ├── Rank
│       │   │           ├── Category Icon
│       │   │           ├── Title
│       │   │           ├── Play Count
│       │   │           └── Play Button
│       │   │
│       │   ├── LoadingState (conditional)
│       │   ├── ErrorState (conditional)
│       │   └── EmptyState (conditional)
│       │
│       ├── TimePeriodTabs
│       │   └── GlassMorphism
│       │       └── Tab[] (3 tabs)
│       │           └── InteractiveTouchableOpacity
│       │               └── Text (label)
│       │
│       ├── SummaryStats
│       │   └── StatsGrid
│       │       └── StatCard[] (3 cards)
│       │           ├── GlassMorphism
│       │           ├── Icon
│       │           ├── Value
│       │           ├── Label
│       │           └── Subtitle
│       │
│       └── MeditationChart
│           ├── Title
│           └── GlassMorphism
│               └── Chart
│                   ├── YAxis (labels)
│                   └── BarsContainer
│                       └── Bar[] (multiple)
│                           ├── Bar (visual)
│                           ├── XAxisLabel
│                           └── ValueLabel
```

### ProfileScreen Stats Integration
```
ProfileScreen
└── StatsSummary
    ├── SectionHeader
    │   ├── Icon
    │   ├── Title
    │   └── Description
    │
    ├── ContentWrapper
    │   ├── WeeklyGoalCard
    │   │   ├── Header
    │   │   ├── Progress
    │   │   └── ProgressBar
    │   │
    │   ├── StatsGrid
    │   │   ├── StreakCard
    │   │   └── AchievementsCard
    │   │
    │   ├── QuickStatsRow
    │   │   ├── SessionsCard
    │   │   ├── AverageCard
    │   │   └── GrowthCard
    │   │
    │   └── ActionButton
    │
    └── Overlay (if unauthenticated)
        ├── BlurView
        ├── LockIcon
        ├── Title
        ├── Description
        └── SignUpButton
```

---

## 🎨 Styling

### Theme Integration
All components use the theme system via `useTheme` or `useUnifiedTheme` hooks:
- Colors: `theme.colors.primary`, `theme.colors.textPrimary`, etc.
- Typography: `theme.typography.fontFamily` (Raleway)
- Spacing: Consistent padding and margins
- Glass morphism effects

### Responsive Design
- ScrollView for vertical scrolling
- Horizontal ScrollView for badges
- Responsive chart sizing
- Flexible layouts for different screen sizes

### Accessibility
- Semantic labels
- Touch target sizes (min 44x44)
- Color contrast compliance
- Screen reader support
- Clear visual hierarchy

---

## 🔄 State Management

### Local State
- Component-level state (activeTab, etc.)
- Hook-managed state (stats, loading, errors)

### Context State
- `AuthContext` - User authentication
- User session data

### Server State
- Supabase database - Session and analytics data
- Real-time updates (future)

---

## 🧪 Testing Considerations

### Component Tests
- Badge display and progress
- Chart rendering
- Statistics calculation
- Empty states
- Error states
- Loading states

### Integration Tests
- Hook data fetching
- Service method calls
- Navigation flows
- User interactions

### E2E Tests
- Complete stats screen flow
- Period filtering
- Sound playback from list
- Navigation from profile

---

## 📊 Component Metrics

### Complexity
- **StatsScreen:** Medium (multiple components, state management)
- **BadgeDisplay:** Low (display only)
- **SummaryStats:** Low (display only)
- **MeditationChart:** Medium (chart calculations)
- **MostUsedSounds:** Medium (list + interactions)
- **TimePeriodTabs:** Low (simple tabs)
- **StatsSummary:** High (multiple sections, auth logic)

### Reusability
- **BadgeDisplay:** High (used in StatsScreen)
- **SummaryStats:** High (used in StatsScreen)
- **MeditationChart:** High (used in StatsScreen)
- **MostUsedSounds:** High (used in StatsScreen)
- **TimePeriodTabs:** High (used in StatsScreen)
- **StatsSummary:** Medium (used in ProfileScreen)

### Dependencies
- All components depend on theme system
- All components depend on hooks for data
- Chart components depend on data formatting
- StatsSummary depends on authentication

---

*For service dependencies, see `services.md`*  
*For user flows, see `user-flows.md`*  
*For technical details, see `technical-spec.md`*
