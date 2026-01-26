# Session Tracking System - Components Inventory

## 📱 Screens

### StatsScreen
**File:** `src/screens/StatsScreen.tsx`  
**Route:** `/stats`  
**Purpose:** Main statistics screen displaying session analytics

**State:**
- `activeTab: 'week' | 'month' | 'year'` - Selected time period

**Components Used:**
- `BadgeDisplay` - Achievement badges
- `SummaryStats` - Summary statistics
- `TimePeriodTabs` - Time period selector
- `MeditationChart` - Activity chart
- `MostUsedSounds` - Most played sounds list

**Hooks Used:**
- `useSessionStats` - Session statistics
- `useWeeklyActivity` - Weekly activity data
- `useUnifiedTheme` - Theme styling

**Features:**
- Achievement badges display
- Summary statistics (total minutes, sessions, average, streak)
- Time period tabs (week, month, year)
- Activity chart visualization
- Most played sounds list
- Responsive layout
- Scrollable content

**User Interactions:**
- Switch between time periods
- View achievement progress
- Scroll through statistics
- View activity charts

---

## 🧩 Components

### AudioPlayerEnhanced
**File:** `src/components/AudioPlayerEnhanced.tsx`  
**Type:** Audio Player Component with Session Tracking

**Props:**
```typescript
interface AudioPlayerEnhancedProps {
  sound: Sound;
  favoriteId?: string | null;
  onClose: () => void;
}
```

**State:**
- `currentSessionId: string | null` - Active session ID
- `sessionStartTime: number` - Session start timestamp

**Hooks Used:**
- `useSupabaseAudio` - Audio playback
- `useProductionAuth` - User authentication
- `SessionTrackingService` - Session tracking

**Features:**
- Automatic session creation on playback start
- Progress updates every 30 seconds
- Session completion on playback end
- Session completion on player close
- Session completion on app termination
- Background tracking support
- Error handling

**Session Tracking Integration:**
- Starts session when `isPlaying` becomes true
- Updates progress every 30 seconds during playback
- Completes session when playback ends or player closes
- Handles app state changes (background/foreground)

**User Interactions:**
- Play/pause audio
- Close player
- Navigate away (triggers session completion)

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
  period: 'week' | 'month' | 'year';
}
```

**Features:**
- Total minutes display
- Total sessions count
- Average session length
- Period indicator
- Formatted numbers
- Icon indicators

**Data Source:**
- `useSessionStats` hook

---

### MeditationChart
**File:** `src/components/stats/MeditationChart.tsx`  
**Type:** Activity Chart Component

**Props:**
```typescript
interface MeditationChartProps {
  data: ActivityData[];
  period: 'week' | 'month' | 'year';
}
```

**Features:**
- Bar chart visualization
- Activity data display
- Period-specific formatting
- Zero-value handling
- Responsive design

**Data Source:**
- `useWeeklyActivity` hook

---

### MostUsedSounds
**File:** `src/components/stats/MostUsedSounds.tsx`  
**Type:** Most Played Sounds List Component

**Props:**
```typescript
interface MostUsedSoundsProps {
  limit?: number; // Default: 5
}
```

**Features:**
- Most played sounds list
- Play count display
- Sound metadata (title, description)
- Sorted by play count
- Loading state
- Error state

**Data Source:**
- `useMostPlayedSounds` hook
- `SessionTrackingService.getMostPlayedSounds()`

---

### TimePeriodTabs
**File:** `src/components/stats/TimePeriodTabs.tsx`  
**Type:** Tab Selector Component

**Props:**
```typescript
interface TimePeriodTabsProps {
  activeTab: 'week' | 'month' | 'year';
  onTabChange: (tab: 'week' | 'month' | 'year') => void;
}
```

**Features:**
- Three tab options (week, month, year)
- Active tab highlighting
- Tab switching
- Responsive design

---

### BadgeDisplay
**File:** `src/components/stats/BadgeDisplay.tsx`  
**Type:** Achievement Badges Component

**Props:**
```typescript
interface BadgeDisplayProps {
  badges: AchievementBadge[];
}
```

**Features:**
- Achievement badges grid
- Unlocked/locked states
- Progress indicators
- Icon display
- Color coding

**Badge Types:**
- First session
- Streak badges (3, 7, 30 days)
- Time-based (60 minutes)
- Activity-based (focus, explorer, night owl, early bird)

---

## 🔗 Component Relationships

### StatsScreen Component Tree
```
StatsScreen
├── SafeAreaView
│   └── ScrollView
│       ├── BadgeDisplay
│       │   └── AchievementBadge[] (grid)
│       ├── MostUsedSounds
│       │   └── useMostPlayedSounds hook
│       ├── TimePeriodTabs
│       │   ├── Tab (Week)
│       │   ├── Tab (Month)
│       │   └── Tab (Year)
│       ├── SummaryStats
│       │   └── useSessionStats hook
│       └── MeditationChart
│           └── useWeeklyActivity hook
```

### AudioPlayerEnhanced Session Tracking Flow
```
AudioPlayerEnhanced
├── useEffect (Playback Start)
│   └── SessionTrackingService.startSession()
│       └── Sets currentSessionId
├── useEffect (Progress Updates)
│   └── setInterval (30s)
│       └── SessionTrackingService.updateProgress()
└── useEffect (Cleanup)
    └── SessionTrackingService.completeSession()
