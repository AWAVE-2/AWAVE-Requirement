# Sales Screens - Technical Specification

## 🏗️ Architecture Overview

### Technology Stack

#### UI Framework
- **React Native** - Cross-platform mobile framework
- **React Navigation** - Screen navigation and routing
- **LinearGradient** - `react-native-linear-gradient` for gradient backgrounds
- **Lucide Icons** - `lucide-react-native` for iconography

#### State Management
- **React Hooks** - `useState`, `useEffect`, `useCallback`
- **Custom Hooks** - `useSubscriptionForm` for sales form logic
- **AsyncStorage** - Local persistence for discounts and selections

#### Sensors
- **React Native Sensors** - Accelerometer for shake detection
- **Sensor Types** - `SensorTypes.accelerometer`
- **Update Interval** - 100ms for responsive shake detection

#### IAP Integration
- **react-native-iap** - In-App Purchase library
- **Platform-specific** - iOS and Android product IDs
- **Receipt Validation** - Supabase Edge Function

#### Storage
- **AsyncStorage** - Local key-value storage
- **Storage Keys:**
  - `awaveSelectedPlan` - Selected plan data
  - `awaveDiscount` - Discount activation status
  - `downsellOfferDismissed` - Permanent dismissal flag

---

## 📁 File Structure

```
src/
├── screens/
│   ├── SubscribeScreen.tsx              # Main subscription sales screen
│   └── DownsellScreen.tsx                # Exit-intent discount offer
├── components/
│   └── payment/
│       ├── SubscriptionCard.tsx          # Plan display card
│       ├── TrustElements.tsx             # Trial, guarantee, proof
│       ├── AdditionalTrustElements.tsx   # Value props, objections
│       └── DiscountButton.tsx             # Shake discount component
├── hooks/
│   └── useSubscriptionForm.ts            # Sales form logic hook
└── utils/
    └── subscriptionStorage.ts            # Local storage utilities
```

---

## 🔧 Components

### SubscribeScreen
**Location:** `src/screens/SubscribeScreen.tsx`

**Purpose:** Main subscription plan selection and sales screen

**Props:**
```typescript
// No props - uses navigation hook
```

**State:**
```typescript
{
  selectedPlan: SubscriptionPeriod;  // 'weekly' | 'monthly' | 'annual'
  isDiscountApplied: boolean;
  isShakingDevice: boolean;
  isProcessing: boolean;
}
```

**Components Used:**
- `SubscriptionCard` (3 instances)
- `TrialInfoCard`
- `MoneyBackGuarantee`
- `ScientificProof`
- `ValuePropositionSection`
- `ObjectionHandling`
- `DiscountButton`
- `AnimatedButton`
- `LinearGradient`

**Hooks Used:**
- `useSubscriptionForm` - Sales form logic
- `useNavigation` - Navigation handling

**Features:**
- Plan selection with visual feedback
- Shake discount activation
- Trust elements display
- Purchase flow initiation
- Responsive scrollable layout

**Navigation:**
- Route: `/subscribe`
- Can navigate back or to MainTabs
- Navigates to Auth after successful purchase

---

### DownsellScreen
**Location:** `src/screens/DownsellScreen.tsx`

**Purpose:** Exit-intent discount offer with countdown timer

**Props:**
```typescript
// No props - uses navigation hook
```

**State:**
```typescript
{
  countdown: number;  // 120 seconds
  selectedPlan: SubscriptionPeriod;
  isProcessing: boolean;
}
```

**Components Used:**
- `SubscriptionCard` (3 instances)
- `TrialInfoCard`
- `MoneyBackGuarantee`
- `AnimatedButton`
- `LinearGradient`
- `Icon` (Timer, Sparkles)

**Hooks Used:**
- `useSubscriptionForm` - Sales form logic
- `useNavigation` - Navigation handling
- `useEffect` - Countdown timer
- `useCallback` - Timer expiration handler

**Features:**
- 120-second countdown timer
- 30% additional discount on all plans
- Exit prevention dialog
- Permanent dismissal option
- Same purchase flow as SubscribeScreen

**Navigation:**
- Route: `/downsell`
- Navigates to Start on timer expiration
- Navigates to Start on permanent dismissal
- Navigates to Auth after successful purchase

