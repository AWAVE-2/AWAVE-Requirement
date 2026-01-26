# Search Drawer - Technical Specification

## 🏗️ Architecture Overview

### Technology Stack

#### Frontend
- **React Native** - Mobile app framework
- **TypeScript** - Type safety and development experience
- **React Native Reanimated** - Smooth animations (via BottomSheet)
- **React Native Gesture Handler** - Swipe gestures
- **React Native Linear Gradient** - Gradient backgrounds

#### Backend
- **Supabase** - PostgreSQL database with full-text search
- **ProductionBackendService** - Backend integration layer
- **SearchService** - Search-specific service utilities

#### State Management
- **React Hooks** - useState, useEffect, useCallback
- **Custom Hooks** - useIntelligentSearch, useDebounce
- **Context API** - useAuth for user context

---

## 📁 File Structure

```
src/
├── components/
│   ├── SearchDrawer.tsx              # Main search drawer component
│   ├── SearchResults.tsx             # Results display component
│   └── BottomSheet.tsx               # Reusable bottom sheet container
├── hooks/
│   ├── useIntelligentSearch.ts      # Search logic hook with SOS detection
│   └── useSoundSearch.ts            # Alternative search hook (legacy)
├── services/
│   ├── ProductionBackendService.ts  # Backend integration
│   └── SearchService.ts             # Search utilities
└── components/navigation/
    └── TabNavigator.tsx              # Search drawer integration
```

---

## 🔧 Components

### SearchDrawer
**Location:** `src/components/SearchDrawer.tsx`

**Purpose:** Main search interface component with bottom sheet presentation

**Props:**
```typescript
interface SearchDrawerProps {
  isOpen: boolean;
  onClose: () => void;
  onSoundSelect: (sound: Sound) => void | Promise<void>;
  onSOSTriggered?: (config: SOSConfig) => void;
  onCloseToLastTab?: () => void;
}
```

**State:**
- `searchQuery: string` - Current search input value
- `debouncedQuery: string` - Debounced query for search execution

**Features:**
- Bottom sheet presentation with animations
- Search input with icon and clear button
- Real-time search with debouncing
- SOS trigger detection
- Responsive height (tablet/phone)
- Keyboard-aware layout
- Search results display
- Header with title and close button

**Dependencies:**
- `useIntelligentSearch` hook
- `BottomSheet` component
- `SearchResults` component
- `useTheme` hook
- `AnimatedButton` component

**Responsive Design:**
- Phone: 85% screen height (increased by ~100px)
- Tablet: 60% screen height (increased by ~100px)
- Maximum: 95% (prevents full screen)

---

### SearchResults
**Location:** `src/components/SearchResults.tsx`

**Purpose:** Display search results with loading and empty states

**Props:**
```typescript
interface SearchResultsProps {
  results: SearchResultItem[];
  onPlaySound: (sound: Sound) => void;
  isLoading: boolean;
}
```

**State:** None (stateless component)

**Features:**
- Loading skeleton loaders
- Empty state with suggestions
- Results list with cards
- Result count display
- Sound selection handling
- Scrollable list (FlatList)

**Result Card Structure:**
- Icon container with gradient background
- Sound icon (music)
- Title (truncated to 1 line)
- Description (truncated to 2 lines)
- Play button

**Dependencies:**
- `AnimatedButton` component
- `Icon` component
- `SkeletonLoader` component
- `useTheme` hook

---

### BottomSheet
**Location:** `src/components/BottomSheet.tsx`

**Purpose:** Reusable bottom sheet container with gestures

**Props:**
```typescript
interface BottomSheetProps {
  isOpen: boolean;
  onClose: () => void;
  children: ReactNode;
  maxHeightRatio?: number; // default 0.85
  zIndex?: number; // default 200
}
```

**Features:**
- Slide-up animation (280ms)
- Slide-down animation (220ms)
- Swipe-down gesture to close
- Backdrop overlay (60% opacity)
- Spring animations for gestures
- Safe area insets support
- Configurable z-index

**Animation Configuration:**
- Spring: damping: 18, mass: 0.6, stiffness: 160
- Close threshold: 20% of screen height
- Easing: cubic (out for open, in for close)

**Dependencies:**
- `react-native-reanimated`
- `react-native-gesture-handler`
- `react-native-safe-area-context`

