# Navigation System - Components Inventory

**Implementation note:** The current app is **Swift/SwiftUI**. Root is `RootView`; tabs in `MainTabView` (TabView); stack via NavigationStack. This is the **baseline for Android**. The list below describes logical components; iOS uses SwiftUI views (e.g. RootView, MainTabView, CategorySelectionSheet).

## 📱 Navigation Components

### Navigation Container
**File (iOS):** `AWAVE/AWAVE/Navigation/RootView.swift`  
**Type:** Root view  
**Purpose:** Main entry (Preloader → Onboarding or MainTabView)

**Components Used (iOS):**
- SwiftUI NavigationStack / TabView
- RootView, MainTabView, category screens, Search drawer, Profile

**Features:**
- Wraps entire app
- Provides navigation context
- Handles deep linking
- Manages navigation state

**Dependencies:**
- `@react-navigation/native`
- `@react-navigation/stack`
- Theme system
- All screen components

---

### MainNavigator
**File:** `src/navigation/index.tsx`  
**Type:** Stack Navigator Component  
**Purpose:** Root stack navigator with all screens

**State:** Tab/stack state (iOS: SwiftUI state; baseline for Android)

**Screens Registered:**
1. `Index` - Entry point
2. `OnboardingSlides` - Onboarding flow
3. `MainTabs` - Main app tabs
4. `Auth` - Authentication
5. `Signup` - User registration
6. `EmailVerification` - Email verification
7. `Library` - Sound library
8. `Subscribe` - Subscription plans
9. `Downsell` - Subscription downsell (modal)
10. `Stats` - Analytics dashboard
11. `AccountSettings` - Account management
12. `PrivacySettings` - Privacy settings
13. `Legal` - Legal information
14. `DataPrivacy` - Data privacy
15. `TermsAndConditions` - Terms of service
16. `AppPrivacyPolicy` - Privacy policy
17. `Support` - Support and help
18. `NotificationPreferences` - Notification settings
19. `Klangwelten` - Category detail screen
20. `NotFound` - 404 error page

**Screen Options:**
- `headerShown: false` - No default headers
- `gestureEnabled: true` - Swipe-back gestures
- `gestureDirection: 'horizontal'` - Horizontal gestures
- Theme-based background colors

**Special Configurations:**
- **Downsell:** Modal presentation, gestures disabled
- **MainTabs:** Custom component with route parameters

**Dependencies:**
- Theme system
- All screen components
- TabNavigator component

---

### TabNavigator
**File:** `src/components/navigation/TabNavigator.tsx`  
**Type:** Custom Tab Navigator Component  
**Purpose:** Custom tab bar (iOS: TabView; baseline for Android)

**Props:**
```typescript
interface CustomTabNavigatorProps {
  initialTab?: 'schlafen' | 'stress' | 'leichtigkeit' | 'profile';
}
```

**State:**
- `activeTab: CategoryTab` - Current active tab
- `searchDrawerOpen: boolean` - Search drawer state
- `libraryModalOpen: boolean` - Library modal state
- `sosDrawerOpen: boolean` - SOS drawer state
- `sosConfig: SOSConfig | null` - SOS configuration
- `lastActiveTabBeforeSearch: CategoryTab | null` - Tab state before search

**Components Used:**
- `CustomNavbar` - Bottom navigation bar
- `SchlafScreen` - Sleep category screen
- `RuheScreen` - Stress category screen
- `ImFlussScreen` - Lightness category screen
- `ProfileScreen` - Profile screen
- `SearchDrawer` - Search bottom sheet
- `SOSDrawer` - SOS bottom sheet
- `LibraryScreen` - Library modal
- `Modal` - React Native modal

**Hooks Used:**
- `useTheme` - Theme styling
- `useRegistrationFlow` - Registration flow
- `useSoundPlayer` - Sound player integration
- `useOnboardingStorage` - Onboarding state

**Features:**
- Tab state management
- Screen rendering based on active tab
- Modal/drawer state management
- Last active tab tracking
- Initial tab determination

**User Interactions:**
- Tab press switches screens
- Search tab opens drawer
- Library tab opens modal
- Profile tab navigates to profile

