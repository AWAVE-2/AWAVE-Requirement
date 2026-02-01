# Category Screens - Technical Specification

## 🏗️ Architecture Overview

### Technology Stack (React Native - Reference)

#### Backend
- **Supabase** - Primary data source (React Native)
  - `audio_categories` table - Category metadata
  - `sound_metadata` table - Sound metadata
  - Real-time subscriptions (future enhancement)

#### State Management
- **React Context API** - `CategoryContext` for global category state
- **Custom Hooks** - `useCategoryManagement`, `useCategoryContext`
- **AsyncStorage** - Local caching and persistence

#### UI Components
- **React Native** - Core UI framework
- **React Native Linear Gradient** - Gradient backgrounds
- **Lucide React Native** - Icons (Sparkles, Activity)
- **React Navigation** - Navigation structure

#### Services Layer
- `CategoryService` - Backend data fetching
- `onboardingStorage` - Category selection persistence
- `useSoundPlayer` - Audio playback integration
- `useFavoritesManagement` - Favorites handling
- `useCustomSounds` - Custom sounds management

---

## 🍎 Swift iOS Implementation

### Technology Stack

#### Backend
- **Firebase Firestore** - Category session storage
  - `users/{userId}/categorySessions/{category}/sessions/{sessionId}` - Session documents
  - Batch operations for atomic saves/deletes
  - Offline persistence built-in

#### State Management
- **SwiftUI @Observable** - CategorySessionsViewModel
- **@Environment** - Dependency injection
- **Property Wrappers** - @Published for reactive state

#### UI Components
- **SwiftUI** - Native UI framework
- **LazyVGrid** - Session grid layout
- **NavigationStack** - Navigation structure
- **@Observable** macro - State management

#### Services Layer
- `CategorySessionGenerator` - Deterministic session generation
- `FirestoreSessionRepository` - Backend data persistence
- `SessionRepositoryProtocol` - Repository abstraction
- `AuthServiceProtocol` - User authentication
- `MockSessionRepository` - Testing support

### Key Differences from React Native

| Feature | React Native | Swift iOS |
|---------|--------------|-----------|
| Backend | Supabase | Firebase Firestore |
| State | Context API | @Observable |
| Sessions | Backend-fetched sounds | Generated sessions (SessionGenerator) |
| Navigation | Tab Navigator | NavigationStack + TabView |
| Data Structure | Sound metadata | Full Session objects with phases |
| Offline | AsyncStorage | Firestore offline + local generation |
| Testing | Jest/React Testing Library | XCTest + Swift Testing |

---

## 📁 File Structure

### React Native (Reference)
```
src/
├── screens/
│   ├── SchlafScreen.tsx              # Sleep category screen
│   ├── RuheScreen.tsx                # Stress/rest category screen
│   └── ImFlussScreen.tsx             # Flow/lightness category screen
├── components/
│   ├── screens/
│   │   ├── CategoryScreenBase.tsx    # Reusable base component
│   │   └── CategoryHeroHeader.tsx    # Category header component
│   ├── SoundGrid.tsx                 # Sound grid layout
│   └── ui/
│       └── CategoryCard.tsx          # Category card component
├── contexts/
│   └── CategoryContext.tsx           # Global category context
├── services/
│   └── CategoryService.ts            # Backend data fetching
├── hooks/
│   └── useCategoryManagement.ts      # Category management hook
├── data/
│   ├── exactDataStructures.ts        # Category and sound interfaces
│   └── categories.ts                  # Category data (legacy)
└── navigation/
    └── TabNavigator.tsx               # Tab navigation component
```

### Swift iOS Implementation
```
AWAVE/
├── Features/
│   ├── Categories/
│   │   ├── CategorySessionsView.swift           # Category sessions screen
│   │   └── CategorySessionsViewModel.swift      # ViewModel with business logic
│   └── Home/
│       └── HomeView.swift                       # Entry point with navigation
├── Services/
│   ├── CategorySessionGenerator.swift           # Session generation logic
│   └── Mock/
│       └── MockSessionRepository.swift          # Mock for testing
├── Navigation/
│   ├── Destinations.swift                       # Navigation destinations
│   └── AppCoordinator.swift                     # Navigation coordinator
└── Tests/
    ├── Features/
    │   └── Categories/
    │       └── CategorySessionsViewModelTests.swift  # ViewModel tests (14 tests)
    └── Services/
        └── CategorySessionGeneratorTests.swift       # Generator tests (16 tests)

Packages/
├── AWAVEDomain/
│   └── Sources/
│       ├── Models/
│       │   ├── OnboardingCategory.swift         # Category enum
│       │   ├── Session.swift                    # Session model
│       │   └── Voice.swift                      # Voice enum
│       └── Repositories/
│           └── SessionRepositoryProtocol.swift  # Repository protocol
└── AWAVEData/
    └── Sources/
        └── Repositories/
            └── FirestoreSessionRepository.swift # Firestore implementation
```

