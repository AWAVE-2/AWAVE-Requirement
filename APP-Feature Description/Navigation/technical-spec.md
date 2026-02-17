# Navigation System - Technical Specification

## 🏗️ Architecture Overview

### Technology Stack (Current: iOS Swift/SwiftUI – baseline for Android)

#### Navigation (Swift)
- **SwiftUI NavigationStack** - Root stack, 20+ screens, gesture back
- **SwiftUI TabView** - Custom tab bar (MainTabView); 5 tabs (3 category + Search + Profile)
- **Sheets** - Search drawer, SOS drawer, category selection, modals

#### Deep Linking
- **URL Scheme:** `awave://` (email verification, password reset)
- **Token Extraction:** Hash fragments and query parameters
- Handled in app lifecycle and scene phase

#### State Management
- **OnboardingStorageService** - Initial tab, category preference (UserDefaults; Firestore when backend ready)
- **Local @State / ViewModel** - Tab state, modal state
- **Route parameters** - Passed via navigation path / environment

#### Platform Support
- **iOS:** 26.2+ (SwiftUI, gesture navigation, modal presentations). This app is the baseline for Android.
- **Android:** Implement to match behaviour; min SDK per project.

---

## 📁 File Structure (iOS – AWAVE/AWAVE/)

```
AWAVE/AWAVE/
├── Navigation/
│   ├── RootView.swift              # Preloader → Onboarding or MainTabView
│   └── MainTabView.swift           # TabView with category + Search + Profile tabs
├── Features/
│   ├── Onboarding/                 # OnboardingView, CategorySelectionView, AnalyticsConsentToastView
│   ├── Categories/                 # SchlafScreen, StressScreen, ImFlussScreen, CategorySelectionSheet
│   ├── Profile/                    # ProfileScreen
│   └── [other features]            # Auth, Player, Search, etc.
├── Services/
│   └── TabSelectionService.swift   # Initial tab from OnboardingStorageService
└── [20+ screens via NavigationStack]
```

---

## 🔧 Components

### Navigation Container
**Location:** `src/navigation/index.tsx`

**Purpose:** Root navigation container wrapping entire app

**Structure:**
```typescript
NavigationContainer
  └── MainNavigator (Stack.Navigator)
      └── [20+ Stack.Screen components]
```

**Features:**
- Wraps entire app in NavigationContainer
- Provides navigation context to all screens
- Handles deep linking configuration
- Manages navigation state

**Configuration:**
- No header by default
- Gesture navigation enabled
- Theme-based styling
- Initial route: 'Index'

---

### MainNavigator
**Location:** `src/navigation/index.tsx`

**Type:** Stack Navigator

**Route Type Definition:**
```typescript
type RootStackParamList = {
  Index: undefined;
  OnboardingSlides: { startAtSlide?: number };
  MainTabs: { initialTab?: 'schlafen' | 'stress' | 'leichtigkeit' } | undefined;
  Auth: { onBack?: () => void };
  Signup: undefined;
  EmailVerification: undefined;
  Library: undefined;
  Subscribe: undefined;
  Downsell: undefined;
  Stats: undefined;
  AccountSettings: undefined;
  PrivacySettings: undefined;
  Legal: undefined;
  DataPrivacy: undefined;
  TermsAndConditions: undefined;
  AppPrivacyPolicy: undefined;
  Support: undefined;
  NotificationPreferences: undefined;
  Klangwelten: { categoryId: string; categoryTitle?: string };
  NotFound: undefined;
};
```

**Screen Options:**
```typescript
{
  headerShown: false,
  gestureEnabled: true,
  gestureDirection: 'horizontal',
  cardStyle: {
    backgroundColor: theme.colors.awave.background,
  },
}
```

**Special Screen Configurations:**
- **Downsell:** Modal presentation, gestures disabled
- **MainTabs:** Custom component with route parameters

---

### TabNavigator
**Location:** `src/components/navigation/TabNavigator.tsx`

**Purpose:** Custom tab bar (TabView) – 5 tabs; iOS implementation is baseline for Android

**Props:**
```typescript
interface CustomTabNavigatorProps {
  initialTab?: 'schlafen' | 'stress' | 'leichtigkeit' | 'profile';
}
```

**State Management:**
```typescript
const [activeTab, setActiveTab] = useState<CategoryTab>('schlafen');
const [searchDrawerOpen, setSearchDrawerOpen] = useState(false);
const [libraryModalOpen, setLibraryModalOpen] = useState(false);
const [sosDrawerOpen, setSOSDrawerOpen] = useState(false);
const [lastActiveTabBeforeSearch, setLastActiveTabBeforeSearch] = useState<CategoryTab | null>(null);
```

