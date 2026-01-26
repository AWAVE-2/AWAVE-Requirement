# User Onboarding Screens - Components Inventory

## 📱 Screens

### IndexScreen
**File:** `src/screens/IndexScreen.tsx`  
**Route:** `/` (initial route)  
**Purpose:** App entry point with preloader and routing logic

**Props:** None

**State:**
- `showPreloader: boolean` - Controls preloader visibility

**Components Used:**
- `Preloader` - Animated intro component (internal)

**Hooks Used:**
- `useNavigation` - Navigation
- `useUnifiedTheme` - Theme styling
- `useTranslation` - Translations
- `onboardingStorage` - Storage service

**Features:**
- 3-second preloader animation
- Onboarding state checking
- Conditional routing logic
- Loading state handling

**User Interactions:**
- None (automatic navigation)

**Routing Logic:**
1. Check onboarding completion status
2. If completed → Navigate to MainTabs
3. If profile exists but not completed → Navigate to slide 5 only
4. If no profile → Navigate to full onboarding

---

### OnboardingSlidesScreen
**File:** `src/screens/OnboardingSlidesScreen.tsx`  
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
- `AnimatedButton` - Action buttons (Next, Skip)
- `LinearGradient` - Gradient backgrounds
- `BlurView` - Blur effects for glassmorphism
- `GestureDetector` - Swipe gesture handling
- `ScrollView` - Scrollable content container
- `OnboardingIcons` - SVG icons (WelcomeIcon, KlangweltenIcon, etc.)
- `WaveBar` - Animated wave visualization (internal)
- `ChoiceButtonWrapper` - Choice button animation wrapper (internal)
- `IconContainer` - Icon display container (internal)
- `AnimatedBackgroundBlob` - Background animation (internal, unused)

**Hooks Used:**
- `useNavigation` - Navigation
- `useRoute` - Route parameters
- `useProductionAuth` - User authentication
- `useTranslation` - Translations
- `onboardingStorage` - Storage service

**Features:**
- 5-slide presentation
- Swipe gesture navigation (left/right)
- Category selection interface
- Slide transitions with fade animations
- Backend sync for authenticated users
- Navigation to MainTabs with initial tab
- Skip functionality
- Pagination dots

**User Interactions:**
- Swipe left/right to navigate slides
- Tap "Next" button to advance
- Tap "Skip" button to jump to last slide
- Select category on slide 5
- Tap "Get Started" to complete

**Slide Types:**
1. **Welcome Slide** - Introduction with WelcomeIcon
2. **Feature Slide** - Klangwelten with KlangweltenIcon
3. **Feature Slide** - Wirksamkeit with WirksamkeitIcon
4. **Feature Slide** - Wachstum with WachstumIcon
5. **Choice Slide** - Category selection with wave visualization

---

## 🧩 Components

### Preloader
**File:** `src/screens/IndexScreen.tsx` (internal component)  
**Type:** Animated Intro Component

**Props:**
```typescript
interface PreloaderProps {
  onComplete: () => void;
}
```

**State:**
- `isVisible: boolean` - Visibility control
- Multiple animation values (fade, scale, opacity, translate)

**Components Used:**
- `Animated.View` - Animated container
- `Image` - Favicon and logo
- `Text` - Tagline
- `Reanimated.View` - Reanimated animated views

**Features:**
- 3-second display duration
- Favicon pulsating animation
- Logo and tagline fade-in with delays
- Background ripple circles (3 concentric)
- Smooth fade-out animation

**Animation Sequence:**
1. Favicon: Fade in (800ms) + Pulsate continuously
2. Logo: Fade in + translate (300ms delay)
3. Tagline: Fade in + translate (500ms delay)
4. Background circles: Continuous ripple
5. Fade out (500ms) after 3 seconds
6. Call onComplete callback

**User Interactions:**
- None (automatic progression)

---

### WaveBar
**File:** `src/screens/OnboardingSlidesScreen.tsx` (internal component)  
**Type:** Animated Wave Visualization Component

**Props:**
```typescript
interface WaveBarProps {
  index: number;
  baseHeight: number;
  maxScale: number;
  delay: number;
}
```

**State:**
- `height: SharedValue<number>` - Animated height value

**Components Used:**
- `LinearGradient` - Gradient fill (primary to secondary)

**Features:**
- Animated height transitions
- Progressive delays for wave effect
- Gradient colors
- Continuous loop animation

**Animation:**
- Base height → Max height → Base height
- 4.5-second cycle per bar
- Staggered delays create left-to-right wave

---

### ChoiceButtonWrapper
**File:** `src/screens/OnboardingSlidesScreen.tsx` (internal component)  
**Type:** Animation Wrapper Component

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
- Scale animation on selection (1.02x)
- Smooth transitions (300ms)
- Wraps choice button for animation

---

### IconContainer
**File:** `src/screens/OnboardingSlidesScreen.tsx` (internal component)  
**Type:** Static Container Component

**Props:**
```typescript
interface IconContainerProps {
  children: React.ReactNode;
}
```

**Features:**
- Static container for icons
- No animations (icons are static)

---