---

## 🔧 Components

### SchlafScreen
**Location:** `src/screens/SchlafScreen.tsx`

**Purpose:** Sleep category screen with meditation, dream journeys, theta waves, white noise

**Props:** None (screen component)

**State:**
- `isAddSoundOpen: boolean` - Add sound drawer state

**Hooks Used:**
- `useCategoryContext` - Category data
- `useSoundPlayer` - Audio playback
- `useCustomSounds` - Custom sounds
- `useFavoritesManagement` - Favorites
- `useRegistrationFlow` - Registration handling

**Features:**
- Category content display
- Sound selection and playback
- Mini player strip
- Add sound drawer
- Klangwelten navigation

**Dependencies:**
- `CategoryScreenBase` component
- `MiniPlayerStrip` component
- `AddNewSoundDrawer` component
- `AudioPlayerEnhanced` component

---

### RuheScreen
**Location:** `src/screens/RuheScreen.tsx`

**Purpose:** Stress/rest category screen with relaxation exercises, breathing techniques, calming sounds

**Props:** None (screen component)

**State:**
- `isAddSoundOpen: boolean` - Add sound drawer state

**Hooks Used:**
- `useCategoryContext` - Category data
- `useSoundPlayer` - Audio playback
- `useCustomSounds` - Custom sounds
- `useFavoritesManagement` - Favorites
- `useRegistrationFlow` - Registration handling

**Features:**
- Category content display
- Sound selection and playback
- Mini player strip
- Add sound drawer
- Klangwelten navigation

**Dependencies:**
- `CategoryScreenBase` component
- `MiniPlayerStrip` component
- `AddNewSoundDrawer` component
- `AudioPlayerEnhanced` component

---

### ImFlussScreen
**Location:** `src/screens/ImFlussScreen.tsx`

**Purpose:** Flow/lightness category screen with motivating sounds, energy sounds, focus audio

**Props:** None (screen component)

**State:**
- `isAddSoundOpen: boolean` - Add sound drawer state

**Hooks Used:**
- `useCategoryContext` - Category data
- `useSoundPlayer` - Audio playback
- `useCustomSounds` - Custom sounds
- `useFavoritesManagement` - Favorites
- `useRegistrationFlow` - Registration handling

**Features:**
- Category content display
- Sound selection and playback
- Mini player strip
- Add sound drawer
- Klangwelten navigation

**Dependencies:**
- `CategoryScreenBase` component
- `MiniPlayerStrip` component
- `AddNewSoundDrawer` component
- `AudioPlayerEnhanced` component

---

### CategoryScreenBase
**Location:** `src/components/screens/CategoryScreenBase.tsx`

**Purpose:** Reusable base component for all category screens

**Props:**
```typescript
interface CategoryScreenBaseProps {
  categoryId: 'schlafen' | 'stress' | 'leichtigkeit';
  category: {
    id: string;
    sounds: Sound[];
    title?: string;
  };
  customSounds: Sound[];
  favoriteSounds: FavoriteSound[];
  onSoundSelect: (sound: Sound) => void;
  onAddToMix: (sound: Sound) => void;
  onFavoriteSelect: (favorite: FavoriteSound) => void;
  onRequestAddSound: () => void;
  onRequestKlangwelten?: () => void;
}
```

**Features:**
- Category hero header display
- Sound grid layout
- Favorites filtering by category
- Custom sounds integration
- Scrollable content container

**Dependencies:**
- `CategoryHeroHeader` component
- `SoundGrid` component
- `getCategoryContent` utility

---

### CategoryHeroHeader
**Location:** `src/components/screens/CategoryHeroHeader.tsx`

**Purpose:** Category header with icon, headline, and description

**Props:**
```typescript
interface CategoryHeroHeaderProps {
  content: CategoryContent;
  categoryId: string;
  panelWidth?: number; // Not used but kept for compatibility
}
```

**Features:**
- Category-specific icon with gradient background
- Headline display
- Description text
- Gradient divider
- Category-specific theming

