# Navigation System - Services Documentation

**Implementation note:** The current app is **Swift/SwiftUI** (iOS 26.2). Navigation uses NavigationStack, TabView, OnboardingStorageService, and URL scheme handling. This behaviour is the **baseline for Android**. The requirements below describe the intended capabilities; Swift equivalents are used in code (e.g. `@Environment(\.dismiss)`, TabSelectionService).

## 🔧 Service Layer Overview

The navigation system uses SwiftUI navigation and local services for state persistence, deep linking, and route protection. This document covers navigation-related utilities and integration points (conceptually; iOS uses Swift types and services).

---

## 📦 Navigation Hooks & Utilities

### useNavigation Hook
**Location:** `@react-navigation/native`  
**Type:** React Navigation Hook  
**Purpose:** Access navigation object in components

#### Usage
```typescript
import { useNavigation } from '@react-navigation/native';
import type { NavigationProp } from '@react-navigation/native';

const navigation = useNavigation<NavigationProp<RootStackParamList>>();
```

#### Methods

**`navigate(routeName, params?)`**
- Navigate to a screen
- Adds screen to navigation stack
- Type-safe route names and parameters
- Example: `navigation.navigate('MainTabs', { initialTab: 'schlafen' })`

**`goBack()`**
- Go back one screen in stack
- Removes current screen from stack
- Example: `navigation.goBack()`

**`replace(routeName, params?)`**
- Replace current screen
- Removes current screen and adds new one
- Example: `navigation.replace('Auth')`

**`reset(state)`**
- Reset navigation stack
- Clears entire stack and sets new state
- Example: `navigation.reset({ index: 0, routes: [{ name: 'MainTabs' }] })`

**`setParams(params)`**
- Update current route parameters
- Example: `navigation.setParams({ categoryId: 'new-id' })`

#### Type Safety
- TypeScript types from `RootStackParamList`
- Autocomplete for route names
- Parameter validation
- Type checking at compile time

---

### useRoute Hook
**Location:** `@react-navigation/native`  
**Type:** React Navigation Hook  
**Purpose:** Access current route information

#### Usage
```typescript
import { useRoute } from '@react-navigation/native';
import type { RouteProp } from '@react-navigation/native';

const route = useRoute<RouteProp<RootStackParamList, 'Klangwelten'>>();
const { categoryId, categoryTitle } = route.params;
```

#### Properties

**`route.name`**
- Current route name
- Type: `string`

**`route.key`**
- Unique route key
- Type: `string`

**`route.params`**
- Route parameters
- Type: `RouteParams | undefined`
- Type-safe based on route name

---

### useFocusEffect Hook
**Location:** `@react-navigation/native`  
**Type:** React Navigation Hook  
**Purpose:** Run side effects when screen is focused

#### Usage
```typescript
import { useFocusEffect } from '@react-navigation/native';
import { useCallback } from 'react';

useFocusEffect(
  useCallback(() => {
    // Screen is focused
    loadData();
    
    return () => {
      // Screen is unfocused (cleanup)
      cleanup();
    };
  }, [])
);
```

#### Use Cases
- Load data when screen is focused
- Refresh data on navigation
- Start/stop animations
- Cleanup on navigation away

---

### useIsFocused Hook
**Location:** `@react-navigation/native`  
**Type:** React Navigation Hook  
**Purpose:** Check if screen is currently focused

#### Usage
```typescript
import { useIsFocused } from '@react-navigation/native';

const isFocused = useIsFocused();

if (isFocused) {
  // Screen is focused
}
```

#### Use Cases
- Conditional rendering based on focus
- Conditional data loading
- Animation control

---

## 🔗 Deep Linking Services

### Linking API
**Location:** `react-native`  
**Type:** React Native API  
**Purpose:** Handle deep links and URL schemes

#### Methods

**`Linking.addEventListener(event, handler)`**
- Listen for incoming links
- Event: `'url'`
- Handler: `(event: { url: string }) => void`
- Returns: `{ remove: () => void }`

