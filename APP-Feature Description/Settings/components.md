# Settings System - Components Inventory

## 📱 Screens

### AccountSettingsScreen
**File:** `src/screens/AccountSettingsScreen.tsx`  
**Route:** `/account-settings`  
**Purpose:** Main account settings interface with email, password, and security options

**Props:** None (screen component)

**State:**
- `currentEmail: string` - Current user email address
- `newEmail: string` - New email input value
- `isEmailValid: boolean` - Email validation state
- `newPassword: string` - New password input value
- `showPassword: boolean` - Password visibility toggle
- `isPasswordValid: boolean` - Password validation state
- `biometricEnabled: boolean` - Biometric login toggle state
- `pushNotifications: boolean` - Push notifications toggle state
- `loading: boolean` - Loading state for async operations
- `confirmDialog: object` - Confirmation dialog state

**Components Used:**
- `UnifiedHeader` - Screen header with back button
- `EnhancedCard` - Card container with gradient styling
- `Input` - Text input fields
- `Switch` - Toggle switches
- `ConfirmDialog` - Confirmation dialog
- `ToastContainer` - Toast notification container
- `Icon` - Icon components
- `LinearGradient` - Gradient backgrounds
- `InteractiveTouchableOpacity` - Interactive buttons

**Hooks Used:**
- `useAuth` - Authentication context
- `useTheme` - Theme styling
- `useTranslation` - Translation/localization
- `useToast` - Toast notifications
- `useDevSettings` - Developer settings

**Features:**
- Email update with validation and confirmation
- Password change with strength validation
- Biometric login toggle
- Push notifications toggle
- Developer settings section (DEV mode only)
- Toast notifications for feedback
- Confirmation dialogs for critical actions
- Loading states for async operations

**User Interactions:**
- Enter new email address
- Update email with confirmation
- Enter new password
- Toggle password visibility
- Update password
- Toggle biometric login
- Toggle push notifications
- Toggle developer settings (DEV only)

**Sections:**
1. **Account Information** - Current email display and email update
2. **Security** - Password change, biometric login, push notifications
3. **Developer Settings** - Paywall bypass (DEV only)

---

### PrivacySettingsScreen
**File:** `src/screens/PrivacySettingsScreen.tsx`  
**Route:** `/privacy-settings`  
**Purpose:** Privacy consent management interface

**State:**
- `healthDataConsent: boolean` - Health data consent state
- `analyticsConsent: boolean` - Analytics consent state
- `marketingConsent: boolean` - Marketing consent state
- `isLoading: boolean` - Loading state

**Storage Key:** `awavePrivacyPreferences`

**Components Used:**
- `UnifiedHeader` - Screen header
- `EnhancedCard` - Card containers
- `Checkbox` - Custom checkbox component
- `AnimatedButton` - Action buttons
- `Icon` - Icon components
- `LinearGradient` - Gradient backgrounds

**Hooks Used:**
- `useTheme` - Theme styling
- `useTranslation` - Translation/localization
- `useNavigation` - Navigation

**Features:**
- Health data consent checkbox
- Analytics consent checkbox
- Marketing consent checkbox
- Save preferences button
- Last updated timestamp tracking
- Custom checkbox component
- Gradient card styling
- AsyncStorage persistence

**User Interactions:**
- Toggle health data consent
- Toggle analytics consent
- Toggle marketing consent
- Save all preferences
- Navigate back

**Sections:**
1. **Header** - Title and description
2. **Data Collection** - Health data and analytics consents
3. **Marketing Settings** - Marketing communication consent
4. **Save Button** - Persist preferences

---

### NotificationPreferencesScreen
**File:** `src/screens/NotificationPreferencesScreen.tsx`  
**Route:** `/notification-preferences`  
**Purpose:** Granular notification preference control

**State:**
- `loading: boolean` - Initial load state
- `saving: boolean` - Save operation state
- `preferences: NotificationPreferences | null` - User preferences

**Components Used:**
- `Switch` - Toggle switches
- `ActivityIndicator` - Loading spinner
- `SafeAreaView` - Safe area container
- `ScrollView` - Scrollable container

**Hooks Used:**
- `useAuth` - Authentication context
- `useTheme` - Theme styling

