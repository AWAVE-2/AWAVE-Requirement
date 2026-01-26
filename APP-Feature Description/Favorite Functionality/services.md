# Favorite Functionality - Services Documentation

## 🔧 Service Layer Overview

The favorites system uses a service-oriented architecture with clear separation of concerns. Services handle all backend interactions, local storage, state management, and data synchronization.

---

## 📦 Services

### useFavoritesManagement Hook
**File:** `src/hooks/useFavoritesManagement.ts`  
**Type:** React Hook  
**Purpose:** Main favorites management hook

#### Configuration
- Supports optional `categoryId` parameter for filtering
- Automatic authentication check
- Fallback to local storage when unauthenticated

#### Methods

**`loadFromSupabase(): Promise<FavoriteItem[]>`**
- Loads favorites from Supabase database
- Filters by user ID
- Filters by category if provided
- Orders by `last_used` (descending), then `date_added` (descending)
- Maps Supabase records to `FavoriteItem` format
- Returns empty array on error or if unauthenticated

**`loadFromStorage(): Promise<FavoriteItem[]>`**
- Loads favorites from AsyncStorage
- Used as fallback when unauthenticated
- Maps stored favorites to `FavoriteItem` format
- Returns empty array if no favorites stored

**`loadFavorites(): Promise<void>`**
- Main loading function
- Tries Supabase first, falls back to local storage
- Updates `favorites` state
- Sets `isLoading` state
- Called automatically on mount and when dependencies change

**`refreshFavorites(): Promise<void>`**
- Manually refresh favorites list
- Calls `loadFavorites()`
- Used after add/remove operations

**`addFavorite(userId: string, payload: FavoriteUpsertPayload): Promise<void>`**
- Adds favorite to backend
- Requires authenticated user
- Calls `ProductionBackendService.addFavorite()`
- Refreshes favorites list after add
- Throws error on failure

**`removeFavorite(favoriteIdOrSoundId: string): Promise<void>`**
- Removes favorite from backend
- Requires authenticated user
- Finds favorite by ID or sound ID
- Calls `ProductionBackendService.removeFavorite()`
- Refreshes favorites list after remove
- Logs warning if favorite not found
- Throws error on failure

**`markFavoritePlayed(favoriteId: string): Promise<void>`**
- Updates usage tracking for favorite
- Updates `last_used` timestamp
- Requires authenticated user
- Direct Supabase update (bypasses service layer)
- Silent failure (logs warning only)
- Used when favorite sound is played

#### State Management
- `favorites: FavoriteItem[]` - Current favorites list
- `isLoading: boolean` - Loading state indicator

#### Data Mapping

**`mapSupabaseFavorite(record: SupabaseFavoriteRecord): FavoriteRecord`**
- Maps Supabase database record to internal format
- Handles null/undefined values
- Provides fallback values

**`mapRecordToSound(record: FavoriteRecord, fallbackCategory?: string): Sound`**
- Maps favorite record to Sound format
- Used for display in UI
- Handles missing fields

#### Dependencies
- `useAuth` - Authentication context
- `ProductionBackendService` - Backend API
- `AWAVEStorage` - Local storage
- `supabase` - Supabase client

#### Error Handling
- Catches and logs errors
- Returns empty arrays on failure
- Throws errors for critical operations
- User-friendly error messages

---

### ProductionBackendService
**File:** `src/services/ProductionBackendService.ts`  
**Type:** Static Service Class  
**Purpose:** Backend API integration for favorites

#### Methods

**`getUserFavorites(userId: string): Promise<UserFavorite[]>`**
- Fetches all favorites for a user
- Queries `user_favorites` table
- Filters by `user_id`
- Orders by `last_used` (descending, nulls last)
- Returns empty array on error
- Uses `safeApiCall` wrapper

**`addFavorite(userId: string, favoriteData: Partial<UserFavorite>): Promise<UserFavorite>`**
- Creates new favorite record
- Inserts into `user_favorites` table
- Sets default values:
  - `date_added`: Current timestamp
  - `use_count`: 0
  - `is_public`: false
- Returns created favorite record
- Uses `safeApiCall` wrapper

**`removeFavorite(favoriteId: string, userId: string): Promise<void>`**
- Deletes favorite record
- Verifies user ownership (double check)
- Deletes from `user_favorites` table
- Filters by both `id` and `user_id` for security
- Returns void on success
- Uses `safeApiCall` wrapper

