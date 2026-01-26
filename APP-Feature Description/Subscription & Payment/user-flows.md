# Subscription & Payment System - User Flows

## 🔄 Primary User Flows

### 1. Subscription Purchase Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Navigate to Subscribe Screen
   └─> Display subscription plans
       └─> Show: Weekly, Monthly, Annual plans
           └─> Display pricing and features

2. Select Plan
   └─> Update selected plan state
       └─> Highlight selected plan card
           └─> Show plan features
               └─> Display daily price

3. Optional: Activate Discount
   └─> Shake device
       └─> Detect shake gesture
           └─> Show shaking animation
               └─> Apply 20% discount
                   └─> Update prices
                       └─> Store discount status

4. Click "Weiter" (Continue)
   └─> Validate plan selection
       └─> Check network connectivity
           ├─> Offline → Show error
           └─> Online → Continue
               └─> Save plan selection to storage
                   └─> Show loading state
                       └─> Map plan to IAP product ID
                           └─> Call IAPService.purchaseProduct()
                               ├─> Error → Show error message
                               └─> Success → Continue
                                   └─> Open native store purchase dialog
                                       ├─> User cancels → Return silently
                                       └─> User approves → Continue
                                           └─> Receive purchase receipt
                                               └─> Store pending purchase
                                                   └─> Validate receipt with backend
                                                       ├─> Invalid → Show error
                                                       └─> Valid → Continue
                                                           └─> Update subscription in database
                                                               └─> Finish transaction
                                                                   └─> Clear pending purchase
                                                                       └─> Navigate to Auth/Main App
```

**Success Path:**
- User selects plan
- Purchase completes
- Receipt validated
- Subscription activated
- Navigate to main app

**Error Paths:**
- Network error → Show connectivity error
- User cancellation → Return silently (no error)
- Invalid receipt → Show error, retry option
- Store error → Show error message

---

### 2. Trial Creation Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Complete Signup
   └─> OAuthService.handleSuccessfulOAuth()
       └─> Check for selected plan
           ├─> No plan → Skip trial creation
           └─> Plan selected → Continue
               └─> ProductionBackendService.createSubscription()
                   └─> Create subscription record
                       ├─> Set plan_type (monthly/yearly)
                       ├─> Set status ('trialing')
                       ├─> Set trial_start (now)
                       ├─> Set trial_end (now + 7 days)
                       ├─> Set trial_days_remaining (7)
                       └─> Insert into subscriptions table
                           └─> Return subscription data
                               └─> useTrialStatus.checkTrialStatus()
                                   └─> Update local trial state
                                       └─> Schedule trial reminders
```

**Success Path:**
- User signs up
- Trial subscription created
- Trial status tracked
- Reminders scheduled

**Error Paths:**
- Subscription creation failure → Log error, continue
- Database error → Fallback to local storage

---

### 3. Trial Reminder Flow

```
System Event                   System Response
─────────────────────────────────────────────────────────
1. Trial Status Check
   └─> useTrialStatus.checkTrialStatus()
       └─> Get subscription from backend
           └─> Calculate days remaining
               ├─> > 3 days → Continue
               ├─> 3 days → Show reminder
               │   └─> Alert: "Noch 3 Tage kostenlos"
               ├─> 1 day → Show reminder
               │   └─> Alert: "Noch 1 Tag kostenlos"
               └─> 0 days → Show expiration alert
                   └─> Alert: "Testversion endet heute!"
                       └─> Update trial status
```

**Reminder Triggers:**
- 3 days remaining
- 1 day remaining
- Expiration day

---

### 4. Plan Change Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Navigate to Subscription Management
   └─> Display current subscription
       └─> Show plan options

2. Select New Plan
   └─> Update selected plan state
       └─> Show plan details

3. Click "Plan ändern" (Change Plan)
   └─> Confirm plan change
       └─> Check network connectivity
           ├─> Offline → Show error
           └─> Online → Continue
               └─> Show loading state
                   └─> SubscriptionService.changePlan()
                       ├─> Get current subscription
                       │   └─> No subscription → Show error
                       └─> Current subscription found → Continue
                           └─> Call supabase.rpc('change_subscription_plan')
                               ├─> Error → Show error
                               └─> Success → Continue
                                   └─> Fetch updated subscription
                                       └─> Update UI with new plan
                                           └─> Show success message
