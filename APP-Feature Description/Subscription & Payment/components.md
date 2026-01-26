# Subscription & Payment System - Components Inventory

## 📱 Screens

### SubscribeScreen
**File:** `src/screens/SubscribeScreen.tsx`  
**Route:** `/subscribe`  
**Purpose:** Main subscription plan selection screen

**Props:**
```typescript
// No props - uses navigation hook
```

**State:**
- `selectedPlan: SubscriptionPeriod` - Currently selected plan
- `isDiscountApplied: boolean` - Discount activation status
- `isShakingDevice: boolean` - Shake animation state
- `isProcessing: boolean` - Purchase processing state

**Components Used:**
- `SubscriptionCard` - Plan display cards (3 instances)
- `TrialInfoCard` - Trial information display
- `MoneyBackGuarantee` - Trust element
- `ScientificProof` - Scientific proof display
- `ValuePropositionSection` - Value propositions
- `ObjectionHandling` - Objection handling section
- `DiscountButton` - Shake discount activation button
- `AnimatedButton` - Continue button
- `LinearGradient` - Background gradient

**Hooks Used:**
- `useSubscriptionForm` - Subscription form logic
- `useNavigation` - Navigation handling
- `useTheme` - Theme styling

**Features:**
- Plan selection (weekly, monthly, annual)
- Discount activation (shake)
- Purchase initiation
- Trust elements display
- Plan comparison
- Responsive layout
- Loading states

**User Interactions:**
- Select subscription plan
- Activate shake discount
- Continue to purchase
- Close screen

---

### DownsellScreen
**File:** `src/screens/DownsellScreen.tsx`  
**Route:** `/downsell`  
**Purpose:** Exit-intent discount offer with countdown timer

**State:**
- `countdown: number` - Timer countdown (120 seconds)
- `selectedPlan: SubscriptionPeriod` - Selected plan
- `isProcessing: boolean` - Purchase processing state

**Components Used:**
- `SubscriptionCard` - Plan display cards (3 instances)
- `TrialInfoCard` - Trial information
- `MoneyBackGuarantee` - Trust element
- `AnimatedButton` - Purchase button
- `LinearGradient` - Background gradient
- `Icon` - Timer icon

**Hooks Used:**
- `useSubscriptionForm` - Subscription form logic
- `useNavigation` - Navigation handling

**Features:**
- 30% additional discount offer
- Countdown timer (120 seconds)
- Permanent dismissal option
- Auto-redirect on timer expiry
- Close confirmation dialog
- Discount applied to all plans

**User Interactions:**
- Select plan with discount
- Continue to purchase
- Decline offer (with confirmation)
- Close screen (with confirmation)

**Storage:**
- `downsellOfferDismissed` - Permanent dismissal flag

---

## 🧩 Components

### SubscriptionCard
**File:** `src/components/payment/SubscriptionCard.tsx`  
**Type:** Plan Display Card

**Props:**
```typescript
interface SubscriptionCardProps {
  period: string;              // Display period text
  price: number;               // Current price
  originalPrice: number;       // Original price
  perUnit: string;             // Unit text (Woche/Monat/Jahr)
  dailyPrice: string;          // Daily price display
  features: string[];           // Feature list
  recommended?: boolean;       // Recommended badge
  savings?: string;            // Savings percentage
  onSelect: () => void;        // Selection handler
  selected: boolean;           // Selection state
  isDiscountApplied?: boolean; // Discount state
}
```

**State:**
- `scaleAnim: Animated.Value` - Selection animation

**Components Used:**
- `LinearGradient` - Card gradient background
- `Check` icon - Feature checkmarks
- `Animated.View` - Animated container

**Features:**
- Plan pricing display
- Daily price breakdown
- Feature list (when selected)
- Recommended badge
- Savings badge
- Selection indicator
- Discount application
- Animated selection state
- Visual feedback on selection

**Styling:**
- Gradient background
- Border highlight when selected
- Shadow effects
- Responsive layout

---

### DiscountButton
**File:** `src/components/payment/DiscountButton.tsx`  
**Type:** Discount Activation Button

**Props:**
```typescript
interface DiscountButtonProps {
  isDiscountApplied: boolean;
  isShakingDevice: boolean;
  onActivateDiscount: () => void;
}
```

**Features:**
- Shake device to activate discount
- Visual feedback (shaking animation)
- Discount status display
- 20% discount activation
- Persistent discount state

**User Interactions:**
- Shake device to activate
- Visual confirmation

---

### TrialInfoCard
**File:** `src/components/payment/TrustElements.tsx`  
**Type:** Trust Element Component

**Props:** None (stateless)

**Features:**
- 7-day free trial information
- Timeline visualization
- Step indicators (Today, Day 5, Day 7)
- Clear messaging
- Gradient background

**Content:**
- "7 Tage kostenlos testen"
- "Keine Abbuchung heute. Jederzeit kündbar."
- Timeline steps with descriptions

---

### MoneyBackGuarantee
**File:** `src/components/payment/TrustElements.tsx`  
**Type:** Trust Element Component

**Props:** None (stateless)

**Features:**
- 30-day money-back guarantee
- Shield icon
- Clear guarantee text
- Trust-building element

**Content:**
- "30 Tage Geld-zurück-Garantie"
- "Wenn du nicht zufrieden bist, erstatten wir dir den vollen Betrag. Ohne Fragen."

---

### ScientificProof
**File:** `src/components/payment/TrustElements.tsx`  
**Type:** Trust Element Component

**Props:** None (stateless)