**`updateFavoriteUsage(favoriteId: string, userId: string, currentUseCount: number): Promise<UserFavorite>`**
- Updates usage tracking
- Increments `use_count` by 1
- Updates `last_used` to current timestamp
- Returns updated favorite record
- Filters by both `id` and `user_id` for security
- Uses `safeApiCall` wrapper

#### Error Handling
- All methods use `safeApiCall` wrapper
- Errors are caught and logged
- Returns appropriate fallback values
- Throws errors for critical failures

#### Dependencies
- `supabase` - Supabase client
- `TABLES` - Table name constants
- `safeApiCall` - Error handling wrapper

---

### AWAVEStorage Service
**File:** `src/services/AWAVEStorage.ts`  
**Type:** Static Service Class  
**Purpose:** Local storage for offline support

#### Storage Key
- `awaveFavorites` - Local favorites cache

#### Methods

**`getFavorites(): Promise<UserFavorite[]>`**
- Retrieves favorites from AsyncStorage
- Parses JSON data
- Returns empty array if none exist
- Returns `UserFavorite[]` format

**`setFavorites(favorites: UserFavorite[]): Promise<void>`**
- Stores favorites in AsyncStorage
- Serializes to JSON
- Used for offline fallback
- Called when user is unauthenticated

#### Type Definition
```typescript
interface UserFavorite {
  id: string;
  soundId: string;
  addedAt: string;
}
```

#### Dependencies
- `AsyncStorage` - React Native storage
- `@react-native-async-storage/async-storage`

#### Usage
- Fallback when user is unauthenticated
- Queue for sync when online
- Temporary storage during offline period

---

## 🔗 Service Dependencies

### Dependency Graph
```
useFavoritesManagement
├── useAuth (AuthContext)
│   └── User authentication state
├── ProductionBackendService
│   ├── getUserFavorites()
│   ├── addFavorite()
│   ├── removeFavorite()
│   └── supabase client
├── AWAVEStorage
│   ├── getFavorites()
│   └── AsyncStorage
└── supabase client
    └── Direct queries (markFavoritePlayed)
```

### External Dependencies

#### Supabase
- **Database:** PostgreSQL `user_favorites` table
- **Auth:** User authentication
- **RLS:** Row-level security policies
- **Realtime:** Optional real-time subscriptions

#### Storage
- **AsyncStorage:** Local caching and persistence
- **React Native:** Platform-specific storage

---

## 🔄 Service Interactions

### Add Favorite Flow
```
User Action
    │
    └─> useFavoritesManagement.addFavorite()
        ├─> Check authentication
        ├─> ProductionBackendService.addFavorite()
        │   └─> supabase.from('user_favorites').insert()
        │       └─> Database insert
        └─> refreshFavorites()
            └─> loadFromSupabase()
                └─> Update state
```

### Remove Favorite Flow
```
User Action
    │
    └─> useFavoritesManagement.removeFavorite()
        ├─> Find favorite by ID
        ├─> ProductionBackendService.removeFavorite()
        │   └─> supabase.from('user_favorites').delete()
        │       └─> Database delete
        └─> refreshFavorites()
            └─> loadFromSupabase()
                └─> Update state
```

### Load Favorites Flow
```
Component Mount / Refresh
    │
    └─> useFavoritesManagement.loadFavorites()
        ├─> Check authentication
        ├─> If authenticated:
        │   └─> loadFromSupabase()
        │       └─> Query database
        │           └─> Map to FavoriteItem[]
        └─> If not authenticated:
            └─> loadFromStorage()
                └─> Read from AsyncStorage
                    └─> Map to FavoriteItem[]
```

### Usage Tracking Flow
```
User Plays Favorite
    │
    └─> useFavoritesManagement.markFavoritePlayed()
        └─> supabase.from('user_favorites').update()
            ├─> Update use_count
            ├─> Update last_used
            └─> refreshFavorites()
                └─> Re-sort by last_used
```

### Offline Sync Flow
```
User Action (Offline)
    │
    ├─> Check authentication
    │   ├─> Authenticated:
    │   │   └─> Queue operation
    │   │       └─> Sync when online
    │   └─> Unauthenticated:
    │       └─> AWAVEStorage.setFavorites()
    │           └─> AsyncStorage
    │
    └─> When Online
        └─> Sync local to backend
            └─> Merge with remote
                └─> Update UI
```