**Category Themes:**
- **Schlafen:** Purple gradient, Sparkles icon
- **Stress:** Blue gradient, Activity icon
- **Leichtigkeit:** Emerald gradient, Sparkles icon

**Dependencies:**
- `LinearGradient` component
- `Icon` component
- `lucide-react-native` icons

---

### SoundGrid
**Location:** `src/components/SoundGrid.tsx`

**Purpose:** Grid layout for displaying sounds with airplane window design

**Props:**
```typescript
interface SoundGridProps {
  sounds: Sound[];
  customSounds: Sound[];
  favoriteSounds: FavoriteSound[];
  onSoundSelect: (sound: Sound) => void;
  onAddToMix: (sound: Sound) => void;
  onFavoriteSelect: (favorite: FavoriteSound) => void;
  onRequestAddSound: () => void;
  onRequestKlangwelten?: () => void;
  categoryId?: string;
}
```

**Features:**
- Sound cards with airplane window design
- "Weitere Sessions" button
- "Eigene Klangwelt" section
- Sound selection handling
- Gradient button styling

**Dependencies:**
- `EnhancedCard` component
- `AnimatedButton` component
- `LinearGradient` component

---

## 🔌 Services

### CategoryService
**Location:** `src/services/CategoryService.ts`

**Class:** Static service

**Methods:**

**`fetchPrimaryCategories(): Promise<Category[]>`**
- Fetches all three primary categories from Supabase
- Fetches category metadata from `audio_categories` table
- Fetches sound metadata from `sound_metadata` table
- Merges backend data with fallback data
- Returns ordered categories array

**Data Fetching:**
- Fetches from `audio_categories` table (id, name, display_name, description, icon_name, color_hex, sort_order)
- Fetches from `sound_metadata` table (sound_id, title, description, category_id, tags, keywords, search_weight, metadata, image_url, artwork_url, bucket_id, storage_path)
- Orders sounds by `search_weight` (descending)
- Limits to 8 sounds per category

**Fallback Mechanism:**
- Uses `majorCategories` from `exactDataStructures.ts` if backend unavailable
- Maps backend metadata to Sound interface
- Handles missing or invalid data gracefully

**Error Handling:**
- Network errors: Returns fallback categories
- Invalid data: Uses fallback sounds
- Missing categories: Uses default category structure

---

### CategoryContext
**Location:** `src/contexts/CategoryContext.tsx`

**Class:** React Context Provider

**State:**
```typescript
{
  selectedCategory: string;
  orderedCategories: Category[];
  isLoading: boolean;
}
```

**Methods:**
- `handleCategorySelect(categoryId: string): Promise<void>` - Select category and persist
- `refreshCategories(): Promise<void>` - Refresh category data
- `loadInitialCategories(): Promise<void>` - Load categories on mount

**Features:**
- Global category state management
- Category selection persistence
- Category data loading
- Fixed category ordering (no reordering based on selection)

**Storage:**
- Category selection stored in `onboardingStorage`
- Category data cached in memory
- Initial category loaded from onboarding profile

---

## 🪝 Hooks

### useCategoryContext
**Location:** `src/contexts/CategoryContext.tsx`

**Purpose:** Access category context

**Returns:**
```typescript
{
  selectedCategory: string;
  orderedCategories: Category[];
  handleCategorySelect: (categoryId: string) => Promise<void>;
  refreshCategories: () => Promise<void>;
  isLoading: boolean;
}
```

**Usage:**
```typescript
const { orderedCategories, selectedCategory } = useCategoryContext();
```

---

### useCategoryManagement
**Location:** `src/hooks/useCategoryManagement.ts`

**Purpose:** Category management hook (wrapper around useCategoryContext)

**Returns:** Same as `useCategoryContext`

**Usage:**
```typescript
const categoryManagement = useCategoryManagement();
```

---

## 📊 Data Structures

### Category Interface
```typescript
interface Category {
  id: string;
  title: string;
  description: string;
  iconUrl: string;
  icon?: string; // Emoji or icon name
  iconComponent?: React.ComponentType; // LucideIcon component
  sounds: Sound[];
  heroImage?: string; // Category hero image URL
  gradient?: string[]; // Category gradient colors [from, to]
}
```

### Sound Interface
```typescript
interface Sound {
  id: string;
  title: string;
  description: string;
  imageUrl?: string;
  isCustom?: boolean;
  audioFile?: string;
  categoryId?: string;
  createdAt?: string;
  bucketId?: string;
  storagePath?: string;
  baseSound?: Sound; // Reference to library sound
  generatorType?: 'wave' | 'rain' | 'noise';
  generatorParams?: {
    type?: 'ocean' | 'lake' | 'river';
    intensity?: 'light' | 'medium' | 'heavy';
    color?: 'white' | 'pink' | 'brown';
    duration?: number;
  };
}
```

