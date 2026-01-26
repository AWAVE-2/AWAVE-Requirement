# Sales Screens - Feature Documentation

**Feature Name:** Sales Screens & Subscription Offers  
**Status:** ✅ Complete  
**Priority:** High  
**Last Updated:** 2025-01-27

## 📋 Feature Overview

The Sales Screens system provides conversion-focused subscription sales experiences for the AWAVE app. It includes the main subscription selection screen and an exit-intent downsell screen with time-limited offers, designed to maximize subscription conversions through strategic pricing, trust elements, and urgency tactics.

### Description

The sales screens system is built on:
- **SubscribeScreen** - Main subscription plan selection with trust elements
- **DownsellScreen** - Exit-intent discount offer with countdown timer
- **Trust elements** - Money-back guarantee, scientific proof, value propositions
- **Discount system** - Shake-to-activate discount and exit-intent offers
- **IAP integration** - Native store purchase flow
- **Conversion optimization** - Strategic pricing, urgency, and objection handling

### User Value

- **Clear pricing** - Transparent plan comparison with daily price breakdown
- **Trust building** - Money-back guarantee, scientific proof, value propositions
- **Flexible options** - Weekly, monthly, and annual plans with savings
- **Special offers** - Shake discount and exit-intent offers for better value
- **Urgency** - Time-limited offers create action motivation
- **Transparency** - No hidden costs, clear cancellation policy

---

## 🎯 Core Features

### 1. SubscribeScreen - Main Sales Screen
- **Plan selection** - Weekly (€3.99), Monthly (€11.99), Annual (€79.99)
- **Trust elements** - Trial info, money-back guarantee, scientific proof
- **Value propositions** - Cost comparison, immediate effects, personalization
- **Objection handling** - Privacy, cancellation, pricing, offline support
- **Shake discount** - 20% additional discount via device shake gesture
- **Plan comparison** - Features, savings percentages, daily prices
- **Visual design** - Gradient backgrounds, animated cards, modern UI

### 2. DownsellScreen - Exit-Intent Offer
- **Time-limited offer** - 30% additional discount with 120-second countdown
- **Urgency creation** - Countdown timer and scarcity messaging
- **Exit prevention** - Confirmation dialog when attempting to close
- **Permanent dismissal** - Option to permanently dismiss offer
- **Same plan options** - All three plans with enhanced discounts
- **Conversion focus** - Designed to recover abandoned purchases

### 3. Discount System
- **Shake discount** - 20% off via accelerometer gesture detection
- **Downsell discount** - 30% additional discount on exit intent
- **Discount persistence** - Discounts stored and persist across sessions
- **Visual feedback** - Clear indication when discounts are applied
- **Price updates** - Real-time price recalculation with discounts

### 4. Trust Elements
- **Trial information** - 7-day free trial with timeline visualization
- **Money-back guarantee** - 30-day guarantee with clear messaging
- **Scientific proof** - Research-backed statistics (40% less stress, 2x focus)
- **Value propositions** - Cost comparison, immediate effects, personalization
- **Objection handling** - Privacy, cancellation, pricing, offline, science, flexibility

### 5. Plan Display
- **Three plans** - Weekly, monthly (recommended), annual
- **Price breakdown** - Original price, discounted price, daily price
- **Savings badges** - Visual savings percentages (30%, 61%)
- **Feature lists** - Plan-specific features displayed on selection
- **Recommended badge** - Monthly plan highlighted as "Meistgewählt"
- **Visual selection** - Animated card selection with scale effect

### 6. Purchase Flow Integration
- **IAP integration** - Native App Store / Play Store purchase
- **Plan storage** - Selected plan saved before purchase
- **Receipt validation** - Backend validation via Supabase Edge Function
- **Error handling** - Graceful handling of cancellations and errors
- **Navigation** - Automatic navigation after successful purchase

---

## 🏗️ Architecture

### Technology Stack
- **UI Components:** React Native components with LinearGradient
- **State Management:** React Hooks (`useSubscriptionForm`)
- **Storage:** AsyncStorage for discount and plan persistence
- **IAP:** `react-native-iap` for native store integration
- **Sensors:** Accelerometer for shake detection
- **Navigation:** React Navigation for screen transitions

### Key Components
- `SubscribeScreen` - Main subscription sales screen
- `DownsellScreen` - Exit-intent discount offer screen
- `SubscriptionCard` - Plan display component
- `TrustElements` - Trial info, guarantee, scientific proof
- `AdditionalTrustElements` - Value propositions, objection handling
- `DiscountButton` - Shake discount activation component
- `useSubscriptionForm` - Sales form logic hook

---

## 📱 Screens

1. **SubscribeScreen** (`/subscribe`) - Main subscription plan selection
2. **DownsellScreen** (`/downsell`) - Exit-intent discount offer with countdown

---

## 🔄 User Flows

### Primary Flows
1. **Subscribe Flow** - Plan Selection → Discount Activation → Purchase → Validation
2. **Downsell Flow** - Exit Intent → Discount Offer → Countdown → Purchase
3. **Shake Discount Flow** - Shake Device → Discount Applied → Purchase

### Alternative Flows
- **Plan Comparison** - View Plans → Compare Features → Select Plan
- **Discount Activation** - Shake Device → Discount Applied → Price Update
- **Exit Prevention** - Attempt Close → Confirmation → Stay or Dismiss

---

## 💰 Pricing Strategy

### Plan Pricing
- **Weekly:** €3.99/week (€0.57/day)
- **Monthly:** €11.99/month (€0.40/day) - 30% savings vs weekly
- **Annual:** €79.99/year (€0.22/day) - 61% savings vs weekly

### Discount Application
- **Shake Discount:** 20% off all plans
- **Downsell Discount:** 30% additional off all plans
- **Combined Discounts:** Applied sequentially (base discount, then shake/downsell)

---

## 📊 Integration Points

### Related Features
- **Subscription & Payment** - IAP integration and receipt validation
- **Authentication** - User signup triggers trial creation
- **Onboarding** - Plan selection during registration flow
- **Profile** - Subscription status display and management

### External Services
- Apple App Store Connect (IAP products)
- Google Play Console (IAP products)
- Supabase (receipt validation Edge Function)
- App Store / Play Store (payment processing)

---

## 🧪 Testing Considerations

### Test Cases
- Plan selection and price calculation
- Shake discount activation
- Downsell countdown timer
- Exit prevention dialog
- Discount persistence across sessions
- IAP purchase flow from sales screens
- Trust elements display
- Responsive layout on different screen sizes

### Edge Cases
- Shake detection on simulators (fallback)
- Countdown expiration handling
- Network failures during purchase
- Multiple discount applications
- Plan selection state persistence
- Screen navigation edge cases

---

## 📚 Additional Resources

- [React Native IAP Documentation](https://github.com/dooboolab/react-native-iap)
- [Apple In-App Purchase Guide](https://developer.apple.com/in-app-purchase/)
- [Google Play Billing](https://developer.android.com/google/play/billing)
- [React Native Sensors](https://github.com/react-native-sensors/react-native-sensors)

---

## 📝 Notes

- Shake discount requires accelerometer sensor (fallback for simulators)
- Downsell offer can be permanently dismissed per device
- Discounts persist across app sessions via AsyncStorage
- All prices displayed in EUR (€)
- Countdown timer runs for 120 seconds on downsell screen
- Recommended plan (monthly) is highlighted with badge
- Trust elements are strategically placed for maximum conversion

---

*For detailed technical specifications, see `technical-spec.md`*  
*For user flow diagrams, see `user-flows.md`*  
*For component details, see `components.md`*  
*For service dependencies, see `services.md`*
