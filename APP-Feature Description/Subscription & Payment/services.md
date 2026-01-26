# Subscription & Payment System - Services Documentation

## 🔧 Service Layer Overview

The subscription and payment system uses a service-oriented architecture with clear separation of concerns. Services handle all IAP operations, backend interactions, receipt validation, and local storage management.

---

## 📦 Services

### IAPService
**File:** `src/services/IAPService.ts`  
**Type:** Singleton Class  
**Purpose:** In-App Purchase provider abstraction and management

#### Configuration
```typescript
const IAP_PRODUCT_IDS = Platform.select({
  ios: [
    'com.awave.premium.weekly',
    'com.awave.premium.monthly',
    'com.awave.premium.annual',
  ],
  android: [
    'awave_premium_weekly',
    'awave_premium_monthly',
    'awave_premium_annual',
  ],
});

const INTRO_OFFER_IDS = {
  weekly: 'intro_weekly_20off',
  monthly: 'intro_monthly_20off',
  annual: 'intro_annual_20off',
};
```

#### Methods

**`initialize(): Promise<boolean>`**
- Initializes connection to App Store / Play Store
- Fetches products from stores
- Sets up purchase listeners
- Clears old iOS transactions
- Processes pending purchases from previous session
- Returns success status
- Called once at app startup

**`getProducts(): Promise<IAPProduct[]>`**
- Gets available products from store
- Returns cached products if available
- Auto-initializes if not initialized
- Returns array of IAP products

**`purchaseProduct(productId, applyIntroOffer, userId): Promise<PurchaseResult>`**
- Initiates purchase flow for product
- Handles native store purchase dialog
- Extracts receipt (iOS/Android format)
- Stores pending purchase for retry
- Returns purchase result with transaction details
- Handles user cancellation gracefully

**`restorePurchases(userId): Promise<PurchaseResult[]>`**
- Retrieves available purchases from store
- Validates each receipt with backend
- Returns array of restored purchases
- Used for restoring purchases on new device

**`validateReceipt(receipt, productId, userId): Promise<boolean>`**
- Validates receipt with Supabase Edge Function
- Sends receipt to `validate-iap-receipt` function
- Handles validation response
- Clears pending purchase on success
- Returns validation success status

**`cleanup(): Promise<void>`**
- Removes purchase listeners
- Ends IAP connection
- Cleans up resources
- Called on app unmount

#### Error Handling
- Cancellation: Returns gracefully (no error)
- Network errors: Throws error with message
- Invalid product ID: Throws error
- Store connectivity: Throws error

#### Dependencies
- `react-native-iap` - IAP library
- `@react-native-async-storage/async-storage` - Local storage
- `supabase` client - Backend validation
- `executeWithConnectivity` utility - Network checks

---

### SubscriptionService
**File:** `src/services/SubscriptionService.ts`  
**Type:** Service Object  
**Purpose:** Backend subscription operations

#### Methods

**`getUserSubscription(userId): Promise<SubscriptionDetails | null>`**
- Gets current subscription for user
- Queries `subscriptions` table
- Orders by created_at (descending)
- Returns most recent subscription
- Transforms database row to SubscriptionDetails
- Returns null if no subscription found

**`getPaymentHistory(userId, limit): Promise<PaymentHistory[]>`**
- Gets payment history for user
- Queries `payments` table
- Orders by created_at (descending)
- Limits results (default: 10)
- Returns array of payment records

**`changePlan(userId, newPlan): Promise<SubscriptionUpdateResponse>`**
- Changes subscription plan
- Gets current subscription first
- Calls Supabase RPC function `change_subscription_plan`
- Fetches updated subscription
- Returns success status and updated subscription

**`cancelSubscription(userId, request): Promise<SubscriptionUpdateResponse>`**
- Cancels subscription
- Calls Supabase RPC function `cancel_subscription`
- Supports cancel at period end or immediately
- Collects cancellation reason and feedback (optional)
- Returns success status and updated subscription

**`reactivateSubscription(userId): Promise<SubscriptionUpdateResponse>`**
- Reactivates cancelled subscription
- Calls Supabase RPC function `reactivate_subscription`
- Returns success status and updated subscription

**`calculateProration(userId, newPlan): Promise<PlanChangeRequest>`**
- Calculates proration for plan change
- Gets current subscription
- Calculates price difference
- Returns proration details
- Note: Currently basic calculation, should be done on backend

#### Database Operations
- Queries `subscriptions` table
- Queries `payments` table
- Calls Supabase RPC functions:
  - `change_subscription_plan`
  - `cancel_subscription`
  - `reactivate_subscription`

