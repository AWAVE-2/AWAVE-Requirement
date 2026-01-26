# Subscription & Payment System - Feature Documentation

**Feature Name:** Subscription & Payment Management  
**Status:** ✅ Complete  
**Priority:** High  
**Last Updated:** 2025-01-27

## 📋 Feature Overview

The Subscription & Payment system provides comprehensive subscription management for the AWAVE app. It supports In-App Purchases (IAP) through Apple App Store and Google Play Store, trial subscriptions, plan management, payment history, and subscription lifecycle management.

### Description

The subscription system is built on:
- **In-App Purchase (IAP)** integration with native store platforms
- **Supabase backend** for subscription data and receipt validation
- **Trial management** with 7-day free trials
- **Plan management** with weekly, monthly, and annual options
- **Payment processing** via App Store and Play Store
- **Receipt validation** through Supabase Edge Functions

### User Value

- **Seamless purchasing** - Native store integration for secure payments
- **Flexible plans** - Multiple subscription periods (weekly, monthly, annual)
- **Trial experience** - 7-day free trial to explore premium features
- **Transparency** - Clear pricing, payment history, and subscription status
- **Convenience** - Automatic renewals and easy plan management
- **Trust elements** - Money-back guarantee, scientific proof, value propositions

---

## 🎯 Core Features

### 1. Subscription Plans
- **Weekly Plan** - €3.99/week
- **Monthly Plan** - €11.99/month (30% savings vs weekly)
- **Annual Plan** - €79.99/year (61% savings vs weekly)
- Plan comparison with features
- Daily price calculation
- Savings percentage display

### 2. In-App Purchase (IAP) Integration
- **Apple App Store** - Native iOS purchase flow
- **Google Play Store** - Native Android purchase flow
- Product fetching from stores
- Purchase initiation and completion
- Receipt validation via backend
- Purchase restoration

### 3. Trial Management
- **7-day free trial** - Automatic trial creation on signup
- Trial status tracking
- Days remaining calculation
- Trial expiration reminders
- Trial-to-paid conversion

### 4. Subscription Management
- **View subscription** - Current plan, status, billing dates
- **Change plan** - Upgrade/downgrade between plans
- **Cancel subscription** - Cancel at period end or immediately
- **Reactivate subscription** - Restore cancelled subscriptions
- **Payment history** - View past transactions

### 5. Discount System
- **Shake discount** - 20% additional discount via device shake
- **Downsell offer** - 30% additional discount on exit intent
- Discount persistence across sessions
- Discount application to all plans

### 6. Receipt Validation
- **Backend validation** - Supabase Edge Function validates receipts
- **Apple receipt validation** - Production and sandbox support
- **Google receipt validation** - Play Developer API integration
- **Receipt storage** - Secure storage in database
- **Subscription sync** - Automatic subscription updates

---

## 🏗️ Architecture

### Technology Stack
- **IAP Libraries:**
  - `react-native-iap` - Cross-platform IAP integration
- **Backend:** Supabase
  - Database tables: `subscriptions`, `payments`, `iap_receipts`
  - Edge Functions: `validate-iap-receipt`
- **Storage:** AsyncStorage for local caching
- **State Management:** React Hooks and Context API

### Key Components
- `SubscribeScreen` - Main subscription selection screen
- `DownsellScreen` - Exit-intent discount offer
- `SubscriptionCard` - Plan display component
- `IAPService` - IAP provider abstraction
- `SubscriptionService` - Backend subscription operations
- `useSubscriptionForm` - Subscription form logic hook

---

## 📱 Screens

1. **SubscribeScreen** (`/subscribe`) - Main subscription plan selection
2. **DownsellScreen** (`/downsell`) - Exit-intent discount offer with countdown
3. **ProfileScreen** (`/profile`) - Subscription management section
4. **AccountSettingsScreen** (`/account-settings`) - Subscription settings

---

## 🔄 User Flows

### Primary Flows
1. **Subscribe Flow** - Plan Selection → IAP Purchase → Receipt Validation → Subscription Active
2. **Trial Flow** - Signup → Trial Creation → Trial Reminders → Conversion
3. **Plan Change Flow** - View Current → Select New Plan → Confirm → Update
4. **Cancel Flow** - View Subscription → Cancel → Confirm → Status Update

### Alternative Flows
- **Downsell Flow** - Exit Intent → Discount Offer → Purchase
- **Restore Purchases** - Settings → Restore → Validation → Sync
- **Discount Activation** - Shake Device → Discount Applied → Purchase

---

## 💳 Payment Processing

### Payment Methods
- **Apple App Store** - Native iOS payments
- **Google Play Store** - Native Android payments
- **No credit card required** - All payments through store accounts

### Receipt Validation
- Receipts validated server-side via Supabase Edge Function
- Apple: Production and sandbox environment support
- Google: Play Developer API integration
- Automatic subscription status updates

---

## 📊 Integration Points

### Related Features
- **Authentication** - Trial creation after signup
- **Profile** - Subscription status display
- **Onboarding** - Plan selection during registration
- **Audio Library** - Premium feature access control

### External Services
- Apple App Store Connect (IAP products)
- Google Play Console (IAP products)
- Supabase (database and Edge Functions)
- App Store / Play Store (payment processing)

---

## 🧪 Testing Considerations

### Test Cases
- IAP purchase flow (iOS and Android)
- Receipt validation
- Trial creation and expiration
- Plan changes
- Subscription cancellation
- Purchase restoration
- Discount application
- Payment history retrieval

### Edge Cases
- Network failures during purchase
- Invalid receipts
- Expired trials
- Store connectivity issues
- Multiple purchase attempts
- Restore on new device

---

## 📚 Additional Resources

- [React Native IAP Documentation](https://github.com/dooboolab/react-native-iap)
- [Apple In-App Purchase Guide](https://developer.apple.com/in-app-purchase/)
- [Google Play Billing](https://developer.android.com/google/play/billing)
- [Supabase Edge Functions](https://supabase.com/docs/guides/functions)

---

## 📝 Notes

- IAP product IDs must be configured in App Store Connect and Play Console
- Receipt validation requires backend configuration (shared secrets, service accounts)
- Trial subscriptions are automatically created on user signup
- Discounts are stored locally and persist across sessions
- Subscription status is synced with backend on app launch
- All payments are processed through native store platforms

---

*For detailed technical specifications, see `technical-spec.md`*  
*For user flow diagrams, see `user-flows.md`*  
*For component details, see `components.md`*  
*For service dependencies, see `services.md`*
