# Subscription & Payment System - Technical Specification

## 🏗️ Architecture Overview

### Technology Stack

#### In-App Purchase
- **react-native-iap** - Cross-platform IAP library
  - iOS: App Store Connect integration
  - Android: Google Play Billing integration
  - Product fetching and purchase management
  - Purchase restoration
  - Receipt handling

#### Backend
- **Supabase Database**
  - `subscriptions` table - Subscription records
  - `payments` table - Payment history
  - `iap_receipts` table - Receipt storage
- **Supabase Edge Functions**
  - `validate-iap-receipt` - Receipt validation service
  - Apple receipt validation (production + sandbox)
  - Google Play receipt validation

#### State Management
- **React Hooks** - Custom hooks for subscription logic
- **AsyncStorage** - Local caching and persistence
- **React Context** - Global subscription state (if needed)

#### Services Layer
- `IAPService` - IAP provider abstraction
- `SubscriptionService` - Backend subscription operations
- `ProductionBackendService` - Supabase integration
- `SubscriptionStorage` - Local storage management

---

## 📁 File Structure

```
src/
├── screens/
│   ├── SubscribeScreen.tsx              # Main subscription screen
│   └── DownsellScreen.tsx                # Exit-intent discount offer
├── components/
│   ├── payment/
│   │   ├── SubscriptionCard.tsx         # Plan display card
│   │   ├── DiscountButton.tsx           # Shake discount button
│   │   ├── TrustElements.tsx            # Trust badges (trial, guarantee)
│   │   └── AdditionalTrustElements.tsx   # Value props, objections
│   └── subscription/
│       ├── SubscriptionManagementModal.tsx  # Subscription management UI
│       └── TrialInfoCard.tsx            # Trial information display
├── services/
│   ├── IAPService.ts                    # IAP provider service
│   ├── SubscriptionService.ts           # Backend subscription operations
│   └── ProductionBackendService.ts      # Supabase integration
├── hooks/
│   ├── useSubscriptionForm.ts          # Subscription form logic
│   ├── useSubscriptionManagement.ts     # Subscription management
│   └── useTrialStatus.ts                # Trial status tracking
├── utils/
│   └── subscriptionStorage.ts           # Local storage utilities
├── types/
│   └── subscription.ts                  # TypeScript type definitions
└── integrations/
    └── supabase/
        └── functions/
            └── validate-iap-receipt/     # Edge Function for receipt validation
```

---

## 🔧 Components

### SubscribeScreen
**Location:** `src/screens/SubscribeScreen.tsx`

**Purpose:** Main subscription plan selection screen

**State:**
- `selectedPlan: SubscriptionPeriod` - Currently selected plan
- `isDiscountApplied: boolean` - Discount activation status
- `isShakingDevice: boolean` - Shake animation state
- `isProcessing: boolean` - Purchase processing state

**Components Used:**
- `SubscriptionCard` - Plan display cards
- `TrialInfoCard` - Trial information
- `MoneyBackGuarantee` - Trust element
- `ScientificProof` - Trust element
- `ValuePropositionSection` - Value props
- `ObjectionHandling` - Objection handling
- `DiscountButton` - Shake discount button

**Hooks Used:**
- `useSubscriptionForm` - Subscription form logic

**Features:**
- Plan selection (weekly, monthly, annual)
- Discount activation (shake)
- Purchase initiation
- Trust elements display
- Plan comparison

---

### DownsellScreen
**Location:** `src/screens/DownsellScreen.tsx`

**Purpose:** Exit-intent discount offer with countdown

**State:**
- `countdown: number` - Timer countdown (120 seconds)
- `selectedPlan: SubscriptionPeriod` - Selected plan
- `isProcessing: boolean` - Purchase processing

**Features:**
- 30% additional discount offer
- Countdown timer
- Permanent dismissal option
- Auto-redirect on timer expiry
- Close confirmation dialog

**Storage:**
- `downsellOfferDismissed` - Permanent dismissal flag

---

### SubscriptionCard Component
**Location:** `src/components/payment/SubscriptionCard.tsx`

**Purpose:** Plan display card with selection

**Props:**
```typescript
interface SubscriptionCardProps {
  period: string;
  price: number;
  originalPrice: number;
  perUnit: string;
  dailyPrice: string;
  features: string[];
  recommended?: boolean;
  savings?: string;
  onSelect: () => void;
  selected: boolean;
  isDiscountApplied?: boolean;
}
```

**Features:**
- Plan pricing display
- Daily price breakdown
- Feature list (when selected)
- Recommended badge
- Savings badge
- Selection indicator
- Discount application
- Animated selection state

---

## 🔌 Services

### IAPService
**Location:** `src/services/IAPService.ts`

**Class:** Singleton service

**Product IDs:**
```typescript
iOS: [
  'com.awave.premium.weekly',
  'com.awave.premium.monthly',
  'com.awave.premium.annual',
]
Android: [
  'awave_premium_weekly',
  'awave_premium_monthly',
  'awave_premium_annual',
]
```

