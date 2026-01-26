# Account Settings - Components Inventory

## 📱 Screen

### AccountSettingsScreen
**File:** `src/screens/AccountSettingsScreen.tsx`  
**Route:** `/account-settings`  
**Purpose:** Main account settings screen with email, password, and security management

**Props:** None (screen component)

**State:**
- `loading: boolean` - Loading state for updates
- `currentEmail: string` - Current user email
- `newEmail: string` - New email input value
- `isEmailValid: boolean` - Email validation state
- `newPassword: string` - New password input value
- `showPassword: boolean` - Password visibility toggle
- `isPasswordValid: boolean` - Password validation state
- `biometricEnabled: boolean` - Biometric login state
- `pushNotifications: boolean` - Push notification state
- `confirmDialog: object` - Confirmation dialog state
- `toasts: array` - Toast notifications array

**Components Used:**
- `UnifiedHeader` - Screen header with back button
- `EnhancedCard` - Card containers with gradient variants
- `Input` - Form input fields
- `Switch` - Toggle switches
- `ConfirmDialog` - Confirmation dialog
- `ToastContainer` - Toast notification container
- `Icon` - Icons for sections
- `LinearGradient` - Gradient backgrounds
- `FadeIn` - Animation wrapper

**Hooks Used:**
- `useAuth` - Authentication context
- `useTheme` - Theme styling
- `useTranslation` - Translation strings
- `useToast` - Toast notification system
- `useDevSettings` - Developer settings hook

**Features:**
- Email update with validation
- Password change with validation
- Biometric login toggle
- Push notification toggle
- Developer settings (dev only)
- Confirmation dialogs
- Toast notifications
- Form validation
- Error handling

**User Interactions:**
- Enter new email
- Update email (with confirmation)
- Enter new password
- Toggle password visibility
- Update password
- Toggle biometric login
- Toggle push notifications
- Toggle paywall bypass (dev only)

---

## 🧩 Components

### Input Component
**File:** `src/components/ui/Input.tsx`  
**Type:** Reusable Form Input

**Props:**
```typescript
interface InputProps {
  value: string;
  onChangeText: (text: string) => void;
  placeholder?: string;
  keyboardType?: string;
  autoCapitalize?: string;
  secureTextEntry?: boolean;
  style?: StyleProp<ViewStyle>;
}
```

**Features:**
- Text input with styling
- Placeholder support
- Keyboard type configuration
- Secure text entry support
- Theme integration

---

### EnhancedCard Component
**File:** `src/components/ui/EnhancedCard.tsx`  
**Type:** Card Container

**Props:**
```typescript
interface EnhancedCardProps {
  variant?: 'subtle-gradient' | 'default';
  gradientColors?: string[];
  padding?: number;
  borderRadius?: number;
  style?: StyleProp<ViewStyle>;
  children: React.ReactNode;
}
```

**Features:**
- Gradient background variants
- Customizable padding and border radius
- Theme integration
- Consistent styling

---

### ConfirmDialog Component
**File:** `src/components/ui/ConfirmDialog.tsx`  
**Type:** Confirmation Dialog

**Props:**
```typescript
interface ConfirmDialogProps {
  visible: boolean;
  title: string;
  message?: string;
  onConfirm: () => void;
  onCancel: () => void;
  destructive?: boolean;
  confirmText?: string;
  cancelText?: string;
}
```

**Features:**
- Modal dialog display
- Title and message support
- Confirm/cancel actions
- Destructive variant
- Customizable button text

---

### Toast Component
**File:** `src/components/ui/Toast.tsx`  
**Type:** Toast Notification System

**Hooks:**
- `useToast()` - Returns toast management functions

**Features:**
- Success toast notifications
- Error toast notifications
- Info toast notifications
- Auto-dismiss functionality
- Toast container management

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
│       │       ├── View (Section Header)
│       │       │   ├── LinearGradient (Icon Container)
│       │       │   │   └── Icon (User)
│       │       │   └── Text (Section Title)
│       │       ├── View (Form Group - Current Email)
│       │       │   ├── Text (Label)
│       │       │   └── View (Current Email Container)
│       │       │       └── Text (Current Email)
│       │       └── View (Form Group - New Email)
│       │           ├── Text (Label)
│       │           ├── Input (New Email)
│       │           └── InteractiveAnimatedButton (Update Email)
│       ├── FadeIn (Security Section)
│       │   └── EnhancedCard
│       │       ├── View (Section Header)
│       │       │   ├── LinearGradient (Icon Container)
│       │       │   │   └── Icon (Shield)
│       │       │   └── Text (Section Title)
│       │       ├── View (Form Group - Password)
│       │       │   ├── Text (Label)
│       │       │   ├── View (Password Container)
│       │       │   │   ├── Input (Password)
│       │       │   │   └── InteractiveAnimatedButton (Toggle Visibility)
│       │       │   └── InteractiveAnimatedButton (Update Password)
│       │       ├── View (Setting Row - Biometric)
│       │       │   ├── View (Setting Info)
│       │       │   │   ├── Text (Label)
│       │       │   │   └── Text (Description)
│       │       │   └── Switch (Biometric Toggle)
│       │       └── View (Setting Row - Push Notifications)
│       │           ├── View (Setting Info)
│       │           │   ├── Text (Label)
│       │           │   └── Text (Description)
│       │           └── Switch (Push Notifications Toggle)
│       └── FadeIn (Developer Settings - Dev Only)
│           └── EnhancedCard
│               ├── View (Section Header)
│               │   ├── Icon (Code)
│               │   └── Text (Section Title)
│               └── View (Setting Row - Paywall Bypass)
│                   ├── View (Setting Info)
│                   │   ├── Text (Label)
│                   │   └── Text (Description)
│                   └── Switch (Paywall Bypass Toggle)
```

---

## 🎨 Styling

### Theme Integration
All components use the theme system via `useTheme` hook:
- Colors: `theme.colors.primary`, `theme.colors.textPrimary`, etc.
- Typography: `theme.typography.fontFamily`
- Spacing: Consistent padding and margins (PROFILE_RADIUS = 16)

### Responsive Design
- ScrollView for small screens
- SafeAreaView for status bar handling
- Consistent card spacing and padding

### Accessibility
- Semantic labels
- Touch target sizes (min 44x44)
- Color contrast compliance
- Screen reader support

---

## 🔄 State Management

### Local State
- Form inputs (email, password)
- UI state (loading, visibility, validation)
- Toggle states (biometric, notifications)
- Dialog state

### Context State
- `AuthContext` - User authentication state
- `ThemeContext` - Theme styling
- `TranslationContext` - Translation strings

### Persistent State
- `AsyncStorage` - Developer settings
- Supabase - User profile and preferences

---

## 🧪 Testing Considerations

### Component Tests
- Form validation
- Input interactions
- Toggle functionality
- Dialog interactions
- Toast notifications
- Error display

### Integration Tests
- Email update flow
- Password update flow
- Backend synchronization
- Error handling

### E2E Tests
- Complete email update journey
- Complete password update journey
- Settings toggle functionality
- Error scenarios

---

## 📊 Component Metrics

### Complexity
- **AccountSettingsScreen:** Medium (multiple forms + toggles)

### Reusability
- **Input:** High (used across forms)
- **EnhancedCard:** High (used throughout app)
- **ConfirmDialog:** Medium (used for confirmations)
- **Toast:** High (used for notifications)

### Dependencies
- All components depend on theme system
- Form components depend on validation utilities
- Screen depends on AuthContext

---

*For service dependencies, see `services.md`*  
*For user flows, see `user-flows.md`*  
*For technical details, see `technical-spec.md`*