**Features:**
- Manages tab state locally (SwiftUI TabView)
- Renders active screen based on activeTab
- Handles modal/drawer state
- Tracks last active tab before search
- Loads initial tab from onboarding storage

**Screen Rendering:**
```typescript
const renderActiveScreen = () => {
  switch (activeTab) {
    case 'schlafen': return <SchlafScreen />;
    case 'stress': return <RuheScreen />;
    case 'leichtigkeit': return <ImFlussScreen />;
    case 'profile': return <ProfileScreen />;
    default: return <SchlafScreen />;
  }
};
```

**Modal/Drawer Integration:**
- SearchDrawer: Bottom sheet search interface
- SOSDrawer: Full-height emergency drawer
- Library Modal: Half-screen modal (formSheet on iOS)

---

### CustomNavbar
**Location:** `src/components/navigation/NavBar.tsx`

**Purpose:** Custom bottom navigation bar matching React web app

**Props:**
```typescript
interface CustomNavbarProps {
  activeTab: string;
  onTabPress: (tab: string) => void;
  onSearchPress?: () => void;
  onLibraryPress?: () => void;
}
```

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

**Tab Structure:**
- **Category Tabs:** Built dynamically from CategoryContext (first 3 categories)
- **Utility Tabs:** Fixed tabs (search, profile)

**Styling:**
- Matches React web app CSS exactly
- Fixed bottom position
- Glow effects on active tab
- Theme-based colors
- Responsive layout

**Tab Press Handling:**
```typescript
const handleTabPress = async (tab: NavTab) => {
  if (tab.type === 'category') {
    await handleCategorySelect(tab.id);
    onTabPress(tab.id);
  } else if (tab.type === 'modal') {
    if (tab.id === 'search' && onSearchPress) {
      onSearchPress();
    } else if (tab.id === 'library' && onLibraryPress) {
      onLibraryPress();
    }
  } else {
    onTabPress(tab.id);
  }
};
```

---

### UnifiedHeader
**Location:** `src/components/navigation/UnifiedHeader.tsx`

**Purpose:** Consistent header component for all screens

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

**Features:**
- Back button (left arrow) for stack navigation
- Close button (X) for modals/drawers
- Optional title display
- Right element support
- Glass morphism styling
- Micro-interactions

**Usage:**
- Stack screens: `variant='back'`
- Modals/Drawers: `variant='close'`

---

## 🔌 Navigation Hooks & Utilities

### useNavigation Hook
**Location:** `@react-navigation/native`

**Usage:**
```typescript
import { useNavigation } from '@react-navigation/native';

const navigation = useNavigation<NavigationProp<RootStackParamList>>();
```

**Methods:**
- `navigation.navigate(routeName, params?)` - Navigate to screen
- `navigation.goBack()` - Go back one screen
- `navigation.replace(routeName, params?)` - Replace current screen
- `navigation.reset(state)` - Reset navigation stack

**Type Safety:**
- TypeScript types from RootStackParamList
- Route parameter validation
- Autocomplete for route names

---

### useRoute Hook
**Location:** `@react-navigation/native`

**Usage:**
```typescript
import { useRoute } from '@react-navigation/native';

const route = useRoute<RouteProp<RootStackParamList, 'Klangwelten'>>();
const { categoryId, categoryTitle } = route.params;
```

**Features:**
- Access route parameters
- Type-safe parameter access
- Route name and key access

---

## 🔗 Deep Linking Implementation

### URL Scheme Configuration

**iOS (Info.plist):**
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>awave</string>
    </array>
  </dict>