**Dependencies:**
- Category screens
- Modal/drawer components
- Navigation hooks
- Onboarding storage

---

### CustomNavbar
**File:** `src/components/navigation/NavBar.tsx`  
**Type:** Bottom Navigation Bar Component  
**Purpose:** Custom bottom navigation bar (iOS: SwiftUI; baseline for Android)

**Props:**
```typescript
interface CustomNavbarProps {
  activeTab: string;
  onTabPress: (tab: string) => void;
  onSearchPress?: () => void;
  onLibraryPress?: () => void;
}
```

**State:** None (stateless, uses props)

**Components Used:**
- `NavButton` - Individual tab button
- `Icon` - Tab icons

**Hooks Used:**
- `useTheme` - Theme styling
- `useTranslation` - Translations
- `useCategoryContext` - Category data

**Tab Structure:**
- **Category Tabs:** Built dynamically from CategoryContext (first 3)
- **Utility Tabs:** Fixed tabs (search, profile)

**Tab Types:**
```typescript
type TabType = 'category' | 'modal' | 'screen';

interface NavTab {
  id: string;
  icon: string;
  label: string;
  type: TabType;
}
```

**Features:**
- Dynamic category tabs
- Fixed utility tabs
- Active tab indication
- Tab press handling
- Theme-based styling
- Glow effects on active tab

**Styling:**
- Fixed bottom position
- Matches React web app CSS exactly
- Theme colors and typography
- Responsive layout
- Shadow/glow effects

**User Interactions:**
- Tab press triggers navigation
- Category tabs switch screens
- Modal tabs open drawers/modals
- Screen tabs navigate to screens

**Dependencies:**
- CategoryContext
- Translation system
- Theme system
- Icon component

---

### NavButton
**File:** `src/components/navigation/NavBar.tsx`  
**Type:** Tab Button Component  
**Purpose:** Individual navigation button in navbar

**Props:**
```typescript
interface NavButtonProps {
  icon: string;
  label: string;
  isActive: boolean;
  onPress: () => void;
}
```

**State:** None (stateless)

**Components Used:**
- `Icon` - Tab icon
- `TouchableOpacity` - Button wrapper

**Features:**
- Icon display
- Label display
- Active state styling
- Touch feedback
- Glow effect when active

**Styling:**
- Circular button (48x48px)
- Theme-based colors
- Active state glow
- Label below icon
- Consistent spacing

**User Interactions:**
- Press triggers onPress callback
- Visual feedback on press

---

### UnifiedHeader
**File:** `src/components/navigation/UnifiedHeader.tsx`  
**Type:** Header Component  
**Purpose:** Consistent header for all screens

**Props:**
```typescript
interface UnifiedHeaderProps {
  title?: string;
  variant?: 'back' | 'close';
  onPress?: () => void;
  showButton?: boolean;
  rightElement?: React.ReactNode;
}
```

**State:** None (stateless)

**Components Used:**
- `InteractiveTouchableOpacity` - Button with interactions
- `GlassMorphism` - Glass effect wrapper
- `ArrowLeft` / `X` - Icons from LucideCompat

**Hooks Used:**
- `useNavigation` - Navigation hook
- `useTheme` - Theme styling

**Features:**
- Back button (left arrow)
- Close button (X)
- Optional title
- Right element support
- Glass morphism styling
- Micro-interactions

**Variants:**
- **Back:** Shows left arrow, navigates back
- **Close:** Shows X, closes modal/drawer

**Styling:**
- Glass morphism effect
- Theme-based colors
- Consistent padding
- Responsive layout

**User Interactions:**
- Back/close button press
- Custom onPress handler
- Default navigation.goBack()

**Dependencies:**
- Navigation hook
- Theme system
- Visual effects components

---

## 🔗 Component Relationships

### Navigation Component Tree
```
App
└── NavigationContainer
    └── MainNavigator (Stack.Navigator)
        ├── Stack.Screen (Index)
        ├── Stack.Screen (OnboardingSlides)
        ├── Stack.Screen (MainTabs)
        │   └── TabNavigator
        │       ├── [Active Screen: SchlafScreen | RuheScreen | ImFlussScreen | ProfileScreen]
        │       ├── CustomNavbar
        │       │   └── NavButton × 5
        │       ├── SearchDrawer (conditional)
        │       ├── SOSDrawer (conditional)
        │       └── Library Modal (conditional)
        ├── Stack.Screen (Auth)
        ├── Stack.Screen (Signup)
        └── [18+ other Stack.Screens]
```

