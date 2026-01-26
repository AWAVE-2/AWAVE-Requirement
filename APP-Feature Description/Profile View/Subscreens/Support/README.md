# Support - Feature Documentation

**Feature Name:** Support & Help Center  
**Status:** ✅ Complete  
**Priority:** High  
**Last Updated:** 2025-01-27

## 📋 Feature Overview

The Support screen provides comprehensive support functionality, including a contact form, quick help resources, and alternative contact methods. Users can submit support requests, access quick help, and contact support via email or phone.

### Description

The Support system provides:
- **Contact Form** - Submit support requests with subject selection
- **Quick Help** - Quick access to help resources (Getting Started, FAQ)
- **Alternative Contact** - Email and phone support options
- **Form Validation** - Email format and required field validation
- **XSS Prevention** - Input sanitization

### User Value

- **Accessibility** - Multiple ways to get help
- **Convenience** - Easy-to-use contact form
- **Quick Help** - Immediate access to common resources
- **Direct Contact** - Email and phone support options

---

## 🎯 Core Features

### 1. Contact Form
- Name input field
- Email input field with validation
- Subject picker (Technical, Account, Billing, Feature, Other)
- Message textarea (max 1000 characters)
- Character counter
- Submit button with loading state
- Form validation
- Success confirmation

### 2. Quick Help Section
- Getting Started card
- FAQ card
- Navigation to help resources

### 3. Alternative Contact Methods
- Email support card (info@awave-app.de)
- Phone support card (+49 176 50203275)
- Direct contact via native apps

### 4. Form Validation
- Required field validation
- Email format validation
- XSS prevention (script tag removal)
- Character limit enforcement

---

## 🏗️ Architecture

### Technology Stack
- **Frontend:** React Native with TypeScript
- **State Management:** React Hooks (useState)
- **Linking:** React Native Linking API for email/phone
- **UI Components:** EnhancedCard, TextInput, AnimatedButton

### Key Components
- `SupportScreen` - Main support screen
- `EnhancedCard` - Card containers
- `TextInput` - Form inputs
- `AnimatedButton` - Action buttons

---

## 📱 Screen

**SupportScreen** (`/support`) - Main support screen

**Navigation:** Accessible from Profile → Support → Help & Support

---

## 🔄 User Flows

### Primary Flows
1. **Submit Contact Form** - Fill form → Validate → Submit → Success
2. **Quick Help** - Click help card → Navigate to resource
3. **Email Support** - Click email card → Open email app
4. **Phone Support** - Click phone card → Open phone app

---

## 🔐 Security Features

- XSS prevention (script tag removal)
- Email format validation
- Input sanitization
- Character limit enforcement

---

## 📊 Integration Points

### Related Features
- **Profile** - Navigation from Profile Support Section
- **Linking** - Native app integration for email/phone

### External Services
- Email client (mailto: links)
- Phone app (tel: links)
- Support backend (form submission - to be implemented)

---

## 🧪 Testing Considerations

### Test Cases
- Form validation
- Email format validation
- Subject selection
- Form submission
- Email/phone link opening
- XSS prevention
- Character limit enforcement

### Edge Cases
- Invalid email format
- Missing required fields
- Network connectivity issues
- Email/phone app not available
- Form submission failures

---

## 📚 Additional Resources

- [React Native Linking](https://reactnative.dev/docs/linking)
- [XSS Prevention](https://owasp.org/www-community/attacks/xss/)

---

## 📝 Notes

- Form submission currently simulated (to be connected to backend)
- Email: info@awave-app.de
- Phone: +49 176 50203275
- Character limit: 1000 characters for message
- XSS prevention: Removes script tags from input
- Consistent design system (PROFILE_RADIUS = 16)

---

*For detailed technical specifications, see `technical-spec.md`*  
*For user flow diagrams, see `user-flows.md`*  
*For component details, see `components.md`*  
*For service dependencies, see `services.md`*