**`Linking.getInitialURL()`**
- Get URL that opened app
- Returns: `Promise<string | null>`
- Used on app launch

**`Linking.openURL(url)`**
- Open URL (external or internal)
- Returns: `Promise<void>`
- Example: `Linking.openURL('awave://email-verification?token=...')`

#### Usage Example
```typescript
import { Linking } from 'react-native';

useEffect(() => {
  // Listen for incoming links
  const subscription = Linking.addEventListener('url', handleDeepLink);
  
  // Check initial URL
  Linking.getInitialURL().then((url) => {
    if (url) {
      handleDeepLink({ url });
    }
  });
  
  return () => {
    subscription.remove();
  };
}, []);
```

---

## 💾 State Persistence Services

### onboardingStorage
**Location:** `src/hooks/useOnboardingStorage.ts`  
**Type:** Storage Utility  
**Purpose:** Persist onboarding and navigation state

#### Methods

**`getSelectedCategory(): Promise<string | null>`**
- Get saved category selection
- Used for initial tab determination
- Returns: Category ID or null

**`loadOnboardingState(): Promise<{ completed: boolean; profile?: any }>`**
- Load onboarding completion status
- Used for initial route determination
- Returns: Onboarding state

**`saveSelectedCategory(categoryId: string): Promise<void>`**
- Save category selection
- Persists user's category choice
- Used for tab state recovery

#### Storage Keys
- `onboarding.selectedCategory` - Selected category ID
- `onboarding.completed` - Onboarding completion flag
- `onboarding.profile` - Onboarding profile data

#### Usage in Navigation
```typescript
// In TabNavigator
const getInitialTab = async (): Promise<CategoryTab> => {
  const savedCategory = await onboardingStorage.getSelectedCategory();
  if (savedCategory === 'schlafen' || savedCategory === 'stress' || savedCategory === 'leichtigkeit') {
    return savedCategory as CategoryTab;
  }
  return 'schlafen';
};

// In IndexScreen
const { completed } = await onboardingStorage.loadOnboardingState();
if (completed) {
  navigation.navigate('MainTabs');
} else {
  navigation.navigate('OnboardingSlides');
}
```

---

## 🔐 Route Protection Services

### Authentication Check
**Location:** Various screens  
**Type:** Utility Function  
**Purpose:** Check authentication before accessing protected routes

#### Implementation
```typescript
import { useAuth } from '../contexts/AuthContext';

const { isAuthenticated, user } = useAuth();

useEffect(() => {
  if (!isAuthenticated) {
    navigation.navigate('Auth');
  }
}, [isAuthenticated, navigation]);
```

#### Protected Routes
- MainTabs (after onboarding)
- Profile screens
- Subscription screens
- Stats screen
- Account settings

---

### Subscription Access Check
**Location:** `src/components/AudioPlayerEnhanced.tsx`  
**Type:** Access Validation  
**Purpose:** Check subscription access for premium features

#### Implementation
```typescript
const checkAccess = async () => {
  const plan = await SubscriptionStorage.getSelectedPlan();
  if (!plan && !userId) {
    setHasAccess(false);
    navigation.navigate('Subscribe');
  } else {
    setHasAccess(true);
  }
};
```

#### Use Cases
- Audio player access
- Premium content access
- Feature gating

---

## 🔄 Navigation State Services

### Navigation State Management
**Location:** React Navigation (built-in)  
**Type:** Built-in Service  
**Purpose:** Manage navigation stack state

#### Features
- Navigation stack history
- Route parameters
- Navigation state persistence
- State recovery on app restart

#### State Structure
```typescript
{
  index: number; // Current route index
  routes: Array<{
    name: string;
    key: string;
    params?: object;
  }>;
}
```

---

## 🔗 Service Dependencies