### CategoryContent Interface
```typescript
interface CategoryContent {
  headline: string;
  copy: string;
  heroImage?: string;
  gradient: string[];
}
```

### Primary Categories
- `schlafen` - Sleep category
- `stress` - Stress/rest category
- `leichtigkeit` - Flow/lightness category

---

## 🔄 State Management

### CategoryContext State
```typescript
{
  selectedCategory: string; // Currently selected category ID
  orderedCategories: Category[]; // All categories in fixed order
  isLoading: boolean; // Loading state
}
```

### Category Selection Flow
1. User selects category (via tab or onboarding)
2. `handleCategorySelect` called
3. Category ID stored in `onboardingStorage`
4. `selectedCategory` state updated
5. Navigation handled by `TabNavigator`

### Category Data Loading Flow
1. App starts → `CategoryProvider` mounts
2. `loadInitialCategories` called
3. `CategoryService.fetchPrimaryCategories()` fetches data
4. Categories loaded from Supabase or fallback
5. Initial category selected from onboarding storage
6. `orderedCategories` state updated

---

## 🌐 API Integration

### Supabase Tables

#### audio_categories
```sql
- id: string
- name: string (schlafen, stress, leichtigkeit)
- display_name: string
- description: string | null
- icon_name: string | null
- color_hex: string | null
- sort_order: number | null
```

#### sound_metadata
```sql
- sound_id: string
- title: string | null
- description: string | null
- category_id: string | null
- tags: string[] | null
- keywords: string[] | null
- search_weight: number | null
- metadata: JSON | null
- image_url: string | null
- artwork_url: string | null
- bucket_id: string | null
- storage_path: string | null
- created_at: string
- updated_at: string
```

### Query Patterns
```typescript
// Fetch categories
supabase
  .from('audio_categories')
  .select('id, name, display_name, description, icon_name, color_hex, sort_order')
  .in('name', ['schlafen', 'stress', 'leichtigkeit'])

// Fetch sounds for category
supabase
  .from('sound_metadata')
  .select('sound_id, title, description, category_id, tags, keywords, search_weight, metadata, image_url, artwork_url, bucket_id, storage_path')
  .eq('category_id', categoryId)
  .order('search_weight', { ascending: false })
  .limit(8)
```

---

## 📱 Platform-Specific Notes

### iOS
- Safe area handling for notch and status bar
- Native navigation transitions
- Haptic feedback support (optional)

### Android
- Safe area handling for status bar
- Material Design navigation patterns
- Back button handling

### Common
- Responsive layout for different screen sizes
- Scrollable content with proper padding
- Touch target sizes (min 44x44)

---

## 🧪 Testing Strategy

### Unit Tests
- Category context state management
- Category service data fetching
- Category content configuration
- Sound filtering logic
- Category selection persistence

### Integration Tests
- Category screen rendering
- Category navigation flow
- Sound selection and playback
- Backend data fetching
- Fallback mechanism

### E2E Tests
- Complete category browsing flow
- Category selection and persistence
- Sound playback from category
- Navigation between categories
- Custom sounds integration

---

## 🐛 Error Handling

### Error Types
- Network errors (Supabase connection failures)
- Data validation errors (invalid category/sound data)
- Storage errors (AsyncStorage failures)
- Navigation errors (invalid routes)

### Error Messages
- User-friendly German messages
- Clear action guidance
- Retry options where applicable
- No technical jargon

### Fallback Mechanisms
- Local category data when backend unavailable
- Default category structure for missing data
- Empty state handling for no sounds
- Graceful degradation for missing metadata

---

## 📊 Performance Considerations

### Optimization
- Lazy loading of category screens
- Efficient data fetching (parallel requests)
- Category data caching
- Sound grid virtualization (future)
- Image optimization and caching

### Monitoring
- Category screen load time
- Data fetch success rate
- Navigation transition performance
- Sound selection response time

---

## 🔐 Security Considerations

### Data Security
- Category data fetched from authenticated Supabase
- Sound metadata validated before display
- Category selection stored securely
- No sensitive data in category screens

### Privacy
- Category selection is user-specific
- No personal data in category screens
- Sound metadata doesn't expose user data

---

*For component details, see `components.md`*  
*For service dependencies, see `services.md`*  
*For user flows, see `user-flows.md`*
