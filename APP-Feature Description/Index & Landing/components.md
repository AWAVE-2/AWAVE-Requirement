# Index & Landing Screen - Components Inventory

## 📱 Screens

### IndexScreen
**File:** `src/screens/IndexScreen.tsx`  
**Route:** `/` (root route, initial route)  
**Purpose:** Entry point screen with preloader and intelligent routing

**Props:**
```typescript
// No props - root screen
```

**State:**
```typescript
const [showPreloader, setShowPreloader] = useState(true);
```

**Components Used:**
- `Preloader` - Internal preloader component
- `View` - Container components
- `Text` - Loading text display

**Hooks Used:**
- `useNavigation` - Navigation routing
- `useUnifiedTheme` - Theme styling
- `useCallback` - Memoized callback
- `onboardingStorage` - Storage service

**Features:**
- Preloader display management
- Onboarding state checking
- Intelligent routing logic
- Error handling
- Loading state during navigation

**User Interactions:**
- None (automatic navigation after preloader)

**Navigation Logic:**
1. Check onboarding completion status
2. Check profile existence
3. Navigate based on state:
   - Completed → MainTabs
   - Profile exists → OnboardingSlides (slide 5)
   - First time → OnboardingSlides (full)

**Error Handling:**
- Catches storage errors
- Falls back to full onboarding on errors
- Logs errors to console
- Prevents app crashes

---

## 🧩 Components

### Preloader
**File:** `src/screens/IndexScreen.tsx` (internal component)  
**Type:** Functional Component  
**Purpose:** Animated preloader with branding

**Props:**
```typescript
interface PreloaderProps {
  onComplete: () => void;
}
```

**State:**
```typescript
const [isVisible, setIsVisible] = useState(true);
const fadeAnim = useState(new Animated.Value(1))[0];
const scaleAnim1 = useState(new Animated.Value(1))[0];
const scaleAnim2 = useState(new Animated.Value(1))[0];
const scaleAnim3 = useState(new Animated.Value(1))[0];
const opacityAnim1 = useState(new Animated.Value(0.3))[0];
const opacityAnim2 = useState(new Animated.Value(0.4))[0];
const opacityAnim3 = useState(new Animated.Value(0.5))[0];

// Reanimated values
const faviconScale = useSharedValue(0.8);
const faviconOpacity = useSharedValue(0);
const logoOpacity = useSharedValue(0);
const logoTranslateY = useSharedValue(20);
const taglineOpacity = useSharedValue(0);
const taglineTranslateY = useSharedValue(20);
```

**Components Used:**
- `Animated.View` - Animated container
- `Reanimated.View` - Reanimated container
- `Image` - Favicon and logo images
- `Text` - Tagline text
- `View` - Layout containers

**Hooks Used:**
- `useState` - State management
- `useEffect` - Animation setup and cleanup
- `useSharedValue` - Reanimated shared values
- `useAnimatedStyle` - Reanimated styles
- `useUnifiedTheme` - Theme access
- `useTranslation` - Translation access

**Features:**
- Favicon pulsation animation
- Logo fade-in animation
- Tagline fade-in animation
- Three ripple circle animations
- Fade-out transition
- 3-second display duration
- Automatic completion callback

**Visual Elements:**
1. **Favicon Container**
   - Centered container
   - Three ripple circles positioned around it
   - Favicon image with pulsation

2. **Logo**
   - AWAVE logo image
   - Fade-in with translate animation
   - 200x60px size

3. **Tagline**
   - Translated text
   - Fade-in with translate animation
   - Theme-aware styling

4. **Ripple Circles**
   - Three concentric circles
   - Border-only (not filled)
   - Different sizes and positions
   - Continuous scale and opacity animations

**Animation Timeline:**
- 0ms: Favicon fades in
- 300ms: Logo starts fade-in
- 500ms: Tagline starts fade-in
- 3000ms: Fade-out starts
- 3500ms: onComplete callback

**User Interactions:**
- None (automatic progression)

---

## 🔗 Component Relationships

### IndexScreen Component Tree
```
IndexScreen
├── Conditional: showPreloader === true
│   └── Preloader
│       ├── Animated.View (Container with fade)
│       │   └── View (Content Container)
│       │       ├── View (Favicon Container)
│       │       │   ├── Animated.View (Circle 1 - Outer)
│       │       │   ├── Animated.View (Circle 2 - Middle)
│       │       │   ├── Animated.View (Circle 3 - Inner)
│       │       │   └── Reanimated.View (Favicon)
│       │       │       └── Image (Favicon)
│       │       ├── Reanimated.View (Logo)
│       │       │   └── Image (Logo)
│       │       └── Reanimated.View (Tagline)
│       │           └── Text (Tagline)
│       └── useEffect (Animation setup)
│
└── Conditional: showPreloader === false
    └── View (Loading Container)
        └── Text ("Loading...")
```

