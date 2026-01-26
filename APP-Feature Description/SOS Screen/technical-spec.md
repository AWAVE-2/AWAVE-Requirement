# SOS Screen - Technical Specification

## 🏗️ Architecture Overview

### Technology Stack

#### Backend
- **Supabase Database** - Configuration storage
  - Table: `sos_config`
  - Row-level security (RLS) policies
  - Real-time updates (future enhancement)

#### State Management
- **React Hooks** - `useIntelligentSearch` hook
- **React State** - Local component state
- **In-memory Cache** - Configuration caching (1-hour duration)

#### UI Components
- **React Native** - Core framework
- **BottomSheet** - Custom drawer component
- **React Native Linking** - Phone and URL handling
- **React Native Image** - Image display

#### Services Layer
- `ProductionBackendService` - Database access
- `SearchService` - SOS config loading (alternative)
- `useIntelligentSearch` - Search with SOS detection

---

## 📁 File Structure

```
src/
├── components/
│   ├── SOSDrawer.tsx              # Full-height drawer wrapper
│   └── SOSScreenDrawer.tsx        # Main SOS content component
├── hooks/
│   └── useIntelligentSearch.ts    # Search hook with SOS detection
├── services/
│   ├── ProductionBackendService.ts  # SOS config loading
│   └── SearchService.ts           # Alternative SOS config service
├── components/
│   └── SearchDrawer.tsx           # Search with SOS integration
└── components/navigation/
    └── TabNavigator.tsx           # Navigation coordinator
```

---

## 🔧 Components

### SOSDrawer
**Location:** `src/components/SOSDrawer.tsx`

**Purpose:** Full-height drawer wrapper for SOS screen

**Props:**
```typescript
interface SOSDrawerProps {
  isOpen: boolean;
  onClose: () => void;
  sosConfig: SOSConfig;
  onDismiss: () => void;
}
```

**Features:**
- Full-height bottom sheet (maxHeightRatio: 1.0)
- High z-index (300) to overlay SearchDrawer
- Swipe-down gesture support
- Close callback handling
- Dismiss state management

**State:**
- None (stateless wrapper)

**Dependencies:**
- `BottomSheet` component
- `SOSScreenDrawer` component
- `SOSConfig` type from `useIntelligentSearch`

---

### SOSScreenDrawer
**Location:** `src/components/SOSScreenDrawer.tsx`

**Purpose:** Main SOS content screen with all resources

**Props:**
```typescript
interface SOSScreenDrawerProps {
  title: string;
  message: string;
  imageUrl?: string;
  phoneNumber: string;
  chatLink?: string;
  resources: string[];
  onDismiss: () => void;
}
```

**Features:**
- Scrollable content layout
- Header with close button
- Optional image display
- Title and message sections
- Call button with phone number
- Chat button (conditional)
- Resources list with phone extraction
- Information box
- Phone number extraction from text
- German phone format support

**State:**
- None (presentational component)

**Phone Number Extraction:**
- Regex pattern: `/(\+?\d{1,4}[\s-]?)?(\(?\d{1,4}\)?[\s-]?)?(\d{1,4}[\s-]?)*\d{1,9}/g`
- Supports formats: +49, 0800, 116, 030, etc.
- Returns longest match (most likely full number)

**Action Handlers:**
- `handleCall(number?: string)` - Opens phone dialer
- `handleChat()` - Opens chat link
- `extractPhoneNumber(text: string)` - Extracts phone from text

**Dependencies:**
- `useTheme` hook
- `AnimatedButton` component
- `Icon` component
- `Linking` API (React Native)
- `Alert` API (React Native)

---

### useIntelligentSearch Hook
**Location:** `src/hooks/useIntelligentSearch.ts`

**Purpose:** Search functionality with SOS keyword detection

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

