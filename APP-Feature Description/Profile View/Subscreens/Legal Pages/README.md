# Legal Pages - Feature Documentation

**Feature Name:** Legal Information Hub  
**Status:** ✅ Complete  
**Priority:** High  
**Last Updated:** 2025-01-27

## 📋 Feature Overview

The Legal Pages system provides a centralized hub for accessing all legal documents and compliance information. It includes internal screens for Terms and Conditions, App Privacy Policy, and Data Privacy, as well as external links to Impressum and Data Protection information.

### Description

The Legal Pages system provides:
- **Legal Hub Screen** - Central navigation to all legal documents
- **Terms and Conditions** - Terms of service (internal screen)
- **App Privacy Policy** - App privacy policy (internal screen)
- **Data Privacy** - GDPR compliance information (internal screen)
- **Impressum** - Company information (external link)
- **Data Protection** - Data protection information (external link)

### User Value

- **Transparency** - Easy access to all legal information
- **Compliance** - GDPR and legal compliance information
- **Convenience** - Centralized location for legal documents
- **Trust** - Clear presentation of legal terms and privacy policies

---

## 🎯 Core Features

### 1. Legal Hub Screen
- Central navigation to all legal documents
- Internal navigation to Terms, Privacy Policy, Data Privacy
- External links to Impressum and Data Protection
- Consistent card-based design
- Icon-based visual identification

### 2. Terms and Conditions
- Internal screen with terms of service
- Scrollable content
- Consistent styling

### 3. App Privacy Policy
- Internal screen with app privacy policy
- Scrollable content
- Consistent styling

### 4. Data Privacy (GDPR)
- Internal screen with GDPR compliance information
- Scrollable content
- Consistent styling

### 5. External Links
- **Impressum** - Opens in browser (`https://www.awave-app.de/impressum`)
- **Data Protection** - Opens in browser (`https://www.awave-app.de/datenschutz`)

---

## 🏗️ Architecture

### Technology Stack
- **Frontend:** React Native with TypeScript
- **Navigation:** React Navigation
- **Linking:** React Native Linking API for external URLs
- **UI Components:** EnhancedCard, Icon, LinearGradient

### Key Components
- `LegalScreen` - Main legal hub screen
- `TermsAndConditionsScreen` - Terms of service (if implemented)
- `AppPrivacyPolicyScreen` - Privacy policy (if implemented)
- `DataPrivacyScreen` - GDPR information

---

## 📱 Screens

1. **LegalScreen** (`/legal`) - Legal hub with navigation to all documents
2. **TermsAndConditions** (`/legal/terms`) - Terms of service (internal)
3. **AppPrivacyPolicy** (`/legal/privacy-policy`) - Privacy policy (internal)
4. **DataPrivacy** (`/legal/data-privacy`) - GDPR compliance (internal)

---

## 🔄 User Flows

### Primary Flows
1. **View Legal Hub** - Profile → Account → Rechtliches → Legal Hub
2. **View Terms** - Legal Hub → Terms and Conditions → View content
3. **View Privacy Policy** - Legal Hub → App Privacy Policy → View content
4. **View Data Privacy** - Legal Hub → Data Privacy → View content
5. **View Impressum** - Legal Hub → Impressum → Opens in browser
6. **View Data Protection** - Legal Hub → Data Protection → Opens in browser

---

## 🔐 Security Features

- Secure external link handling
- URL validation before opening
- Safe navigation between screens
- No sensitive data exposure

---

## 📊 Integration Points

### Related Features
- **Profile** - Navigation from Profile Account Section
- **Navigation** - React Navigation routing

### External Services
- Web browser (for external links)
- Company website (awave-app.de)

---

## 🧪 Testing Considerations

### Test Cases
- Navigation to legal hub
- Internal screen navigation
- External link opening
- URL validation
- Error handling for broken links

### Edge Cases
- Network connectivity issues
- Invalid URLs
- Browser not available
- Deep link handling

---

## 📚 Additional Resources

- [React Native Linking](https://reactnative.dev/docs/linking)
- [GDPR Compliance](https://gdpr.eu/)

---

## 📝 Notes

- External links open in default browser
- Internal screens use consistent styling
- All legal documents accessible from one hub
- Consistent design system (PROFILE_RADIUS = 16)

---

*For detailed technical specifications, see `technical-spec.md`*  
*For user flow diagrams, see `user-flows.md`*  
*For component details, see `components.md`*  
*For service dependencies, see `services.md`*
