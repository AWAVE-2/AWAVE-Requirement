# User Onboarding Screens - Technical Specification

## 🏗️ Architecture Overview

### Technology Stack

#### Core Libraries
- **React Native** - Mobile framework
- **React Native Reanimated** - High-performance animations
  - `useSharedValue` - Shared animation values
  - `useAnimatedStyle` - Animated styles
  - `withTiming`, `withSequence`, `withRepeat` - Animation functions
- **React Native Gesture Handler** - Gesture recognition
  - `Gesture.Pan()` - Swipe detection
- **React Native Linear Gradient** - Gradient backgrounds
- **React Native Blur** - Blur effects (`@react-native-community/blur`)
- **React Native SVG** - Custom icon rendering

#### State Management
- **AsyncStorage** - Local persistence via `storageBridge`
- **React Context** - Global state (AuthContext for userId)
- **React Hooks** - Local component state

#### Services
- `onboardingStorage` - Storage service abstraction
- `ProductionBackendService` - Backend profile sync
- `useProductionAuth` - Authentication hook

---

## 📁 File Structure

```
src/
├── screens/
│   ├── IndexScreen.tsx              # Entry point with preloader
│   └── OnboardingSlidesScreen.tsx   # Main onboarding screen
├── components/
│   └── onboarding/
│       └── OnboardingIcons.tsx       # SVG icon components
├── hooks/
│   └── useOnboardingStorage.ts      # Storage service
└── translations/
    └── de.ts                        # German translations
```

---

## 🔧 Components

### IndexScreen
**Location:** `src/screens/IndexScreen.tsx`  
**Route:** `/` (initial route)  
**Purpose:** App entry point with preloader and routing logic

**Props:** None

**State:**
- `showPreloader: boolean` - Controls preloader visibility

**Components Used:**
- `Preloader` - Animated intro component

**Hooks Used:**
- `useNavigation` - Navigation
- `useUnifiedTheme` - Theme styling
- `useTranslation` - Translations
- `onboardingStorage` - Storage service

**Features:**
- 3-second preloader animation
- Onboarding state checking
- Conditional routing:
  - Completed → MainTabs
  - Profile exists → Slide 5 only
  - No profile → Full onboarding

**Routing Logic:**
```typescript
const { completed, profile } = await onboardingStorage.loadOnboardingState();

if (completed) {
  navigation.navigate('MainTabs');
} else if (profile) {
  navigation.navigate('OnboardingSlides', { startAtSlide: 4 });
} else {
  navigation.navigate('OnboardingSlides');
}
```

**Dependencies:**
- `onboardingStorage.loadOnboardingState()`
- Navigation system

---

### OnboardingSlidesScreen
**Location:** `src/screens/OnboardingSlidesScreen.tsx`  
**Route:** `/onboarding-slides`  
**Purpose:** Main onboarding flow with 5 slides

**Props:**
```typescript
interface RouteParams {
  startAtSlide?: number; // Optional: start at specific slide (0-based)
}
```

**State:**
- `currentSlide: number` - Current slide index (0-4)
- `selectedChoice: string | null` - Selected category ID
- `slideOpacity: SharedValue<number>` - Slide transition opacity

**Components Used:**
- `AnimatedButton` - Action buttons
- `LinearGradient` - Gradient backgrounds
- `BlurView` - Blur effects
- `GestureDetector` - Swipe gesture handling
- `OnboardingIcons` - SVG icons (WelcomeIcon, KlangweltenIcon, etc.)

**Hooks Used:**
- `useNavigation` - Navigation
- `useRoute` - Route parameters
- `useProductionAuth` - User authentication
- `useTranslation` - Translations
- `onboardingStorage` - Storage service

**Features:**
- 5-slide presentation
- Swipe gesture navigation
- Category selection interface
- Slide transitions with fade animations
- Backend sync for authenticated users
- Navigation to MainTabs with initial tab

**Slide Structure:**
```typescript
const slides = [
  { type: 'welcome', title: string, description: string, icon: 'welcome' },
  { type: 'feature', title: string, description: string, icon: 'klangwelten' },
  { type: 'feature', title: string, description: string, icon: 'wirksamkeit' },
  { type: 'feature', title: string, description: string, icon: 'wachstum' },
  { type: 'choice', title: string, description: string, choices: Choice[] }
];
```

**Category Choices:**
```typescript
{
  id: 'schlafen' | 'stress' | 'leichtigkeit',
  label: string,
  imageUrl: string,
  description: string
}
```

**Dependencies:**
- `onboardingStorage`
- `ProductionBackendService`
- `useProductionAuth`
- Navigation system

---