**SOSConfig Interface:**
```typescript
interface SOSConfig {
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

**Features:**
- SOS configuration loading on mount
- Keyword detection in search queries
- SOS trigger state management
- Search result management
- Analytics logging
- Configuration transformation

**Methods:**
- `loadSOSConfig()` - Loads config from database
- `checkForSOSTrigger(query: string)` - Checks for keywords
- `logSearch(query, count, sosTriggered)` - Logs analytics
- `search(query)` - Performs search with SOS check
- `clearSearch()` - Clears search state
- `dismissSOS()` - Clears SOS state

**Configuration Loading:**
- Loads on component mount
- Transforms database format to component format
- Handles missing config gracefully
- Logs errors in development

**Keyword Detection:**
- Case-insensitive matching
- Partial match support (query contains keyword)
- Normalizes query and keywords
- Returns boolean trigger status

---

## 🔌 Services

### ProductionBackendService
**Location:** `src/services/ProductionBackendService.ts`

**Method:** `getActiveSOSConfig()`

**Returns:** `Promise<SosConfig | null>`

**Implementation:**
```typescript
static async getActiveSOSConfig(): Promise<SosConfig | null> {
  return safeApiCall(async () => {
    const { data, error } = await supabase
      .from('sos_config')
      .select('id, keywords, title, message, image_url, phone_number, chat_link, resources, active, created_at, updated_at')
      .order('created_at', { ascending: false })
      .limit(10);

    if (error) {
      console.warn('[ProductionBackendService] SOS config query error:', error);
      return null;
    }

    if (!data || data.length === 0) {
      return null;
    }

    const activeConfig = data.find((config: SosConfig) => config.active === true);
    return (activeConfig || data[0]) as SosConfig;
  });
}
```

**Features:**
- Explicit column selection
- Active configuration filtering
- Most recent config fallback
- Error handling with null return
- Safe API call wrapper

**Database Schema:**
- Table: `sos_config`
- Columns: id, keywords, title, message, image_url, phone_number, chat_link, resources, active, created_at, updated_at
- Primary key: id (UUID)
- Index: created_at (for ordering)

---

### SearchService (Alternative)
**Location:** `src/services/SearchService.ts`

**Purpose:** Alternative SOS config loading with caching

**Cache Configuration:**
- Duration: 1 hour (3600000ms)
- In-memory storage
- Automatic expiration check

**Methods:**
- `loadSOSConfig()` - Loads with caching
- `checkForSOSTrigger(query)` - Checks keywords

**Cache Implementation:**
```typescript
private static sosConfig: SOSConfig | null = null;
private static sosConfigLoadedAt: number | null = null;
private static readonly SOS_CONFIG_CACHE_DURATION = 3600000;

static async loadSOSConfig(): Promise<SOSConfig | null> {
  const now = Date.now();
  if (
    this.sosConfig &&
    this.sosConfigLoadedAt &&
    now - this.sosConfigLoadedAt < this.SOS_CONFIG_CACHE_DURATION
  ) {
    return this.sosConfig;
  }
  // ... load from database
}
```

---

### Search Analytics Service
**Location:** `src/services/ProductionBackendService.ts`

**Method:** `logSearchAnalytics()`

**Implementation:**
```typescript
static async logSearchAnalytics(
  userId: string,
  query: string,
  resultsCount: number,
  sosTriggered: boolean,
) {
  return safeApiCall(async () => {
    const { error } = await supabase.from('search_analytics').insert({
      user_id: userId,
      search_query: query,
      results_count: resultsCount,
      sos_triggered: sosTriggered,
    });
    if (error) throw error;
    return { success: true };
  });
}
```

**Analytics Schema:**
- Table: `search_analytics`
- Columns: user_id, search_query, results_count, sos_triggered, created_at
- User ID: nullable (anonymous support)

---

## 🪝 Hooks

### useIntelligentSearch
**Location:** `src/hooks/useIntelligentSearch.ts`

**Purpose:** Search with SOS detection

**State Management:**
- `isLoading: boolean` - Search loading state
- `searchResults: SearchResult[]` - Search results
- `sosConfig: SOSConfig | null` - Loaded SOS config
- `showSOSScreen: boolean` - SOS trigger state

**Effects:**
- Loads SOS config on mount
- Checks keywords during search
- Logs analytics after search

**Callbacks:**
- `search(query)` - Main search function
- `clearSearch()` - Clears search state
- `dismissSOS()` - Clears SOS state
- `checkForSOSTrigger(query)` - Keyword check
- `loadSOSConfig()` - Config loading
- `logSearch(...)` - Analytics logging

---

## 🔐 Security Implementation

### Database Security
- Row-level security (RLS) policies
- Explicit column selection
- Error handling prevents data leaks
- No sensitive data in logs

### Phone Number Security
- Phone numbers validated before dialing
- URL scheme validation (`tel:`)
- Error handling for unavailable actions
- No phone numbers stored locally

### Link Security
- URL validation before opening
- `canOpenURL` check before `openURL`
- Error handling for invalid links
- No malicious link execution

---

## 🔄 State Management

### SOS State Flow
```
User types search query
  ↓
