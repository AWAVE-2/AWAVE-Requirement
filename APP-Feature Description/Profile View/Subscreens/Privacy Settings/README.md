# Privacy Settings - Feature Documentation

**Feature Name:** Privacy Settings & Data Consent  
**Status:** ✅ Complete  
**Priority:** High  
**Last Updated:** 2025-01-27

## 📋 Feature Overview

The Privacy Settings screen provides comprehensive privacy preference management, allowing users to control data collection, analytics, and marketing communications. All preferences are stored locally in AsyncStorage and can be synced with backend if needed.

### Description

The Privacy Settings system provides:
- **Health Data Consent** - Toggle for health data collection consent
- **Analytics Consent** - Toggle for analytics data collection
- **Marketing Consent** - Toggle for marketing communications
- **Local Storage** - Preferences stored in AsyncStorage
- **Save Functionality** - Save preferences with confirmation

### User Value

- **Control** - Users control their data privacy preferences
- **Transparency** - Clear descriptions of what each preference means
- **Compliance** - GDPR-compliant consent management
- **Convenience** - Easy-to-use interface for privacy settings

---

## 🎯 Core Features

### 1. Health Data Consent
- Toggle for health data collection
- Description of what health data is collected
- Stored in AsyncStorage
- Default: enabled

### 2. Analytics Consent
- Toggle for analytics data collection
- Description of analytics usage
- Stored in AsyncStorage
- Default: enabled

### 3. Marketing Consent
- Toggle for marketing communications
- Description of marketing usage
- Stored in AsyncStorage
- Default: enabled

### 4. Save Preferences
- Save button to persist preferences
- Success confirmation alert
- Error handling
- Preferences stored in AsyncStorage

---

## 🏗️ Architecture

### Technology Stack
- **Frontend:** React Native with TypeScript
- **State Management:** React Hooks (useState, useEffect)
- **Storage:** AsyncStorage for local preferences
- **UI Components:** EnhancedCard, Checkbox, AnimatedButton

### Key Components
- `PrivacySettingsScreen` - Main privacy settings screen
- `Checkbox` - Custom checkbox component
- `EnhancedCard` - Card containers

---

## 📱 Screen

**PrivacySettingsScreen** (`/privacy-settings`) - Main privacy settings screen

**Navigation:** Accessible from Profile → Account → Datenschutz-Einstellungen

---

## 🔄 User Flows

### Primary Flows
1. **View Privacy Settings** - Navigate to screen → View preferences → Toggle preferences → Save
2. **Update Preferences** - Toggle consent → Save → Confirmation
3. **Load Preferences** - Screen loads → Preferences loaded from AsyncStorage → Display current state

---

## 🔐 Security Features

- Local storage of preferences
- Secure AsyncStorage usage
- No sensitive data exposure
- GDPR-compliant consent management

---

## 📊 Integration Points

### Related Features
- **Profile** - Navigation from Profile Account Section
- **AsyncStorage** - Local preference storage

### External Services
- None (local storage only)

---

## 🧪 Testing Considerations

### Test Cases
- Preference loading from AsyncStorage
- Toggle functionality
- Save functionality
- Preference persistence
- Error handling

### Edge Cases
- AsyncStorage read failures
- AsyncStorage write failures
- Missing preferences (defaults)
- Concurrent preference updates

---

## 📚 Additional Resources

- [React Native AsyncStorage](https://react-native-async-storage.github.io/async-storage/)
- [GDPR Compliance](https://gdpr.eu/)

---

## 📝 Notes

- Preferences stored locally in AsyncStorage
- Key: `awavePrivacyPreferences`
- Default preferences: all enabled
- Save confirmation via Alert
- Consistent design system (PROFILE_RADIUS = 16)

---

*For detailed technical specifications, see `technical-spec.md`*  
*For user flow diagrams, see `user-flows.md`*  
*For component details, see `components.md`*  
*For service dependencies, see `services.md`*
