# Notifications System - Components Inventory

## 📱 Screens

### NotificationPreferencesScreen
**File:** `src/screens/NotificationPreferencesScreen.tsx`  
**Route:** `/notification-preferences`  
**Purpose:** Dedicated screen for managing all notification preferences

**Props:** None (uses route params)

**State:**
- `loading: boolean` - Loading state during data fetch
- `saving: boolean` - Saving state during preference update
- `preferences: NotificationPreferences | null` - Current user preferences

**Components Used:**
- `SafeAreaView` - Safe area handling
- `ScrollView` - Scrollable content
- `View` - Container components
- `Text` - Text display
- `Switch` - Toggle switches
- `ActivityIndicator` - Loading spinner
- `Alert` - Error alerts

**Hooks Used:**
- `useAuth` - User authentication context
- `useTheme` - Theme styling
- `useEffect` - Side effects (load preferences)

**Features:**
- Load preferences on mount
- Display all preference categories in sections
- Toggle switches for each preference
- Optimistic UI updates
- Error handling and user feedback
- Loading and empty states
- Authentication check

**Sections:**
1. **Header**
   - Title: "Benachrichtigungen"
   - Subtitle: "Verwalte deine Benachrichtigungseinstellungen"

2. **General Settings Section**
   - Push notifications toggle
   - Email notifications toggle

3. **Content Notifications Section**
   - Trial reminders toggle
   - Favorites updates toggle
   - New content toggle
   - System updates toggle

4. **Info Section**
   - Help text about notification management

**User Interactions:**
- Toggle any preference switch
- View preference descriptions
- Navigate back (via navigation)

**State Transitions:**
- Loading → Loaded → Toggle → Saving → Saved
- Loading → Error → Retry
- Unauthenticated → Empty state

**Dependencies:**
- `NotificationService` - Preference operations
- `useAuth` context - User authentication
- `useTheme` hook - Theme styling

---

### AccountSettingsScreen (Notification Section)
**File:** `src/screens/AccountSettingsScreen.tsx`  
**Route:** `/account-settings`  
**Purpose:** Quick push notification toggle in account settings

**State:**
- `pushNotifications: boolean` - Push notification enabled state

**Components Used:**
- `View` - Container
- `Text` - Labels and descriptions
- `Switch` - Toggle switch
- `EnhancedCard` - Card container

**Hooks Used:**
- `useAuth` - User authentication
- `useTheme` - Theme styling
- `useTranslation` - Translations

**Features:**
- Quick toggle for push notifications
- Description text
- Immediate save on toggle
- Visual feedback
- Integrated in account settings

**User Interactions:**
- Toggle push notification switch
- View description

**Dependencies:**
- `useAuth` context
- `useTheme` hook
- Translation system

---

### ProfileScreen (Notification Integration)
**File:** `src/screens/ProfileScreen.tsx`  
**Route:** `/profile`  
**Purpose:** Notification preferences display and quick toggle

**State:**
- `notificationsEnabled: boolean` - Notification enabled state
- `healthKitEnabled: boolean` - HealthKit state (unrelated)

**Components Used:**
- `ProfileSettingsSection` - Settings section component
- Various profile components

**Hooks Used:**
- `useUserProfile` - User profile and preferences
- `useAuth` - User authentication
- `useTheme` - Theme styling
- `useProductionAuth` - Production auth
- `useNavigation` - Navigation
- `useTranslation` - Translations

**Features:**
- Display notification preferences from backend
- Quick toggle functionality
- Sync with backend preferences
- Update via useUserProfile hook
- Auto-sync on preference load

**User Interactions:**
- Toggle notification switch
- Navigate to account settings
- Navigate to notification preferences (via settings)

**State Management:**
- Syncs `notificationsEnabled` with `notificationPreferences.push_notifications`
- Updates backend on toggle

**Dependencies:**
- `useUserProfile` hook
- `useAuth` context
- `useTheme` hook

---

## 🧩 Components

### ProfileSettingsSection
**File:** `src/components/profile/ProfileSettingsSection.tsx`  
**Type:** Reusable Settings Component

**Props:**
```typescript
interface ProfileSettingsSectionProps {
  notificationsEnabled?: boolean;
  biometricEnabled?: boolean;
  onNotificationsToggle?: (enabled: boolean) => void;
  onBiometricToggle?: (enabled: boolean) => void;
}
```

**State:**
- `notificationsEnabled: boolean` - Local notification state
- `biometricEnabled: boolean` - Local biometric state
- `isLoading: boolean` - Loading state

**Components Used:**
- `View` - Container
- `Text` - Labels
- `Switch` - Toggle switches
- `Icon` - Icons
- `ActivityIndicator` - Loading spinner

**Hooks Used:**
- `useTheme` - Theme styling
- `AsyncStorage` - Local storage

**Features:**
- Notification toggle with local storage
- Biometric toggle with local storage
- External handler support
- Toast notifications for feedback
- Error handling

**User Interactions:**
- Toggle notification switch
- Toggle biometric switch

**Storage Keys:**
- `awave_notifications_enabled`
- `awave_biometric_enabled`

**Dependencies:**
- `AsyncStorage`
- `useTheme` hook
- Toast notification system

---

## 🔗 Component Relationships

