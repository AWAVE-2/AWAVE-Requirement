# Authentication System - Components Inventory

## 📱 Screens

### AuthScreen
**File:** `src/screens/AuthScreen.tsx`  
**Route:** `/auth`  
**Purpose:** Main authentication screen with login/signup toggle

**Props:**
```typescript
interface AuthScreenProps {
  onBack?: () => void;
}
```

**State:**
- `isLogin: boolean` - Current mode (login/signup)

**Components Used:**
- `AuthForm` - Main form component
- `AnimatedButton` - Back button, OAuth buttons
- `Icon` - OAuth button icons

**Hooks Used:**
- `useOAuth` - OAuth functionality
- `useTheme` - Theme styling
- `useNavigation` - Navigation

**Features:**
- Login/signup mode toggle
- Email/password authentication
- OAuth buttons (Google, Apple)
- Back navigation
- Responsive layout

**User Interactions:**
- Toggle between login/signup
- Submit email/password form
- Click OAuth buttons
- Navigate back

---

### SignupScreen
**File:** `src/screens/SignupScreen.tsx`  
**Route:** `/signup`  
**Purpose:** Dedicated signup screen with OAuth options

**State:**
- `loading: boolean` - Loading state
- `errors: Record<string, string>` - Error messages
- `userId: string` - Generated user ID (AWAVE-XXXXXXXX)

**Components Used:**
- `SocialAuthButton` - OAuth provider buttons
- `AnimatedButton` - Action buttons
- `Icon` - User icon

**Hooks Used:**
- `useAuth` - Authentication context
- `useNavigation` - Navigation

**Features:**
- User ID generation and display
- OAuth signup options
- Email signup navigation
- Terms and conditions links
- Error display
- Loading indicators

**User Interactions:**
- Click OAuth signup buttons
- Navigate to email signup
- Navigate to login
- View terms and conditions

---

### EmailVerificationScreen
**File:** `src/screens/EmailVerificationScreen.tsx`  
**Route:** `/email-verification`  
**Purpose:** Email verification status and resend

**State:**
- `verificationStatus: 'pending' | 'verifying' | 'success' | 'error'`
- `userEmail: string`
- `isResending: boolean`
- `resendCooldown: number` - Seconds remaining

**Components Used:**
- `AnimatedButton` - Action buttons
- `ActivityIndicator` - Loading spinner

**Hooks Used:**
- `useTheme` - Theme styling
- `useNavigation` - Navigation
- `Linking` API - Deep link handling

**Features:**
- Verification status display
- Email address display
- Resend functionality with cooldown
- Deep link handling
- Status-based UI updates
- Auto-navigation on success

**User Interactions:**
- Resend verification email
- Navigate back to auth
- Click verification link (deep link)

**Deep Link Handling:**
- Listens for `email-verification` URLs
- Extracts tokens from hash or query params
- Creates session with tokens

---

### ForgotPasswordScreen
**File:** `src/screens/ForgotPasswordScreen.tsx`  
**Route:** `/forgot-password`  
**Purpose:** Password reset request

**State:**
- `resetStatus: 'pending' | 'sending' | 'success' | 'error'`
- `email: string`
- `isSending: boolean`
- `resendCooldown: number`

**Components Used:**
- `Input` - Email input field
- `AnimatedButton` - Action buttons
- `ActivityIndicator` - Loading spinner

**Hooks Used:**
- `useTheme` - Theme styling
- `useNavigation` - Navigation

**Features:**
- Email input
- Reset link sending
- Resend with cooldown
- Status tracking
- Success/error states
- Help text

**User Interactions:**
- Enter email address
- Request reset link
- Resend reset link
- Navigate back to auth

---

### ResetPasswordScreen
**File:** `src/screens/ResetPasswordScreen.tsx`  
**Route:** `/reset-password`  
**Purpose:** New password entry after reset link

**State:**
- `resetStatus: 'pending' | 'verifying' | 'success' | 'error'`
- `password: string`
- `confirmPassword: string`
- `showPassword: boolean`
- `showConfirmPassword: boolean`
- `isUpdating: boolean`
- `passwordStrength: PasswordStrength`