### Preloader Component
**Location:** `src/screens/IndexScreen.tsx` (internal component)  
**Purpose:** Animated intro screen

**Props:**
```typescript
interface PreloaderProps {
  onComplete: () => void;
}
```

**State:**
- `isVisible: boolean` - Visibility control
- `fadeAnim: Animated.Value` - Fade animation
- `scaleAnim1/2/3: Animated.Value` - Circle scale animations
- `opacityAnim1/2/3: Animated.Value` - Circle opacity animations
- `faviconScale: SharedValue<number>` - Favicon pulsation
- `faviconOpacity: SharedValue<number>` - Favicon fade
- `logoOpacity: SharedValue<number>` - Logo fade
- `logoTranslateY: SharedValue<number>` - Logo position
- `taglineOpacity: SharedValue<number>` - Tagline fade
- `taglineTranslateY: SharedValue<number>` - Tagline position

**Animation Sequence:**
1. Favicon: Fade in (800ms) + Pulsate (1.2x ↔ 0.8x, 1.5s cycle)
2. Logo: Fade in + translate (300ms delay, 800ms duration)
3. Tagline: Fade in + translate (500ms delay, 800ms duration)
4. Background circles: Continuous ripple animations
5. Fade out: 500ms after 3 seconds
6. onComplete callback

**Dependencies:**
- `useUnifiedTheme`
- `useTranslation`

---

### OnboardingIcons
**Location:** `src/components/onboarding/OnboardingIcons.tsx`  
**Purpose:** SVG icon components for slides

**Components:**
- `WelcomeIcon` - Compass-like circles
- `KlangweltenIcon` - Wave curves
- `WirksamkeitIcon` - Concentric circles with cross
- `WachstumIcon` - Growth curves
- `FrequenzIcon` - Wave frequency patterns (unused)

**Props:**
```typescript
interface IconProps {
  size?: number;  // Default: 60
  color?: string; // Default: 'white'
}
```

**Features:**
- 60x60 viewBox
- White stroke/fill with opacity variations
- Customizable size and color

---

## 🔌 Services

### onboardingStorage
**Location:** `src/hooks/useOnboardingStorage.ts`  
**Type:** Static Service Object  
**Purpose:** Onboarding state persistence

**Storage Keys:**
- `awaveOnboardingCompleted` - Completion flag ('true' | null)
- `awaveOnboardingProfile` - Profile JSON string
- `awaveSelectedCategory` - Category ID string

**Methods:**

**`loadOnboardingState(): Promise<{completed: boolean, profile: string | null}>`**
- Loads completion flag and profile
- Returns parsed state object
- Used by IndexScreen for routing

**`saveOnboardingCompleted(): Promise<void>`**
- Saves completion flag as 'true'
- Called on onboarding completion

**`saveOnboardingProfile(profile: string): Promise<void>`**
- Saves profile JSON string
- Called on onboarding completion

**`getSelectedCategory(): Promise<string | null>`**
- Gets saved category preference
- Returns category ID or null

**`setSelectedCategory(category: string): Promise<void>`**
- Saves category preference
- Called immediately on selection

**`clearOnboardingFlags(): Promise<void>`**
- Removes completion flag and profile
- Used for reset functionality

**`resetOnboardingToQuestionnaire(): Promise<void>`**
- Removes only completion flag
- Keeps profile for questionnaire-only mode

**Dependencies:**
- `storageBridge` (AsyncStorage abstraction)

---

### ProductionBackendService
**Location:** `src/services/ProductionBackendService.ts`  
**Purpose:** Backend profile synchronization

**Methods Used:**

**`updateUserProfile(userId, updates): Promise<Profile>`**
- Updates user profile with onboarding data
- Called after onboarding completion for authenticated users

**Profile Update Structure:**
```typescript
{
  onboarding_completed: true,
  onboarding_category_preference: 'schlafen' | 'stress' | 'leichtigkeit',
  onboarding_data: {
    steps_completed: ['welcome', 'klangwelten', 'wirksamkeit', 'wachstum', 'choice'],
    category_preference: string,
    completed_at: ISO8601 string,
    preferred_session_type: 'sleep' | 'meditation' | 'focus'
  },
  metadata: {
    primary_category: string,
    onboarding_completed_at: ISO8601 string
  }
}
```

**Category to Session Type Mapping:**
- `schlafen` → `sleep`
- `stress` → `meditation`
- `leichtigkeit` → `focus`

**Dependencies:**
- Supabase client
- User authentication

---

## 🪝 Hooks

### useProductionAuth
**Location:** `src/hooks/useProductionAuth.ts`  
**Purpose:** Get current user ID for backend sync

**Returns:**
```typescript
{
  userId: string | undefined;
  // ... other auth properties
}
```