**Methods:**
- `initialize()` - Initialize IAP connection
- `getProducts()` - Fetch available products
- `purchaseProduct(productId, applyIntroOffer, userId)` - Initiate purchase
- `restorePurchases(userId)` - Restore previous purchases
- `validateReceipt(receipt, productId, userId)` - Validate receipt with backend
- `cleanup()` - Cleanup resources

**Configuration:**
- Product IDs configured per platform
- Intro offer IDs (for future promotional offers)
- Pending purchase storage key

**Error Handling:**
- User cancellation (returns gracefully, no error)
- Network errors
- Invalid product IDs
- Store connectivity issues

---

### SubscriptionService
**Location:** `src/services/SubscriptionService.ts`

**Purpose:** Backend subscription operations

**Methods:**
- `getUserSubscription(userId)` - Get current subscription
- `getPaymentHistory(userId, limit)` - Get payment history
- `changePlan(userId, newPlan)` - Change subscription plan
- `cancelSubscription(userId, request)` - Cancel subscription
- `reactivateSubscription(userId)` - Reactivate cancelled subscription
- `calculateProration(userId, newPlan)` - Calculate proration (future)

**Database Operations:**
- Queries `subscriptions` table
- Queries `payments` table
- Calls Supabase RPC functions:
  - `change_subscription_plan`
  - `cancel_subscription`
  - `reactivate_subscription`

---

### ProductionBackendService
**Location:** `src/services/ProductionBackendService.ts`

**Subscription Methods:**
- `getUserSubscription(userId)` - Get subscription from database
- `createSubscription(userId, planType)` - Create trial subscription
- `checkTrialDaysRemaining(userId)` - Calculate trial days remaining

**Database Tables:**
- `subscriptions` - Subscription records
- `user_profiles` - User profile data

---

### SubscriptionStorage
**Location:** `src/utils/subscriptionStorage.ts`

**Purpose:** Local storage management

**Storage Keys:**
- `awaveSelectedPlan` - Selected plan data
- `awaveDiscount` - Discount activation status
- `downsellOfferDismissed` - Downsell dismissal flag

**Methods:**
- `saveSelectedPlan(selection)` - Save plan selection
- `getSelectedPlan()` - Retrieve plan selection
- `clearSelectedPlan()` - Clear plan selection
- `isDiscountActivated()` - Check discount status
- `setDiscountActivated(activated)` - Set discount status
- `isDownsellPermanentlyDismissed()` - Check downsell dismissal
- `setDownsellPermanentlyDismissed()` - Set downsell dismissal

---

## 🪝 Hooks

### useSubscriptionForm
**Location:** `src/hooks/useSubscriptionForm.ts`

**Purpose:** Subscription form state and logic

**Returns:**
```typescript
{
  selectedPlan: SubscriptionPeriod;
  setSelectedPlan: (plan) => void;
  isDiscountApplied: boolean;
  isShakingDevice: boolean;
  isProcessing: boolean;
  handleContinue: () => Promise<void>;
  getDiscountedPrice: (originalPrice) => number;
  activateDiscount: () => void;
  getDailyPrice: (price, days) => string;
  getSavingsPercentage: (planType) => string;
  getPlanDetails: () => PlanDetails;
}
```

**Features:**
- Plan selection state
- Discount management
- Price calculations
- Purchase initiation
- IAP integration

---

### useSubscriptionManagement
**Location:** `src/hooks/useSubscriptionManagement.ts`

**Purpose:** Subscription management operations

**Returns:**
```typescript
{
  subscription: SubscriptionDetails | null;
  paymentHistory: PaymentHistory[];
  isLoading: boolean;
  isChangingPlan: boolean;
  isCancelling: boolean;
  error: string | null;
  refreshSubscription: () => Promise<void>;
  changePlan: (newPlan) => Promise<boolean>;
  cancelSubscription: (request) => Promise<boolean>;
  reactivateSubscription: () => Promise<boolean>;
}
```

**Features:**
- Subscription data fetching
- Plan change operations
- Cancellation handling
- Reactivation handling
- Payment history retrieval

---

### useTrialStatus
**Location:** `src/hooks/useTrialStatus.ts`

**Purpose:** Trial status tracking and reminders

**Returns:**
```typescript
{
  trialDaysRemaining: number | null;
  isTrialActive: boolean;
  showTrialReminder: boolean;
  checkTrialStatus: () => Promise<void>;
  createTrialSubscription: (planType, planPrice, planInterval) => Promise<any>;
}
```

**Features:**
- Trial status checking
- Days remaining calculation
- Trial reminder scheduling
- Trial creation
- Local trial status caching

---

## 🔐 Security Implementation

### Receipt Validation
- **Server-side validation** - All receipts validated via Supabase Edge Function
- **Apple validation** - Production and sandbox environment support
- **Google validation** - Play Developer API integration
- **Receipt storage** - Secure storage in `iap_receipts` table
- **No local validation** - All validation happens server-side

