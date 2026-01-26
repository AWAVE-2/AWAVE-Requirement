# Sales Screens - User Flows

## 🔄 Primary User Flows

### 1. Subscribe Flow - Main Sales Screen

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Navigate to Subscribe Screen
   └─> Display SubscribeScreen
       └─> Load discount status from storage
           └─> Check AsyncStorage for 'awaveDiscount'
               ├─> Discount active → Set isDiscountApplied = true
               └─> No discount → Set isDiscountApplied = false
                   └─> Display screen with default pricing

2. View Subscription Plans
   └─> Display three plans:
       ├─> Weekly: €3.99/week
       ├─> Monthly: €11.99/month (Recommended)
       └─> Annual: €79.99/year
           └─> Show trust elements:
               ├─> Trial Info Card
               ├─> Money-Back Guarantee
               ├─> Scientific Proof
               ├─> Value Propositions
               └─> Objection Handling

3. Select Plan
   └─> User taps plan card
       └─> Update selectedPlan state
           └─> Animate card selection (scale 1.02)
               └─> Show plan features
                   └─> Update daily price display

4. Optional: Activate Shake Discount
   └─> User shakes device
       └─> Accelerometer detects shake (speed > 15)
           └─> Show shaking animation
               └─> After 1.5 seconds:
                   ├─> Set isDiscountApplied = true
                   ├─> Save to AsyncStorage
                   └─> Recalculate all prices
                       └─> Update plan cards with 20% discount
                           └─> Show "20% Rabatt aktiviert!" message

5. Click "Weiter" (Continue)
   └─> Validate plan selection
       └─> Check network connectivity
           ├─> Offline → Show error
           └─> Online → Continue
               └─> Set isProcessing = true
                   └─> Calculate final price
                       └─> Save plan selection to storage
                           └─> Map plan to IAP product ID
                               └─> Call IAPService.purchaseProduct()
                                   └─> Open native store purchase dialog
                                       ├─> User cancels → Return silently
                                       └─> User approves → Continue
                                           └─> Receive purchase receipt
                                               └─> Store pending purchase
                                                   └─> Validate receipt with backend
                                                       ├─> Invalid → Show error
                                                       └─> Valid → Continue
                                                           └─> Update subscription in database
                                                               └─> Clear pending purchase
                                                                   └─> Navigate to Auth/Main App
```

**Success Path:**
- User selects plan
- Optional discount activated
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

### 2. Downsell Flow - Exit-Intent Offer

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Navigate to Downsell Screen
   └─> Check if permanently dismissed
       └─> SubscriptionStorage.isDownsellPermanentlyDismissed()
           ├─> Dismissed → Navigate away automatically
           └─> Not dismissed → Continue
               └─> Display DownsellScreen
                   └─> Start 120-second countdown timer

2. View Exit-Intent Offer
   └─> Display offer header:
       ├─> "Exklusiver 30% Zusatzrabatt!"
       └─> Urgency messaging
           └─> Show all three plans with downsell pricing:
               ├─> Weekly: 30% additional discount
               ├─> Monthly: 30% additional discount
               └─> Annual: 30% additional discount
                   └─> Show trust elements:
                       ├─> Trial Info Card
                       └─> Money-Back Guarantee

3. Countdown Timer Running
   └─> Timer decrements every second
       └─> Display: "läuft in X Sekunden ab"
           └─> If timer reaches 0:
               └─> handleTimerExpired()
                   ├─> Set permanently dismissed
                   └─> Navigate to Start screen

4. Attempt to Close
   └─> User taps close button
       └─> Show confirmation dialog:
           ├─> Title: "Einmaliges Angebot verlassen?"
           ├─> Message: Explains offer uniqueness
           └─> Options:
               ├─> "Mit 30% Angebot fortfahren" (Cancel)
               │   └─> Stay on screen
               └─> "Ja, ich bin mir sicher" (Confirm)
                   └─> Set permanently dismissed
                       └─> Navigate to Start screen

5. Select Plan and Purchase
   └─> User selects plan
       └─> Click "Ja, ich will 30% sparen!"
           └─> Same purchase flow as SubscribeScreen
               └─> [See Subscribe Flow step 5]
```

**Success Path:**
- User sees offer
- Selects plan
- Purchase completes
- Navigate to main app

**Error Paths:**
- Timer expires → Auto-navigate away
- User dismisses → Permanent dismissal
- Purchase fails → Show error