```

**Success Path:**
- User selects new plan
- Plan change confirmed
- Backend updates subscription
- UI updates with new plan

**Error Paths:**
- No active subscription → Show error
- Network error → Show connectivity error
- Backend error → Show error message

---

### 5. Subscription Cancellation Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Navigate to Subscription Management
   └─> Display current subscription
       └─> Show cancellation option

2. Click "Abonnement kündigen"
   └─> Show cancellation options
       ├─> Cancel at period end
       └─> Cancel immediately

3. Select Cancellation Option
   └─> Show confirmation dialog
       ├─> Cancel → Return to management
       └─> Confirm → Continue
           └─> Optional: Collect cancellation reason
               └─> Optional: Collect feedback
                   └─> Show loading state
                       └─> SubscriptionService.cancelSubscription()
                           └─> Call supabase.rpc('cancel_subscription')
                               ├─> Error → Show error
                               └─> Success → Continue
                                   └─> Fetch updated subscription
                                       └─> Update UI with cancellation status
                                           └─> Show success message
                                               └─> Display cancellation date
```

**Success Path:**
- User confirms cancellation
- Backend processes cancellation
- Subscription status updated
- Cancellation date displayed

**Error Paths:**
- Network error → Show connectivity error
- Backend error → Show error message

---

### 6. Purchase Restoration Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Navigate to Settings/Account
   └─> Display "Purchases wiederherstellen" option

2. Click "Purchases wiederherstellen"
   └─> Show loading state
       └─> Check network connectivity
           ├─> Offline → Show error
           └─> Online → Continue
               └─> IAPService.restorePurchases()
                   └─> Get available purchases from store
                       ├─> No purchases → Show message
                       └─> Purchases found → Continue
                           └─> For each purchase:
                               └─> Validate receipt with backend
                                   ├─> Invalid → Skip
                                   └─> Valid → Continue
                                       └─> Sync subscription
                                           └─> Update subscription in database
                                               └─> Show success message
                                                   └─> Display restored subscriptions
```

**Success Path:**
- Purchases found
- Receipts validated
- Subscriptions restored
- Success message shown

**Error Paths:**
- No purchases → Show message
- Invalid receipts → Skip, show warning
- Network error → Show connectivity error

---

## 🔀 Alternative Flows

### Downsell Offer Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User Attempts to Leave Subscribe Screen
   └─> Detect exit intent
       └─> Check if downsell already dismissed
           ├─> Dismissed → Allow exit
           └─> Not dismissed → Continue
               └─> Navigate to DownsellScreen
                   └─> Display 30% additional discount
                       └─> Start countdown timer (120s)
                           └─> Show discounted plans
                               └─> Display timer

2. User Options:
   ├─> Select Plan and Continue
   │   └─> Apply 30% discount
   │       └─> Initiate purchase flow
   │
   ├─> Decline Offer
   │   └─> Show confirmation dialog
   │       ├─> Cancel → Stay on screen
   │       └─> Confirm → Continue
   │           └─> Mark downsell as permanently dismissed
   │               └─> Navigate away
   │
   └─> Timer Expires
       └─> Auto-mark as dismissed
           └─> Navigate away
```

**Use Cases:**
- Exit intent detection
- Last-chance discount offer
- Conversion optimization

---

### Discount Activation Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. View Subscribe Screen
   └─> Display DiscountButton
       └─> Show "Schütteln für Rabatt" option

2. Shake Device
   └─> Detect shake gesture
       └─> Show shaking animation
           └─> Apply 20% discount
               └─> Update all plan prices
                   └─> Store discount status
                       └─> Display discount badge
                           └─> Show updated prices
```

**Discount Features:**
- 20% discount on all plans
- Persistent across sessions
- Visual feedback (animation)
- Applied automatically to purchase

---

### Receipt Validation Flow

```
System Event                   System Response
─────────────────────────────────────────────────────────
1. Purchase Complete
   └─> Purchase Update Listener Triggered
       └─> Extract receipt
           ├─> iOS: transactionReceipt
           └─> Android: purchaseToken
               └─> IAPService.validateReceipt()
                   └─> Call supabase.functions.invoke('validate-iap-receipt')
                       └─> Edge Function Processing
                           ├─> Platform Detection
                           │
                           ├─> iOS: validateAppleReceipt()
                           │   ├─> Try Production Validation
                           │   │   └─> Apple Receipt Validation API
                           │   └─> Fallback to Sandbox
                           │       └─> Sandbox Receipt Validation API
                           │
                           └─> Android: validateGoogleReceipt()
                               └─> Google Play Developer API
                                   └─> Validate Purchase Token
                                       │
                                       └─> Validation Result
                                           ├─> Invalid → Return error
                                           └─> Valid → Continue
                                               └─> storeReceipt()
                                                   └─> Insert into iap_receipts table
                                                       └─> updateUserSubscription()
                                                           └─> Update subscriptions table
                                                               └─> Return success
                                                                   └─> Finish Transaction
                                                                       └─> Clear Pending Purchase