---

## 🧪 Service Testing

### Unit Tests
- Service method calls
- Error handling
- Data mapping functions
- State management
- Local storage operations

### Integration Tests
- Supabase API calls
- Local storage sync
- Authentication flow
- Error recovery
- Offline operations

### Mocking
- Supabase client
- AsyncStorage
- Authentication context
- Network requests

---

## 📊 Service Metrics

### Performance
- **Load Favorites:** < 3 seconds
- **Add Favorite:** < 2 seconds
- **Remove Favorite:** < 2 seconds
- **Usage Tracking:** < 1 second
- **Local Storage:** < 100ms

### Reliability
- **Add Success Rate:** > 95%
- **Remove Success Rate:** > 95%
- **Sync Success Rate:** > 90%
- **Error Recovery:** > 99%

### Error Rates
- **Network Errors:** < 1%
- **Authentication Errors:** < 1%
- **Validation Errors:** < 0.5%
- **Database Errors:** < 0.5%

---

## 🔐 Security Considerations

### Authentication
- All backend operations require authenticated user
- User ID verified before operations
- Row-level security in database

### Authorization
- Users can only access their own favorites
- RLS policies enforce user isolation
- No cross-user data access

### Data Validation
- Input validation before database operations
- Type checking with TypeScript
- Sanitization of user input

### Network Security
- All requests use HTTPS
- Token transmission encrypted
- No credentials in logs

---

## 🐛 Error Handling

### Service-Level Errors
- Network connectivity checks
- Retry logic for transient failures
- User-friendly error messages
- Error logging for debugging

### Error Types
- **Network Errors:** Connectivity issues
- **Authentication Errors:** Invalid credentials, expired sessions
- **Validation Errors:** Invalid input data
- **Database Errors:** Constraint violations, connection issues
- **Storage Errors:** AsyncStorage failures

### Error Recovery
- Automatic retry for transient failures
- Fallback to local storage
- Queue operations for sync
- Graceful degradation

---

## 📝 Service Configuration

### Environment Variables
```typescript
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_key
```

### Service Initialization
```typescript
// Hook initialization (automatic)
const { favorites, addFavorite, removeFavorite } = useFavoritesManagement();

// Service initialization (automatic via Supabase client)
// No manual initialization required
```

### Service Cleanup
```typescript
// React hook cleanup (automatic)
// useEffect cleanup handles subscriptions
```

---

## 🔄 Service Updates

### Future Enhancements
- Real-time synchronization
- Batch operations
- Favorite folders/categories
- Share favorites
- Export/import favorites
- Advanced filtering and sorting
- Favorite recommendations

### Performance Improvements
- Caching improvements
- Background sync optimization
- Batch operations for usage tracking
- Virtualized list rendering
- Pagination support

---

## 📚 API Reference

### useFavoritesManagement Hook

```typescript
const {
  favorites,           // FavoriteItem[]
  isLoading,          // boolean
  refreshFavorites,    // () => Promise<void>
  addFavorite,        // (userId: string, payload: FavoriteUpsertPayload) => Promise<void>
  removeFavorite,     // (favoriteIdOrSoundId: string) => Promise<void>
  markFavoritePlayed,  // (favoriteId: string) => Promise<void>
} = useFavoritesManagement(categoryId?: string);
```

### ProductionBackendService

```typescript
// Get all favorites
const favorites = await ProductionBackendService.getUserFavorites(userId);

// Add favorite
const favorite = await ProductionBackendService.addFavorite(userId, {
  sound_id: 'sound-123',
  title: 'Sound Title',
  description: 'Sound Description',
  category_id: 'meditation',
  image_url: 'https://...',
});

// Remove favorite
await ProductionBackendService.removeFavorite(favoriteId, userId);

// Update usage
await ProductionBackendService.updateFavoriteUsage(favoriteId, userId, currentUseCount);
```

### AWAVEStorage

```typescript
// Get favorites from local storage
const favorites = await AWAVEStorage.getFavorites();

// Set favorites in local storage
await AWAVEStorage.setFavorites(favorites);
```

---

*For component usage, see `components.md`*  
*For user flows, see `user-flows.md`*  
*For technical details, see `technical-spec.md`*
