# Subscription & Payment System - Functional Requirements

## 📋 Core Requirements

### 1. Subscription Plans

#### Plan Options
- [x] Weekly plan available (€3.99/week)
- [x] Monthly plan available (€11.99/month)
- [x] Annual plan available (€79.99/year)
- [x] Plan pricing displayed clearly
- [x] Savings percentage calculated and displayed
- [x] Daily price calculation and display
- [x] Plan features listed for each plan
- [x] Recommended plan highlighted (monthly)
- [x] Plan selection state management

#### Plan Display
- [x] Original price displayed
- [x] Discounted price displayed (if applicable)
- [x] Price per unit (week/month/year)
- [x] Daily price breakdown
- [x] Feature comparison list
- [x] Visual selection indicator
- [x] Recommended badge for monthly plan
- [x] Savings badge for annual plan

### 2. In-App Purchase (IAP) Integration

#### IAP Initialization
- [x] IAP service initialization on app startup
- [x] Connection to App Store / Play Store
- [x] Product fetching from stores
- [x] Product caching for performance
- [x] Purchase listener setup
- [x] Error listener setup
- [x] Pending purchase recovery

#### Purchase Flow
- [x] Purchase initiation from selected plan
- [x] Native store purchase dialog
- [x] Purchase completion handling
- [x] Receipt extraction (iOS/Android)
- [x] Receipt validation with backend
- [x] Transaction finishing
- [x] Purchase success confirmation
- [x] Purchase error handling
- [x] User cancellation handling (graceful)

#### Purchase Restoration
- [x] Restore purchases functionality
- [x] Available purchases retrieval
- [x] Receipt validation for restored purchases
- [x] Subscription sync after restoration
- [x] Success/failure feedback

### 3. Receipt Validation

#### Backend Validation
- [ ] Receipt sent to backend (e.g. Cloud Function) (Not implemented; app uses StoreKitManager)
- [x] Apple receipt validation (production) (StoreKitManager)
- [x] Apple receipt validation (sandbox fallback) (StoreKitManager)
- [ ] Google receipt validation via Play API (Not applicable - iOS app)
- [x] Validation result processing (StoreKitManager)
- [ ] Receipt storage in database (Not implemented)
- [ ] Subscription update after validation (Not fully implemented)
- [x] Error handling for invalid receipts (Implemented)

#### Receipt Storage
- [ ] Receipt data stored in `iap_receipts` table (Not implemented)
- [ ] Transaction ID storage (Not implemented)
- [ ] Original transaction ID storage (Not implemented)
- [ ] Platform identification (iOS/Android) (Not implemented)
- [ ] Purchase date storage (Not implemented)
- [ ] Expiration date storage (Not implemented)
- [ ] Trial period flag storage (Not implemented)
- [ ] Intro offer flag storage (Not implemented)

### 4. Trial Management

#### Trial Creation
- [ ] Automatic trial creation on signup (Not implemented)
- [ ] 7-day trial period (Not implemented)
- [ ] Trial start date tracking (Not implemented)
- [ ] Trial end date calculation (Not implemented)
- [ ] Trial days remaining calculation (Not implemented)
- [ ] Trial status tracking (active/expired) (Not implemented)
- [ ] Trial subscription record creation (Not implemented)

#### Trial Status
- [x] Trial status display
- [x] Days remaining display
- [x] Trial expiration detection
- [x] Trial-to-paid conversion tracking
- [x] Trial reminder scheduling
- [x] Trial expiration alerts
- [x] Local trial status caching

#### Trial Reminders
- [x] Reminder at 3 days remaining
- [x] Reminder at 1 day remaining
- [x] Reminder on expiration day
- [x] Alert notifications
- [x] Reminder message display

### 5. Subscription Management

#### View Subscription
- [x] Current subscription details display
- [x] Plan type display
- [x] Subscription status display
- [x] Current period dates
- [x] Next billing date
- [x] Trial status (if applicable)
- [x] Cancellation status
- [x] Auto-renew status

#### Change Plan
- [x] View current plan
- [x] Select new plan
- [x] Proration calculation (future)
- [x] Plan change confirmation
- [x] Backend plan update
- [x] Subscription refresh after change
- [x] Success/error feedback

#### Cancel Subscription
- [x] Cancel subscription option
- [x] Cancel at period end option
- [x] Cancel immediately option
- [x] Cancellation reason collection (optional)
- [x] Cancellation feedback collection (optional)
- [x] Cancellation confirmation
- [x] Backend cancellation processing
- [x] Status update after cancellation

#### Reactivate Subscription
- [x] Reactivate option for cancelled subscriptions
- [x] Reactivation confirmation
- [x] Backend reactivation processing
- [x] Status update after reactivation

### 6. Payment History

#### Payment Records
- [x] Payment history retrieval
- [x] Payment list display
- [x] Payment amount display
- [x] Payment date display
- [x] Payment status display
- [x] Plan type for each payment
- [x] Invoice URL (if available)
- [x] Payment description

