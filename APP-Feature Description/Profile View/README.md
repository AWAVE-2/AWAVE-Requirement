# Profile View System - Feature Documentation

**Feature Name:** Profile View & Account Management  
**Status:** ✅ Complete  
**Priority:** High  
**Last Updated:** 2025-01-27

## 📋 Feature Overview

The Profile View system provides comprehensive user profile management, account settings, subscription management, and privacy controls for the AWAVE app. It serves as the central hub for users to manage their account, view statistics, control settings, and access support resources.

### Description

The Profile View system is built with React Native and provides:
- **User Profile Display** - Avatar, display name, email, subscription status
- **Statistics Summary** - Weekly goals, streaks, achievements, session tracking
- **Subscription Management** - View status, trial progress, upgrade options, cancellation
- **Account Settings** - Email/password updates, biometric login, push notifications
- **Privacy Controls** - Health data consent, analytics preferences, marketing settings
- **Support Access** - Help resources, contact forms, app sharing
- **Account Deletion** - Secure account and data deletion

### User Value

- **Centralized Management** - All account features in one place
- **Transparency** - Clear subscription status and trial progress
- **Control** - Comprehensive privacy and notification settings
- **Support** - Easy access to help and resources
- **Security** - Secure account management and deletion options

---

## 🎯 Core Features

### 1. Profile Header
- User avatar display (with fallback icon)
- Display name and email
- Subscription status badge
- Premium crown indicator for active subscribers
- Gradient card design matching web app

### 2. Statistics Summary
- Weekly meditation goal progress
- Current streak counter
- Achievement badges (unlocked/total)
- Quick stats (sessions, average minutes, growth)
- Blur overlay for unauthenticated users
- Navigation to detailed stats screen

### 3. Subscription Management
- Subscription status display (Active, Trial, Inactive)
- Trial progress bar with remaining days
- Subscription end date display
- Feature grid (Premium sounds, Offline, Custom sounds, Advanced stats)
- Upgrade CTA for non-subscribers
- Subscription change management
- Cancellation flow with confirmation

### 4. Account Section
- Account settings navigation (Email, Password, Security)
- Legal information (Terms, Privacy Policy, Data Protection)
- Privacy settings navigation
- Purchase restoration (IAP)
- Onboarding reset (Dev only)

### 5. Settings Section
- Push notifications toggle
- Apple HealthKit integration toggle
- Real-time preference updates
- Backend synchronization

### 6. Support Section
- App sharing functionality
- Help & Support navigation
- Sign out functionality
- Visual feedback for actions

### 7. Account Deletion
- Secure deletion confirmation
- Warning about active subscriptions
- Complete data removal
- Automatic sign out after deletion

---

## 🏗️ Architecture

### Technology Stack
- **Frontend:** React Native with TypeScript
- **State Management:** React Hooks (useState, useEffect, useContext)
- **Backend:** Supabase (Database, Auth, Storage)
- **IAP:** React Native IAP for purchase restoration
- **Storage:** AsyncStorage for local preferences
- **Navigation:** React Navigation

### Key Components
- `ProfileScreen` - Main profile screen container
- `ProfileHeader` - User profile display
- `StatsSummary` - Statistics overview
- `ProfileSubscriptionSection` - Subscription management
- `ProfileAccountSection` - Account navigation
- `ProfileSettingsSection` - App settings
- `ProfileSupportSection` - Support and sign out
- `ProfileDeleteAccountSection` - Account deletion

### Related Screens
- `AccountSettingsScreen` - Email/password management
- `PrivacySettingsScreen` - Privacy preferences
- `LegalScreen` - Legal documents hub
- `SupportScreen` - Support contact form

---

## 📱 Screens

1. **ProfileScreen** (`/profile`) - Main profile view with all sections
2. **AccountSettingsScreen** (`/account-settings`) - Email, password, security settings
3. **PrivacySettingsScreen** (`/privacy-settings`) - Privacy and data consent
4. **LegalScreen** (`/legal`) - Legal documents hub
5. **SupportScreen** (`/support`) - Support contact form

---

## 📂 Subscreens Structure

The Profile View contains multiple subscreens accessible via the Profile Account Section. Each subscreen has comprehensive documentation:

