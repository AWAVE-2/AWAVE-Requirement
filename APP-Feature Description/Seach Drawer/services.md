# Search Drawer - Services Documentation

## 🔧 Service Layer Overview

The Search Drawer feature uses a service-oriented architecture with clear separation of concerns. Services handle all backend interactions, search logic, SOS detection, and analytics tracking.

---

## 📦 Services

### ProductionBackendService
**File:** `src/services/ProductionBackendService.ts`  
**Type:** Service Class (Static Methods)  
**Purpose:** Primary backend integration layer for Supabase

#### Search Methods

**`searchSounds(keyword: string): Promise<SoundMetadata[]>`**

Searches the sound_metadata table for matching sounds.

**Parameters:**
- `keyword: string` - Search query string

**Returns:**
- `Promise<SoundMetadata[]>` - Array of matching sound metadata

**Implementation:**
```typescript
static async searchSounds(keyword: string): Promise<SoundMetadata[]> {
  return safeApiCall(async () => {
    const { data, error } = await supabase
      .from(TABLES.SOUND_METADATA)
      .select('*')
      .or(`title.ilike.%${keyword}%,keywords.cs.{${keyword}},tags.cs.{${keyword}}`)
      .order('search_weight', { ascending: false });

    if (error) throw error;
    return data || [];
  });
}
```

**Query Logic:**
- Searches title using ILIKE (case-insensitive)
- Searches keywords using array contains (cs)
- Searches tags using array contains (cs)
- Orders results by search_weight (descending)
- Returns all matching records

**Error Handling:**
- Wrapped in `safeApiCall` for error handling
- Returns empty array on error
- Logs errors in development mode

**Dependencies:**
- `supabase` client
- `TABLES.SOUND_METADATA` constant
- `safeApiCall` utility

---

**`getActiveSOSConfig(): Promise<SosConfig | null>`**

Loads the active SOS configuration from the database.

**Returns:**
- `Promise<SosConfig | null>` - Active SOS config or null

**Implementation:**
```typescript
static async getActiveSOSConfig(): Promise<SosConfig | null> {
  return safeApiCall(async () => {
    try {
      const { data, error } = await supabase
        .from('sos_config')
        .select('id, keywords, title, message, image_url, phone_number, chat_link, resources, active, created_at, updated_at')
        .order('created_at', { ascending: false })
        .limit(10);

      if (error) {
        if (__DEV__) console.warn('[ProductionBackendService] SOS config error:', error);
        return null;
      }

      if (!data || data.length === 0) {
        return null;
      }

      // Filter by active in code
      const activeConfig = data.find((config) => config.active === true);
      const configToUse = activeConfig || data[0];

      // Transform to SosConfig format
      return {
        id: configToUse.id,
        keywords: configToUse.keywords || [],
        title: configToUse.title || 'Soforthilfe',
        message: configToUse.message || 'Du bist nicht allein.',
        image_url: configToUse.image_url,
        phone_number: configToUse.phone_number || '0800 111 0 111',
        chat_link: configToUse.chat_link,
        resources: configToUse.resources || [],
        active: configToUse.active,
        created_at: configToUse.created_at,
        updated_at: configToUse.updated_at,
      };
    } catch (error) {
      if (__DEV__) console.error('[ProductionBackendService] getActiveSOSConfig error:', error);
      return null;
    }
  });
}
```

**Query Logic:**
- Selects all columns from sos_config table
- Orders by created_at (descending)
- Limits to 10 records
- Filters by active = true in code
- Falls back to most recent if no active config

**Error Handling:**
- Returns null on error (non-blocking)
- Logs warnings in development
- Allows app to continue without SOS config

**Dependencies:**
- `supabase` client
- `safeApiCall` utility

---

**`logSearchAnalytics(userId, query, resultsCount, sosTriggered): Promise<{success: boolean}>`**

Logs search queries to analytics table.

**Parameters:**
- `userId: string` - User ID (from auth context)
- `query: string` - Search query text
- `resultsCount: number` - Number of results returned
- `sosTriggered: boolean` - Whether SOS was triggered

**Returns:**
- `Promise<{success: boolean}>` - Success status

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

**Query Logic:**
- Inserts into search_analytics table
- Includes user_id (nullable for anonymous)
- Includes search_query text
- Includes results_count
- Includes sos_triggered boolean
- Timestamp created automatically