#### Dependencies
- `supabase` client
- `executeWithConnectivity` utility
- `handleSupabaseError` utility

---

### ProductionBackendService
**File:** `src/services/ProductionBackendService.ts`  
**Type:** Service Class  
**Purpose:** Supabase integration layer

#### Subscription Methods

**`getUserSubscription(userId): Promise<Subscription | null>`**
- Gets user subscription from database
- Queries `subscriptions` table
- Returns subscription or null

**`createSubscription(userId, planType): Promise<Subscription>`**
- Creates trial subscription
- Sets 7-day trial period
- Sets status to 'trialing'
- Creates subscription record
- Returns created subscription

**`checkTrialDaysRemaining(userId): Promise<number>`**
- Calculates trial days remaining
- Gets subscription from database
- Calculates difference between trial_end and now
- Returns number of days

#### Dependencies
- `supabase` client
- `safeApiCall` utility

---

### SubscriptionStorage
**File:** `src/utils/subscriptionStorage.ts`  
**Type:** Static Service Object  
**Purpose:** Local storage management

#### Storage Keys
- `awaveSelectedPlan` - Selected plan data
- `awaveDiscount` - Discount activation status
- `downsellOfferDismissed` - Downsell permanent dismissal

#### Methods

**`saveSelectedPlan(selection): Promise<void>`**
- Saves plan selection to AsyncStorage
- Stores PlanSelection object
- Used before purchase initiation

**`getSelectedPlan(): Promise<PlanSelection | null>`**
- Retrieves saved plan selection
- Returns PlanSelection or null
- Used to resume purchase flow

**`clearSelectedPlan(): Promise<void>`**
- Clears saved plan selection
- Called after successful purchase

**`isDiscountActivated(): Promise<boolean>`**
- Checks if discount is activated
- Returns boolean status
- Used to apply discount to prices

**`setDiscountActivated(activated): Promise<void>`**
- Sets discount activation status
- Stores boolean value
- Persists across sessions

**`isDownsellPermanentlyDismissed(): Promise<boolean>`**
- Checks if downsell was permanently dismissed
- Returns boolean status
- Used to prevent showing downsell again

**`setDownsellPermanentlyDismissed(): Promise<void>`**
- Sets downsell permanent dismissal
- Stores boolean value
- Persists across sessions

#### Dependencies
- `@react-native-async-storage/async-storage`

---

## 🔗 Service Dependencies

### Dependency Graph
```
SubscribeScreen
├── useSubscriptionForm
│   ├── SubscriptionStorage
│   │   └── AsyncStorage
│   └── IAPService
│       ├── react-native-iap
│       ├── AsyncStorage
│       └── supabase client
│           └── validate-iap-receipt Edge Function
│
useSubscriptionManagement
└── SubscriptionService
    ├── supabase client
    │   └── subscriptions table
    │   └── payments table
    │   └── RPC functions
    └── executeWithConnectivity
```

### External Dependencies

#### Native Modules
- **react-native-iap** - IAP library
- **AsyncStorage** - Local storage

#### Supabase
- **Database Tables:**
  - `subscriptions` - Subscription records
  - `payments` - Payment history
  - `iap_receipts` - Receipt storage
- **Edge Functions:**
  - `validate-iap-receipt` - Receipt validation

#### Store Platforms
- **Apple App Store Connect** - Product configuration
- **Google Play Console** - Product configuration

---

## 🔄 Service Interactions

### Purchase Flow
```
User Action
    │
    └─> useSubscriptionForm.handleContinue()
        ├─> SubscriptionStorage.saveSelectedPlan()
        │   └─> AsyncStorage.setItem()
        │
        └─> IAPService.purchaseProduct()
            ├─> react-native-iap.requestSubscription()
            │   └─> Native Store Purchase Dialog
            │       └─> User Approves/Cancels
            │
            ├─> IAPService.storePendingPurchase()
            │   └─> AsyncStorage.setItem()
            │
            └─> Purchase Update Listener
                └─> IAPService.validateReceipt()
                    └─> supabase.functions.invoke('validate-iap-receipt')
                        ├─> Apple/Google Receipt Validation
                        ├─> storeReceipt() - Store in database
                        └─> updateUserSubscription() - Update subscription
                            └─> SubscriptionService.getUserSubscription()
```

