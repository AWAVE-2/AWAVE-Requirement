# Start Screens System - Technical Specification

## 🏗️ Architecture Overview

### Technology Stack

#### Core Framework
- **React Native** - Mobile app framework
- **TypeScript** - Type safety and developer experience
- **React Navigation** - Navigation and routing

#### Animation Libraries
- **React Native Reanimated** - High-performance animations
- **React Native Animated** - Basic animations
- **React Native Gesture Handler** - Swipe gestures

#### UI Libraries
- **React Native Linear Gradient** - Gradient backgrounds
- **@react-native-community/blur** - Blur effects
- **React Native SVG** - Icon rendering

#### Storage
- **AsyncStorage** - Local persistence
- **Storage Bridge** - Abstraction layer for storage

#### State Management
- **React Context API** - Global state
- **React Hooks** - Local state management
- **Custom Hooks** - Reusable state logic

---

## 📁 File Structure

```
src/
├── screens/
│   ├── IndexScreen.tsx              # Entry point with preloader
│   └── OnboardingSlidesScreen.tsx   # Onboarding flow
├── components/
│   └── onboarding/
│       └── OnboardingIcons.tsx      # SVG icon components
├── hooks/
│   └── useOnboardingStorage.ts      # Storage service
├── services/
│   └── ProductionBackendService.ts # Backend sync
└── contexts/
    ├── LanguageContext.tsx           # Translations
    └── AuthContext.tsx               # Authentication state
```

---

## 🔧 Components

### IndexScreen
**Location:** `src/screens/IndexScreen.tsx`

**Purpose:** Entry point with preloader and routing logic

**Props:** None (root screen)

**State:**
- `showPreloader: boolean` - Controls preloader visibility

**Components Used:**
- `Preloader` - Internal animated preloader component

**Hooks Used:**
- `useNavigation` - Navigation
- `useUnifiedTheme` - Theme styling
- `useTranslation` - Translations
- `onboardingStorage` - Storage service

**Features:**
- Animated preloader with branding
- Intelligent routing based on onboarding state
- Error handling and fallbacks
- Loading state during navigation

**Routing Logic:**
```typescript
if (onboardingCompleted) {
  navigate('MainTabs');
} else if (profileExists) {
  navigate('OnboardingSlides', { startAtSlide: 4 });
} else {
  navigate('OnboardingSlides');
}
```

---

### Preloader Component
**Location:** `src/screens/IndexScreen.tsx` (internal component)

**Purpose:** Animated preloader with AWAVE branding

**Props:**
```typescript
interface PreloaderProps {
  onComplete: () => void;
}
```

**State:**
- `isVisible: boolean` - Component visibility
- Animation values for favicon, logo, tagline, circles

**Features:**
- Favicon pulsating animation
- Logo fade-in with translate
- Tagline fade-in with translate
- Three concentric ripple circles
- 3-second duration with fade-out

**Animation Timing:**
- Favicon: Immediate fade-in (800ms), continuous pulsation
- Logo: 300ms delay, fade-in (800ms)
- Tagline: 500ms delay, fade-in (800ms)
- Preloader: 3 seconds total
- Fade-out: 500ms
- Navigation delay: 500ms after fade-out

---

### OnboardingSlidesScreen
**Location:** `src/screens/OnboardingSlidesScreen.tsx`

**Purpose:** Multi-slide onboarding experience

**Props:** None (route params used)

**Route Params:**
```typescript
{
  startAtSlide?: number; // Optional slide index to start at
}
```

**State:**
- `currentSlide: number` - Current slide index (0-4)
- `selectedChoice: string | null` - Selected category
- `slideOpacity: SharedValue<number>` - Slide transition opacity

**Components Used:**
- `AnimatedButton` - Interactive buttons
- `LinearGradient` - Gradient backgrounds
- `BlurView` - Blur effects
- `GestureDetector` - Swipe gestures
- `OnboardingIcons` - SVG icons

**Hooks Used:**
- `useNavigation` - Navigation
- `useRoute` - Route params
- `useProductionAuth` - Authentication state
- `useTranslation` - Translations
- `onboardingStorage` - Storage service

**Features:**
- 5 slides with different content types
- Swipe gesture navigation
- Next/Skip buttons
- Category selection on last slide
- State persistence
- Backend synchronization

**Slide Structure:**
```typescript
interface Slide {
  type: 'welcome' | 'feature' | 'choice';
  title: string;
  description: string;
  icon?: string;
  choices?: Choice[];
}
```

---

### OnboardingIcons
**Location:** `src/components/onboarding/OnboardingIcons.tsx`

**Purpose:** SVG icon components for onboarding slides

**Icons:**
- `WelcomeIcon` - Welcome slide icon
- `KlangweltenIcon` - Sound worlds icon
- `WirksamkeitIcon` - Effectiveness icon
- `WachstumIcon` - Growth icon

**Props:**
```typescript
interface IconProps {
  size?: number;
  color?: string;
}
```

---

## 🔌 Services

### onboardingStorage
**Location:** `src/hooks/useOnboardingStorage.ts`

**Type:** Static Service Object

**Storage Keys:**
- `awaveOnboardingCompleted` - Completion flag
- `awaveOnboardingProfile` - Profile JSON string
- `awaveSelectedCategory` - Category preference

**Methods:**

**`loadOnboardingState(): Promise<{completed: boolean, profile: string | null}>`**
- Loads completion status and profile
- Returns both values asynchronously
- Handles missing data gracefully