useIntelligentSearch.search()
  ↓
checkForSOSTrigger(query)
  ↓
Keyword match? → Yes → setShowSOSScreen(true)
  ↓
SearchDrawer detects showSOSScreen
  ↓
Calls onSOSTriggered(sosConfig)
  ↓
TabNavigator opens SOSDrawer
  ↓
SOSDrawer displays SOSScreenDrawer
```

### Configuration State
```typescript
{
  sosConfig: SOSConfig | null;      // Loaded config
  showSOSScreen: boolean;            // Trigger state
  isLoading: boolean;                // Loading state
}
```

### Cache State (SearchService)
```typescript
{
  sosConfig: SOSConfig | null;       // Cached config
  sosConfigLoadedAt: number | null;  // Cache timestamp
}
```

---

## 🌐 API Integration

### Supabase Queries

**Get Active SOS Config:**
```sql
SELECT id, keywords, title, message, image_url, phone_number, chat_link, resources, active, created_at, updated_at
FROM sos_config
WHERE active = true
ORDER BY created_at DESC
LIMIT 10;
```

**Log Search Analytics:**
```sql
INSERT INTO search_analytics (user_id, search_query, results_count, sos_triggered, created_at)
VALUES (?, ?, ?, ?, ?);
```

---

## 📱 Platform-Specific Notes

### iOS
- Phone dialer opens via `tel:` URL scheme
- Chat links open in Safari or app
- Bottom sheet uses native gestures
- Image loading uses React Native Image

### Android
- Phone dialer opens via `tel:` intent
- Chat links open in browser or app
- Bottom sheet uses native gestures
- Image loading uses React Native Image

### Linking API
- `Linking.canOpenURL(url)` - Checks availability
- `Linking.openURL(url)` - Opens URL
- Error handling for both platforms
- Platform-specific URL schemes

---

## 🧪 Testing Strategy

### Unit Tests
- Keyword detection logic
- Phone number extraction
- Configuration transformation
- Cache expiration logic
- Error handling

### Integration Tests
- Database config loading
- SOS trigger flow
- Phone call initiation
- Chat link opening
- Analytics logging

### E2E Tests
- Complete SOS trigger flow
- Search → SOS transition
- Phone call functionality
- Chat link functionality
- Close/dismiss flow

---

## 🐛 Error Handling

### Error Types
- Database connection errors
- Configuration load failures
- Invalid phone numbers
- Unavailable phone dialer
- Invalid chat links
- Network errors

### Error Messages
- User-friendly German messages
- Clear action guidance
- No technical jargon
- Helpful suggestions

### Fallback Behavior
- Default configuration values
- Cache fallback
- Graceful degradation
- Continue app functionality

---

## 📊 Performance Considerations

### Optimization
- Configuration caching (1 hour)
- Lazy loading of images
- Efficient keyword matching
- Debounced search queries
- Minimal re-renders

### Monitoring
- SOS trigger frequency
- Configuration load time
- Phone call success rate
- Chat link success rate
- Cache hit rate

---

## 🔄 Data Flow

### Configuration Loading Flow
```
App Start
  ↓
useIntelligentSearch mounts
  ↓
useEffect triggers loadSOSConfig()
  ↓
ProductionBackendService.getActiveSOSConfig()
  ↓
Supabase query
  ↓
Transform database format
  ↓
Set sosConfig state
```

### SOS Trigger Flow
```
User types search query
  ↓
search() called
  ↓
checkForSOSTrigger(query)
  ↓
Keyword match found
  ↓
setShowSOSScreen(true)
  ↓
SearchDrawer useEffect detects
  ↓
onSOSTriggered(sosConfig) called
  ↓
TabNavigator opens SOSDrawer
```

### Action Flow (Phone Call)
```
User clicks "Sofort anrufen"
  ↓
handleCall() called
  ↓
Format phone number
  ↓
Linking.canOpenURL(tel:...)
  ↓
Linking.openURL(tel:...)
  ↓
Native phone dialer opens
```

---

*For component details, see `components.md`*  
*For service dependencies, see `services.md`*  
*For user flows, see `user-flows.md`*