**Timer Logic:**
- Starts at 120 seconds
- Decrements every second
- Auto-navigates on expiration
- Clears on component unmount

---

### SubscriptionCard Component
**Location:** `src/components/payment/SubscriptionCard.tsx`

**Purpose:** Individual plan display card

**Props:**
```typescript
interface SubscriptionCardProps {
  price: number;
  originalPrice: number;
  period: string;
  perUnit: string;
  features: string[];
  recommended?: boolean;
  savings?: string;
  dailyPrice: string;
  onSelect: () => void;
  selected: boolean;
  isDiscountApplied?: boolean;
}
```

**Features:**
- Animated selection (scale effect)
- Recommended badge ("Meistgewählt")
- Savings badge (percentage)
- Original price with strikethrough
- Daily price display
- Feature list (shown when selected)
- Radio button indicator (hidden)
- Gradient border on selection

**Animations:**
- Spring animation on selection (scale 1.02)
- Smooth transitions
- Native driver for performance

---

### TrustElements Components
**Location:** `src/components/payment/TrustElements.tsx`

**Components:**
1. **TrialInfoCard**
   - 7-day trial messaging
   - Timeline visualization
   - Gradient background

2. **MoneyBackGuarantee**
   - 30-day guarantee
   - Shield icon
   - Green theme

3. **ScientificProof**
   - Research statistics
   - Grid layout with icons
   - Source citation

---

### AdditionalTrustElements Components
**Location:** `src/components/payment/AdditionalTrustElements.tsx`

**Components:**
1. **ValuePropositionSection**
   - Cost comparison card
   - Immediate effects card
   - Personalization card
   - Check marks for benefits

2. **ObjectionHandling**
   - Six objection cards
   - Privacy, cancellation, pricing, etc.
   - Color-coded icons

---

### DiscountButton Component
**Location:** `src/components/payment/DiscountButton.tsx`

**Purpose:** Shake discount activation component

**Props:**
```typescript
interface DiscountButtonProps {
  isDiscountApplied: boolean;
  isShakingDevice?: boolean;
  onActivateDiscount: () => void;
}
```

**Features:**
- Accelerometer shake detection
- Threshold: speed > 15
- Update interval: 100ms
- Visual feedback when activated
- Fallback for simulators (auto-activate after 5s)

**Sensor Integration:**
```typescript
accelerometer.pipe(
  map(({ x, y, z }) => Math.sqrt(x * x + y * y + z * z))
).subscribe({
  next: (speed) => {
    if (speed > 15 && !isDiscountApplied) {
      onActivateDiscount();
    }
  }
});
```

---

## 🪝 Hooks

### useSubscriptionForm
**Location:** `src/hooks/useSubscriptionForm.ts`

**Purpose:** Sales form logic and state management

**Returns:**
```typescript
{
  selectedPlan: SubscriptionPeriod;
  setSelectedPlan: (plan: SubscriptionPeriod) => void;
  isDiscountApplied: boolean;
  isShakingDevice: boolean;
  isProcessing: boolean;
  handleContinue: () => Promise<void>;
  getDiscountedPrice: (originalPrice: number) => number;
  activateDiscount: () => void;
  getDailyPrice: (price: number, days: number) => string;
  getSavingsPercentage: (planType: SubscriptionPeriod) => string;
  getPlanDetails: () => PlanDetails;
}
```

**Features:**
- Plan selection state
- Discount activation and persistence
- Price calculations (discounted, daily, savings)
- Purchase flow initiation
- IAP product ID mapping
- Error handling

**Price Calculation Logic:**
```typescript
// Base discounts
monthly: 11.99 → 8.39 (30% off)
annual: 79.99 → 79.99 (61% savings vs weekly)

// Additional discounts
shake: 20% off
downsell: 30% off

// Combined: base discount * additional discount
```

**Purchase Flow:**
1. Save plan selection to storage
2. Map plan to IAP product ID
3. Call IAPService.purchaseProduct()
4. Handle result (success/error/cancellation)
5. Navigate on success

---

## 🔌 Services

### SubscriptionStorage
**Location:** `src/utils/subscriptionStorage.ts`

**Purpose:** Local storage management for sales screens