**Components Used:**
- `Input` - Password input fields
- `PasswordStrengthIndicator` - Password validation UI
- `AnimatedButton` - Action buttons
- `Icon` - Password visibility toggle
- `ActivityIndicator` - Loading spinner

**Hooks Used:**
- `useTheme` - Theme styling
- `useNavigation` - Navigation
- `Linking` API - Deep link handling

**Features:**
- Deep link handling for reset link
- Password input with visibility toggle
- Password confirmation
- Real-time strength validation
- Password match validation
- Success/error states

**User Interactions:**
- Toggle password visibility
- Enter new password
- Confirm password
- Submit password reset
- Navigate to forgot password (if error)

**Deep Link Handling:**
- Listens for `password-reset` URLs
- Extracts tokens
- Creates session
- Allows password update

---

## 🧩 Components

### AuthForm
**File:** `src/components/auth/AuthForm.tsx`  
**Type:** Reusable Form Component

**Props:**
```typescript
interface AuthFormProps {
  mode: 'login' | 'signup';
  onSuccess?: () => void;
  toggleMode: () => void;
  children?: React.ReactNode;
}
```

**State:**
- `loading: boolean`
- `email: string`
- `password: string`
- `fullName: string` (signup only)
- `showPassword: boolean`

**Components Used:**
- `Input` - Form inputs
- `AnimatedButton` - Submit button
- `Icon` - Password visibility icon

**Hooks Used:**
- `useAuth` - Authentication context
- `useTheme` - Theme styling

**Features:**
- Email input with validation
- Password input with visibility toggle
- Full name input (signup mode only)
- Submit button with loading state
- Mode toggle link
- Error handling
- Form validation

**User Interactions:**
- Enter email
- Enter password
- Toggle password visibility
- Enter full name (signup)
- Submit form
- Toggle mode

---

### SocialAuthButton
**File:** `src/components/auth/SocialAuthButton.tsx`  
**Type:** OAuth Provider Button

**Props:**
```typescript
interface SocialAuthButtonProps {
  provider: 'apple' | 'google' | 'email';
  onPress: () => void;
  disabled?: boolean;
}
```

**State:** None (stateless)

**Components Used:**
- `AppleLogo` - Apple icon component
- `GoogleLogo` - Google icon component
- `Icon` - Email icon

**Features:**
- Provider-specific styling
- Icon display based on provider
- Disabled state
- Touch feedback
- Consistent button design

**Provider Configurations:**
- **Apple:** Black background, white text
- **Google:** White background, dark text
- **Email:** Purple tinted background

**User Interactions:**
- Click button to trigger OAuth flow

---

### PasswordStrengthIndicator
**File:** `src/components/auth/PasswordStrengthIndicator.tsx`  
**Type:** Validation UI Component

**Props:**
```typescript
interface PasswordStrengthIndicatorProps {
  strength: 'weak' | 'medium' | 'strong';
  password: string;
}
```

**State:** None (stateless)

**Features:**
- Progress bar visualization
- Strength label (Weak/Medium/Strong)
- Criteria checklist
- Real-time updates
- Color-coded feedback

**Strength Levels:**
- **Weak:** Red, 33% progress
- **Medium:** Orange, 66% progress
- **Strong:** Green, 100% progress

**Criteria Checked:**
- Minimum 8 characters
- Uppercase letter
- Lowercase letter
- Number
- Special character (recommended)

**User Interactions:**
- Visual feedback only (no direct interaction)

---

### AppleLogo
**File:** `src/components/auth/AppleLogo.tsx`  
**Type:** Icon Component

**Props:**
```typescript
interface AppleLogoProps {
  width?: number;
  height?: number;
  color?: string;
}
```

**Features:**
- SVG Apple logo
- Customizable size and color
- Consistent branding

---

### GoogleLogo
**File:** `src/components/auth/GoogleLogo.tsx`  
**Type:** Icon Component

**Props:**
```typescript
interface GoogleLogoProps {
  width?: number;
  height?: number;
}
```

**Features:**
- SVG Google logo
- Customizable size
- Consistent branding

---