```

---

## 🎨 Styling

### Theme Integration
All components use the theme system via `useUnifiedTheme` hook:
- Colors: `theme.colors.primary`, `theme.colors.textPrimary`, etc.
- Typography: `theme.typography.fontFamily`
- Spacing: Consistent padding and margins

### Responsive Design
- ScrollView for small screens
- SafeAreaView for status bar handling
- Flexible layouts
- Chart responsiveness

### Accessibility
- Semantic labels
- Touch target sizes (min 44x44)
- Color contrast compliance
- Screen reader support

---

## 🔄 State Management

### Local State
- Component-specific UI state
- Loading states
- Error states
- Tab selection

### Hook State
- `useSessionStats` - Statistics data
- `useWeeklyActivity` - Activity data
- `useMostPlayedSounds` - Sound analytics
- `useSessionTracking` - Session lifecycle

### Persistent State
- Supabase database - Session records
- Supabase database - Analytics records

---

## 🧪 Testing Considerations

### Component Tests
- Statistics display accuracy
- Chart rendering
- Tab switching
- Loading states
- Error states

### Integration Tests
- Hook data fetching
- Service method calls
- Database operations
- Error handling

### E2E Tests
- Complete statistics flow
- Session tracking during playback
- Chart data updates
- Most played sounds updates

---

## 📊 Component Metrics

### Complexity
- **StatsScreen:** Medium (multiple components, data fetching)
- **AudioPlayerEnhanced:** High (audio + session tracking)
- **SummaryStats:** Low (display only)
- **MeditationChart:** Medium (chart rendering)
- **MostUsedSounds:** Medium (data fetching + display)

### Reusability
- **SummaryStats:** High (reusable statistics display)
- **MeditationChart:** High (reusable chart component)
- **TimePeriodTabs:** High (reusable tab component)
- **BadgeDisplay:** Medium (achievement-specific)

### Dependencies
- All components depend on theme system
- Statistics components depend on hooks
- AudioPlayerEnhanced depends on SessionTrackingService
- All components depend on navigation (implicit)

---

## 🔌 Integration Points

### Audio Player Integration
- `AudioPlayerEnhanced` automatically tracks sessions
- No manual session management required
- Seamless integration with audio playback

### Statistics Display
- `StatsScreen` consumes session data
- Real-time statistics updates
- Period-based filtering

### Analytics Consumption
- Components fetch data on mount
- Manual refresh capability
- Loading and error states

---

*For service dependencies, see `services.md`*  
*For user flows, see `user-flows.md`*  
*For technical details, see `technical-spec.md`*