**Features:**
- General notification toggles (push, email)
- Content notification toggles (trial, favorites, new content, system)
- Real-time preference updates
- Backend synchronization via NotificationService
- Optimistic UI updates
- Error handling with rollback
- Loading and empty states

**User Interactions:**
- Toggle push notifications
- Toggle email notifications
- Toggle trial reminders
- Toggle favorites updates
- Toggle new content alerts
- Toggle system updates

**Sections:**
1. **Header** - Title and subtitle
2. **General Settings** - Push and email notifications
3. **Content Notifications** - Trial, favorites, new content, system updates
4. **Info Section** - Additional information

---

## 🧩 Components

### ProfileSettingsSection
**File:** `src/components/profile/ProfileSettingsSection.tsx`  
**Type:** Reusable Section Component

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
- `notificationsEnabled: boolean` - Notification toggle state
- `biometricEnabled: boolean` - Biometric toggle state
- `isLoading: boolean` - Loading state

**Storage Keys:**
- `@awave_notifications_enabled` - Notification toggle persistence
- `@awave_biometric_enabled` - Biometric toggle persistence

**Components Used:**
- `EnhancedCard` - Card containers
- `Switch` - Toggle switches
- `Icon` - Icon components

**Hooks Used:**
- `useTheme` - Theme styling
- `useToast` - Toast notifications

**Features:**
- Notifications toggle with persistence
- HealthKit toggle with persistence
- Toast notifications for feedback
- External prop synchronization
- Local storage fallback
- Icon-based visual design

**User Interactions:**
- Toggle notifications
- Toggle HealthKit integration

---

### ProfileAccountSection
**File:** `src/components/profile/ProfileAccountSection.tsx`  
**Type:** Navigation Section Component

**Props:** None

**State:**
- `isRestoring: boolean` - Purchase restoration state

**Components Used:**
- `EnhancedCard` - Card containers
- `TouchableOpacity` - Navigation buttons
- `Icon` - Icon components
- `AnimatedButton` - Action buttons
- `LinearGradient` - Gradient backgrounds

**Hooks Used:**
- `useTheme` - Theme styling
- `useNavigation` - Navigation
- `useTranslation` - Translation/localization

**Features:**
- Navigation to Account Settings
- Navigation to Legal screen
- Navigation to Privacy Settings
- Restore purchases functionality
- Reset onboarding (DEV only)
- Gradient card styling
- Icon-based navigation

**User Interactions:**
- Navigate to Account Settings
- Navigate to Legal information
- Navigate to Privacy Settings
- Restore purchases
- Reset onboarding (DEV only)

**Navigation Links:**
1. **Kontoeinstellungen** - Account Settings screen
2. **Rechtliches** - Legal screen
3. **Datenschutz-Einstellungen** - Privacy Settings screen
4. **Käufe wiederherstellen** - Restore purchases

---

### Checkbox (Custom Component)
**File:** `src/screens/PrivacySettingsScreen.tsx` (inline component)  
**Type:** Custom Checkbox Component

**Props:**
```typescript
interface CheckboxProps {
  checked: boolean;
  onPress: () => void;
  color?: string;
}
```

**State:** None (stateless)

**Features:**
- Custom checkbox styling
- Checkmark display when checked
- Color customization
- Touch feedback
- Border and background styling

**User Interactions:**
- Toggle checkbox state

---

## 🔗 Component Relationships

### AccountSettingsScreen Component Tree
```
AccountSettingsScreen
├── SafeAreaView
│   ├── UnifiedHeader
│   └── ScrollView
│       ├── ToastContainer
│       ├── ConfirmDialog
│       ├── FadeIn (Account Information)
│       │   └── EnhancedCard
│       │       ├── Section Header (Icon + Title)
│       │       ├── Current Email Display
│       │       ├── New Email Input
│       │       └── Update Email Button
│       ├── FadeIn (Security)
│       │   └── EnhancedCard
│       │       ├── Section Header (Icon + Title)
│       │       ├── Password Input (with visibility toggle)
│       │       ├── Update Password Button
│       │       ├── Biometric Login Switch
│       │       └── Push Notifications Switch
│       └── FadeIn (Developer Settings) - DEV only
│           └── EnhancedCard
│               ├── Section Header
│               └── Paywall Bypass Switch
```