**`saveOnboardingCompleted(): Promise<void>`**
- Saves completion flag as 'true'
- Used when onboarding is finished

**`saveOnboardingProfile(profile: string): Promise<void>`**
- Saves profile JSON string
- Used to store user preferences

**`setSelectedCategory(category: string): Promise<void>`**
- Saves selected category
- Used for immediate preference storage

**`getSelectedCategory(): Promise<string | null>`**
- Retrieves selected category
- Returns null if not set

**`clearOnboardingFlags(): Promise<void>`**
- Removes completion flag and profile
- Used for reset functionality

**`resetOnboardingToQuestionnaire(): Promise<void>`**
- Removes only completion flag
- Keeps profile for partial reset

**Dependencies:**
- `storageBridge` - Storage abstraction layer

---

### ProductionBackendService
**Location:** `src/services/ProductionBackendService.ts`

**Purpose:** Backend synchronization for onboarding data

**Methods Used:**

**`updateUserProfile(userId: string, updates: ProfileUpdates): Promise<Result>`**
- Updates user profile with onboarding data
- Includes completion status, category preference, metadata
- Returns result with data or error

**Onboarding Data Structure:**
```typescript
{
  onboarding_completed: boolean;
  onboarding_category_preference: string;
  onboarding_data: {
    steps_completed: string[];
    category_preference: string;
    completed_at: string;
    preferred_session_type: 'sleep' | 'meditation' | 'focus';
  };
  metadata: {
    primary_category: string;
    onboarding_completed_at: string;
  };
}
```

---

## 🪝 Hooks

### useOnboardingStorage
**Location:** `src/hooks/useOnboardingStorage.ts`

**Purpose:** Storage service for onboarding state

**Exports:**
- `onboardingStorage` - Service object with methods

**Usage:**
```typescript
const { completed, profile } = await onboardingStorage.loadOnboardingState();
await onboardingStorage.saveOnboardingCompleted();
await onboardingStorage.setSelectedCategory('schlafen');
```

---

### useProductionAuth
**Location:** `src/hooks/useProductionAuth.ts`

**Purpose:** Authentication state hook

**Returns:**
```typescript
{
  userId: string | undefined;
  // ... other auth properties
}
```

**Usage in Onboarding:**
- Checks if user is authenticated
- Only syncs to backend if userId exists
- Supports guest mode (no userId)

---

## 🎨 Styling

### Theme Integration
All components use the unified theme system:
- `useUnifiedTheme()` - Theme hook
- `colors.awavePrimary` - Primary brand color
- `colors.awaveSecondary` - Secondary brand color
- `colors.awaveBackground` - Background color

### Animation Styles
- **Reanimated** - High-performance animations
- **Animated API** - Basic animations
- **Shared Values** - Reactive animation values
- **Worklets** - UI thread animations

### Layout Styles
- **Flexbox** - Layout system
- **Dimensions API** - Screen size detection
- **SafeAreaView** - Safe area handling
- **KeyboardAvoidingView** - Keyboard handling

---

## 🔄 State Management

### Local State
- Slide index (currentSlide)
- Selected choice (selectedChoice)
- Animation values (opacity, scale, etc.)
- Loading states

### Persistent State
- Onboarding completion flag
- User profile data
- Category preference
- Stored in AsyncStorage

### Backend State
- User profile with onboarding data
- Synced for authenticated users
- Optional (local storage is primary)

---

## 🌐 API Integration

### Backend Endpoints
- `updateUserProfile` - Updates user profile with onboarding data

### Data Flow
```
Local Selection → Save Locally → Check Auth → Sync to Backend
     │                │              │              │
     │                │              │              └─> Success/Error
     │                │              └─> No Auth → Skip Sync
     │                └─> AsyncStorage
     └─> Immediate Feedback
```

---

## 📱 Platform-Specific Notes

### iOS
- Native blur effects via BlurView
- Smooth animations with Reanimated
- Gesture handling via Gesture Handler
- Safe area handling

### Android
- Blur effects via community library
- Animations work identically
- Gesture handling works identically
- Status bar handling

### Common
- Both platforms use same code
- Platform-specific optimizations handled by libraries
- Responsive design for all screen sizes

---

## 🧪 Testing Strategy

### Unit Tests
- Storage operations
- State transitions
- Animation calculations
- Data transformations

### Integration Tests
- Navigation flows
- Storage persistence
- Backend synchronization
- Error handling

### E2E Tests
- Complete onboarding flow
- Category selection
- State persistence
- Backend sync

---

## 🐛 Error Handling

### Error Types
- Storage errors
- Network errors
- Navigation errors
- Backend sync errors

### Error Handling Strategy
- Graceful degradation
- Fallback to safe states
- Error logging
- User-friendly messages

### Error Recovery
- Retry mechanisms
- State recovery
- Data validation
- Fallback navigation

---

## 📊 Performance Considerations

### Optimization
- Lazy loading of images
- Efficient animation calculations
- Debounced user interactions
- Optimized re-renders

### Monitoring
- Animation frame rates
- Storage operation times
- Backend sync success rates
- User completion rates

---

## 🔐 Security Considerations

### Data Storage
- No sensitive data in local storage
- Category preferences are non-sensitive
- Profile data is user-generated

### Backend Sync
- Authenticated requests only
- Secure token transmission
- Error messages don't expose sensitive data

---

*For component details, see `components.md`*  
*For service dependencies, see `services.md`*  
*For user flows, see `user-flows.md`*