### Account Settings
**Location:** `Subscreens/Account Settings/`  
**Route:** `/account-settings`  
**Purpose:** Email, password, and security settings management

- Email update functionality
- Password change with strength validation
- Biometric login toggle
- Push notifications toggle
- Developer settings (dev only)

*See `Subscreens/Account Settings/` for complete documentation*

### Legal Pages
**Location:** `Subscreens/Legal Pages/`  
**Route:** `/legal`  
**Purpose:** Legal information hub with links to all legal documents

**Subscreens:**
- **Terms and Conditions** (`/legal/terms`) - Terms of service
- **App Privacy Policy** (`/legal/privacy-policy`) - App privacy policy
- **Data Privacy** (`/legal/data-privacy`) - GDPR compliance information
- **Impressum** (External) - Company information
- **Data Protection** (External) - Data protection information

*See `Subscreens/Legal Pages/` for complete documentation*

### Privacy Settings
**Location:** `Subscreens/Privacy Settings/`  
**Route:** `/privacy-settings`  
**Purpose:** Privacy preferences and data consent management

- Health data consent
- Analytics consent
- Marketing communication preferences
- Local storage of preferences

*See `Subscreens/Privacy Settings/` for complete documentation*

### Support
**Location:** `Subscreens/Support/`  
**Route:** `/support`  
**Purpose:** Support contact form and help resources

- Contact form with subject selection
- Quick help cards
- Alternative contact methods (email, phone)
- Form validation and submission

*See `Subscreens/Support/` for complete documentation*

---

## 🔄 User Flows

### Primary Flows
1. **View Profile** - Navigate to profile → View all sections → Interact with features
2. **Update Settings** - Profile → Settings → Toggle preferences → Save
3. **Manage Subscription** - Profile → Subscription → View status → Manage/Cancel
4. **Update Account** - Profile → Account → Settings → Update email/password
5. **Delete Account** - Profile → Delete Account → Confirm → Account removed

### Alternative Flows
- **Restore Purchases** - Account → Restore → IAP validation → Subscription activated
- **View Statistics** - Profile → Stats → View details → Detailed stats screen
- **Share App** - Support → Share → Native share dialog
- **Contact Support** - Support → Help → Contact form → Submit

---

## 🔐 Security Features

- Secure account deletion with confirmation
- Password validation (10+ characters)
- Email format validation
- Biometric authentication support
- Privacy consent management
- Secure IAP purchase restoration

---

## 📊 Integration Points

### Related Features
- **Authentication** - User session and profile data
- **Subscription** - Trial status, plan management, cancellation
- **Statistics** - Session tracking, goals, achievements
- **Notifications** - Push notification preferences
- **HealthKit** - Health data synchronization (iOS)
- **IAP** - Purchase restoration and validation

### External Services
- Supabase (User profiles, subscriptions, preferences)
- React Native IAP (Purchase restoration)
- Apple HealthKit (Health data sync)
- Native Share API (App sharing)

---

## 🧪 Testing Considerations

### Test Cases
- Profile data loading and display
- Subscription status display
- Settings toggle functionality
- Account settings updates
- Subscription cancellation flow
- Purchase restoration
- Account deletion
- Navigation between screens
- Error handling (network, validation)

### Edge Cases
- Network connectivity issues
- Invalid subscription data
- Missing user profile
- IAP restoration failures
- Account deletion with active subscription
- Privacy preference persistence

---

## 📚 Additional Resources

- [Supabase Documentation](https://supabase.com/docs)
- [React Native IAP](https://github.com/dooboolab/react-native-iap)
- [Apple HealthKit](https://developer.apple.com/documentation/healthkit)

---

## 📝 Notes

- Profile data is loaded from Supabase on screen mount
- Subscription status updates in real-time
- Settings preferences are synced with backend
- IAP restoration requires network connectivity
- Account deletion is permanent and irreversible
- Privacy preferences are stored locally in AsyncStorage
- All screens use consistent design system (PROFILE_RADIUS = 16)

---

*For detailed subscreen documentation, see `Subscreens/` folder*  
*Each subscreen contains: `README.md`, `requirements.md`, `components.md`, `services.md`, `user-flows.md`, `technical-spec.md`*
