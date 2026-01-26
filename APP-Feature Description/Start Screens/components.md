# Start Screens System - Components Inventory

## 📱 Screens

### IndexScreen
**File:** `src/screens/IndexScreen.tsx`  
**Route:** `/`  
**Purpose:** Entry point with preloader and intelligent routing

**Props:** None (root screen)

**State:**
- `showPreloader: boolean` - Controls preloader visibility

**Components Used:**
- `Preloader` - Internal animated preloader component
- `View` - Container components
- `Text` - Loading text
- `Animated.View` - Animated container
- `Image` - Logo and favicon images

**Hooks Used:**
- `useNavigation` - Navigation routing
- `useUnifiedTheme` - Theme styling
- `useTranslation` - Translations
- `useCallback` - Memoized callbacks
- `useState` - Local state
- `onboardingStorage` - Storage service

**Features:**
- Animated preloader display
- Intelligent routing logic
- State management
- Error handling
- Loading state display

**User Interactions:**
- None (automatic navigation)

**Navigation Logic:**
- Checks onboarding completion
- Routes based on user state
- Handles errors gracefully

---

### OnboardingSlidesScreen
**File:** `src/screens/OnboardingSlidesScreen.tsx`  
**Route:** `/onboarding-slides`  
**Purpose:** Multi-slide onboarding experience

**Route Params:**
```typescript
{
  startAtSlide?: number; // Optional starting slide index
}
```

**State:**
- `currentSlide: number` - Current slide index (0-4)
- `selectedChoice: string | null` - Selected category
- `slideOpacity: SharedValue<number>` - Transition opacity

**Components Used:**
- `LinearGradient` - Gradient backgrounds
- `BlurView` - Blur effects
- `AnimatedButton` - Interactive buttons
- `GestureDetector` - Swipe gesture handling
- `ScrollView` - Scrollable content
- `View` - Container components
- `Text` - Text content
- `Image` - Category images
- `Reanimated.View` - Animated containers
- `OnboardingIcons` - SVG icons

**Hooks Used:**
- `useNavigation` - Navigation
- `useRoute` - Route params
- `useProductionAuth` - Authentication
- `useTranslation` - Translations
- `useState` - Local state
- `useEffect` - Side effects
- `useSharedValue` - Animation values
- `useAnimatedStyle` - Animated styles
- `onboardingStorage` - Storage service
- `ProductionBackendService` - Backend sync

**Features:**
- 5 slides with different content
- Swipe gesture navigation
- Next/Skip buttons
- Category selection
- State persistence
- Backend synchronization
- Smooth animations

**User Interactions:**
- Swipe left/right to navigate
- Tap Next button
- Tap Skip button
- Select category option
- Tap Get Started button

---

## 🧩 Components

### Preloader Component
**File:** `src/screens/IndexScreen.tsx` (internal)  
**Type:** Internal Component

**Props:**
```typescript
interface PreloaderProps {
  onComplete: () => void;
}
```

**State:**
- `isVisible: boolean` - Component visibility
- Animation values (fadeAnim, scaleAnim, opacityAnim, etc.)

**Components Used:**
- `Animated.View` - Animated containers
- `Reanimated.View` - Reanimated containers
- `Image` - Favicon and logo
- `Text` - Tagline text
- `View` - Layout containers

**Features:**
- Favicon pulsating animation
- Logo fade-in animation
- Tagline fade-in animation
- Three concentric ripple circles
- 3-second duration
- Fade-out transition

**Animation Details:**
- **Favicon:** Pulsating scale (0.8 → 1.2 → 0.8), continuous
- **Logo:** Fade-in (opacity 0 → 1) with translate (20 → 0), 300ms delay
- **Tagline:** Fade-in (opacity 0 → 1) with translate (20 → 0), 500ms delay
- **Circles:** Scale and opacity animations, synchronized

---

### ChoiceButtonWrapper
**File:** `src/screens/OnboardingSlidesScreen.tsx` (internal)  
**Type:** Internal Animated Component

**Props:**
```typescript
interface ChoiceButtonWrapperProps {
  children: React.ReactNode;
  selected: boolean;
}
```

**State:**
- `scale: SharedValue<number>` - Scale animation value

**Features:**
- Scale animation on selection
- Smooth transitions
- Visual feedback

**Animation:**
- Selected: Scale 1 → 1.02 (300ms)
- Unselected: Scale 1.02 → 1 (300ms)

---

### AnimatedBackgroundBlob
**File:** `src/screens/OnboardingSlidesScreen.tsx` (internal)  
**Type:** Internal Animated Component

**Props:**
```typescript
interface AnimatedBackgroundBlobProps {
  style: any;
  scaleSequence: number[];
  opacitySequence: number[];
  rotateSequence: number[];
  duration: number;
  delay?: number;
}
```

**Features:**
- Animated background decoration
- Scale, opacity, and rotation animations
- Configurable sequences
- Optional delay

**Usage:**
- Background visual effects
- Subtle animation enhancement

---

### WaveBar
**File:** `src/screens/OnboardingSlidesScreen.tsx` (internal)  
**Type:** Internal Animated Component

**Props:**
```typescript
interface WaveBarProps {
  index: number;
  baseHeight: number;
  maxScale: number;
  delay: number;
}
```

**Features:**
- Animated wave visualization
- Progressive delay for wave effect
- Gradient fill
- Used in choice slide

