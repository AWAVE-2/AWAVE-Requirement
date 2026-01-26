# Account Settings - Feature Documentation

**Feature Name:** Account Settings & Security  
**Status:** ✅ Complete  
**Priority:** High  
**Last Updated:** 2025-01-27

## 📋 Feature Overview

The Account Settings screen provides comprehensive account management functionality, allowing users to update their email address, change their password, and configure security settings including biometric login and push notifications.

### Description

The Account Settings system provides:
- **Email Management** - Update email address with validation and confirmation
- **Password Management** - Change password with strength validation (10+ characters)
- **Security Settings** - Biometric login toggle and push notification preferences
- **Developer Settings** - Paywall bypass toggle (dev mode only)

### User Value

- **Account Control** - Users can manage their account credentials independently
- **Security** - Strong password requirements and biometric authentication options
- **Convenience** - Easy-to-use interface for updating account information
- **Transparency** - Clear validation feedback and confirmation dialogs

---

## 🎯 Core Features

### 1. Email Management
- Current email display (read-only)
- New email input with format validation
- Email update with confirmation dialog
- Success/error feedback via toast notifications
- Real-time email format validation

### 2. Password Management
- New password input with visibility toggle
- Password strength validation (minimum 10 characters)
- Password update functionality
- Secure password entry with show/hide toggle
- Success/error feedback via toast notifications

### 3. Security Settings
- **Biometric Login** - Toggle biometric authentication (Face ID/Touch ID)
- **Push Notifications** - Toggle push notification preferences
- Real-time preference updates
- Visual feedback for toggle states

### 4. Developer Settings (Dev Only)
- Paywall bypass toggle
- Development-only features
- Hidden in production builds

---

## 🏗️ Architecture

### Technology Stack
- **Frontend:** React Native with TypeScript
- **State Management:** React Hooks (useState)
- **Backend:** Supabase Auth API
- **Storage:** AsyncStorage for local preferences
- **UI Components:** EnhancedCard, Input, Switch, ConfirmDialog, Toast

### Key Components
- `AccountSettingsScreen` - Main account settings screen
- `Input` - Form input component
- `EnhancedCard` - Card container with gradient variants
- `ConfirmDialog` - Confirmation dialog for email updates
- `Toast` - Success/error feedback system

---

## 📱 Screen

**AccountSettingsScreen** (`/account-settings`) - Main account settings screen

**Navigation:** Accessible from Profile → Account → Kontoeinstellungen

---

## 🔄 User Flows

### Primary Flows
1. **Update Email** - Enter new email → Validate → Confirm → Update → Success
2. **Change Password** - Enter new password → Validate → Update → Success
3. **Toggle Biometric** - Toggle switch → Update preference → Feedback
4. **Toggle Notifications** - Toggle switch → Update preference → Feedback

### Alternative Flows
- **Validation Errors** - Invalid input → Show error → Retry
- **Network Errors** - Update fails → Show error → Retry
- **Confirmation Cancellation** - Cancel confirmation → Return to form

---

## 🔐 Security Features

- Password validation (10+ characters minimum)
- Email format validation
- Secure password input with visibility toggle
- Confirmation dialog for email changes
- Biometric authentication support
- Secure backend API integration

---

## 📊 Integration Points

### Related Features
- **Authentication** - Email/password update via AuthContext
- **User Profile** - Profile data display
- **Notifications** - Push notification preference management
- **HealthKit** - HealthKit integration toggle

### External Services
- Supabase Auth (email/password updates)
- AsyncStorage (local preference storage)

---

## 🧪 Testing Considerations

### Test Cases
- Email format validation
- Password strength validation
- Email update flow
- Password update flow
- Biometric toggle functionality
- Notification toggle functionality
- Error handling (network, validation)
- Confirmation dialog interactions

### Edge Cases
- Invalid email format
- Weak password (< 10 characters)
- Network connectivity issues
- Backend update failures
- Concurrent update attempts

---

## 📚 Additional Resources

- [Supabase Auth Documentation](https://supabase.com/docs/guides/auth)
- [React Native AsyncStorage](https://react-native-async-storage.github.io/async-storage/)

---

## 📝 Notes

- Email updates require confirmation dialog
- Password must be at least 10 characters
- Biometric toggle provides immediate feedback
- Developer settings only visible in __DEV__ mode
- All updates use toast notifications for feedback
- Consistent design system (PROFILE_RADIUS = 16)

---

*For detailed technical specifications, see `technical-spec.md`*  
*For user flow diagrams, see `user-flows.md`*  
*For component details, see `components.md`*  
*For service dependencies, see `services.md`*