### Payment Security
- **No credit card data** - All payments through store platforms
- **No payment tokens stored** - Only transaction IDs stored
- **HTTPS only** - All network requests use HTTPS
- **Secure storage** - Receipts stored securely in database

### IAP Security
- **Native SDKs** - Uses official store SDKs
- **No token exposure** - Receipts handled securely
- **Automatic validation** - Receipts validated automatically
- **Transaction finishing** - Transactions finished after validation

---

## 🔄 State Management

### Subscription State
```typescript
{
  selectedPlan: 'weekly' | 'monthly' | 'annual';
  isDiscountApplied: boolean;
  isShakingDevice: boolean;
  isProcessing: boolean;
}
```

### Subscription Details State
```typescript
{
  id: string;
  userId: string;
  planType: PlanType;
  status: SubscriptionStatus;
  currentPeriodStart: string;
  currentPeriodEnd: string;
  nextBillingDate: string | null;
  amount: number;
  currency: string;
  isTrialActive: boolean;
  trialDaysRemaining: number | null;
  trialEndDate: string | null;
  cancelAtPeriodEnd: boolean;
  cancelledAt: string | null;
}
```

### Trial State
```typescript
{
  isActive: boolean;
  endDate: string;
  daysRemaining: number;
}
```

---

## 🌐 API Integration

### Supabase Database

#### Subscriptions Table
```sql
CREATE TABLE subscriptions (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  plan_type plan_type NOT NULL,
  status subscription_status NOT NULL,
  trial_start TIMESTAMPTZ,
  trial_end TIMESTAMPTZ,
  trial_days_remaining INTEGER,
  current_period_start TIMESTAMPTZ,
  current_period_end TIMESTAMPTZ,
  cancel_at_period_end BOOLEAN,
  auto_renew BOOLEAN,
  selected_plan_price NUMERIC,
  selected_plan_interval TEXT,
  iap_transaction_id TEXT,
  iap_original_transaction_id TEXT,
  iap_platform TEXT,
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ
);
```

#### Payments Table
```sql
CREATE TABLE payments (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  amount NUMERIC,
  currency TEXT,
  status TEXT,
  plan_type plan_type,
  invoice_url TEXT,
  description TEXT,
  created_at TIMESTAMPTZ
);
```

#### IAP Receipts Table
```sql
CREATE TABLE iap_receipts (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  transaction_id TEXT,
  original_transaction_id TEXT,
  product_id TEXT,
  platform TEXT,
  receipt_data TEXT,
  validation_response JSONB,
  purchase_date TIMESTAMPTZ,
  expires_date TIMESTAMPTZ,
  is_trial_period BOOLEAN,
  is_intro_offer BOOLEAN,
  created_at TIMESTAMPTZ
);
```

### Supabase Edge Functions

#### validate-iap-receipt
**Endpoint:** `supabase.functions.invoke('validate-iap-receipt')`

**Request:**
```typescript
{
  receipt: string;
  productId: string;
  platform: 'ios' | 'android';
  userId?: string;
}
```

**Response:**
```typescript
{
  valid: boolean;
  transactionId?: string;
  expiresDate?: string;
  error?: string;
}
```

**Functionality:**
- Validates Apple receipts (production + sandbox)
- Validates Google Play receipts
- Stores receipts in database
- Updates subscription records
- Returns validation result

---

## 📱 Platform-Specific Notes

### iOS
- **App Store Connect** - Product IDs must be configured
- **Receipt format** - Base64 encoded receipt data
- **Transaction clearing** - Old transactions cleared on init
- **Sandbox testing** - Sandbox environment for testing
- **Production validation** - Production environment for live

### Android
- **Play Console** - Product IDs must be configured
- **Purchase token** - Token-based validation
- **Play Developer API** - Service account required
- **Billing library** - Google Play Billing Library integration

### Deep Link Handling
- Purchase completion may trigger deep links
- Receipt validation may be triggered via deep links
- Subscription status updates via deep links

---

## 🧪 Testing Strategy

### Unit Tests
- Price calculation functions
- Discount application logic
- Trial days remaining calculation
- Storage operations
- Plan selection logic

### Integration Tests
- IAP purchase flow
- Receipt validation
- Subscription creation
- Plan changes
- Cancellation flow

### E2E Tests
- Complete purchase flow
- Trial creation and expiration
- Subscription management
- Purchase restoration
- Discount activation

---

## 🐛 Error Handling

### Error Types
- Network errors
- Invalid receipts
- Store connectivity issues
- Product not found
- Purchase failures
- Validation failures

### Error Messages
- User-friendly German messages
- Clear action guidance
- Retry options where applicable
- No technical jargon

---

## 📊 Performance Considerations

### Optimization
- Product caching after initial fetch
- Lazy loading of subscription data
- Efficient receipt validation
- Local storage for offline support
- Debounced discount activation

### Monitoring
- Purchase success rate
- Receipt validation success rate
- Average purchase completion time
- Subscription management success rate
- Discount activation rate

---

*For component details, see `components.md`*  
*For service dependencies, see `services.md`*  
*For user flows, see `user-flows.md`*
