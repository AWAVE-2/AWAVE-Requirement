# Category Screens - Services Documentation

## 🔧 Service Layer Overview

The Category Screens feature uses a service-oriented architecture with clear separation of concerns. Services handle backend data fetching, category state management, and data persistence.

---

## 📦 Services

### CategoryService
**File:** `src/services/CategoryService.ts`  
**Type:** Static Service Class  
**Purpose:** Backend category and sound data fetching

#### Configuration
```typescript
const PRIMARY_CATEGORY_IDS = ['schlafen', 'stress', 'leichtigkeit'];
```

#### Methods

**`fetchPrimaryCategories(): Promise<Category[]>`**
- Fetches all three primary categories from Supabase
- Fetches category metadata from `audio_categories` table
- Fetches sound metadata from `sound_metadata` table for each category
- Merges backend data with fallback data
- Returns ordered categories array
- Handles errors gracefully with fallback mechanism

#### Data Fetching Flow

1. **Fetch Category Records**
   ```typescript
   supabase
     .from('audio_categories')
     .select('id, name, display_name, description, icon_name, color_hex, sort_order')
     .in('name', PRIMARY_CATEGORY_IDS)
   ```

2. **Fetch Sounds for Each Category**
   ```typescript
   supabase
     .from('sound_metadata')
     .select('sound_id, title, description, category_id, tags, keywords, search_weight, metadata, image_url, artwork_url, bucket_id, storage_path')
     .eq('category_id', categoryId)
     .order('search_weight', { ascending: false })
     .limit(8)
   ```

3. **Merge Data**
   - Maps backend category records to Category interface
   - Maps backend sound metadata to Sound interface
   - Merges with fallback data from `majorCategories`
   - Handles missing or invalid data

#### Fallback Mechanism

**When Backend Unavailable:**
- Uses `majorCategories` from `exactDataStructures.ts`
- Provides default category structure
- Ensures app functionality without backend

**When Data Missing:**
- Uses fallback sounds from `majorCategories`
- Provides default category metadata
- Handles empty sound arrays gracefully

#### Error Handling
- Network errors: Returns fallback categories
- Invalid data: Uses fallback sounds
- Missing categories: Uses default category structure
- Console warnings for debugging

#### Dependencies
- `supabase` client
- `majorCategories` from `exactDataStructures.ts`
- Type definitions: `Category`, `Sound`

---

### CategoryContext (Context Service)
**File:** `src/contexts/CategoryContext.tsx`  
**Type:** React Context Provider  
**Purpose:** Global category state management

#### State Structure
```typescript
{
  selectedCategory: string;
  orderedCategories: Category[];
  isLoading: boolean;
}
```

#### Methods

**`loadInitialCategories(): Promise<void>`**
- Loads categories on app startup
- Fetches categories from CategoryService
- Loads saved category selection from onboarding storage
- Sets initial selected category
- Handles errors with fallback

**`handleCategorySelect(categoryId: string): Promise<void>`**
- Updates selected category state
- Persists selection to onboarding storage
- Updates CategoryContext state
- Note: Navigation is handled by TabNavigator, not CategoryContext

**`refreshCategories(): Promise<void>`**
- Refreshes category data from backend
- Reloads categories from CategoryService
- Updates orderedCategories state
- Maintains selected category

#### Storage Integration

**Onboarding Storage:**
- Category selection stored in `onboardingStorage`
- Loaded from `onboardingStorage.getSelectedCategory()`
- Saved via `onboardingStorage.setSelectedCategory(categoryId)`
- Profile JSON parsing for primary category

**Storage Keys:**
- Category selection: Managed by `onboardingStorage`
- Category data: Cached in memory (not persisted)

#### Category Ordering

**Fixed Order:**
- Categories are kept in fixed order: `['schlafen', 'stress', 'leichtigkeit']`
- Order does not change based on selection
- Ensures icon positions stay fixed in NavBar
- Matches Development branch behavior

#### Error Handling
- Failed category fetch: Uses fallback categories
- Invalid category selection: Uses first category as fallback
- Storage errors: Logs warning, continues with default

#### Dependencies
- `CategoryService` - Data fetching
- `onboardingStorage` - Category selection persistence
- `majorCategories` - Fallback data

---

### onboardingStorage (Storage Service)
**File:** `src/hooks/useOnboardingStorage.ts`  
**Type:** Storage Service  
**Purpose:** Category selection persistence

#### Methods

**`getSelectedCategory(): Promise<string | null>`**
- Gets saved category selection
- Returns category ID or null
- Used for initial category loading