**Error Handling:**
- Wrapped in `safeApiCall`
- Returns { success: false } on error
- Non-blocking (errors don't prevent search)

**Dependencies:**
- `supabase` client
- `safeApiCall` utility

---

### SearchService
**File:** `src/services/SearchService.ts`  
**Type:** Static Service Class  
**Purpose:** Search-specific utilities and SOS config management

#### Configuration

**SOS Config Caching:**
- Cache duration: 1 hour (3600000ms)
- Static cache variables: `sosConfig`, `sosConfigLoadedAt`
- Cache invalidation: Time-based expiration

#### Methods

**`loadSOSConfig(): Promise<SOSConfig | null>`**

Loads SOS configuration with caching.

**Returns:**
- `Promise<SOSConfig | null>` - SOS config or null

**Implementation:**
- Checks cache validity (1 hour)
- Returns cached config if valid
- Queries database if cache expired
- Transforms database format to component format
- Updates cache on successful load

**Cache Logic:**
```typescript
const now = Date.now();
if (
  this.sosConfig &&
  this.sosConfigLoadedAt &&
  now - this.sosConfigLoadedAt < this.SOS_CONFIG_CACHE_DURATION
) {
  return this.sosConfig;
}
```

**Error Handling:**
- Returns null on error
- Logs errors in development
- Allows app to continue without SOS config

---

**`checkForSOSTrigger(query: string): Promise<SOSConfig | null>`**

Checks if search query contains SOS trigger keywords.

**Parameters:**
- `query: string` - Search query to check

**Returns:**
- `Promise<SOSConfig | null>` - SOS config if triggered, null otherwise

**Implementation:**
- Loads SOS config (with caching)
- Checks if config is active
- Normalizes query (lowercase, trim)
- Checks if query includes any trigger keywords
- Returns config if triggered, null otherwise

**Keyword Matching:**
```typescript
const queryLower = query.toLowerCase().trim();
const triggered = config.trigger_keywords.some((keyword) =>
  queryLower.includes(keyword.toLowerCase())
);
```

**Error Handling:**
- Returns null on error
- Logs errors in development
- Non-blocking (doesn't prevent search)

---

**`searchSounds(query: string, filters?: SearchFilters): Promise<SoundMetadata[]>`**

Full-text search with optional filters.

**Parameters:**
- `query: string` - Search query
- `filters?: SearchFilters` - Optional filters

**Returns:**
- `Promise<SoundMetadata[]>` - Matching sounds

**Filters:**
- `categoryId?: string` - Filter by category
- `brainwaveType?: string` - Filter by brainwave type
- `minDuration?: number` - Minimum duration
- `maxDuration?: number` - Maximum duration
- `isPublic?: boolean` - Public/private filter

**Implementation:**
- Builds Supabase query with ILIKE matching
- Applies filters if provided
- Orders by title (ascending)
- Limits to 50 results

**Note:** This method exists but is not used by SearchDrawer. SearchDrawer uses `ProductionBackendService.searchSounds` instead.

---

**`getSearchSuggestions(query: string): Promise<SearchSuggestion[]>`**

Gets autocomplete suggestions based on partial query.

**Parameters:**
- `query: string` - Partial search query

**Returns:**
- `Promise<SearchSuggestion[]>` - Array of suggestions

**Implementation:**
- Requires query length >= 2
- Searches tags, keywords, category_id
- Collects matching terms
- Counts occurrences
- Returns top 5 suggestions sorted by count

**Note:** This method exists but is not currently used by SearchDrawer.

---

**`logSearch(userId, query, resultsCount, sosTriggered): Promise<void>`**

Logs search query to analytics.

**Parameters:**
- `userId: string | null` - User ID (nullable)
- `query: string` - Search query
- `resultsCount: number` - Results count
- `sosTriggered: boolean` - SOS trigger status

**Returns:**
- `Promise<void>`

**Implementation:**
- Inserts into search_analytics table
- Includes timestamp
- Handles errors gracefully

**Note:** This method exists but SearchDrawer uses `ProductionBackendService.logSearchAnalytics` instead.

---

## 🔗 Service Dependencies

### Dependency Graph
```
SearchDrawer
├── useIntelligentSearch
│   ├── ProductionBackendService
│   │   ├── searchSounds()
│   │   ├── getActiveSOSConfig()
│   │   └── logSearchAnalytics()
│   └── useAuth (for user ID)
└── SearchService (not used, legacy)
```

### External Dependencies

#### Supabase
- **Database:** PostgreSQL with full-text search
- **Tables:**
  - `sound_metadata` - Sound data
  - `sos_config` - SOS configuration
  - `search_analytics` - Search analytics
- **RLS Policies:** Row-level security enabled
- **API:** REST API with real-time capabilities

#### Authentication
- **useAuth Context:** Provides user ID for analytics
- **User ID:** Used for search analytics logging
- **Anonymous Support:** Null user ID for non-authenticated users

---

## 🔄 Service Interactions

### Search Flow
```
User Types Query
    │
    └─> useIntelligentSearch.search()
        │
        ├─> checkForSOSTrigger(query)
        │   └─> ProductionBackendService.getActiveSOSConfig()
        │       └─> Supabase: sos_config table
        │
        ├─> ProductionBackendService.searchSounds(query)
        │   └─> Supabase: sound_metadata table
        │       └─> Client-side scoring and ranking
        │
        └─> ProductionBackendService.logSearchAnalytics(...)
            └─> Supabase: search_analytics table
```

### SOS Trigger Flow
```
User Types Crisis Query
    │
    └─> useIntelligentSearch.search()
        │
        └─> checkForSOSTrigger(query)
            └─> ProductionBackendService.getActiveSOSConfig()
                └─> Supabase: sos_config table
                    └─> Keyword matching
                        └─> SOS triggered
                            └─> onSOSTriggered callback
                                └─> TabNavigator opens SOSDrawer
```

### Analytics Flow
```
Search Executed
    │
    └─> ProductionBackendService.logSearchAnalytics(...)
        │
        └─> Supabase: search_analytics table
            └─> INSERT (user_id, search_query, results_count, sos_triggered)
                └─> Analytics logged (non-blocking)
```

---

## 🧪 Service Testing

### Unit Tests
- Service method calls
- Error handling
- Cache expiration logic
- Keyword matching
- Query transformation

### Integration Tests
- Supabase API calls
- SOS config loading
- Search execution
- Analytics logging
- Error scenarios

### Mocking
- Supabase client
- useAuth context
- Network requests
- Database responses

---

## 📊 Service Metrics

### Performance
- **Search Execution:** < 2 seconds
- **SOS Config Load:** < 500ms (cached)
- **Analytics Logging:** < 100ms (async)
- **Cache Hit Rate:** > 80%

### Reliability
- **Search Success Rate:** > 95%
- **SOS Config Load Success:** > 99%
- **Analytics Logging Success:** > 99%
- **Error Recovery:** Graceful degradation

### Error Rates
- **Network Errors:** < 1%
- **Database Errors:** < 0.5%
- **Cache Misses:** < 20%

---

## 🔐 Security Considerations

### Data Privacy
- User ID only logged if authenticated
- Anonymous searches supported
- No sensitive data in search queries
- Analytics comply with privacy regulations

### Input Sanitization
- Query trimming (whitespace)
- Query normalization (lowercase)
- SQL injection prevention (Supabase parameterized queries)
- XSS prevention (React Native safe rendering)

### Network Security
- All requests use HTTPS
- Supabase API keys secured
- RLS policies enforce data access
- No credentials in logs

---

## 🐛 Error Handling

### Service-Level Errors
- Network connectivity checks
- Retry logic for transient failures
- User-friendly error messages
- Error logging for debugging
- Graceful degradation

### Error Types
- **Network Errors:** Connectivity issues
- **Database Errors:** Query failures, RLS violations
- **Authentication Errors:** Missing user context
- **Configuration Errors:** Missing SOS config
- **Validation Errors:** Invalid queries

### Error Recovery
- Fallback to empty results
- Continue operation on non-critical errors
- Cache fallback for SOS config
- Non-blocking analytics logging

---

## 📝 Service Configuration

### Environment Variables
```typescript
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_key
```

### Constants
- SOS config cache duration: 1 hour
- Search result limit: 6 (client-side)
- Database query limit: 50 (server-side)
- Debounce delay: 300ms

### Service Initialization
```typescript
// Services are initialized automatically
// No explicit initialization required
// SOS config loaded on first use
```

---

## 🔄 Service Updates

### Future Enhancements
- Search suggestions integration
- Advanced filters (category, duration, etc.)
- Search history
- Popular searches
- Search result caching
- Offline search support

---

*For component usage, see `components.md`*  
*For user flows, see `user-flows.md`*  
*For technical details, see `technical-spec.md`*
