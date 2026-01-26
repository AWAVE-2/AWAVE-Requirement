# Profile View System - Functional Requirements

## 📋 Core Requirements

### 1. Profile Header Display

#### User Information
- [x] Display user avatar (from profile or fallback icon)
- [x] Display user display name (or email if no name)
- [x] Display user email address
- [x] Show subscription status badge
- [x] Display premium crown indicator for active subscribers
- [x] Gradient card design matching web app
- [x] Responsive layout with proper spacing

#### Subscription Status
- [x] Show "Aktiv" for active subscriptions
- [x] Show "Testversion" for trialing subscriptions
- [x] Show "Kostenlos" for free users
- [x] Color-coded status indicators
- [x] Badge with icon and text

---

### 2. Statistics Summary

#### Weekly Progress
- [x] Display weekly meditation goal (e.g., 120 minutes)
- [x] Show current progress (e.g., 85 minutes)
- [x] Visual progress bar with percentage
- [x] Percentage completion display
- [x] Real-time progress updates

#### Streak and Achievements
- [x] Display current streak (days)
- [x] Show unlocked badges (e.g., 5/12)
- [x] Achievement icons and labels
- [x] Visual card design

#### Quick Stats
- [x] Total sessions count
- [x] Average minutes per session
- [x] Growth percentage
- [x] Grid layout with icons

#### Authentication State
- [x] Blur overlay for unauthenticated users
- [x] Sign up CTA for unauthenticated users
- [x] Navigation to detailed stats for authenticated users
- [x] Platform-specific blur implementation (iOS/Android)

---

### 3. Subscription Management

#### Subscription Status Display
- [x] Show subscription plan name (Premium, etc.)
- [x] Display subscription status (Active, Trial, Inactive)
- [x] Show trial progress with remaining days
- [x] Display subscription end date
- [x] Format dates in German locale
- [x] Visual status indicators (icons, colors)

#### Trial Progress
- [x] Calculate trial progress percentage
- [x] Display progress bar
- [x] Show remaining days until billing
- [x] Warning message about auto-renewal

#### Subscription Features
- [x] Display feature grid (Premium sounds, Offline, Custom sounds, Stats)
- [x] Feature icons and labels
- [x] Visual card layout

#### Upgrade Flow
- [x] Upgrade CTA for non-subscribers
- [x] Benefits list display
- [x] Navigation to subscription screen
- [x] Trial information (7 days free)

#### Subscription Actions
- [x] "Abonnement ändern" button
- [x] "Abonnement kündigen" button
- [x] Cancellation confirmation dialog
- [x] Two-step cancellation (show warning, then confirm)
- [x] Cancel at period end (not immediately)
- [x] Loading states during cancellation
- [x] Success/error feedback

#### Subscription Management Modal
- [x] Modal for subscription changes
- [x] Current plan display
- [x] Status information
- [x] Close functionality

---

### 4. Account Section

#### Account Settings Navigation
- [x] Navigate to Account Settings screen
- [x] Display "Kontoeinstellungen" card
- [x] Show description "E-Mail, Passwort & mehr"
- [x] Icon and visual styling

#### Legal Navigation
- [x] Navigate to Legal screen
- [x] Display "Rechtliches" card
- [x] Show description "AGB & Datenschutz"
- [x] Icon and visual styling

#### Privacy Settings Navigation
- [x] Navigate to Privacy Settings screen
- [x] Display "Datenschutz-Einstellungen" card
- [x] Show description "Privatsphäre verwalten"
- [x] Icon and visual styling

#### Purchase Restoration
- [x] "Käufe wiederherstellen" button
- [x] Confirmation dialog before restoration
- [x] IAP service integration
- [x] Loading state during restoration
- [x] Success message with count of restored purchases
- [x] Error handling for failed restoration
- [x] Empty state message if no purchases found