## 🔗 Component Relationships

### AuthScreen Component Tree
```
AuthScreen
├── AnimatedButton (Back)
├── View (Form Container)
│   ├── View (Header)
│   │   ├── Text (Title)
│   │   └── Text (Subtitle)
│   ├── AuthForm
│   │   ├── Input (Name - signup only)
│   │   ├── Input (Email)
│   │   ├── Input (Password)
│   │   ├── AnimatedButton (Submit)
│   │   └── AnimatedButton (Toggle Mode)
│   ├── View (OAuth Divider)
│   └── View (OAuth Buttons)
│       ├── AnimatedButton (Google)
│       └── AnimatedButton (Apple)
└── ScrollView
```

### SignupScreen Component Tree
```
SignupScreen
├── KeyboardAvoidingView
│   └── ScrollView
│       └── View (Card)
│           ├── View (Icon Container)
│           │   └── Icon (User)
│           ├── Text (Title)
│           ├── Text (Subtitle)
│           ├── View (User ID Container)
│           │   ├── Text (Label)
│           │   └── Text (User ID)
│           ├── SocialAuthButton (Apple)
│           ├── SocialAuthButton (Google)
│           ├── SocialAuthButton (Email)
│           ├── View (Terms Container)
│           │   └── Text (Terms)
│           ├── AnimatedButton (Already Registered)
│           ├── View (Error Container) - conditional
│           └── View (Loading Container) - conditional
```

### EmailVerificationScreen Component Tree
```
EmailVerificationScreen
├── SafeAreaView
│   └── ScrollView
│       └── View (Card)
│           ├── View (Icon Container)
│           │   ├── Text (Status Icon)
│           │   └── ActivityIndicator - conditional
│           ├── Text (Title)
│           ├── Text (Description)
│           ├── View (Email Container) - conditional
│           │   └── Text (Email)
│           ├── View (Button Container)
│           │   ├── AnimatedButton (Resend) - conditional
│           │   ├── AnimatedButton (Back to Auth) - conditional
│           │   └── AnimatedButton (Continue) - conditional
│           └── View (Help Text) - conditional
```

---

## 🎨 Styling

### Theme Integration
All components use the theme system via `useTheme` hook:
- Colors: `theme.colors.primary`, `theme.colors.textPrimary`, etc.
- Typography: `theme.typography.fontFamily`
- Spacing: Consistent padding and margins

### Responsive Design
- ScrollView for small screens
- KeyboardAvoidingView for input screens
- SafeAreaView for status bar handling

### Accessibility
- Semantic labels
- Touch target sizes (min 44x44)
- Color contrast compliance
- Screen reader support

---

## 🔄 State Management

### Local State
- Form inputs (email, password, etc.)
- UI state (loading, errors, visibility)
- Status tracking (verification, reset)

### Context State
- `AuthContext` - Global auth state
- User session
- Authentication status

### Persistent State
- `AsyncStorage` - Email, cache, preferences
- Supabase session - Server-side session

---

## 🧪 Testing Considerations

### Component Tests
- Form validation
- Button interactions
- State updates
- Error display
- Loading states

### Integration Tests
- Navigation flows
- API calls
- Deep link handling
- OAuth flows

### E2E Tests
- Complete user journeys
- Error scenarios
- Network failures
- OAuth cancellation

---

## 📊 Component Metrics

### Complexity
- **AuthScreen:** Medium (form + OAuth)
- **SignupScreen:** Low (buttons + display)
- **EmailVerificationScreen:** Medium (status + deep links)
- **ForgotPasswordScreen:** Low (simple form)
- **ResetPasswordScreen:** Medium (form + validation)

### Reusability
- **AuthForm:** High (used in AuthScreen)
- **SocialAuthButton:** High (used in multiple screens)
- **PasswordStrengthIndicator:** Medium (used in forms)

### Dependencies
- All screens depend on theme system
- All screens depend on navigation
- OAuth screens depend on native modules
- Forms depend on validation utilities

---

*For service dependencies, see `services.md`*  
*For user flows, see `user-flows.md`*  
*For technical details, see `technical-spec.md`*
