# Notifications System - Feature Documentation

**Feature Name:** Notifications & Preferences Management  
**Status:** ✅ Complete  
**Priority:** High  
**Last Updated:** 2025-01-27

## 📋 Feature Overview

The Notifications system provides comprehensive notification preference management and automated trial reminder notifications for the AWAVE app. It enables users to control their notification preferences across multiple categories and automatically sends trial expiration reminders to help retain users.

### Description

The notifications system is built on Supabase and provides:
- **Notification preference management** - Granular control over notification types
- **Trial reminder notifications** - Automated reminders 3 days before trial expiration
- **Preference persistence** - User preferences stored in database and synced across devices
- **Notification logging** - Complete audit trail of sent notifications
- **Default preferences** - Automatic creation of sensible defaults for new users

### User Value

- **Control** - Users can customize which notifications they receive
- **Engagement** - Trial reminders help users stay engaged before subscription expires
- **Transparency** - Clear descriptions of each notification type
- **Convenience** - Preferences sync across devices
- **Privacy** - Users can opt-out of marketing and non-essential notifications

---

## 🎯 Core Features

### 1. Notification Preferences Management
- Push notifications toggle
- Email notifications toggle
- Trial reminder notifications
- Favorites updates notifications
- New content notifications
- System updates notifications
- Granular preference control per category

### 2. Trial Reminder System
- Automatic detection of trial expiration (3 days before)
- Preference-based reminder sending
- Duplicate prevention (one reminder per trial)
- Notification logging for audit trail
- Integration with subscription system

### 3. Preference Persistence
- Database-backed preferences (Supabase)
- Local caching for offline access
- Automatic sync on app launch
- Default preference creation for new users

### 4. Notification Logging
- Complete audit trail of sent notifications
- Notification type tracking
- Timestamp recording
- User-specific notification history

### 5. User Interface
- Dedicated notification preferences screen
- Quick toggle in account settings
- Profile screen integration
- Clear descriptions for each preference type

---

## 🏗️ Architecture

### Technology Stack
- **Backend:** Supabase (notification_preferences, notification_logs tables)
- **Storage:** AsyncStorage for local caching
- **State Management:** React Context API, Custom Hooks
- **UI Components:** React Native Switch, ScrollView, SafeAreaView

### Key Components
- `NotificationService` - Core notification logic and preference management
- `NotificationPreferencesScreen` - Dedicated preferences UI
- `useUserProfile` - Hook for notification preference management
- `AuthContext` - Trial reminder checking on authentication

---

## 📱 Screens

1. **NotificationPreferencesScreen** (`/notification-preferences`) - Main notification settings screen
2. **AccountSettingsScreen** (`/account-settings`) - Quick push notification toggle
3. **ProfileScreen** (`/profile`) - Notification preferences integration

---

## 🔄 User Flows

### Primary Flows
1. **View Preferences** - Navigate to settings → View all notification options
2. **Update Preferences** - Toggle switch → Save automatically → Confirmation
3. **Trial Reminder** - Trial expires in 3 days → Automatic check → Send reminder (if enabled)
4. **Default Setup** - New user → Default preferences created automatically

### Alternative Flows
- **Quick Toggle** - Profile screen → Toggle push notifications → Save
- **Preference Sync** - App launch → Load preferences from database → Update UI

---

## 🔐 Security Features

- User-specific preferences (RLS policies)
- Secure database storage
- Preference validation
- Audit logging for compliance

---

## 📊 Integration Points

### Related Features
- **Authentication** - Trial reminder checking on sign-in
- **Subscription** - Trial status checking for reminders
- **Profile** - Preference display and quick toggle
- **Account Settings** - Notification preference management

### External Services
- Supabase Database (preferences and logs)
- AsyncStorage (local caching)
- Subscription Service (trial status)

---

## 🧪 Testing Considerations

### Test Cases
- Preference loading and saving
- Trial reminder detection and sending
- Default preference creation
- Preference sync across devices
- Duplicate reminder prevention
- Error handling (network, database)

### Edge Cases
- Network connectivity issues
- Missing preferences (new users)
- Trial expiration edge cases
- Concurrent preference updates
- Database errors

---

## 📚 Additional Resources

- [Supabase Database Documentation](https://supabase.com/docs/guides/database)
- [React Native AsyncStorage](https://react-native-async-storage.github.io/async-storage/)

---

## 📝 Notes

- Trial reminders are sent 3 days before expiration
- Default preferences enable all notification types except marketing
- Preferences are automatically created for new users
- Trial reminder is sent only once per trial period
- Notification logs are stored for audit and analytics purposes

---

*For detailed technical specifications, see `technical-spec.md`*  
*For user flow diagrams, see `user-flows.md`*  
*For component details, see `components.md`*  
*For service dependencies, see `services.md`*