### Dependency Graph
```
Navigation System
├── React Navigation
│   ├── NavigationContainer
│   ├── Stack Navigator
│   └── Navigation Hooks
├── React Native Linking
│   ├── URL Scheme Handling
│   └── Deep Link Processing
├── AsyncStorage
│   ├── onboardingStorage
│   └── Navigation State Persistence
└── Context Providers
    ├── AuthContext (Route Protection)
    ├── CategoryContext (Tab Data)
    └── ThemeContext (Styling)
```

### External Dependencies

#### React Navigation
- **Core:** `@react-navigation/native`
- **Stack:** `@react-navigation/stack`
- **Types:** `@react-navigation/bottom-tabs` (for types only)

#### React Native
- **Linking:** Built-in API
- **AsyncStorage:** `@react-native-async-storage/async-storage`

#### Internal Services
- `onboardingStorage` - State persistence
- `AuthContext` - Authentication state
- `CategoryContext` - Category data
- `ThemeProvider` - Styling

---

## 🔄 Service Interactions

### Navigation Flow
```
User Action
    │
    ├─> useNavigation().navigate()
    │   └─> React Navigation Stack
    │       └─> Screen Component Renders
    │
    ├─> Tab Press
    │   └─> TabNavigator State Update
    │       └─> Screen Component Switch
    │
    └─> Deep Link
        └─> Linking API
            └─> Token Extraction
                └─> Navigation
```

### State Persistence Flow
```
App Launch
    │
    └─> onboardingStorage.loadOnboardingState()
        ├─> Check Completion
        │   ├─> Completed → Navigate to MainTabs
        │   └─> Not Completed → Navigate to Onboarding
        │
        └─> onboardingStorage.getSelectedCategory()
            └─> Set Initial Tab
```

### Route Protection Flow
```
Screen Access
    │
    └─> Check Authentication
        ├─> Authenticated → Render Screen
        └─> Not Authenticated
            └─> Navigate to Auth
                └─> Preserve Intended Destination
```

---

## 🧪 Service Testing

### Unit Tests
- Navigation hook usage
- Deep link parsing
- State persistence
- Route parameter handling

### Integration Tests
- Navigation flows
- Deep link handling
- State recovery
- Route protection

### Mocking
- React Navigation hooks
- Linking API
- AsyncStorage
- Context providers

---

## 📊 Service Metrics

### Performance
- **Navigation Transition:** < 300ms
- **Tab Switching:** < 100ms
- **Deep Link Processing:** < 500ms
- **State Loading:** < 200ms

### Reliability
- **Navigation Success Rate:** > 99%
- **Deep Link Success Rate:** > 95%
- **State Recovery Rate:** > 98%
- **Route Protection Accuracy:** > 99%

---

## 🔐 Security Considerations

### Deep Link Security
- Token validation before use
- URL parameter sanitization
- Expired token handling
- Invalid link error handling

### Route Protection Security
- Authentication state validation
- Session expiry checks
- Subscription status verification
- Protected route access control

---

## 📝 Service Configuration

### Navigation Configuration
```typescript
// Navigation container setup
<NavigationContainer>
  <Stack.Navigator
    initialRouteName='Index'
    screenOptions={{
      headerShown: false,
      gestureEnabled: true,
      gestureDirection: 'horizontal',
    }}
  >
    {/* Screens */}
  </Stack.Navigator>
</NavigationContainer>
```

### Deep Link Configuration
```typescript
// iOS Info.plist
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>awave</string>
    </array>
  </dict>
</array>

// Android AndroidManifest.xml
<intent-filter>
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="awave" />
</intent-filter>
```

---

## 🔄 Service Updates

### Future Enhancements
- Navigation state persistence across app restarts
- Advanced deep linking with query parameters
- Navigation analytics
- Route transition customization
- Navigation state debugging tools

---

*For component usage, see `components.md`*  
*For user flows, see `user-flows.md`*  
*For technical details, see `technical-spec.md`*