### PrivacySettingsScreen Component Tree
```
PrivacySettingsScreen
├── SafeAreaView
│   ├── UnifiedHeader
│   └── ScrollView
│       └── View (Content)
│           ├── Header Section
│           │   ├── Icon Container (Gradient)
│           │   ├── Title
│           │   └── Description
│           ├── Data Collection Section
│           │   └── EnhancedCard
│           │       ├── Description
│           │       ├── Health Data Checkbox Row
│           │       └── Analytics Data Checkbox Row
│           ├── Marketing Settings Section
│           │   ├── Icon Container (Gradient)
│           │   ├── Title
│           │   ├── Subtitle
│           │   └── EnhancedCard
│           │       ├── Description
│           │       └── Marketing Communication Checkbox Row
│           └── Save Button
```

### NotificationPreferencesScreen Component Tree
```
NotificationPreferencesScreen
├── SafeAreaView
│   └── ScrollView
│       ├── Header
│       │   ├── Title
│       │   └── Subtitle
│       ├── General Settings Section
│       │   ├── Section Title
│       │   └── Setting Card
│       │       ├── Push Notifications Row (Switch)
│       │       ├── Divider
│       │       └── Email Notifications Row (Switch)
│       ├── Content Notifications Section
│       │   ├── Section Title
│       │   └── Setting Card
│       │       ├── Trial Reminders Row (Switch)
│       │       ├── Divider
│       │       ├── Favorites Updates Row (Switch)
│       │       ├── Divider
│       │       ├── New Content Row (Switch)
│       │       ├── Divider
│       │       └── System Updates Row (Switch)
│       └── Info Section
│           └── Info Text
```

---

## 🎨 Styling

### Theme Integration
All components use the theme system via `useTheme` hook:
- Colors: `theme.colors.primary`, `theme.colors.textPrimary`, etc.
- Typography: `theme.typography.fontFamily`
- Spacing: Consistent padding and margins via `awaveSpacing`

### Design Constants
- `PROFILE_RADIUS = 16` - Consistent border radius for profile-related cards
- Gradient colors for section headers and icons
- Icon colors matching design system (blue-400, green-400, purple-400, etc.)

### Responsive Design
- ScrollView for small screens
- SafeAreaView for status bar handling
- Consistent padding and margins
- Touch target sizes (min 44x44)

### Accessibility
- Semantic labels
- Touch target sizes
- Color contrast compliance
- Screen reader support
- Clear visual feedback

---

## 🔄 State Management

### Local State
- Form inputs (email, password)
- Toggle states (biometric, notifications)
- Loading and saving states
- Validation states

### Context State
- `AuthContext` - User authentication state
- User session and profile data

### Persistent State
- `AsyncStorage` - Privacy preferences, dev settings, notification toggles
- Supabase - Notification preferences, user profile

---

## 🧪 Testing Considerations

### Component Tests
- Form validation
- Toggle interactions
- State updates
- Error display
- Loading states
- Navigation

### Integration Tests
- Backend synchronization
- Preference persistence
- Error handling
- Network failures

### E2E Tests
- Complete user journeys
- Preference updates
- Error scenarios
- Network failures

---

## 📊 Component Metrics

### Complexity
- **AccountSettingsScreen:** High (multiple forms, validation, dialogs)
- **PrivacySettingsScreen:** Medium (checkboxes, save functionality)
- **NotificationPreferencesScreen:** Medium (multiple toggles, backend sync)
- **ProfileSettingsSection:** Low (simple toggles)
- **ProfileAccountSection:** Low (navigation links)

### Reusability
- **ProfileSettingsSection:** High (used in ProfileScreen)
- **ProfileAccountSection:** High (used in ProfileScreen)
- **Checkbox:** Medium (used in PrivacySettingsScreen)

### Dependencies
- All screens depend on theme system
- All screens depend on navigation
- Settings screens depend on authentication
- Notification screen depends on NotificationService

---

*For service dependencies, see `services.md`*  
*For user flows, see `user-flows.md`*  
*For technical details, see `technical-spec.md`*