**Features:**
- Scientific proof statistics
- Visual proof grid
- Icon-based display
- Trust-building data

**Content:**
- "40% Weniger Stress"
- "60% Bessere Schlafqualität"
- "35% Mehr Konzentration"

---

### ValuePropositionSection
**File:** `src/components/payment/AdditionalTrustElements.tsx`  
**Type:** Value Proposition Component

**Props:** None (stateless)

**Features:**
- Value proposition display
- Key benefits listing
- Visual elements
- Trust-building content

---

### ObjectionHandling
**File:** `src/components/payment/AdditionalTrustElements.tsx`  
**Type:** Objection Handling Component

**Props:** None (stateless)

**Features:**
- Common objections addressed
- FAQ-style content
- Trust-building responses
- Conversion optimization

---

### SubscriptionManagementModal
**File:** `src/components/subscription/SubscriptionManagementModal.tsx`  
**Type:** Modal Component

**Props:**
```typescript
interface SubscriptionManagementModalProps {
  isOpen: boolean;
  onClose: () => void;
  currentPlan: string;
  currentStatus: string;
}
```

**State:**
- `selectedPlan: string` - Selected plan
- `selectedPaymentMethod: string` - Selected payment method
- `activeTab: 'plans' | 'payment' | 'billing'` - Active tab

**Features:**
- Tab navigation (Plans, Payment, Billing)
- Plan selection
- Payment method selection
- Subscription cancellation
- Billing history
- Plan change functionality

**Tabs:**
1. **Plans** - View and change subscription plans
2. **Payment** - Manage payment methods
3. **Billing** - View billing history

---

## 🔗 Component Relationships

### SubscribeScreen Component Tree
```
SubscribeScreen
├── SafeAreaView
│   ├── View (Header)
│   │   ├── Text (Title)
│   │   └── TouchableOpacity (Close)
│   └── ScrollView
│       ├── TrialInfoCard
│       ├── MoneyBackGuarantee
│       ├── Text (Description)
│       ├── View (Plans Container)
│       │   ├── SubscriptionCard (Weekly)
│       │   ├── SubscriptionCard (Monthly)
│       │   └── SubscriptionCard (Annual)
│       ├── ScientificProof
│       ├── ValuePropositionSection
│       ├── ObjectionHandling
│       ├── DiscountButton
│       └── TouchableOpacity (Continue)
│           └── LinearGradient
│               └── Text (Button Text)
└── LinearGradient (Background)
```

### DownsellScreen Component Tree
```
DownsellScreen
├── SafeAreaView
│   ├── View (Header)
│   │   ├── Text (Title)
│   │   └── TouchableOpacity (Close)
│   └── ScrollView
│       ├── View (Offer Header)
│       │   ├── Icon (Sparkles)
│       │   └── Text (Offer Title)
│       ├── Text (Description)
│       ├── TrialInfoCard
│       ├── MoneyBackGuarantee
│       ├── View (Plans Container)
│       │   ├── SubscriptionCard (Weekly)
│       │   ├── SubscriptionCard (Monthly)
│       │   └── SubscriptionCard (Annual)
│       ├── View (Timer Container)
│       │   ├── Icon (Timer)
│       │   └── Text (Countdown)
│       ├── TouchableOpacity (Continue)
│       └── TouchableOpacity (Decline)
└── LinearGradient (Background)
```

---

## 🎨 Styling

### Theme Integration
All components use the theme system:
- Colors: `theme.colors.primary`, `theme.colors.textPrimary`, etc.
- Typography: `theme.typography.fontFamily`
- Spacing: Consistent padding and margins

### Color Scheme
- **Primary:** `#9b87f5` (Purple)
- **Background:** `#0F172A` (Dark blue)
- **Gradient:** `['#0F172A', '#1E1B4B']`
- **Text:** White with opacity variations
- **Accent:** `#C084FC` (Light purple)

### Responsive Design
- ScrollView for small screens
- SafeAreaView for status bar handling
- Flexible layouts
- Touch target sizes (min 44x44)

### Accessibility
- Semantic labels
- Touch target sizes
- Color contrast compliance
- Screen reader support

---

## 🔄 State Management

### Local State
- Form inputs (plan selection)
- UI state (loading, errors, visibility)
- Discount status
- Timer countdown

### Persistent State
- `AsyncStorage` - Plan selection, discount status, dismissal flags
- Supabase database - Subscription records, payment history

### Context State
- Subscription status (if using context)
- User authentication state

---

## 🧪 Testing Considerations

### Component Tests
- Plan selection
- Discount activation
- Button interactions
- State updates
- Error display
- Loading states

### Integration Tests
- Purchase flow
- Navigation flows
- IAP integration
- Receipt validation
- Subscription management

### E2E Tests
- Complete purchase journey
- Discount activation flow
- Downsell offer flow
- Subscription management flow

---

## 📊 Component Metrics

### Complexity
- **SubscribeScreen:** High (multiple components, IAP integration)
- **DownsellScreen:** Medium (timer, discount logic)
- **SubscriptionCard:** Medium (animations, state)
- **Trust Elements:** Low (display only)

### Reusability
- **SubscriptionCard:** High (used in multiple screens)
- **Trust Elements:** High (used in multiple screens)
- **DiscountButton:** Medium (specific use case)

### Dependencies
- All screens depend on theme system
- All screens depend on navigation
- IAP screens depend on native modules
- Components depend on hooks for logic

---

*For service dependencies, see `services.md`*  
*For user flows, see `user-flows.md`*  
*For technical details, see `technical-spec.md`*