### OnboardingIcons
**File:** `src/components/onboarding/OnboardingIcons.tsx`  
**Type:** SVG Icon Components

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
- SVG-based for crisp rendering

**Usage:**
```typescript
<WelcomeIcon size={60} color="white" />
<KlangweltenIcon size={60} color="white" />
<WirksamkeitIcon size={60} color="white" />
<WachstumIcon size={60} color="white" />
```

---

## 🔗 Component Relationships

### IndexScreen Component Tree
```
IndexScreen
├── Preloader (if showPreloader)
│   ├── Animated.View (Container)
│   │   ├── View (Favicon Container)
│   │   │   ├── Animated.View (Circle 1 - Outer)
│   │   │   ├── Animated.View (Circle 2 - Middle)
│   │   │   ├── Animated.View (Circle 3 - Inner)
│   │   │   └── Reanimated.View (Favicon)
│   │   │       └── Image (Favicon)
│   │   ├── Reanimated.View (Logo)
│   │   │   └── Image (AWAVE Logo)
│   │   └── Reanimated.View (Tagline)
│   │       └── Text (Tagline)
│   └── View (Loading) - conditional
└── View (Loading) - conditional
```

### OnboardingSlidesScreen Component Tree
```
OnboardingSlidesScreen
├── GestureDetector (Swipe Gestures)
│   └── LinearGradient (Background)
│       ├── ScrollView (Content)
│       │   └── View (Slide Container)
│       │       └── Reanimated.View (Slide Content)
│       │           ├── [Welcome/Feature Slide]
│       │           │   ├── IconContainer
│       │           │   │   ├── BlurView
│       │           │   │   │   └── LinearGradient
│       │           │   │   │       └── [Icon Component]
│       │           │   ├── Text (Title)
│       │           │   └── Text (Description)
│       │           └── [Choice Slide]
│       │               ├── View (Wave Visualization)
│       │               │   └── [60x WaveBar components]
│       │               ├── View (Text Container)
│       │               │   ├── Text (Title)
│       │               │   └── Text (Description)
│       │               └── View (Choice Buttons)
│       │                   └── [3x ChoiceButtonWrapper]
│       │                       └── AnimatedButton
│       │                           └── BlurView
│       │                               ├── [Selected State]
│       │                               │   └── LinearGradient
│       │                               │       ├── View (Radio Button)
│       │                               │       ├── Image (Category Image)
│       │                               │       └── View (Text Content)
│       │                               │           ├── Text (Label)
│       │                               │           └── Text (Description)
│       │                               └── [Unselected State]
│       │                                   └── View
│       │                                       ├── View (Radio Button)
│       │                                       ├── Image (Category Image)
│       │                                       └── View (Text Content)
│       └── View (Bottom Navigation)
│           └── View (Navigation Content)
│               ├── AnimatedButton (Next/Get Started)
│               │   └── LinearGradient (if enabled)
│               ├── AnimatedButton (Skip) - conditional
│               └── View (Pagination Dots)
│                   └── [5x View (Dot)]
```

---

## 🎨 Styling

### Theme Integration
All components use the theme system:
- Colors: `colors.awavePrimary`, `colors.awaveSecondary`, `colors.awaveBackground`
- Typography: Consistent font sizes and weights
- Spacing: Consistent padding and margins

### Responsive Design
- `screenWidth` and `screenHeight` from Dimensions
- Max width constraints (400px for content)
- Flexible layouts for different screen sizes
- Safe area handling

### Animation Styles
- Reanimated for high-performance animations
- Shared values for smooth transitions
- Easing functions for natural motion
- Duration constants for consistency

---

## 🔄 State Management

### Local State
- Slide index (currentSlide)
- Selected choice (selectedChoice)
- Animation values (opacity, scale, etc.)

### Persistent State
- AsyncStorage for completion flag
- AsyncStorage for profile data
- AsyncStorage for category preference

### Context State
- AuthContext for userId (backend sync)

---

## 🧪 Testing Considerations

### Component Tests
- Icon rendering
- Button interactions
- Animation triggers
- State updates
- Navigation calls

### Integration Tests
- Complete onboarding flow
- State persistence
- Backend sync
- Navigation routing

### E2E Tests
- First-time user journey
- Returning user journey
- Category selection
- Skip functionality
- Reset functionality

---

## 📊 Component Metrics

### Complexity
- **IndexScreen:** Low (routing logic only)
- **OnboardingSlidesScreen:** High (animations, gestures, state)
- **Preloader:** Medium (multiple animations)
- **WaveBar:** Low (single animation)
- **ChoiceButtonWrapper:** Low (simple wrapper)
- **OnboardingIcons:** Low (static SVG)

### Reusability
- **OnboardingIcons:** High (used in multiple slides)
- **WaveBar:** Medium (used in choice slide)
- **ChoiceButtonWrapper:** Low (specific to choice slide)
- **Preloader:** Low (specific to IndexScreen)

### Dependencies
- All screens depend on theme system
- All screens depend on navigation
- OnboardingSlidesScreen depends on multiple animation libraries
- Components depend on translation system

---

*For service dependencies, see `services.md`*  
*For user flows, see `user-flows.md`*  
*For technical details, see `technical-spec.md`*
