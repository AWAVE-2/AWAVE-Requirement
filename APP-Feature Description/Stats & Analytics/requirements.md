# Stats & Analytics System - Functional Requirements

## 📋 Core Requirements

### 1. Session Statistics Display

#### Overview Statistics
- [x] Display total meditation minutes
- [x] Display total sessions completed
- [x] Display average session length
- [x] Display current streak (consecutive days)
- [x] Format time values (hours and minutes)
- [x] Period-specific filtering (week, month, year)
- [x] Real-time data updates
- [x] Loading states during data fetch
- [x] Error handling for failed requests

#### Statistics Calculation
- [x] Calculate total minutes from completed sessions
- [x] Count total sessions (started and completed)
- [x] Calculate average session length
- [x] Calculate current streak from session dates
- [x] Filter sessions by time period
- [x] Handle empty data states

### 2. Achievement Badges System

#### Badge Display
- [x] Display achievement badges in horizontal scroll
- [x] Show badge name and description
- [x] Display badge icons
- [x] Visual distinction between unlocked and locked badges
- [x] Progress indicators for locked badges
- [x] Unlock indicators (checkmark) for unlocked badges
- [x] Color-coded badges by category

#### Badge Types
- [x] First session achievement
- [x] Streak achievements (3, 7, 30 days)
- [x] Time-based achievements (60 minutes total, 30-minute sessions)
- [x] Activity-based achievements (night owl, early bird)
- [x] Exploration achievements (try different sounds)
- [x] Progress tracking for each badge

#### Badge Logic (Future)
- [ ] Automatic badge unlocking based on user activity
- [ ] Progress calculation for each badge type
- [ ] Badge notification system
- [ ] Badge history tracking

### 3. Activity Charts

#### Chart Display
- [x] Display bar chart for meditation activity
- [x] Week view (last 7 days)
- [x] Month view (4 weeks aggregated)
- [x] Year view (12 months aggregated)
- [x] Time period tabs for switching views
- [x] Y-axis labels with minute values
- [x] X-axis labels with time periods
- [x] Value labels on each bar
- [x] Responsive chart sizing
- [x] Empty state handling

#### Chart Data
- [x] Fetch weekly activity data
- [x] Format data for week view
- [x] Aggregate data for month view
- [x] Aggregate data for year view
- [x] Calculate maximum value for scaling
- [x] Handle zero/minimal data

### 4. Most Used Sounds