### NotificationPreferencesScreen Component Tree
```
NotificationPreferencesScreen
├── SafeAreaView
│   └── ScrollView
│       ├── View (Header)
│       │   ├── Text (Title)
│       │   └── Text (Subtitle)
│       ├── View (General Section)
│       │   ├── Text (Section Title)
│       │   └── View (Setting Card)
│       │       ├── View (Setting Row - Push)
│       │       │   ├── View (Setting Info)
│       │       │   │   ├── Text (Title)
│       │       │   │   └── Text (Description)
│       │       │   └── Switch
│       │       ├── View (Divider)
│       │       └── View (Setting Row - Email)
│       │           ├── View (Setting Info)
│       │           └── Switch
│       ├── View (Content Section)
│       │   ├── Text (Section Title)
│       │   └── View (Setting Card)
│       │       ├── View (Setting Row - Trial Reminders)
│       │       ├── View (Divider)
│       │       ├── View (Setting Row - Favorites)
│       │       ├── View (Divider)
│       │       ├── View (Setting Row - New Content)
│       │       ├── View (Divider)
│       │       └── View (Setting Row - System Updates)
│       └── View (Info Section)
│           └── Text (Info Text)
```

### AccountSettingsScreen Notification Section
```
AccountSettingsScreen
└── EnhancedCard
    └── View (Setting Row)
        ├── View (Setting Info)
        │   ├── Text (Label)
        │   └── Text (Description)
        └── Switch
```

### ProfileScreen Notification Integration
```
ProfileScreen
└── ProfileSettingsSection
    └── View (Settings Container)
        ├── View (Notification Row)
        │   ├── View (Info)
        │   │   ├── Icon
        │   │   └── Text (Label)
        │   └── Switch
        └── View (Biometric Row)
            ├── View (Info)
            └── Switch
```

---

## 🎨 Styling

### Theme Integration
All components use the theme system via `useTheme` hook:
- Colors: `theme.colors.primary`, `theme.colors.textPrimary`, `theme.colors.border`, etc.
- Typography: `theme.typography.fontFamily`
- Spacing: Consistent padding and margins

### Component Styles

**NotificationPreferencesScreen:**
- Container: Full screen with background color
- Header: Large title (32px), subtitle (16px)
- Section Title: Uppercase, letter-spaced (14px)
- Setting Card: Rounded (16px), bordered, card background
- Setting Row: Flex row, padding (16px), gap (16px)
- Switch: Custom track and thumb colors

**AccountSettingsScreen:**
- Integrated in EnhancedCard component
- Consistent with other settings rows
- Switch styling matches theme

**ProfileScreen:**
- Integrated in ProfileSettingsSection
- Icon-based layout
- Consistent with profile styling

### Responsive Design
- ScrollView for long content
- SafeAreaView for status bar handling
- Flexible layouts for different screen sizes

### Accessibility
- Semantic labels
- Touch target sizes (min 44x44 for switches)
- Color contrast compliance
- Screen reader support

---

## 🔄 State Management

### Local State
- Form inputs (preference toggles)
- UI state (loading, saving, errors)
- Optimistic updates

### Context State
- `AuthContext` - User authentication state
- User session and ID

### Persistent State
- `AsyncStorage` - Local caching and reminder flags
- Supabase database - Server-side preferences

### State Flow

**Preference Update Flow:**
```
User Toggle
  ↓
Optimistic Update (UI)
  ↓
API Call (Save)
  ↓
Success → Confirm
  ↓
Failure → Revert + Error
```

**Preference Load Flow:**
```
Screen Mount
  ↓
Check User Auth
  ↓
Load from Database
  ↓
Success → Display
  ↓
Not Found → Create Defaults
  ↓
Error → Show Error State
```

---

## 🧪 Testing Considerations

### Component Tests
- Toggle switch interactions
- Loading states
- Error states
- Empty states
- Preference updates

### Integration Tests
- API calls
- Database operations
- State synchronization
- Error handling

### E2E Tests
- Complete preference update flow
- Navigation between screens
- Trial reminder checking
- Default preference creation

---

## 📊 Component Metrics

### Complexity
- **NotificationPreferencesScreen:** Medium (multiple sections, state management)
- **AccountSettingsScreen (Notification):** Low (simple toggle)
- **ProfileScreen (Notification):** Low (integration only)
- **ProfileSettingsSection:** Medium (local storage, external handlers)

### Reusability
- **NotificationPreferencesScreen:** Low (dedicated screen)
- **AccountSettingsScreen:** Medium (part of larger screen)
- **ProfileSettingsSection:** High (reusable component)

### Dependencies
- All screens depend on theme system
- All screens depend on authentication
- NotificationPreferencesScreen depends on NotificationService
- ProfileScreen depends on useUserProfile hook

---

## 🔄 Data Flow

### Preference Update Flow
```
User Action (Toggle)
  ↓
Component State Update (Optimistic)
  ↓
NotificationService.updateNotificationPreferences()
  ↓
Supabase Update
  ↓
Success → State Confirmed
  ↓
Failure → State Reverted + Error
```

### Preference Load Flow
```
Component Mount
  ↓
Check User Auth
  ↓
NotificationService.getNotificationPreferences()
  ↓
Supabase Query
  ↓
Found → Set State
  ↓
Not Found → Create Defaults → Set State
```

### Trial Reminder Flow
```
App Launch / Sign In
  ↓
AuthContext Effect
  ↓
NotificationService.checkAndSendTrialReminder()
  ↓
Check Trial Status
  ↓
Check Preferences
  ↓
Check Already Sent
  ↓
Send Reminder → Log to Database
```

---

## 🎯 Component Responsibilities

### NotificationPreferencesScreen
- Display all notification preferences
- Handle preference toggles
- Manage loading and error states
- Provide user feedback

### AccountSettingsScreen
- Quick access to push notification toggle
- Simple toggle with description
- Immediate save

### ProfileScreen
- Display notification state
- Quick toggle integration
- Sync with backend preferences

### ProfileSettingsSection
- Reusable settings component
- Local storage integration
- External handler support
- Toast notifications

---

*For service dependencies, see `services.md`*  
*For user flows, see `user-flows.md`*  
*For technical details, see `technical-spec.md`*