---

### 3. Shake Discount Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. View Discount Hint
   └─> DiscountButton displays:
       └─> "💡 Tipp: Schüttle dein Gerät für eine Überraschung"

2. Shake Device
   └─> Accelerometer detects motion
       └─> Calculate speed: sqrt(x² + y² + z²)
           └─> If speed > 15 and discount not applied:
               └─> Trigger discount activation
                   └─> useSubscriptionForm.activateDiscount()
                       ├─> Set isShakingDevice = true
                       ├─> Show visual feedback
                       └─> After 1.5 seconds:
                           ├─> Set isDiscountApplied = true
                           ├─> SubscriptionStorage.setDiscountActivated(true)
                           │   └─> Save to AsyncStorage
                           └─> Set isShakingDevice = false
                               └─> Update all prices
                                   └─> Show "20% Rabatt aktiviert!" message

3. Discount Applied
   └─> DiscountButton shows success state:
       ├─> Green gradient background
       ├─> Bolt icon
       └─> "20% Rabatt aktiviert!" text
           └─> All plan prices updated:
               └─> Original price * 0.8 (20% off)
```

**Success Path:**
- Shake detected
- Discount activated
- Prices updated
- Discount persists

**Error Paths:**
- Sensor unavailable → Fallback (simulator auto-activates after 5s)
- Sensor error → Warning log, graceful degradation

---

## 🔀 Alternative Flows

### Plan Comparison Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. View All Plans
   └─> Display three plans side-by-side
       └─> Show:
           ├─> Original prices
           ├─> Discounted prices (if applicable)
           ├─> Daily prices
           ├─> Savings percentages
           └─> Feature lists

2. Compare Plans
   └─> User taps different plans
       └─> Each tap:
           ├─> Updates selection state
           ├─> Animates card selection
           └─> Shows features for selected plan
               └─> Updates daily price display

3. Select Best Plan
   └─> User decides on plan
       └─> Plan remains selected
           └─> Ready for purchase
```

---

### Discount Persistence Flow

```
App Restart / Screen Reload
    │
    └─> SubscribeScreen mounts
        └─> useSubscriptionForm (useEffect)
            └─> SubscriptionStorage.isDiscountActivated()
                └─> AsyncStorage.getItem('awaveDiscount')
                    ├─> 'true' → Set isDiscountApplied = true
                    │   └─> Recalculate prices with discount
                    └─> null/false → Set isDiscountApplied = false
                        └─> Display normal prices
```

---

### Exit Prevention Flow

```
User Attempts to Close Downsell
    │
    └─> handleCloseAttempt()
        └─> Alert.alert()
            ├─> Title: "Einmaliges Angebot verlassen?"
            ├─> Message: Explains offer uniqueness
            └─> Buttons:
                ├─> "Mit 30% Angebot fortfahren"
                │   └─> onPress: () => {} (Do nothing)
                │       └─> Stay on screen
                └─> "Ja, ich bin mir sicher"
                    └─> onPress: async () => {
                        │   await SubscriptionStorage.setDownsellPermanentlyDismissed()
                        │   navigation.navigate('Start')
                        │ }
                        └─> Dismiss permanently
                            └─> Navigate away
```

---

## 🚨 Error Flows

### Purchase Error Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Click "Weiter" (Continue)
   └─> Initiate purchase flow
       └─> IAPService.purchaseProduct()
           └─> Native store dialog opens

2. Purchase Fails
   └─> IAPService returns error
       └─> Parse error type
           ├─> User cancelled → Return silently (no error)
           ├─> Network error → Show connectivity error
           │   └─> "Bitte überprüfe deine Internetverbindung"
           ├─> Invalid product → Show error
           │   └─> "Produkt nicht verfügbar"
           └─> Store error → Show error
               └─> "Kauf fehlgeschlagen. Bitte versuchen Sie es erneut."
                   └─> Set isProcessing = false
                       └─> User can retry
```

---

### Network Error Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Attempt Purchase
   └─> Check network connectivity
       ├─> Connected → Continue with purchase
       └─> Not connected → Show error
           └─> Alert.alert()
               ├─> Title: "Keine Internetverbindung"
               ├─> Message: "Bitte überprüfe deine Internetverbindung"
               └─> Button: "OK"
                   └─> Set isProcessing = false
```