**Animation:**
- Height animation: base → max → base
- Progressive delays create wave effect
- 60 bars total

---

### IconContainer
**File:** `src/screens/OnboardingSlidesScreen.tsx` (internal)  
**Type:** Internal Container Component

**Props:**
```typescript
interface IconContainerProps {
  children: React.ReactNode;
}
```

**Features:**
- Static container for icons
- No animation
- Layout wrapper

---

### OnboardingIcons
**File:** `src/components/onboarding/OnboardingIcons.tsx`  
**Type:** Icon Component Library

**Icons:**
- `WelcomeIcon` - Welcome slide icon
- `KlangweltenIcon` - Sound worlds icon
- `WirksamkeitIcon` - Effectiveness icon
- `WachstumIcon` - Growth icon

**Props:**
```typescript
interface IconProps {
  size?: number; // Default: 60
  color?: string; // Default: 'white'
}
```

**Features:**
- SVG-based icons
- Scalable
- Customizable size and color
- Consistent styling

---

## 🔗 Component Relationships

### IndexScreen Component Tree
```
IndexScreen
├── Preloader (if showPreloader)
│   ├── Animated.View (Container)
│   │   ├── View (Content Container)
│   │   │   ├── View (Favicon Container)
│   │   │   │   ├── Animated.View (Circle 1)
│   │   │   │   ├── Animated.View (Circle 2)
│   │   │   │   ├── Animated.View (Circle 3)
│   │   │   │   └── Reanimated.View (Favicon)
│   │   │   │       └── Image (Favicon)
│   │   │   ├── Reanimated.View (Logo)
│   │   │   │   └── Image (Logo)
│   │   │   └── Reanimated.View (Tagline)
│   │   │       └── Text (Tagline)
│   └── View (Loading State) - if !showPreloader
│       └── Text ("Loading...")
```

### OnboardingSlidesScreen Component Tree
```
OnboardingSlidesScreen
├── GestureDetector (Swipe Gestures)
│   └── LinearGradient (Background)
│       ├── ScrollView (Content)
│       │   └── View (Slide Container)
│       │       └── Reanimated.View (Slide Content)
│       │           ├── IconContainer (if regular slide)
│       │           │   └── BlurView
│       │           │       └── LinearGradient
│       │           │           └── Icon Component
│       │           ├── Text (Title)
│       │           ├── Text (Description)
│       │           ├── View (Wave Visualization) - if choice slide
│       │           │   └── WaveBar[] (60 bars)
│       │           └── View (Choice Buttons) - if choice slide
│       │               └── ChoiceButtonWrapper[]
│       │                   └── AnimatedButton
│       │                       └── BlurView
│       │                           └── LinearGradient/View
│       │                               ├── View (Radio Button)
│       │                               ├── Image (Category Image)
│       │                               └── View (Text Content)
│       │                                   ├── Text (Label)
│       │                                   └── Text (Description)
│       └── View (Bottom Navigation)
│           └── View (Navigation Content)
│               ├── AnimatedButton (Next/Get Started)
│               │   └── LinearGradient/View
│               │       ├── Text (Button Text)
│               │       └── Text (Arrow Icon)
│               ├── AnimatedButton (Skip) - conditional
│               │   └── Text (Skip Text)
│               └── View (Pagination Dots)
│                   └── View[] (Dots)
```

---

## 🎨 Styling

### Theme Integration
All components use the unified theme system:
- `useUnifiedTheme()` hook
- `colors.awavePrimary` - Primary color
- `colors.awaveSecondary` - Secondary color
- `colors.awaveBackground` - Background color
- Typography from theme
- Spacing from theme

### Animation Styles
- **Reanimated** - High-performance animations
- **Animated API** - Basic animations
- **Shared Values** - Reactive values
- **Worklets** - UI thread execution

### Responsive Design
- `Dimensions` API for screen size
- Flexible layouts
- Max width constraints
- Padding and margins from theme

### Accessibility
- Semantic labels
- Touch target sizes (min 44x44)
- Color contrast compliance
- Screen reader support

---

## 🔄 State Management

### Local State
- Preloader visibility
- Current slide index
- Selected category
- Animation values
- Loading states

### Context State
- Theme (ThemeProvider)
- Language (LanguageProvider)
- Authentication (AuthContext)

### Persistent State
- Onboarding completion
- User profile
- Category preference
- Stored in AsyncStorage

---

## 🧪 Testing Considerations

### Component Tests
- Rendering
- User interactions
- State updates
- Animation triggers
- Navigation

### Integration Tests
- Storage operations
- Backend synchronization
- Navigation flows
- Error handling

### E2E Tests
- Complete onboarding flow
- Category selection
- State persistence
- Backend sync

---

## 📊 Component Metrics

### Complexity
- **IndexScreen:** Low (preloader + routing)
- **OnboardingSlidesScreen:** High (multiple slides, animations, state)
- **Preloader:** Medium (multiple animations)

### Reusability
- **OnboardingIcons:** High (used in multiple places)
- **Preloader:** Low (specific to IndexScreen)
- **ChoiceButtonWrapper:** Low (specific to onboarding)

### Dependencies
- All screens depend on theme system
- All screens depend on navigation
- Onboarding depends on storage service
- Onboarding depends on backend service (optional)

---

*For service dependencies, see `services.md`*  
*For user flows, see `user-flows.md`*  
*For technical details, see `technical-spec.md`*
