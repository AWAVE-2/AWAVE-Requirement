# SOS Screen - Services Documentation

## 🔧 Service Layer Overview

The SOS Screen feature uses a service-oriented architecture with clear separation of concerns. Services handle database interactions, configuration management, analytics tracking, and caching.

---

## 📦 Services

### ProductionBackendService
**File:** `src/services/ProductionBackendService.ts`  
**Type:** Service Class  
**Purpose:** Primary database access for SOS configuration

#### SOS Configuration Method

**`getActiveSOSConfig(): Promise<SosConfig | null>`**

**Purpose:** Loads active SOS configuration from database

**Implementation:**
```typescript
static async getActiveSOSConfig(): Promise<SosConfig | null> {
  return safeApiCall(async () => {
    try {
      const { data, error } = await supabase
        .from('sos_config')
        .select(
          'id, keywords, title, message, image_url, phone_number, chat_link, resources, active, created_at, updated_at',
        )
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
    } catch (error) {
      console.error('[ProductionBackendService] getActiveSOSConfig unexpected error:', error);
      return null;
    }
  });
}
```

**Features:**
- Explicit column selection (avoids RLS issues)
- Active configuration filtering
- Most recent config fallback
- Error handling with null return
- Safe API call wrapper
- Development logging

**Database Schema:**
- Table: `sos_config`
- Columns: id, keywords, title, message, image_url, phone_number, chat_link, resources, active, created_at, updated_at
- Primary key: id (UUID)
- Ordering: created_at DESC

**Return Value:**
- Active configuration if found
- Most recent configuration if no active
- Null if no configurations exist or error

---

#### Search Analytics Method

**`logSearchAnalytics(userId, query, resultsCount, sosTriggered): Promise<{success: boolean}>`**

**Purpose:** Logs search queries with SOS trigger flag

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

**Features:**
- User ID association (nullable)
- Query text logging
- Results count tracking
- SOS trigger flag
- Automatic timestamp
- Error handling

**Database Schema:**
- Table: `search_analytics`
- Columns: user_id, search_query, results_count, sos_triggered, created_at
- User ID: nullable (anonymous support)

---

### SearchService
**File:** `src/services/SearchService.ts`  
**Type:** Static Service Class  
**Purpose:** Alternative SOS config loading with caching

#### Cache Configuration
- **Duration:** 1 hour (3600000ms)
- **Storage:** In-memory static variables
- **Expiration:** Automatic check on load

#### Cache State
```typescript
private static sosConfig: SOSConfig | null = null;
private static sosConfigLoadedAt: number | null = null;
private static readonly SOS_CONFIG_CACHE_DURATION = 3600000;
```

#### Methods

**`loadSOSConfig(): Promise<SOSConfig | null>`**

**Purpose:** Loads SOS config with caching

**Implementation:**
```typescript
static async loadSOSConfig(): Promise<SOSConfig | null> {
  try {
    // Return cached config if still valid
    const now = Date.now();
    if (
      this.sosConfig &&
      this.sosConfigLoadedAt &&
      now - this.sosConfigLoadedAt < this.SOS_CONFIG_CACHE_DURATION
    ) {
      return this.sosConfig;
    }

    // Load from database
    const { data, error } = await supabase
      .from('sos_config')
      .select('id, keywords, title, message, image_url, phone_number, chat_link, resources, active, created_at, updated_at')
      .order('created_at', { ascending: false })
      .limit(10);

    if (error) {
      console.warn('[SearchService] SOS config not found:', error);
      return null;
    }

    if (!data || data.length === 0) {
      return null;
    }

    // Filter by active
    const activeConfig = data.find((config) => config.active === true);
    const configToUse = activeConfig || data[0];

    // Transform database format
    const transformedConfig: SOSConfig = {
      id: dbData.id,
      trigger_keywords: dbData.keywords || [],
      title: dbData.title || 'Soforthilfe',
      message: dbData.message || 'Du bist nicht allein. Professionelle Hilfe ist verfügbar.',
      image_url: dbData.image_url,
      hotline_number: dbData.phone_number || '0800 111 0 111',
      hotline_text: dbData.message || 'Telefonseelsorge • 24/7 • Kostenlos & Anonym',
      chat_url: dbData.chat_link,
      crisis_resources: (dbData.resources || []).map((r) => {
        if (typeof r === 'string') {
          return { title: r, description: '' };
        }
        return r as CrisisResource;
      }) as CrisisResource[],
      active: dbData.active,
      created_at: dbData.created_at || new Date().toISOString(),
      updated_at: dbData.updated_at || new Date().toISOString(),
    };

    this.sosConfig = transformedConfig;
    this.sosConfigLoadedAt = now;
    return transformedConfig;
  } catch (error) {
    console.error('[SearchService] loadSOSConfig failed:', error);
    return null;
  }
}
```

**Features:**
- Cache hit check
- Database load on cache miss
- Configuration transformation
- Active config filtering
- Error handling
- Cache update on load

---

**`checkForSOSTrigger(query: string): Promise<SOSConfig | null>`**

**Purpose:** Checks if search query triggers SOS