---

### Timer Expiration Flow

```
Countdown Timer Reaches 0
    │
    └─> handleTimerExpired()
        ├─> SubscriptionStorage.setDownsellPermanentlyDismissed()
        │   └─> AsyncStorage.setItem('downsellOfferDismissed', 'true')
        └─> navigation.navigate('Start')
            └─> User redirected to free tier
```

---

## 🔄 State Transitions

### Plan Selection States

```
No Selection → Weekly Selected
     │              │
     │              ├─> Monthly Selected
     │              │
     │              └─> Annual Selected
     │
     └─> Monthly Selected (Default)
```

### Discount States

```
No Discount → Shake Detected → Discount Applied
     │              │                │
     │              │                └─> Persisted to Storage
     │              │
     │              └─> Animation (1.5s)
     │
     └─> Discount Loaded from Storage
```

### Purchase States

```
Idle → Processing → Success
  │         │          │
  │         │          └─> Navigate to Auth/Main App
  │         │
  │         └─> Error
  │             └─> Show Error Message
  │                 └─> Return to Idle
  │
  └─> Cancelled (Silent)
      └─> Return to Idle
```

### Countdown States

```
120s → 119s → ... → 1s → 0s
  │      │              │    │
  │      │              │    └─> Timer Expired
  │      │              │        └─> Navigate Away
  │      │              │
  │      │              └─> Update Display
  │      │
  │      └─> Update Display
  │
  └─> Update Display
```

---

## 📊 Flow Diagrams

### Complete Subscribe Journey

```
Onboarding / Main App
    │
    ├─> User wants to subscribe
    │   └─> Navigate to SubscribeScreen
    │       ├─> View Plans
    │       │   └─> Select Plan
    │       │       └─> Optional: Shake for Discount
    │       │           └─> Click "Weiter"
    │       │               └─> Native Store Purchase
    │       │                   ├─> User Cancels → Return to Screen
    │       │                   └─> User Approves → Purchase Complete
    │       │                       └─> Receipt Validation
    │       │                           └─> Subscription Active
    │       │                               └─> Navigate to Main App
    │       │
    │       └─> User attempts to leave
    │           └─> Navigate to DownsellScreen
    │               └─> [See Downsell Flow]
    │
    └─> User exits app
        └─> [No action]
```

---

### Complete Downsell Journey

```
User Attempts to Leave SubscribeScreen
    │
    └─> Navigate to DownsellScreen
        ├─> Check if permanently dismissed
        │   ├─> Yes → Navigate away automatically
        │   └─> No → Continue
        │       └─> Display Offer
        │           ├─> Countdown Timer Starts (120s)
        │           │   └─> Timer Updates Every Second
        │           │       └─> If Timer Expires → Navigate Away
        │           │
        │           ├─> User Attempts to Close
        │           │   └─> Show Confirmation Dialog
        │           │       ├─> Cancel → Stay on Screen
        │           │       └─> Confirm → Dismiss Permanently
        │           │           └─> Navigate Away
        │           │
        │           └─> User Selects Plan
        │               └─> Click "Ja, ich will 30% sparen!"
        │                   └─> Purchase Flow
        │                       └─> [Same as Subscribe Flow]
```

---

## 🎯 User Goals

### Goal: Quick Purchase
- **Path:** Subscribe → Select Plan → Purchase
- **Time:** < 30 seconds
- **Steps:** 2-3 taps

### Goal: Best Value
- **Path:** Subscribe → Compare Plans → Select Annual → Shake for Discount → Purchase
- **Time:** ~1 minute
- **Steps:** 5-6 taps + shake

### Goal: Exit Recovery
- **Path:** Attempt Leave → Downsell → Select Plan → Purchase
- **Time:** ~2 minutes
- **Steps:** 4-5 taps

---

## 📱 Screen Transitions

### Navigation Flow
```
SubscribeScreen
    │
    ├─> Purchase Success → Auth / Main App
    ├─> Close → Previous Screen / MainTabs
    └─> Exit Intent → DownsellScreen
        │
        ├─> Purchase Success → Auth / Main App
        ├─> Timer Expires → Start Screen
        ├─> Dismiss → Start Screen
        └─> Close (Cancel) → Stay on Screen
```

---

*For component interactions, see `components.md`*  
*For service calls, see `services.md`*  
*For technical details, see `technical-spec.md`*