#### Onboarding Reset (Dev Only)
- [x] Reset onboarding button (__DEV__ only)
- [x] Confirmation dialog
- [x] Reset to questionnaire state
- [x] Navigate to Index screen after reset
- [x] Clear onboarding flags

---

### 5. Settings Section

#### Push Notifications
- [x] Toggle switch for push notifications
- [x] Display current state (enabled/disabled)
- [x] Update backend preferences on toggle
- [x] Local storage persistence
- [x] Toast notification on save
- [x] Icon and description

#### Apple HealthKit
- [x] Toggle switch for HealthKit integration
- [x] Display current state (enabled/disabled)
- [x] Update user profile metadata on toggle
- [x] Local storage persistence
- [x] Toast notification on save
- [x] Icon and description
- [x] Error handling for sync failures

#### Settings Persistence
- [x] Load settings from AsyncStorage on mount
- [x] Sync with backend preferences
- [x] Handle external prop updates
- [x] Loading state during initialization

---

### 6. Support Section

#### App Sharing
- [x] "AWAVE teilen" button
- [x] Native share dialog
- [x] Share message and title
- [x] Error handling for share failures
- [x] Icon and description

#### Help & Support
- [x] Navigate to Support screen
- [x] Display "Hilfe & Support" card
- [x] Show description "FAQ & Kontakt"
- [x] Icon and visual styling

#### Sign Out
- [x] Sign out button (authenticated users only)
- [x] Visual danger styling (red border, gradient)
- [x] Sign out confirmation
- [x] Clear session and onboarding data
- [x] Navigate to Index screen
- [x] Error handling

---

### 7. Account Deletion

#### Deletion Flow
- [x] "Konto & Daten löschen" section
- [x] Warning message about permanence
- [x] Subscription warning (active subscriptions continue)
- [x] Confirmation dialog
- [x] Two-step confirmation (alert, then action)
- [x] Backend account deletion
- [x] Sign out after deletion
- [x] Navigate to Index screen
- [x] Error handling with support contact option

#### Visual Design
- [x] Danger styling (red colors, border)
- [x] Warning icon
- [x] Clear description text
- [x] Destructive button styling

---

### 8. Account Settings Screen

#### Email Management
- [x] Display current email address
- [x] Input field for new email
- [x] Email format validation
- [x] Update email button
- [x] Confirmation dialog before update
- [x] Backend email update
- [x] Success/error feedback
- [x] Loading states

#### Password Management
- [x] Input field for new password
- [x] Password visibility toggle
- [x] Password validation (10+ characters)
- [x] Update password button
- [x] Backend password update
- [x] Success/error feedback
- [x] Loading states

#### Security Settings
- [x] Biometric login toggle
- [x] Push notifications toggle
- [x] Settings persistence
- [x] Visual feedback on toggle

#### Developer Settings (Dev Only)
- [x] Paywall bypass toggle (__DEV__ only)
- [x] Developer settings section
- [x] Visual indicator for dev mode

---

### 9. Privacy Settings Screen

#### Data Collection Consent
- [x] Health data consent checkbox
- [x] Analytics data consent checkbox
- [x] Consent descriptions
- [x] Visual checkbox component
- [x] Local storage persistence

#### Marketing Settings
- [x] Marketing communication consent checkbox
- [x] Marketing description
- [x] Visual checkbox component
- [x] Local storage persistence

#### Save Preferences
- [x] Save button
- [x] Persist to AsyncStorage
- [x] Success confirmation
- [x] Error handling

---

### 10. Legal Screen

#### Legal Documents
- [x] Terms and Conditions navigation
- [x] Privacy Policy navigation
- [x] Data Protection navigation
- [x] External links (Imprint, Data Protection website)
- [x] Card-based navigation
- [x] Icons and descriptions

---

### 11. Support Screen

#### Contact Form
- [x] Name input field
- [x] Email input field
- [x] Subject dropdown (Technical, Account, Billing, Feature, Other)
- [x] Message text area
- [x] Form validation
- [x] Email format validation
- [x] XSS prevention (script tag removal)
- [x] Submit button
- [x] Loading state during submission
- [x] Success confirmation
- [x] Form reset after submission