### Subscription Management Flow
```
User Action
    │
    └─> useSubscriptionManagement.changePlan()
        └─> SubscriptionService.changePlan()
            ├─> SubscriptionService.getUserSubscription()
            │   └─> supabase.from('subscriptions').select()
            │
            └─> supabase.rpc('change_subscription_plan')
                └─> Database Function Execution
                    └─> SubscriptionService.getUserSubscription()
                        └─> Return Updated Subscription
```

### Trial Management Flow
```
User Signup
    │
    └─> OAuthService.handleSuccessfulOAuth()
        └─> ProductionBackendService.createSubscription()
            └─> supabase.from('subscriptions').insert()
                ├─> Set trial_start
                ├─> Set trial_end (7 days)
                ├─> Set trial_days_remaining (7)
                └─> Set status ('trialing')
                    │
                    └─> useTrialStatus.checkTrialStatus()
                        └─> ProductionBackendService.getUserSubscription()
                            └─> Calculate days remaining
                                └─> Update local state
```

### Receipt Validation Flow
```
Purchase Complete
    │
    └─> Purchase Update Listener
        └─> IAPService.validateReceipt()
            └─> supabase.functions.invoke('validate-iap-receipt')
                ├─> Platform Detection (iOS/Android)
                │
                ├─> iOS: validateAppleReceipt()
                │   ├─> Try Production Validation
                │   └─> Fallback to Sandbox
                │
                └─> Android: validateGoogleReceipt()
                    └─> Google Play Developer API
                        │
                        └─> Validation Result
                            ├─> storeReceipt() - Save receipt
                            └─> updateUserSubscription() - Update subscription
                                └─> Return Validation Result
```

---

## 🧪 Service Testing

### Unit Tests
- Service method calls
- Error handling
- Storage operations
- Price calculations
- Receipt parsing

### Integration Tests
- IAP purchase flow
- Receipt validation
- Subscription creation
- Plan changes
- Payment history retrieval

### Mocking
- react-native-iap
- Supabase client
- AsyncStorage
- Network requests
- Edge Functions

---

## 📊 Service Metrics

### Performance
- **IAP Initialization:** < 5 seconds
- **Product Fetching:** < 3 seconds
- **Purchase Flow:** < 30 seconds
- **Receipt Validation:** < 10 seconds
- **Subscription Fetch:** < 2 seconds
- **Storage Operations:** < 100ms

### Reliability
- **Purchase Success Rate:** > 95%
- **Receipt Validation Success Rate:** > 99%
- **Subscription Sync Success Rate:** > 99%
- **Storage Operation Success Rate:** > 99%

### Error Rates
- **Network Errors:** < 1%
- **User Cancellation:** ~20% (expected)
- **Receipt Validation Failures:** < 1%
- **Subscription Sync Failures:** < 1%

---

## 🔐 Security Considerations

### Receipt Validation
- All receipts validated server-side
- No local validation
- Secure receipt storage in database
- Transaction IDs stored securely

### Payment Security
- No credit card data stored
- All payments through store platforms
- Receipts stored securely
- HTTPS for all network requests

### Storage Security
- Sensitive data not stored locally
- Only transaction IDs and status stored
- Receipts stored in database only
- Local storage for UI state only

---

## 🐛 Error Handling

### Service-Level Errors
- Network connectivity checks
- Retry logic for transient failures
- User-friendly error messages
- Error logging for debugging

### Error Types
- **Network Errors:** Connectivity issues
- **IAP Errors:** Store-specific errors
- **Validation Errors:** Receipt validation failures
- **Subscription Errors:** Backend operation failures
- **Storage Errors:** Local storage failures

---

## 📝 Service Configuration

### Environment Variables
```typescript
// IAP Product IDs (configured in code)
IAP_PRODUCT_IDS = {
  ios: ['com.awave.premium.weekly', ...],
  android: ['awave_premium_weekly', ...],
};

// Edge Function (configured in Supabase)
APPLE_SHARED_SECRET = 'your_shared_secret'
GOOGLE_SERVICE_ACCOUNT_KEY = 'your_service_account_key'
```

### Service Initialization
```typescript
// App startup
await IAPService.initialize();
```

### Service Cleanup
```typescript
// App shutdown
await IAPService.cleanup();
```

---

## 🔄 Service Updates

### Future Enhancements
- Promotional offers support (iOS)
- Proration calculation on backend
- Multi-device subscription sync
- Enhanced error recovery
- Offline purchase queue
- Subscription analytics

---

*For component usage, see `components.md`*  
*For user flows, see `user-flows.md`*  
*For technical details, see `technical-spec.md`*