### Preloader Internal Structure
```
Preloader
├── State Management
│   ├── isVisible (boolean)
│   ├── fadeAnim (Animated.Value)
│   ├── scaleAnim1-3 (Animated.Value)
│   └── opacityAnim1-3 (Animated.Value)
│
├── Reanimated Values
│   ├── faviconScale (SharedValue)
│   ├── faviconOpacity (SharedValue)
│   ├── logoOpacity (SharedValue)
│   ├── logoTranslateY (SharedValue)
│   ├── taglineOpacity (SharedValue)
│   └── taglineTranslateY (SharedValue)
│
├── Animation Setup (useEffect)
│   ├── Favicon animations
│   ├── Logo animations
│   ├── Tagline animations
│   ├── Ripple circle animations
│   └── Timer for completion
│
└── Render
    ├── Animated.View (Main container)
    └── Content elements
```

---

## 🎨 Styling

### Theme Integration
All components use the unified theme system:

**Colors:**
- `theme.colors.background` - Background color
- `theme.colors.textPrimary` - Primary text color
- `theme.colors.textSecondary` - Secondary text color

**Typography:**
- `theme.typography.fontSize.base` - Base font size
- `theme.typography.fontFamily.light` - Light font family
- `theme.typography.fontWeight.light` - Light font weight

**Spacing:**
- Consistent margins and padding
- Centered layout using flexbox

### Component Styles

**IndexScreen Styles:**
```typescript
container: {
  flex: 1,
  backgroundColor: theme.colors.background,
  justifyContent: 'center',
  alignItems: 'center',
  position: 'relative',
}
```

**Preloader Styles:**
```typescript
container: {
  flex: 1,
  backgroundColor: theme.colors.background,
  justifyContent: 'center',
  alignItems: 'center',
  position: 'relative',
}
backgroundCircle: {
  position: 'absolute',
  borderRadius: 150,
  borderWidth: 1,
  backgroundColor: 'transparent',
}
favicon: {
  width: 80,
  height: 80,
  marginBottom: 32,
}
logo: {
  width: 200,
  height: 60,
}
tagline: {
  fontSize: theme.typography.fontSize.base,
  fontFamily: theme.typography.fontFamily.light,
  fontWeight: theme.typography.fontWeight.light,
  color: theme.colors.textSecondary,
  textAlign: 'center',
}
```

### Responsive Design
- Full-screen layout
- Centered content
- Flexible container sizes
- Works on all screen sizes

### Accessibility
- Semantic structure
- Theme-aware colors (contrast)
- Text readable at all sizes
- Screen reader compatible

---

## 🔄 State Management

### Local State
**IndexScreen:**
- `showPreloader: boolean` - Controls preloader visibility

**Preloader:**
- `isVisible: boolean` - Controls component visibility
- Animation values (Animated.Value instances)
- Reanimated shared values

### Storage State
- Read from `onboardingStorage.loadOnboardingState()`
- Returns `{ completed: boolean, profile: string | null }`
- Used for routing decisions

### Navigation State
- Managed by React Navigation
- Stack navigator maintains route history
- Navigation params passed programmatically

---

## 🧪 Testing Considerations

### Component Tests
- Preloader renders correctly
- Animations start and complete
- State updates correctly
- Error handling works
- Navigation logic works

### Integration Tests
- Full flow from app launch
- Storage integration
- Navigation integration
- Theme integration
- Translation integration

### E2E Tests
- First-time user flow
- Returning user (completed) flow
- Returning user (incomplete) flow
- Error scenarios
- Network failure scenarios

---

## 📊 Component Metrics

### Complexity
- **IndexScreen:** Low (routing logic + preloader)
- **Preloader:** Medium (multiple animations)

### Reusability
- **Preloader:** Low (specific to Index screen)
- **IndexScreen:** N/A (root screen)

### Dependencies
- All components depend on theme system
- Preloader depends on animation libraries
- IndexScreen depends on navigation
- Both depend on storage service

### Performance
- Animations run at 60fps
- Minimal re-renders
- Efficient state management
- Cleanup on unmount

---

## 🔧 Component Configuration

### Image Sources
**Favicon:**
- URL: CDN URL (see technical-spec.md)
- Size: 80x80px
- Resize mode: contain

**Logo:**
- URL: CDN URL (see technical-spec.md)
- Size: 200x60px
- Resize mode: contain

### Animation Configuration
**Favicon:**
- Scale: 0.8 → 1.2 → 0.8
- Cycle: 1500ms
- Infinite loop

**Logo:**
- Delay: 300ms
- Duration: 800ms
- Opacity: 0 → 1
- TranslateY: 20 → 0

**Tagline:**
- Delay: 500ms
- Duration: 800ms
- Opacity: 0 → 1
- TranslateY: 20 → 0

**Ripple Circles:**
- See technical-spec.md for detailed configuration

### Timing Configuration
- Preloader duration: 3000ms
- Fade-out duration: 500ms
- Navigation delay: 500ms
- Total: ~4000ms

---

*For service dependencies, see `services.md`*  
*For user flows, see `user-flows.md`*  
*For technical details, see `technical-spec.md`*