**Usage:**
- Check if user is authenticated
- Get userId for backend profile updates
- Guest mode: userId is undefined

---

## 🎨 Animation Implementation

### Slide Transitions
```typescript
// Fade out current slide
slideOpacity.value = withTiming(0, { duration: 200 }, (finished) => {
  if (finished) {
    runOnJS(changeToSlide)(nextSlide);
  }
});

// Fade in new slide (in useEffect)
slideOpacity.value = withTiming(1, { duration: 300 });
```

### Background Blob Animation
```typescript
// Scale, opacity, and rotation sequences
const scaleSequence = [1, 1.4, 1];
const opacitySequence = [0.3, 0, 0.3];
const rotateSequence = [0, 180, 360];

// Continuous loop with 3 keyframes
scale.value = withRepeat(
  withSequence(
    withTiming(scaleSequence[1], { duration: segmentDuration }),
    withTiming(scaleSequence[2], { duration: segmentDuration }),
    withTiming(scaleSequence[0], { duration: segmentDuration })
  ),
  -1, // Infinite
  false
);
```

### Wave Visualization
```typescript
// 60 bars with progressive delays
const delay = (i / 60) * 4500; // Spread across 4.5 seconds

// Wave animation: base → max → base
height.value = withRepeat(
  withSequence(
    withTiming(baseHeight, { duration: 900 }),
    withTiming(maxHeight, { duration: 1800 }),
    withTiming(baseHeight, { duration: 600 }),
    withTiming(baseHeight, { duration: 1200 })
  ),
  -1,
  false
);
```

### Choice Button Selection
```typescript
// Scale animation on selection
scale.value = withTiming(selected ? 1.02 : 1, {
  duration: 300,
  easing: Easing.ease
});
```

---

## 🔐 State Management

### Local State (OnboardingSlidesScreen)
```typescript
{
  currentSlide: number;           // 0-4
  selectedChoice: string | null;   // 'schlafen' | 'stress' | 'leichtigkeit' | null
  slideOpacity: SharedValue<number>; // 0-1
}
```

### Persistent State (AsyncStorage)
```typescript
{
  awaveOnboardingCompleted: 'true' | null;
  awaveOnboardingProfile: string; // JSON
  awaveSelectedCategory: string; // 'schlafen' | 'stress' | 'leichtigkeit'
}
```

### Backend State (Supabase Profile)
```typescript
{
  onboarding_completed: boolean;
  onboarding_category_preference: string;
  onboarding_data: {
    steps_completed: string[];
    category_preference: string;
    completed_at: string;
    preferred_session_type: string;
  };
  metadata: {
    primary_category: string;
    onboarding_completed_at: string;
  };
}
```

---

## 🌐 API Integration

### Supabase Profile Update
```typescript
await ProductionBackendService.updateUserProfile(userId, {
  onboarding_completed: true,
  onboarding_category_preference: selectedChoice,
  onboarding_data: { /* ... */ },
  metadata: { /* ... */ }
});
```

**Error Handling:**
- Non-blocking: Continue navigation even if sync fails
- Log warnings but don't throw errors
- Local storage is primary source of truth

---

## 📱 Platform-Specific Notes

### iOS
- Blur effects work natively
- Gesture handling is smooth
- SVG icons render correctly

### Android
- Blur effects may have performance considerations
- Gesture handling works with Gesture Handler
- SVG icons render correctly

### Common
- Responsive layout for all screen sizes
- Safe area handling for notches
- Keyboard avoidance not needed (no text inputs)

---

## 🧪 Testing Strategy

### Unit Tests
- Storage service methods
- Animation value calculations
- Category mapping logic
- State transition logic

### Integration Tests
- Complete onboarding flow
- Backend sync functionality
- Navigation routing
- State persistence

### E2E Tests
- First-time user flow
- Returning user flow
- Category selection
- Reset functionality
- Offline mode

---

## 🐛 Error Handling

### Error Types
- Storage failures
- Backend sync failures
- Navigation errors
- Animation errors

### Error Handling Strategy
- **Storage:** Graceful degradation, log errors
- **Backend Sync:** Non-blocking, continue with local data
- **Navigation:** Fallback to MainTabs
- **Animations:** Fallback to static state

---

## 📊 Performance Considerations

### Optimization
- Lazy loading of images (Unsplash URLs)
- Efficient re-renders (useSharedValue for animations)
- Debounced slide changes
- Memoized icon components

### Monitoring
- Animation frame rate
- Slide transition time
- Storage operation time
- Backend sync time

---

*For component details, see `components.md`*  
*For service dependencies, see `services.md`*  
*For user flows, see `user-flows.md`*