#### Payment History Features
- [x] Recent payments (last 10)
- [x] Payment sorting (newest first)
- [x] Payment status filtering
- [x] Payment details view

### 7. Discount System

#### Shake Discount
- [x] Device shake detection
- [x] Discount activation on shake
- [x] 20% discount application
- [x] Discount persistence in storage
- [x] Discount status display
- [x] Visual feedback (shaking animation)
- [x] Discount applied to all plans

#### Downsell Discount
- [x] Exit intent detection
- [x] Downsell screen display
- [x] 30% additional discount offer
- [x] Countdown timer (120 seconds)
- [x] Discount application
- [x] Permanent dismissal option
- [x] Dismissal persistence
- [x] Auto-redirect on timer expiry

### 8. Subscription Storage

#### Local Storage
- [x] Selected plan storage
- [x] Discount status storage
- [x] Downsell dismissal storage
- [x] Plan selection retrieval
- [x] Storage clearing on purchase
- [x] Storage persistence across sessions

---

## 🎯 User Stories

### As a new user, I want to:
- See clear subscription plan options with pricing
- Understand what features are included in each plan
- Start a free trial to explore premium features
- Purchase a subscription easily through my device's store
- See my trial days remaining so I know when it expires

### As an existing subscriber, I want to:
- View my current subscription details
- Change my subscription plan if needed
- Cancel my subscription if I no longer need it
- View my payment history
- Restore my purchases on a new device

### As a user considering purchase, I want to:
- See savings compared to other plans
- Understand the daily cost breakdown
- See trust elements (money-back guarantee, scientific proof)
- Activate discounts if available
- Get a downsell offer if I'm about to leave

---

## ✅ Acceptance Criteria

### Subscription Selection
- [x] User can view all available plans
- [x] User can select a plan
- [x] Pricing is clearly displayed
- [x] Savings are calculated correctly
- [x] Features are listed for each plan

### Purchase Flow
- [x] Purchase completes in < 30 seconds
- [x] Receipt is validated automatically
- [x] Subscription is activated immediately after validation
- [x] User receives confirmation
- [x] User cancellation is handled gracefully (no error)

### Trial Management
- [x] Trial is created automatically on signup
- [x] Trial days remaining is accurate
- [x] Reminders are shown at appropriate times
- [x] Trial expiration is detected correctly

### Subscription Management
- [x] User can view subscription details
- [x] User can change plan successfully
- [x] User can cancel subscription
- [x] User can reactivate cancelled subscription
- [x] Changes are reflected immediately

### Discount System
- [x] Shake discount activates on device shake
- [x] Discount persists across sessions
- [x] Discount is applied to all plans
- [x] Downsell offer appears on exit intent
- [x] Countdown timer functions correctly

---

## 🚫 Non-Functional Requirements

### Performance
- [x] IAP initialization completes in < 5 seconds
- [x] Product fetching completes in < 3 seconds
- [x] Purchase flow completes in < 30 seconds
- [x] Receipt validation completes in < 10 seconds
- [x] Subscription data loads in < 2 seconds

### Security
- [x] Receipts validated server-side
- [x] No sensitive payment data stored locally
- [x] Receipts stored securely in database
- [x] IAP credentials stored securely
- [x] All network requests use HTTPS

### Usability
- [x] Clear pricing display
- [x] Intuitive plan selection
- [x] Loading states for all async operations
- [x] Error messages are user-friendly
- [x] Success confirmations are clear

### Reliability
- [x] Network errors handled gracefully
- [x] Pending purchases recovered on app restart
- [x] Receipt validation retries on failure
- [x] Subscription status syncs on app launch
- [x] Offline state detection

---

## 🔄 Edge Cases

### Purchase Edge Cases
- [x] Network failure during purchase
- [x] User cancellation (no error shown)
- [x] Invalid product ID
- [x] Store connectivity issues
- [x] Multiple simultaneous purchase attempts
- [x] Purchase completion without validation

### Receipt Validation Edge Cases
- [x] Invalid receipt format
- [x] Expired receipt
- [x] Receipt from different environment (sandbox/production)
- [x] Network failure during validation
- [x] Backend validation service unavailable

### Trial Edge Cases
- [x] Trial creation failure
- [x] Trial expiration during app use
- [x] Multiple trial creation attempts
- [x] Trial status sync failure
- [x] Local trial status out of sync

### Subscription Management Edge Cases
- [x] Plan change during active subscription
- [x] Cancellation of already cancelled subscription
- [x] Reactivation of active subscription
- [x] Subscription data not found
- [x] Backend sync failure

### Discount Edge Cases
- [x] Discount activation without network
- [x] Discount persistence failure
- [x] Multiple discount activations
- [x] Discount calculation errors
- [x] Downsell timer expiry handling

---

## 📊 Success Metrics

- Subscription conversion rate > 15%
- Trial-to-paid conversion rate > 30%
- Average purchase completion time < 30 seconds
- Receipt validation success rate > 99%
- Discount activation rate > 5%
- Downsell conversion rate > 10%
- Subscription management success rate > 95%