**Implementation:**
```typescript
static async checkForSOSTrigger(query: string): Promise<SOSConfig | null> {
  try {
    const config = await this.loadSOSConfig();
    if (!config || !config.active) {
      return null;
    }

    const queryLower = query.toLowerCase().trim();
    const triggered = config.trigger_keywords.some((keyword) =>
      queryLower.includes(keyword.toLowerCase()),
    );

    if (triggered) {
      return config;
    }

    return null;
  } catch (error) {
    console.error('[SearchService] checkForSOSTrigger failed:', error);
    return null;
  }
}
```

**Features:**
- Config loading (with cache)
- Active check
- Case-insensitive matching
- Partial match support
- Returns config if triggered

---

**`logSearch(userId, query, resultsCount, sosTriggered): Promise<void>`**

**Purpose:** Logs search analytics with SOS flag

**Implementation:**
```typescript
static async logSearch(
  userId: string | null,
  query: string,
  resultsCount: number,
  sosTriggered: boolean = false,
): Promise<void> {
  try {
    await supabase.from('search_analytics').insert({
      user_id: userId,
      search_query: query,
      results_count: resultsCount,
      sos_triggered: sosTriggered,
      created_at: new Date().toISOString(),
    });
  } catch (error) {
    console.warn('[SearchService] Failed to log search:', error);
  }
}
```

**Features:**
- User ID support (nullable)
- Query logging
- Results count
- SOS trigger flag
- Error handling (non-blocking)

---

## 🔗 Service Dependencies

### Dependency Graph
```
useIntelligentSearch
├── ProductionBackendService
│   ├── getActiveSOSConfig()
│   │   └── supabase client
│   └── logSearchAnalytics()
│       └── supabase client
└── SearchService (alternative)
    ├── loadSOSConfig()
    │   └── supabase client
    └── checkForSOSTrigger()
        └── loadSOSConfig()
```

### External Dependencies

#### Supabase
- **Database API:** Configuration storage
- **Auth API:** User identification (optional)
- **RLS Policies:** Row-level security

#### React Native
- **Linking API:** Phone and URL handling (in components)
- **Alert API:** Error messages (in components)

---

## 🔄 Service Interactions

### Configuration Loading Flow
```
App Start / Component Mount
    │
    └─> useIntelligentSearch.loadSOSConfig()
        └─> ProductionBackendService.getActiveSOSConfig()
            └─> Supabase Query
                ├─> Success → Transform Config
                └─> Error → Return Null (use defaults)
```

### SOS Trigger Flow
```
User Types Search Query
    │
    └─> useIntelligentSearch.search()
        └─> checkForSOSTrigger(query)
            └─> Load Config (cached or fresh)
                └─> Check Keywords
                    ├─> Match → Return Config
                    └─> No Match → Return Null
```

### Analytics Logging Flow
```
Search Complete / SOS Triggered
    │
    └─> useIntelligentSearch.logSearch()
        └─> ProductionBackendService.logSearchAnalytics()
            └─> Supabase Insert
                ├─> Success → Continue
                └─> Error → Log (non-blocking)
```

---

## 🧪 Service Testing

### Unit Tests
- Configuration loading
- Cache behavior
- Keyword matching
- Error handling
- Configuration transformation

### Integration Tests
- Supabase API calls
- Cache expiration
- Active config filtering
- Analytics logging
- Error recovery

### Mocking
- Supabase client
- Database responses
- Network requests
- Cache state

---

## 📊 Service Metrics

### Performance
- **Config Load Time:** < 3 seconds
- **Cache Hit Rate:** > 80%
- **Keyword Check:** < 10ms
- **Analytics Log:** < 500ms

### Reliability
- **Config Load Success Rate:** > 99%
- **Cache Hit Accuracy:** 100%
- **Analytics Log Success Rate:** > 95%
- **Error Recovery:** 100% (graceful fallback)

### Error Rates
- **Database Errors:** < 1%
- **Network Errors:** < 2%
- **Cache Misses:** ~20% (expected)

---

## 🔐 Security Considerations

### Database Security
- Row-level security (RLS) policies
- Explicit column selection
- No sensitive data exposure
- Error messages don't leak data

### Data Privacy
- User ID optional in analytics
- No personal information required
- Anonymous tracking supported
- Secure database access

### Network Security
- All requests use HTTPS
- Secure token transmission
- No credentials in logs
- Error handling prevents data leaks

---

## 🐛 Error Handling

### Service-Level Errors
- Database connection failures → Return null, use defaults
- Network errors → Log, return null
- Invalid configurations → Use defaults
- Cache errors → Reload from database

### Error Types
- **Database Errors:** Connection, query, RLS
- **Network Errors:** Timeout, connection loss
- **Configuration Errors:** Missing, invalid format
- **Cache Errors:** Expiration, corruption

### Error Recovery
- Default values ensure functionality
- Cache fallback for performance
- Graceful degradation
- Non-blocking analytics

---

## 📝 Service Configuration

### Environment Variables
```typescript
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_key
```

### Service Initialization
```typescript
// No explicit initialization needed
// Services are called on-demand
```

### Cache Configuration
```typescript
SOS_CONFIG_CACHE_DURATION = 3600000; // 1 hour
```

---

## 🔄 Service Updates

### Future Enhancements
- Real-time config updates
- Multi-config support
- Enhanced caching strategies
- Offline config support
- Config versioning

---

*For component usage, see `components.md`*  
*For user flows, see `user-flows.md`*  
*For technical details, see `technical-spec.md`*
