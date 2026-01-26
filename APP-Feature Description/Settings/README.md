# Settings System - Feature Documentation

**Feature Name:** Settings & Preferences Management  
**Status:** ✅ Complete  
**Priority:** High  
**Last Updated:** 2025-01-27

## 📋 Feature Overview

The Settings system provides comprehensive user preference management and account configuration for the AWAVE app. It enables users to customize their account settings, privacy preferences, notification preferences, and manage their account security.

### Description

The Settings system is organized into multiple specialized screens and components:
- **Account Settings** - Email, password, and security preferences
- **Privacy Settings** - Data collection and marketing consent management
- **Notification Preferences** - Granular notification control
- **Developer Settings** - Development-only features (DEV mode)

### User Value

- **Account Control** - Users can update email and password independently
- **Privacy Management** - Granular control over data collection and marketing communications
- **Notification Customization** - Fine-grained control over notification types
- **Security Features** - Biometric login and push notification controls
- **Transparency** - Clear information about data usage and privacy practices

---

## 🎯 Core Features

### 1. Account Settings
- Email address update with validation
- Password change with strength requirements
- Biometric login toggle (Face ID / Touch ID)
- Push notifications toggle
- Developer settings (DEV mode only)

### 2. Privacy Settings
- **Health Data Consent** - Control Apple HealthKit integration
- **Analytics Consent** - Control analytics data collection
- **Marketing Consent** - Control marketing communications
- Persistent storage of privacy preferences
- Last updated timestamp tracking

### 3. Notification Preferences
- **General Notifications**
  - Push notifications toggle
  - Email notifications toggle
- **Content Notifications**
  - Trial reminders
  - Favorites updates
  - New content alerts
  - System updates
- Real-time preference synchronization
- Backend persistence via Supabase

### 4. Security Features
- Password strength validation (minimum 10 characters)
- Email format validation
- Biometric authentication support
- Secure preference storage

### 5. Developer Settings (DEV Mode Only)
- Paywall bypass toggle
- Development-only features
- Hidden from production builds

---

## 🏗️ Architecture

### Technology Stack
- **Backend:** Supabase (notification preferences, user profiles)
- **Storage:** AsyncStorage (local preferences, dev settings)
- **State Management:** React Context API, Custom Hooks
- **Validation:** Client-side validation with real-time feedback

### Key Components
- `AccountSettingsScreen` - Main account settings interface
- `PrivacySettingsScreen` - Privacy consent management
- `NotificationPreferencesScreen` - Notification preference control
- `ProfileSettingsSection` - Reusable settings section component
- `ProfileAccountSection` - Account navigation section
- `NotificationService` - Notification preference management
- `DevSettingsStorage` - Developer settings persistence

---

## 📱 Screens

1. **AccountSettingsScreen** (`/account-settings`) - Account and security settings
2. **PrivacySettingsScreen** (`/privacy-settings`) - Privacy consent management
3. **NotificationPreferencesScreen** (`/notification-preferences`) - Notification preferences
4. **ProfileScreen** (`/profile`) - Main profile screen with settings sections

---

## 🔄 User Flows

### Primary Flows
1. **Update Email Flow** - Navigate → Enter New Email → Validate → Confirm → Update
2. **Change Password Flow** - Navigate → Enter New Password → Validate → Update
3. **Privacy Consent Flow** - Navigate → Review Options → Toggle Consents → Save
4. **Notification Preferences Flow** - Navigate → Toggle Preferences → Auto-save

### Alternative Flows
- **Biometric Setup** - Toggle → System Prompt → Enable/Disable
- **Privacy Reset** - Clear preferences → Restore defaults
- **Notification Sync** - Preference change → Backend sync → Confirmation

---

## 🔐 Security Features

- Password strength validation (10+ characters)
- Email format validation
- Secure token storage (via Supabase)
- Biometric authentication integration
- Privacy preference encryption (AsyncStorage)

---

## 📊 Integration Points

### Related Features
- **Authentication** - Email/password update integration
- **Profile** - User profile data synchronization
- **Notifications** - Notification preference enforcement
- **Subscription** - Trial reminder notifications
- **HealthKit** - Health data consent management

### External Services
- Supabase (notification preferences, user profiles)
- AsyncStorage (local preferences, dev settings)
- Native Biometric APIs (Face ID / Touch ID)
- Push Notification Service (notification delivery)

---

## 🧪 Testing Considerations

### Test Cases
- Email update with validation
- Password change with strength requirements
- Privacy consent toggles
- Notification preference updates
- Biometric toggle functionality
- Developer settings (DEV mode)
- Preference persistence across app restarts
- Backend synchronization

### Edge Cases
- Invalid email format
- Weak password attempts
- Network failures during updates
- Concurrent preference changes
- Missing user authentication
- Expired sessions during updates

---

## 📚 Additional Resources

- [Supabase Documentation](https://supabase.com/docs)
- [React Native AsyncStorage](https://react-native-async-storage.github.io/async-storage/)
- [React Native Biometrics](https://github.com/SelfLender/react-native-biometrics)

---

## 📝 Notes

- Privacy preferences are stored locally in AsyncStorage
- Notification preferences are synced with Supabase backend
- Developer settings are only available in `__DEV__` mode
- Password minimum length is 10 characters
- Email updates require confirmation dialog
- Notification preferences use optimistic updates

---

*For detailed technical specifications, see `technical-spec.md`*  
*For user flow diagrams, see `user-flows.md`*  
*For component details, see `components.md`*  
*For service dependencies, see `services.md`*