</array>
```

**Android (AndroidManifest.xml):**
```xml
<intent-filter>
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="awave" />
</intent-filter>
```

### Deep Link Handling

**Email Verification:**
```typescript
// URL: awave://email-verification?access_token=...&refresh_token=...
if (url.includes('email-verification')) {
  // Extract tokens from hash or query params
  const accessToken = extractToken(url, 'access_token');
  const refreshToken = extractToken(url, 'refresh_token');
  
  // Create session
  await ProductionBackendService.setAuthSession(accessToken, refreshToken);
  
  // Navigate
  navigation.navigate('MainTabs');
}
```

**Password Reset:**
```typescript
// URL: awave://password-reset?access_token=...&refresh_token=...
if (url.includes('password-reset')) {
  // Extract tokens
  // Create session
  // Navigate to reset password screen
}
```

### Token Extraction

**Hash Fragment Support:**
```typescript
if (url.includes('#')) {
  const hashPart = url.split('#')[1];
  const hashParams = new URLSearchParams(hashPart);
  accessToken = hashParams.get('access_token') || '';
  refreshToken = hashParams.get('refresh_token') || '';
}
```

**Query Parameter Support:**
```typescript
const queryString = url.includes('?') ? url.split('?')[1] : '';
if (queryString) {
  const queryParams = new URLSearchParams(queryString);
  accessToken = queryParams.get('access_token') || '';
  refreshToken = queryParams.get('refresh_token') || '';
}
```

---

## 🔐 Route Protection

### Authentication Guards

**Implementation:**
```typescript
// In screen component
useEffect(() => {
  const checkAuth = async () => {
    const session = await getCurrentSession();
    if (!session) {
      navigation.navigate('Auth');
    }
  };
  checkAuth();
}, []);
```

**Protected Routes:**
- MainTabs (after onboarding)
- Profile screens
- Subscription screens
- Stats screen

### Onboarding Guards

**Implementation:**
```typescript
// In IndexScreen
const handlePreloaderComplete = async () => {
  const { completed } = await onboardingStorage.loadOnboardingState();
  
  if (completed) {
    navigation.navigate('MainTabs');
  } else {
    navigation.navigate('OnboardingSlides');
  }
};
```

### Subscription Guards

**Implementation:**
```typescript
// In AudioPlayerEnhanced
useEffect(() => {
  const checkAccess = async () => {
    const plan = await SubscriptionStorage.getSelectedPlan();
    if (!plan && !userId) {
      setHasAccess(false);
      navigation.navigate('Subscribe');
    }
  };
  checkAccess();
}, []);
```

---

## 🔄 State Management

### Tab State

**Storage:**
- Component state: `activeTab`
- AsyncStorage: `onboarding.selectedCategory`

**Initial Tab Logic:**
```typescript
const getInitialTab = async (): Promise<CategoryTab> => {
  // 1. Check route parameter
  if (initialTab) return initialTab;
  
  // 2. Load from onboarding storage
  const savedCategory = await onboardingStorage.getSelectedCategory();
  if (savedCategory === 'schlafen' || savedCategory === 'stress' || savedCategory === 'leichtigkeit') {
    return savedCategory as CategoryTab;
  }
  
  // 3. Default fallback
  return 'schlafen';
};
```

### Navigation History

**Last Active Tab Tracking:**
```typescript
const handleSearchPress = () => {
  setLastActiveTabBeforeSearch(activeTab);
  setSearchDrawerOpen(true);
};

const handleReturnToLastTab = () => {
  if (lastActiveTabBeforeSearch) {
    setActiveTab(lastActiveTabBeforeSearch);
    setLastActiveTabBeforeSearch(null);
  }
  setSearchDrawerOpen(false);
};
```

---

## 📱 Platform-Specific Notes

### iOS

**Modal Presentations:**
- `formSheet` presentation for Library modal
- Native modal animations
- Gesture dismiss support

**Gesture Navigation:**
- Swipe-back gesture enabled
- Horizontal gesture direction
- Native iOS animations

### Android

**Deep Linking:**
- Intent filters configured
- URL scheme handling
- App launch from links

**Gesture Navigation:**
- Swipe-back gesture enabled
- Material Design animations
- Back button integration

---

## 🧪 Testing Strategy

### Unit Tests
- Navigation state management
- Tab state updates
- Route parameter parsing
- Token extraction logic

### Integration Tests
- Stack navigation flows
- Tab navigation switching
- Modal open/close
- Deep link handling

### E2E Tests
- Complete navigation journeys
- Deep link scenarios
- Route protection
- State persistence

---

## 🐛 Error Handling

### Navigation Errors
- Invalid route names
- Missing route parameters
- Navigation during unmount
- Stack overflow protection

### Deep Link Errors
- Invalid token format
- Expired tokens
- Malformed URLs
- Missing parameters

### State Errors
- Storage read failures
- State corruption
- Concurrent updates
- Recovery failures

---

## 📊 Performance Considerations

### Optimization
- Lazy screen loading
- Memoized tab components
- Efficient state updates
- Minimal re-renders

### Monitoring
- Navigation transition times
- Tab switching performance
- Deep link processing time
- State loading time

---

*For component details, see `components.md`*  
*For service dependencies, see `services.md`*  
*For user flows, see `user-flows.md`*