---

## 🔌 Services

### ProductionBackendService
**Location:** `src/services/ProductionBackendService.ts`

**Search Methods:**

**`searchSounds(keyword: string): Promise<SoundMetadata[]>`**
- Searches sound_metadata table
- Uses ILIKE for title matching
- Uses array contains (cs) for keywords/tags
- Orders by search_weight (descending)
- Returns array of SoundMetadata

**`getActiveSOSConfig(): Promise<SosConfig | null>`**
- Loads active SOS configuration
- Selects from sos_config table
- Filters by active = true
- Orders by created_at (descending)
- Returns first active config or null

**`logSearchAnalytics(userId, query, resultsCount, sosTriggered): Promise<void>`**
- Inserts into search_analytics table
- Logs user_id (nullable)
- Logs search_query
- Logs results_count
- Logs sos_triggered boolean
- Non-blocking (errors don't throw)

---

### SearchService
**Location:** `src/services/SearchService.ts`

**Class:** Static service class

**Methods:**

**`loadSOSConfig(): Promise<SOSConfig | null>`**
- Loads SOS config with caching
- Cache duration: 1 hour
- Returns cached config if valid
- Transforms database format to component format

**`checkForSOSTrigger(query: string): Promise<SOSConfig | null>`**
- Checks query against SOS keywords
- Returns SOS config if triggered
- Returns null if not triggered
- Case-insensitive matching

**`searchSounds(query, filters?): Promise<SoundMetadata[]>`**
- Full-text search with filters
- Supports category, brainwave type, duration filters
- Returns filtered results

**`getSearchSuggestions(query): Promise<SearchSuggestion[]>`**
- Autocomplete suggestions
- Based on tags, keywords, categories
- Returns top 5 suggestions

**`logSearch(userId, query, resultsCount, sosTriggered): Promise<void>`**
- Logs search to analytics
- Includes SOS trigger status
- Handles errors gracefully

---

## 🪝 Hooks

### useIntelligentSearch
**Location:** `src/hooks/useIntelligentSearch.ts`

**Purpose:** Search logic with SOS detection and analytics

**Returns:**
```typescript
{
  search: (query: string) => Promise<SearchResult[]>;
  clearSearch: () => void;
  dismissSOS: () => void;
  isLoading: boolean;
  searchResults: SearchResult[];
  sosConfig: SOSConfig | null;
  showSOSScreen: boolean;
}
```

**State:**
- `isLoading: boolean` - Search execution state
- `searchResults: SearchResult[]` - Current results
- `sosConfig: SOSConfig | null` - Loaded SOS configuration
- `showSOSScreen: boolean` - SOS trigger state

**Features:**
- SOS config loading on mount
- SOS keyword detection before search
- Supabase search integration
- Client-side result scoring
- Search analytics logging
- Result limiting (top 6)

**Search Scoring Algorithm:**
- Title match: +10 points
- Keyword match: +5 points each
- Tag match: +3 points each
- Description match: +2 points
- Final score = (sum of matches) × search_weight
- Results sorted by score (descending)
- Filtered (score > 0)
- Limited to top 6

**Dependencies:**
- `useAuth` context (for user ID)
- `ProductionBackendService`
- `useState`, `useEffect`, `useCallback`

---

### useDebounce
**Location:** `src/components/SearchDrawer.tsx` (inline hook)

**Purpose:** Debounce search query input

**Parameters:**
- `value: string` - Input value to debounce
- `delay: number` - Debounce delay in ms (300ms)

**Returns:** `debouncedValue: string`

**Implementation:**
- Uses setTimeout for delay
- Clears timeout on value change
- Returns debounced value after delay

---

### useSoundSearch
**Location:** `src/hooks/useSoundSearch.ts`

**Purpose:** Alternative search hook (legacy, not used in SearchDrawer)

**Note:** This hook exists but is not used by SearchDrawer. SearchDrawer uses `useIntelligentSearch` instead.

---

## 🔐 Security Implementation

### Input Sanitization
- Query trimming (whitespace removal)
- Query normalization (lowercase)
- SQL injection prevention (Supabase parameterized queries)
- XSS prevention (React Native safe rendering)

### Data Privacy
- User ID only logged if authenticated
- Anonymous searches supported
- No sensitive data in search results
- Analytics comply with privacy regulations

### Error Handling
- Network errors handled gracefully
- Database errors don't crash app
- Analytics failures don't block search
- User-friendly error messages

---

## 🔄 State Management

### SearchDrawer State
```typescript
{
  searchQuery: string;        // Current input value
  debouncedQuery: string;     // Debounced value for search
}
```

### useIntelligentSearch State
```typescript
{
  isLoading: boolean;
  searchResults: SearchResult[];
  sosConfig: SOSConfig | null;
  showSOSScreen: boolean;
}
```

### SearchResult Type
```typescript
{
  id: string;
  sound_id: string;
  category_id: string;
  title: string;
  description?: string;
  keywords: string[];
  tags: string[];
  search_weight: number;
  score: number; // Calculated relevance score
}
```

### SOSConfig Type
```typescript
{
  id: string;
  keywords: string[];
  title: string;
  message: string;
  image_url?: string;
  phone_number: string;
  chat_link?: string;
  resources: string[];
}
```

---

## 🌐 API Integration

### Supabase Queries

**Search Sounds:**
```sql
SELECT * FROM sound_metadata
WHERE title ILIKE '%query%'
   OR keywords @> ARRAY['query']
   OR tags @> ARRAY['query']
ORDER BY search_weight DESC
```

**Get SOS Config:**
```sql
SELECT * FROM sos_config
WHERE active = true
ORDER BY created_at DESC
LIMIT 1
```

**Log Search Analytics:**
```sql
INSERT INTO search_analytics (user_id, search_query, results_count, sos_triggered)
VALUES (?, ?, ?, ?)
```

---

## 📱 Platform-Specific Notes

### iOS
- KeyboardAvoidingView behavior: 'padding'
- Keyboard vertical offset: 0
- Form sheet presentation for modals
- Safe area insets support

### Android
- KeyboardAvoidingView behavior: 'height'
- Keyboard vertical offset: 20
- Full screen modals
- Safe area insets support

### Responsive Design
- Tablet detection: screenWidth >= 768
- Phone height: 85% + ~100px
- Tablet height: 60% + ~100px
- Maximum height: 95%

---

## 🧪 Testing Strategy

### Unit Tests
- Search query debouncing
- Result scoring algorithm
- SOS keyword matching
- Query normalization
- Result limiting

### Integration Tests
- Supabase search integration
- SOS config loading
- Analytics logging
- Navigation flows
- Drawer animations

### E2E Tests
- Complete search flow
- SOS trigger flow
- Navigation flows
- Error scenarios
- Edge cases

---

## 🐛 Error Handling

### Error Types
- Network errors
- Database errors
- Invalid queries
- Missing SOS config
- Analytics failures

### Error Messages
- User-friendly German messages
- Clear action guidance
- No technical jargon
- Retry options where applicable

### Error Recovery
- Graceful degradation
- Fallback to empty state
- Continue operation on non-critical errors
- Log errors for debugging

---

## 📊 Performance Considerations

### Optimization
- Debounced search (300ms)
- Result limiting (top 6)
- Lazy loading of SOS config
- Cached SOS config (1 hour)
- Efficient FlatList rendering
- Memoized callbacks

### Performance Metrics
- Search execution: < 2 seconds
- Results rendering: < 500ms
- Drawer animation: < 300ms
- Smooth 60fps animations

### Monitoring
- Search success rate
- Average search time
- SOS trigger rate
- Analytics logging success rate

---

## 🔄 Integration Points

### TabNavigator Integration
- Search drawer state management
- Tab preservation
- Navigation coordination
- SOS drawer coordination

### Audio Player Integration
- Sound selection callback
- Sound data transformation
- Player state updates

### SOS Drawer Integration
- SOS trigger callback
- Config passing
- Drawer coordination
- Z-index management

---

## 📝 Configuration

### Environment Variables
- `SUPABASE_URL` - Supabase project URL
- `SUPABASE_ANON_KEY` - Supabase anonymous key

### Constants
- Debounce delay: 300ms
- Result limit: 6
- SOS config cache: 1 hour
- Drawer z-index: 200
- SOS drawer z-index: 300

---

*For component details, see `components.md`*  
*For service dependencies, see `services.md`*  
*For user flows, see `user-flows.md`*