**Methods:**
- `saveSelectedPlan(selection)` - Save plan selection
- `getSelectedPlan()` - Retrieve plan selection
- `clearSelectedPlan()` - Clear plan selection
- `isDiscountActivated()` - Check discount status
- `setDiscountActivated(activated)` - Set discount status
- `isDownsellPermanentlyDismissed()` - Check dismissal status
- `setDownsellPermanentlyDismissed()` - Set dismissal status

**Storage Keys:**
- `awaveSelectedPlan` - JSON string of PlanSelection
- `awaveDiscount` - "true" | "false"
- `downsellOfferDismissed` - "true" | "false"

---

### IAPService Integration
**Location:** `src/services/IAPService.ts`

**Methods Used:**
- `purchaseProduct(productId, applyIntroOffer, userId)` - Initiate purchase

**Product ID Mapping:**
```typescript
Platform.select({
  ios: `com.awave.premium.${selectedPlan}`,
  android: `awave_premium_${selectedPlan}`,
})
```

**Purchase Result:**
```typescript
{
  success: boolean;
  transactionId?: string;
  productId?: string;
  error?: string;
}
```

---

## 🎨 Styling

### Theme
- **Background:** Dark purple gradient (`#0F172A` to `#1E1B4B`)
- **Primary Color:** Purple (`#9b87f5`)
- **Text:** White with opacity variations
- **Accents:** Green (guarantee), Blue (info), Orange (proof)

### Typography
- **Header Title:** 24px, bold, white
- **Plan Period:** 18px, semibold
- **Price:** 24px, bold, white
- **Daily Price:** 16px, bold, purple
- **Features:** 13px, regular, white (80% opacity)

### Spacing
- **Card Padding:** 20px
- **Card Margin:** 16px bottom
- **Section Margin:** 24-32px bottom
- **Container Padding:** 20px horizontal

### Animations
- **Plan Selection:** Spring animation (scale 1.02)
- **Shake Detection:** Visual feedback (1.5s)
- **Countdown:** Smooth number updates (1s interval)

---

## 🔄 State Management

### Local State (Component)
- Plan selection
- Discount status
- Processing state
- Countdown timer

### Persistent State (AsyncStorage)
- Selected plan data
- Discount activation
- Downsell dismissal

### Derived State
- Discounted prices
- Daily prices
- Savings percentages
- Display prices

---

## 🌐 Platform-Specific Notes

### iOS
- Product IDs: `com.awave.premium.{period}`
- Receipt format: `transactionReceipt`
- Native purchase dialog
- Shake detection works natively

### Android
- Product IDs: `awave_premium_{period}`
- Receipt format: `purchaseToken`
- Native purchase dialog
- Shake detection works natively

### Simulators
- Shake detection fallback (auto-activate after 5s)
- IAP testing requires sandbox accounts
- Countdown timer works normally

---

## 🧪 Testing Strategy

### Unit Tests
- Price calculations
- Discount application
- Plan selection logic
- Storage operations
- Timer logic

### Integration Tests
- Purchase flow
- IAP integration
- Navigation flows
- Discount persistence

### E2E Tests
- Complete subscribe flow
- Complete downsell flow
- Shake discount activation
- Countdown timer expiration
- Exit prevention dialog

---

## 🐛 Error Handling

### Purchase Errors
- Network failures → User-friendly message
- User cancellation → Silent return (no error)
- Invalid product ID → Error message
- Store errors → Error message with retry

### Sensor Errors
- Sensor unavailable → Fallback (simulator)
- Sensor errors → Warning log, graceful degradation

### Timer Errors
- Backgrounded app → Timer continues
- Component unmount → Timer cleared
- Navigation during countdown → Timer cleared

---

## 📊 Performance Considerations

### Optimization
- Lazy loading of trust elements
- Memoized price calculations
- Efficient re-renders (React.memo)
- Native animations (useNativeDriver)

### Monitoring
- Screen load time
- Purchase completion rate
- Discount activation rate
- Countdown completion rate

---

## 🔐 Security Considerations

### Price Security
- Prices calculated client-side for display only
- Actual prices from IAP products (server-side)
- No price manipulation possible

### Storage Security
- No sensitive data in AsyncStorage
- Only UI state and preferences
- Receipts stored server-side only

---

*For component details, see `components.md`*  
*For service dependencies, see `services.md`*  
*For user flows, see `user-flows.md`*