#### Support Resources
- [x] FAQ section
- [x] Contact information
- [x] Help resources

---

## 🎯 User Stories

### As a user, I want to:
- View my profile information and subscription status at a glance
- See my meditation progress and achievements
- Manage my subscription (view status, cancel, upgrade)
- Update my email and password securely
- Control my notification preferences
- Manage my privacy settings
- Get help when I need it
- Share the app with friends
- Delete my account if I choose to

### As a subscriber, I want to:
- See my trial progress and remaining days
- Understand when my subscription renews
- Cancel my subscription easily
- Restore my purchases if I switch devices

### As a free user, I want to:
- See upgrade options and benefits
- Understand what I'm missing
- Upgrade easily when ready

---

## ✅ Acceptance Criteria

### Profile Display
- [x] Profile loads within 2 seconds
- [x] All user information displays correctly
- [x] Subscription status is accurate
- [x] Avatar displays or shows fallback icon

### Statistics
- [x] Statistics load and display correctly
- [x] Progress bars update accurately
- [x] Unauthenticated users see blur overlay
- [x] Navigation to detailed stats works

### Subscription Management
- [x] Subscription status displays correctly
- [x] Trial progress calculates accurately
- [x] Cancellation flow works end-to-end
- [x] Upgrade navigation works
- [x] Subscription changes reflect immediately

### Settings
- [x] Toggles update backend preferences
- [x] Settings persist across app restarts
- [x] Toast notifications show on save
- [x] Loading states display during updates

### Account Management
- [x] Email updates require confirmation
- [x] Password updates validate length
- [x] Account deletion requires double confirmation
- [x] All updates show success/error feedback

### Purchase Restoration
- [x] Restoration works for valid purchases
- [x] Empty state shows if no purchases found
- [x] Error messages are user-friendly
- [x] Success shows count of restored purchases

---

## 🚫 Non-Functional Requirements

### Performance
- Profile screen loads in < 2 seconds
- Settings updates complete in < 1 second
- Subscription status updates in real-time
- Smooth animations and transitions

### Security
- Account deletion requires double confirmation
- Password validation enforces minimum length
- Email validation prevents invalid formats
- XSS prevention in support form
- Secure IAP purchase validation

### Usability
- Clear visual hierarchy
- Consistent design language
- Accessible touch targets (min 44x44)
- Loading states for all async operations
- Error messages are user-friendly

### Reliability
- Network errors handled gracefully
- Offline state detection
- Data persistence across app restarts
- Automatic retry for transient failures

---

## 🔄 Edge Cases

### Network Issues
- [x] Offline detection before updates
- [x] User-friendly error messages
- [x] Retry capability
- [x] Network status display

### Invalid Data
- [x] Missing user profile → Show fallback
- [x] Invalid subscription data → Show inactive status
- [x] Invalid email format → Show validation error
- [x] Weak password → Show validation error

### Subscription Edge Cases
- [x] Active subscription during deletion → Show warning
- [x] Expired trial → Show inactive status
- [x] Cancelled subscription → Show cancellation date
- [x] No subscription → Show upgrade CTA

### IAP Edge Cases
- [x] No purchases found → Show empty state
- [x] Invalid receipts → Skip and continue
- [x] Network failure → Show error message
- [x] Multiple purchases → Restore all valid

### Settings Edge Cases
- [x] Backend sync failure → Use local storage
- [x] Conflicting preferences → Backend wins
- [x] Missing preferences → Create defaults

---

## 📊 Success Metrics

- Profile screen load time < 2 seconds
- Settings update success rate > 99%
- Subscription cancellation completion rate > 95%
- Purchase restoration success rate > 90%
- Account deletion completion rate > 98%
- User satisfaction with profile features > 4.5/5