**`setSelectedCategory(categoryId: string): Promise<void>`**
- Saves category selection
- Persists to AsyncStorage
- Used when category is selected

**`loadOnboardingState(): Promise<OnboardingState>`**
- Loads full onboarding state
- Includes profile JSON with primary category
- Used for initial category determination

#### Storage Keys
- Category selection: Managed internally by `onboardingStorage`
- Profile JSON: Contains primary category preference

---

## 🔗 Service Dependencies

### Dependency Graph
```
CategoryContext
├── CategoryService
│   ├── supabase client
│   └── majorCategories (fallback)
└── onboardingStorage
    └── AsyncStorage

Category Screens
├── CategoryContext
│   └── CategoryService
├── useSoundPlayer
│   └── Audio playback services
├── useFavoritesManagement
│   └── Favorites service
└── useCustomSounds
    └── Custom sounds service
```

### External Dependencies

#### Supabase
- **Database API:** Category and sound metadata
- **Tables:**
  - `audio_categories` - Category metadata
  - `sound_metadata` - Sound metadata
- **Authentication:** Required for data access

#### Storage
- **AsyncStorage:** Category selection persistence
- **Memory:** Category data caching

---

## 🔄 Service Interactions

### Category Loading Flow
```
App Startup
    │
    └─> CategoryProvider.initialize()
        └─> loadInitialCategories()
            ├─> CategoryService.fetchPrimaryCategories()
            │   ├─> Fetch from Supabase
            │   │   ├─> audio_categories table
            │   │   └─> sound_metadata table
            │   └─> Fallback to majorCategories
            ├─> onboardingStorage.getSelectedCategory()
            └─> Set selectedCategory and orderedCategories
```

### Category Selection Flow
```
User Selects Category
    │
    └─> handleCategorySelect(categoryId)
        ├─> Update selectedCategory state
        └─> onboardingStorage.setSelectedCategory(categoryId)
            └─> AsyncStorage.setItem()
                │
                └─> TabNavigator handles navigation
                    └─> Render category screen
```

### Category Refresh Flow
```
User Triggers Refresh
    │
    └─> refreshCategories()
        └─> loadInitialCategories()
            └─> CategoryService.fetchPrimaryCategories()
                └─> Update orderedCategories state
```

---

## 🧪 Service Testing

### Unit Tests
- CategoryService data fetching
- CategoryService fallback mechanism
- CategoryContext state management
- Category selection persistence
- Data mapping and transformation

### Integration Tests
- Supabase API calls
- Category data fetching
- Category selection persistence
- Fallback mechanism
- Error handling

### Mocking
- Supabase client
- AsyncStorage
- Network requests
- Category data structures

---

## 📊 Service Metrics

### Performance
- **Category Fetch:** < 2 seconds
- **Category Selection:** < 100ms
- **Category Refresh:** < 2 seconds
- **Storage Operations:** < 50ms

### Reliability
- **Category Fetch Success Rate:** > 95%
- **Fallback Success Rate:** 100%
- **Category Selection Persistence:** > 99%
- **Data Mapping Accuracy:** 100%

### Error Rates
- **Network Errors:** < 5%
- **Data Validation Errors:** < 1%
- **Storage Errors:** < 1%

---

## 🔐 Security Considerations

### Data Security
- Category data fetched from authenticated Supabase
- Sound metadata validated before display
- Category selection stored securely
- No sensitive data in category services

### Privacy
- Category selection is user-specific
- No personal data in category services
- Sound metadata doesn't expose user data

---

## 🐛 Error Handling

### Service-Level Errors
- Network connectivity checks
- Retry logic for transient failures
- User-friendly error messages
- Error logging for debugging

### Error Types
- **Network Errors:** Supabase connection failures
- **Data Validation Errors:** Invalid category/sound data
- **Storage Errors:** AsyncStorage failures
- **Mapping Errors:** Data transformation failures

### Error Recovery
- Automatic fallback to local data
- Graceful degradation for missing data
- User notification for critical errors
- Retry mechanisms for transient failures

---

## 📝 Service Configuration

### Environment Variables
```typescript
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_key
```

### Service Initialization
```typescript
// App startup
<CategoryProvider>
  <App />
</CategoryProvider>
```

### Service Cleanup
```typescript
// Automatic cleanup on unmount
// No manual cleanup required
```

---

## 🔄 Service Updates

### Future Enhancements
- Real-time category updates via Supabase subscriptions
- Category caching with expiration
- Category analytics tracking
- Category search functionality
- Category recommendations

---

*For component usage, see `components.md`*  
*For user flows, see `user-flows.md`*  
*For technical details, see `technical-spec.md`*