### TabNavigator Component Tree
```
TabNavigator
├── View (Container)
│   ├── View (Screen Container)
│   │   └── [Active Screen Component]
│   └── CustomNavbar
│       └── View (Navbar Layout)
│           └── View (Categories Container)
│               └── NavButton × 5
├── SearchDrawer (conditional)
├── SOSDrawer (conditional)
└── Modal (Library, conditional)
```

### CustomNavbar Component Tree
```
CustomNavbar
└── View (Navbar Container)
    └── View (Navbar Layout)
        └── View (Nav Section)
            └── View (Categories Container)
                └── NavButton × 5
                    ├── TouchableOpacity
                    │   ├── View (Button)
                    │   │   └── Icon
                    │   └── Text (Label)
```

---

## 🎨 Styling

### Theme Integration
All navigation components use the theme system:
- Colors: `theme.colors.awave.primary`, `theme.colors.awave.background`
- Typography: `theme.typography.fontFamily`, `theme.typography.fontSize`
- Spacing: Consistent padding and margins
- Layout: Theme-based dimensions

### Responsive Design
- ScrollView for small screens
- KeyboardAvoidingView for input screens
- SafeAreaView for status bar handling
- Flexible layouts for different screen sizes

### Accessibility
- Semantic labels for screen readers
- Touch target sizes (min 44x44)
- Color contrast compliance
- Keyboard navigation support

---

## 🔄 State Management

### Local State
- Tab state (activeTab)
- Modal/drawer state (open/closed)
- Navigation history (lastActiveTabBeforeSearch)
- Component-specific UI state

### Context State
- CategoryContext - Category data for tabs
- AuthContext - Authentication state for route protection
- Theme context - Styling

### Persistent State
- AsyncStorage - Onboarding state, category selection
- NavigationStack / TabView state (iOS SwiftUI; baseline for Android)

---

## 🧪 Testing Considerations

### Component Tests
- Tab button interactions
- Navigation state updates
- Modal open/close
- Header button functionality
- Tab switching logic

### Integration Tests
- Navigation flows
- Tab state persistence
- Modal state management
- Deep link handling
- Route protection

### E2E Tests
- Complete navigation journeys
- Tab switching flows
- Modal interactions
- Deep link scenarios
- State recovery

---

## 📊 Component Metrics

### Complexity
- **Navigation Container:** Low (wrapper component)
- **MainNavigator:** Medium (20+ screens)
- **TabNavigator:** High (state management, modals)
- **CustomNavbar:** Medium (dynamic tabs, styling)
- **UnifiedHeader:** Low (simple header)

### Reusability
- **UnifiedHeader:** High (used in many screens)
- **NavButton:** High (used in navbar)
- **CustomNavbar:** Medium (specific to main app)
- **TabNavigator:** Low (specific to main app structure)

### Dependencies
- All components depend on theme system
- Navigation components use SwiftUI NavigationStack/TabView (iOS); Android should match behaviour
- Tab components depend on CategoryContext
- Header depends on navigation hook

---

## 🔧 Component Props Summary

### TabNavigator Props
```typescript
{
  initialTab?: 'schlafen' | 'stress' | 'leichtigkeit' | 'profile';
}
```

### CustomNavbar Props
```typescript
{
  activeTab: string;
  onTabPress: (tab: string) => void;
  onSearchPress?: () => void;
  onLibraryPress?: () => void;
}
```

### UnifiedHeader Props
```typescript
{
  title?: string;
  variant?: 'back' | 'close';
  onPress?: () => void;
  showButton?: boolean;
  rightElement?: React.ReactNode;
}
```

### NavButton Props
```typescript
{
  icon: string;
  label: string;
  isActive: boolean;
  onPress: () => void;
}
```

---

*For service dependencies, see `services.md`*  
*For user flows, see `user-flows.md`*  
*For technical details, see `technical-spec.md`*
