# Legal & Privacy System - Feature Documentation

**Feature Name:** Legal & Privacy Management  
**Status:** ✅ Complete  
**Priority:** High  
**Last Updated:** 2025-01-27

## 📋 Feature Overview

The Legal & Privacy system provides comprehensive legal information, privacy policy management, GDPR compliance, and user privacy preference controls for the AWAVE app. It ensures transparency, regulatory compliance, and user control over their personal data.

### Description

The Legal & Privacy system includes:
- **Legal Information Hub** - Centralized access to all legal documents
- **Terms & Conditions** - Complete terms of service documentation
- **Privacy Policy** - App-specific privacy policy and data handling
- **GDPR Compliance** - Comprehensive GDPR-compliant data privacy information
- **Privacy Settings** - User-controlled privacy preferences
- **External Legal Links** - Links to company legal pages (Impressum, Datenschutz)

### User Value

- **Transparency** - Clear access to all legal and privacy information
- **Control** - User-managed privacy preferences for data collection
- **Compliance** - GDPR-compliant data handling and user rights
- **Trust** - Easy access to legal information builds user confidence
- **Flexibility** - Granular control over health data, analytics, and marketing consent

---

## 🎯 Core Features

### 1. Legal Information Hub
- Central navigation to all legal documents
- Internal navigation to Terms, Privacy Policy, and GDPR information
- External links to company legal pages
- Consistent UI with card-based navigation

### 2. Terms & Conditions
- Complete terms of service documentation
- 11 sections covering all aspects of service usage
- Last updated date display
- Scrollable content with proper formatting

### 3. Privacy Policy
- App-specific privacy policy
- 12 sections covering data collection, processing, and rights
- Contact information for privacy inquiries
- Last updated date tracking

### 4. GDPR Compliance (Data Privacy)
- Comprehensive GDPR-compliant documentation
- 12 accordion sections covering all GDPR requirements
- Interactive privacy preference controls
- Real-time preference saving
- Controller information, data collection, user rights, and more

### 5. Privacy Settings
- User-controlled privacy preferences
- Health data consent management
- Analytics consent management
- Marketing communication preferences
- Persistent storage of user choices

### 6. External Legal Links
- Impressum (Company legal information)
- Datenschutz (Data protection statement)
- Opens in external browser
- URL validation before opening

---

## 🏗️ Architecture

### Technology Stack
- **Storage:** AsyncStorage for privacy preferences
- **Navigation:** React Navigation Stack Navigator
- **UI Components:** Custom Accordion, EnhancedCard, UnifiedHeader
- **External Links:** React Native Linking API
- **State Management:** React useState/useEffect hooks

### Key Components
- `LegalScreen` - Main legal information hub
- `TermsScreen` - Terms and conditions display
- `PrivacyPolicyScreen` - Privacy policy display
- `DataPrivacyScreen` - GDPR compliance with preferences
- `PrivacySettingsScreen` - Privacy preference management
- `Accordion` - Collapsible content sections
- `AWAVEStorage` - Privacy preferences storage service

---

## 📱 Screens

1. **LegalScreen** (`/profile/legal`) - Main legal information hub
2. **TermsScreen** (`/profile/legal/terms`) - Terms and conditions
3. **PrivacyPolicyScreen** (`/profile/legal/privacy-policy`) - Privacy policy
4. **DataPrivacyScreen** (`/profile/legal/data-privacy`) - GDPR compliance
5. **PrivacySettingsScreen** (`/profile/privacy-settings`) - Privacy preferences

---

## 🔄 User Flows

### Primary Flows
1. **Access Legal Information** - Profile → Legal → Select Document
2. **View Terms** - Legal → Terms → Read Content
3. **View Privacy Policy** - Legal → Privacy Policy → Read Content
4. **Manage Privacy Preferences** - Profile → Privacy Settings → Adjust → Save
5. **Review GDPR Information** - Legal → Data Privacy → Read Sections → Adjust Preferences

### Alternative Flows
- **External Legal Pages** - Legal → Impressum/Datenschutz → External Browser
- **Signup Terms Acceptance** - Signup → Terms Links → View Terms/Privacy
- **Quick Privacy Access** - Profile → Privacy Settings → Quick Access

---

## 🔐 Privacy Features

- Privacy preference storage (health data, analytics, marketing)
- GDPR-compliant data privacy documentation
- User rights information (access, deletion, portability)
- Data collection transparency
- Third-party service disclosure
- Legal basis for data processing
- Data storage and retention information

---

## 📊 Integration Points

### Related Features
- **Profile** - Navigation entry point for legal/privacy screens
- **Authentication** - Terms acceptance during signup
- **Settings** - Privacy settings integration
- **Onboarding** - Privacy information during onboarding (future)

### External Services
- Company website (awave-app.de) for Impressum and Datenschutz
- AsyncStorage for local preference storage
- No external API dependencies

---

## 🧪 Testing Considerations

### Test Cases
- Navigation to all legal screens
- Privacy preference saving and loading
- External link opening
- Accordion expand/collapse
- Terms acceptance during signup
- Preference persistence across app restarts

### Edge Cases
- Network issues when opening external links
- AsyncStorage failures
- Missing translation keys
- Invalid preference data

---

## 📚 Additional Resources

- [GDPR Official Website](https://gdpr.eu/)
- [React Native Linking API](https://reactnative.dev/docs/linking)
- [AsyncStorage Documentation](https://react-native-async-storage.github.io/async-storage/)

---

## 📝 Notes

- Privacy preferences default to `true` (opt-in by default)
- All legal content is in German (de)
- External links open in default browser
- Privacy preferences are stored locally only
- GDPR documentation is comprehensive and up-to-date
- Terms and Privacy Policy include last updated dates

---

*For detailed technical specifications, see `technical-spec.md`*  
*For user flow diagrams, see `user-flows.md`*  
*For component details, see `components.md`*  
*For service dependencies, see `services.md`*