```

**Automatic Behavior:**
- Runs in background
- No user interaction required
- Transparent to user

---

## 🚨 Error Flows

### Purchase Error Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Attempt Purchase
   └─> IAPService.purchaseProduct()
       └─> Check IAP initialization
           ├─> Not initialized → Initialize
           └─> Initialized → Continue
               └─> Check network connectivity
                   ├─> Offline → Show error
                   │   └─> "Keine Internetverbindung"
                   └─> Online → Continue
                       └─> Request purchase from store
                           ├─> User cancels → Return silently
                           ├─> Store error → Show error
                           │   └─> "Kauf fehlgeschlagen"
                           └─> Network error → Show error
                               └─> "Bitte überprüfe deine Internetverbindung"
```

**Error Messages:**
- "Keine Internetverbindung"
- "Kauf fehlgeschlagen"
- "Bitte überprüfe deine Internetverbindung"
- Retry option available

---

### Receipt Validation Error Flow

```
System Event                   System Response
─────────────────────────────────────────────────────────
1. Receipt Validation Attempt
   └─> IAPService.validateReceipt()
       └─> Call Edge Function
           ├─> Network Error → Retry
           │   └─> Store as pending purchase
           │       └─> Retry on next app launch
           │
           ├─> Invalid Receipt → Show error
           │   └─> "Ungültiger Kaufbeleg"
           │       └─> Offer restore purchases
           │
           └─> Backend Error → Show error
               └─> "Validierung fehlgeschlagen"
                   └─> Store as pending purchase
                       └─> Retry later
```

**Error Handling:**
- Network errors: Retry with pending purchase
- Invalid receipts: Offer restore
- Backend errors: Store for retry

---

### Subscription Sync Error Flow

```
System Event                   System Response
─────────────────────────────────────────────────────────
1. Subscription Status Check
   └─> SubscriptionService.getUserSubscription()
       └─> Query database
           ├─> Network Error → Use cached data
           │   └─> Show warning
           │       └─> "Daten werden aktualisiert..."
           │
           ├─> No Subscription → Show message
           │   └─> "Kein aktives Abonnement"
           │
           └─> Database Error → Show error
               └─> "Fehler beim Laden der Abonnement-Daten"
                   └─> Retry option
```

**Error Recovery:**
- Network errors: Use cached data
- Database errors: Show error, retry option
- No subscription: Show message, offer to subscribe

---

## 🔄 State Transitions

### Subscription Status States

```
none → trialing → active
  │        │         │
  │        │         └─> cancelled
  │        │              │
  │        │              └─> expired
  │        │
  │        └─> expired
  │
  └─> active (direct purchase)
```

### Purchase States

```
No Purchase → Selecting Plan → Processing → Validating → Active
     │              │              │            │
     │              │              │            └─> Error
     │              │              └─> Error
     │              └─> Cancelled
     │
     └─> Restored
```

### Trial States

```
No Trial → Trial Active → Trial Expiring → Trial Expired
    │           │              │                │
    │           │              │                └─> Converted to Paid
    │           │              └─> Reminder Shown
    │           └─> Reminder Scheduled
    │
    └─> Trial Created
```

---

## 📊 Flow Diagrams

### Complete Purchase Journey

```
Index Screen / Onboarding
    │
    ├─> User completes onboarding
    │   └─> SubscribeScreen
    │       ├─> Select Plan
    │       │   └─> Optional: Activate Discount
    │       │       └─> Continue
    │       │           └─> IAP Purchase Flow
    │       │               └─> Receipt Validation
    │       │                   └─> Subscription Active
    │       │                       └─> Main App
    │       │
    │       └─> Exit Intent
    │           └─> DownsellScreen
    │               └─> [Same purchase flow with 30% discount]
    │
    └─> User signs up
        └─> Trial Created
            └─> Main App
                └─> Trial Reminders
                    └─> SubscribeScreen (on expiration)
```

---

## 🎯 User Goals

### Goal: Quick Purchase
- **Path:** Subscribe → Select Plan → Purchase
- **Time:** < 30 seconds
- **Steps:** 3-4 taps

### Goal: Best Value
- **Path:** Subscribe → Compare Plans → Select Annual → Activate Discount
- **Time:** ~1 minute
- **Steps:** 5-6 taps

### Goal: Restore Purchases
- **Path:** Settings → Restore Purchases
- **Time:** < 15 seconds
- **Steps:** 2 taps

---

*For component interactions, see `components.md`*  
*For service calls, see `services.md`*  
*For technical details, see `technical-spec.md`*