#### Sound List Display
- [x] Display top 5 most played sounds
- [x] Show sound title and description
- [x] Display play count for each sound
- [x] Show category icons
- [x] Rank display (#1, #2, etc.)
- [x] Play button for each sound
- [x] Empty state for new users
- [x] Loading state during fetch
- [x] Error state handling

#### Sound Data
- [x] Fetch most played sounds from session data
- [x] Count plays per sound from sessions
- [x] Sort sounds by play count
- [x] Limit results to top N sounds
- [x] Fetch sound metadata (title, description, category)
- [x] Handle sounds with missing metadata

### 5. Summary Statistics

#### Quick Stats Cards
- [x] Display weekly goal progress
- [x] Show current streak
- [x] Display unlocked badges count
- [x] Show sessions count
- [x] Display average minutes
- [x] Show growth percentage
- [x] Period-specific labels
- [x] Visual icons for each stat

#### Profile Integration
- [x] Stats summary card on profile screen
- [x] Navigation to detailed stats screen
- [x] Authentication-gated content
- [x] Blur overlay for unauthenticated users
- [x] Sign-up prompt for unauthenticated users

### 6. Daily Analytics Aggregation

#### Automatic Aggregation
- [x] Aggregate daily session data after completion
- [x] Calculate total session time for the day
- [x] Count sessions started
- [x] Count sessions completed
- [x] Store in `app_usage_analytics` table
- [x] Upsert to prevent duplicates
- [x] Error handling for aggregation failures

#### Analytics Data
- [x] Track total session time per day
- [x] Track sessions started per day
- [x] Track sessions completed per day
- [x] Date-based storage
- [x] User-specific analytics

---

## 🎯 User Stories

### As a user, I want to:
- View my total meditation time so I can see my progress
- See my current streak so I stay motivated to meditate daily
- View achievement badges so I feel rewarded for my practice
- See my most played sounds so I can quickly access favorites
- View activity charts so I can understand my meditation patterns
- Filter statistics by time period so I can analyze different timeframes
- See weekly goal progress so I can track my goals

### As a new user, I want to:
- See empty states with helpful messages
- Understand what statistics will be available
- Be prompted to start my first session

### As a returning user, I want to:
- See updated statistics after each session
- Track my progress over time
- Unlock new achievements as I progress
- Compare my activity across different time periods

---

## ✅ Acceptance Criteria

### Statistics Display
- [x] Statistics load within 2 seconds
- [x] All metrics display correctly formatted values
- [x] Period filtering updates statistics display
- [x] Loading states show during data fetch
- [x] Error messages are user-friendly

### Achievement Badges
- [x] Badges display in horizontal scroll
- [x] Unlocked badges show checkmark indicator
- [x] Locked badges show progress percentage
- [x] Badge descriptions are clear and motivating
- [x] Badge colors are visually distinct

### Activity Charts
- [x] Charts render correctly for all time periods
- [x] Bar heights scale proportionally to data
- [x] Labels are readable and accurate
- [x] Empty states show helpful messages
- [x] Charts are responsive to screen size

### Most Used Sounds
- [x] Top 5 sounds display correctly
- [x] Play counts are accurate
- [x] Sounds are sorted by play count
- [x] Empty state shows for new users
- [x] Play button navigates to audio player

### Daily Analytics
- [x] Analytics aggregate automatically after session completion
- [x] Data is stored correctly in database
- [x] No duplicate entries for same day
- [x] Aggregation handles errors gracefully

---

## 🚫 Non-Functional Requirements

### Performance
- Statistics load within 2 seconds
- Chart rendering is smooth (60fps)
- Data aggregation doesn't block UI
- Efficient database queries

### Usability
- Clear visual hierarchy
- Intuitive navigation
- Helpful empty states
- Accessible UI components
- Responsive design

### Reliability
- Graceful error handling
- Offline state detection
- Data persistence
- Automatic retry for failed requests

### Data Accuracy
- Statistics match actual session data
- Streak calculation is accurate
- Play counts are correct
- Time calculations handle timezones

---

## 🔄 Edge Cases

### No Data
- [x] Empty states for new users
- [x] Zero values display correctly
- [x] Helpful messages encourage first session

### Incomplete Sessions
- [x] Only completed sessions count toward statistics
- [x] Cancelled sessions don't affect totals
- [x] Progress tracking handles partial sessions

### Network Issues
- [x] Offline detection
- [x] Error messages for failed requests
- [x] Retry capability
- [x] Cached data display when available

### Large Datasets
- [x] Efficient querying with limits
- [x] Pagination for session history
- [x] Performance optimization for charts
- [x] Memory management

### Time Zone Handling
- [x] Consistent date calculations
- [x] Streak calculation handles timezones
- [x] Daily aggregation uses correct dates

---

## 📊 Success Metrics

- Statistics screen load time < 2 seconds
- Chart rendering performance > 60fps
- Daily analytics aggregation success rate > 99%
- User engagement with stats screen > 40%
- Achievement badge unlock rate > 30%
- Most used sounds feature usage > 25%

---

## 🔮 Future Enhancements

### Planned Features
- [ ] Real-time badge unlocking logic
- [ ] Badge notification system
- [ ] Export statistics to PDF/CSV
- [ ] Share statistics on social media
- [ ] Comparison with previous periods
- [ ] Goal setting and tracking
- [ ] Personalized insights and recommendations
- [ ] Mood tracking integration
- [ ] Health stats integration (HealthKit)
- [ ] Advanced filtering options

### Technical Improvements
- [ ] Period-specific statistics calculation
- [ ] Caching for improved performance
- [ ] Real-time updates via Supabase subscriptions
- [ ] Background sync for analytics
- [ ] Optimized database queries
- [ ] Chart animation improvements
