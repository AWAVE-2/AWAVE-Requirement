# Sales Screens - Components Inventory

## 📱 Screens

### SubscribeScreen
**File:** `src/screens/SubscribeScreen.tsx`  
**Route:** `/subscribe`  
**Purpose:** Main subscription plan selection and sales screen

**Props:**
```typescript
// No props - uses navigation hook
```

**State:**
- `selectedPlan: SubscriptionPeriod` - Currently selected plan (from hook)
- `isDiscountApplied: boolean` - Discount activation status (from hook)
- `isShakingDevice: boolean` - Shake animation state (from hook)
- `isProcessing: boolean` - Purchase processing state (from hook)

**Components Used:**
- `SubscriptionCard` - Plan display cards (3 instances: weekly, monthly, annual)
- `TrialInfoCard` - Trial information display
- `MoneyBackGuarantee` - Money-back guarantee card
- `ScientificProof` - Scientific proof section
- `ValuePropositionSection` - Value propositions display
- `ObjectionHandling` - Objection handling section
- `DiscountButton` - Shake discount activation button
- `AnimatedButton` - Continue button (via LinearGradient)
- `LinearGradient` - Background gradient
- `ScrollView` - Scrollable content container
- `SafeAreaView` - Safe area handling
- `TouchableOpacity` - Close button
- `Icon` (X, ArrowRight) - Icons from lucide-react-native

**Hooks Used:**
- `useSubscriptionForm` - Sales form logic and state
- `useNavigation` - Navigation handling

**Features:**
- Plan selection (weekly, monthly, annual)
- Discount activation (shake gesture)
- Purchase initiation
- Trust elements display
- Plan comparison
- Responsive scrollable layout
- Loading states
- Error handling

**User Interactions:**
- Select subscription plan (tap card)
- Shake device for discount
- Click "Weiter" (Continue) button
- Close screen (X button)

**Layout Structure:**
```
SubscribeScreen
├── View (Main Container)
│   ├── LinearGradient (Background)
│   └── SafeAreaView
│       ├── View (Header)
│       │   ├── Text (Title: "Wähle deinen Plan")
│       │   └── TouchableOpacity (Close Button)
│       └── ScrollView
│           ├── TrialInfoCard
│           ├── MoneyBackGuarantee
│           ├── Text (Description)
│           ├── View (Plans Container)
│           │   ├── SubscriptionCard (Weekly)
│           │   ├── SubscriptionCard (Monthly - Recommended)
│           │   └── SubscriptionCard (Annual)
│           ├── ScientificProof
│           ├── ValuePropositionSection
│           ├── ObjectionHandling
│           ├── DiscountButton
│           ├── TouchableOpacity (Continue Button)
│           └── View (Spacer)
```

---

### DownsellScreen
**File:** `src/screens/DownsellScreen.tsx`  
**Route:** `/downsell`  
**Purpose:** Exit-intent discount offer with countdown timer

**State:**
- `countdown: number` - Timer countdown (120 seconds)
- `selectedPlan: SubscriptionPeriod` - Selected plan (from hook)
- `isProcessing: boolean` - Purchase processing state (from hook)

**Components Used:**
- `SubscriptionCard` - Plan display cards (3 instances)
- `TrialInfoCard` - Trial information
- `MoneyBackGuarantee` - Money-back guarantee
- `AnimatedButton` - Purchase button (via LinearGradient)
- `LinearGradient` - Background gradient
- `ScrollView` - Scrollable content container
- `SafeAreaView` - Safe area handling
- `TouchableOpacity` - Close and decline buttons
- `Icon` (X, Sparkles, Timer) - Icons from lucide-react-native
- `Alert` - Confirmation dialog

**Hooks Used:**
- `useSubscriptionForm` - Sales form logic
- `useNavigation` - Navigation handling
- `useEffect` - Countdown timer and persistence check
- `useCallback` - Timer expiration handler

**Features:**
- 120-second countdown timer
- 30% additional discount on all plans
- Exit prevention dialog
- Permanent dismissal option
- Same purchase flow as SubscribeScreen
- Urgency messaging

**User Interactions:**
- Select subscription plan
- Click "Ja, ich will 30% sparen!" button
- Attempt to close (shows confirmation)
- Click decline button

**Layout Structure:**
```
DownsellScreen
├── View (Main Container)
│   ├── LinearGradient (Background)
│   └── SafeAreaView
│       ├── View (Header)
│       │   ├── Text (Title: "Warte! Letztes Angebot")
│       │   └── TouchableOpacity (Close Button)
│       └── ScrollView
│           ├── View (Offer Header)
│           │   ├── View (Icon Container)
│           │   └── Text (Offer Title)
│           ├── Text (Description)
│           ├── TrialInfoCard
│           ├── MoneyBackGuarantee
│           ├── View (Plans Container)
│           │   ├── SubscriptionCard (Weekly)
│           │   ├── SubscriptionCard (Monthly)
│           │   └── SubscriptionCard (Annual)
│           ├── View (Timer Container)
│           │   ├── View (Timer Header)
│           │   └── Text (Timer Text)
│           ├── TouchableOpacity (Purchase Button)
│           ├── TouchableOpacity (Decline Button)
│           └── View (Spacer)
```

---

## 🧩 Components

### SubscriptionCard
**File:** `src/components/payment/SubscriptionCard.tsx`  
**Type:** Plan Display Component

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

**State:**
- `scaleAnim: Animated.Value` - Selection animation value

**Components Used:**
- `TouchableOpacity` - Card container
- `Animated.View` - Animated content container
- `LinearGradient` - Card background and badge
- `View` - Layout containers
- `Text` - All text elements
- `Check` (icon) - Feature check marks

**Features:**
- Animated selection (scale 1.02)
- Recommended badge ("Meistgewählt")
- Savings badge (percentage)
- Original price with strikethrough
- Daily price display
- Feature list (shown when selected)
- Radio button indicator (hidden)
- Gradient border on selection

**Animations:**
- Spring animation on selection
- Smooth scale transition
- Native driver for performance

**Styling:**
- Selected: Purple border (2px), purple gradient background
- Unselected: White border (1px), subtle gradient background
- Badges: Positioned absolutely
- Features: Shown only when selected

---

### TrialInfoCard
**File:** `src/components/payment/TrustElements.tsx`  
**Type:** Trust Element Component

**Props:** None (stateless)

**Components Used:**
- `LinearGradient` - Card background
- `View` - Layout containers
- `Text` - Text elements
- `Sparkles` (icon) - Trial icon

**Features:**
- 7-day trial messaging
- Timeline visualization:
  - Today: Sofortiger Vollzugriff (active dot)
  - Day 5: Erinnerungs-Mail (inactive dot)
  - Day 7: Abo beginnt (inactive dot)
- Connecting lines between timeline steps
- Gradient background

**Layout:**
```
TrialInfoCard
├── LinearGradient
│   ├── View (Header)
│   │   ├── View (Icon Container)
│   │   └── View (Header Text)
│   │       ├── Text (Title)
│   │       └── Text (Subtitle)
│   └── View (Timeline)
│       ├── View (Step 1: Today)
│       ├── View (Line)
│       ├── View (Step 2: Day 5)
│       ├── View (Line)
│       └── View (Step 3: Day 7)
```

---

### MoneyBackGuarantee
**File:** `src/components/payment/TrustElements.tsx`  
**Type:** Trust Element Component

**Props:** None (stateless)

**Components Used:**
- `View` - Container
- `Shield` (icon) - Guarantee icon
- `Text` - Title and description

**Features:**
- 30-day money-back guarantee
- Shield icon
- Green theme styling
- Clear guarantee messaging

---

### ScientificProof
**File:** `src/components/payment/TrustElements.tsx`  
**Type:** Trust Element Component

**Props:** None (stateless)

**Components Used:**
- `View` - Container and grid
- `Text` - Title, values, labels, source
- `Bolt` (icon) - Stress reduction icon
- `Award` (icon) - Focus icon

**Features:**
- Research statistics display
- Two stat cards:
  - 40% Weniger Stress
  - 2x Mehr Fokus
- Source citation
- Grid layout with icons

---

### ValuePropositionSection
**File:** `src/components/payment/AdditionalTrustElements.tsx`  
**Type:** Trust Element Component

**Props:** None (stateless)

**Components Used:**
- `View` - Container and grid
- `Text` - Titles, descriptions
- `DollarSign` (icon) - Cost comparison icon
- `Zap` (icon) - Immediate effects icon
- `Target` (icon) - Personalization icon
- `Check` (icon) - Benefit check marks

**Features:**
- Three value proposition cards:
  1. **Cost Comparison**
     - Coaching: €150 (strikethrough)
     - Medication: €30/month (strikethrough)
     - AWAVE: €0.18/day (highlighted)
  2. **Immediate Effects**
     - First improvements after 3 days
     - Measurable stress reduction
     - Natural, no side effects
  3. **Personalization**
     - Adapts to your rhythm
     - Individual recommendations
     - Works on all devices

---

### ObjectionHandling
**File:** `src/components/payment/AdditionalTrustElements.tsx`  
**Type:** Trust Element Component

**Props:** None (stateless)

**Components Used:**
- `View` - Container and grid
- `Text` - Titles and descriptions
- Various icons (Lock, LogOut, DollarSign, Wifi, Brain, RotateCcw, Shield)

**Features:**
- Six objection handling cards:
  1. **Datenschutz garantiert** - Privacy guarantee
  2. **Einfache Kündigung** - Easy cancellation
  3. **Transparente Preise** - Transparent pricing
  4. **Funktioniert offline** - Offline functionality
  5. **Wissenschaftlich fundiert** - Scientific foundation
  6. **Flexibilität** - Flexibility options

**Styling:**
- Color-coded icons
- Grid layout (2 columns)
- Consistent card styling

---

### DiscountButton
**File:** `src/components/payment/DiscountButton.tsx`  
**Type:** Interactive Component

**Props:**
```typescript
interface DiscountButtonProps {
  isDiscountApplied: boolean;
  isShakingDevice?: boolean;
  onActivateDiscount: () => void;
}
```

**State:**
- `isShakeDetected: boolean` - Shake detection flag

**Components Used:**
- `View` - Container
- `LinearGradient` - Applied state background
- `Text` - Hint and applied messages
- `Bolt` (icon) - Applied state icon

**Features:**
- Accelerometer shake detection
- Threshold: speed > 15
- Update interval: 100ms
- Visual feedback when activated
- Fallback for simulators (auto-activate after 5s)

**States:**
1. **Not Applied:**
   - Shows hint text: "💡 Tipp: Schüttle dein Gerät für eine Überraschung"
2. **Applied:**
   - Shows success message: "20% Rabatt aktiviert!"
   - Green gradient background
   - Bolt icon

**Sensor Integration:**
```typescript
accelerometer.pipe(
  map(({ x, y, z }) => Math.sqrt(x * x + y * y + z * z))
).subscribe({
  next: (speed) => {
    if (speed > 15 && !isDiscountApplied && !isShakeDetected) {
      setIsShakeDetected(true);
      onActivateDiscount();
    }
  }
});
```

---

## 🔗 Component Relationships

### SubscribeScreen Component Tree
```
SubscribeScreen
├── View (Main Container)
│   ├── LinearGradient (Background)
│   └── SafeAreaView
│       ├── View (Header)
│       │   ├── Text (Title)
│       │   └── TouchableOpacity (Close)
│       └── ScrollView
│           ├── TrialInfoCard
│           │   ├── LinearGradient
│           │   ├── View (Header)
│           │   └── View (Timeline)
│           ├── MoneyBackGuarantee
│           │   ├── Shield Icon
│           │   └── Text (Guarantee)
│           ├── Text (Description)
│           ├── View (Plans)
│           │   ├── SubscriptionCard (Weekly)
│           │   ├── SubscriptionCard (Monthly)
│           │   └── SubscriptionCard (Annual)
│           ├── ScientificProof
│           │   ├── Text (Title)
│           │   ├── View (Grid)
│           │   └── Text (Source)
│           ├── ValuePropositionSection
│           │   ├── View (Header)
│           │   └── View (Grid)
│           ├── ObjectionHandling
│           │   ├── View (Header)
│           │   └── View (Grid)
│           ├── DiscountButton
│           │   └── [Shake Detection Logic]
│           └── TouchableOpacity (Continue)
```

### DownsellScreen Component Tree
```
DownsellScreen
├── View (Main Container)
│   ├── LinearGradient (Background)
│   └── SafeAreaView
│       ├── View (Header)
│       │   ├── Text (Title)
│       │   └── TouchableOpacity (Close)
│       └── ScrollView
│           ├── View (Offer Header)
│           ├── Text (Description)
│           ├── TrialInfoCard
│           ├── MoneyBackGuarantee
│           ├── View (Plans)
│           │   ├── SubscriptionCard (Weekly)
│           │   ├── SubscriptionCard (Monthly)
│           │   └── SubscriptionCard (Annual)
│           ├── View (Timer Container)
│           │   ├── View (Timer Header)
│           │   └── Text (Timer Text)
│           ├── TouchableOpacity (Purchase)
│           └── TouchableOpacity (Decline)
```

---

## 🎨 Styling

### Theme Integration
All components use consistent styling:
- **Background:** Dark purple gradient
- **Primary Color:** Purple (`#9b87f5`)
- **Text Colors:** White with opacity variations
- **Accent Colors:** Green (guarantee), Blue (info), Orange (proof)

### Responsive Design
- ScrollView for small screens
- SafeAreaView for status bar handling
- Flexible layouts for different screen sizes

### Accessibility
- Touch targets minimum 44x44
- Color contrast compliance
- Screen reader support (semantic labels)
- Clear visual hierarchy

---

## 🔄 State Management

### Local State
- Component-level state (selection, processing)
- Animation values
- Timer state

### Hook State
- `useSubscriptionForm` manages:
  - Plan selection
  - Discount status
  - Processing state
  - Price calculations

### Persistent State
- AsyncStorage for:
  - Selected plan
  - Discount activation
  - Downsell dismissal

---

## 🧪 Testing Considerations

### Component Tests
- Card selection interaction
- Discount activation
- Timer countdown
- Button interactions
- Navigation flows

### Integration Tests
- Purchase flow from screens
- Discount persistence
- Plan selection persistence
- Timer expiration handling

### E2E Tests
- Complete subscribe flow
- Complete downsell flow
- Shake discount activation
- Exit prevention dialog

---

## 📊 Component Metrics

### Complexity
- **SubscribeScreen:** High (multiple components, complex logic)
- **DownsellScreen:** Medium (similar to SubscribeScreen, simpler)
- **SubscriptionCard:** Medium (animations, multiple states)
- **Trust Elements:** Low (display components)
- **DiscountButton:** Medium (sensor integration)

### Reusability
- **SubscriptionCard:** High (used in both screens)
- **Trust Elements:** High (used in both screens)
- **DiscountButton:** Medium (SubscribeScreen only)

### Dependencies
- All screens depend on `useSubscriptionForm` hook
- All screens depend on navigation
- DiscountButton depends on sensors
- Purchase flow depends on IAPService

---

*For service dependencies, see `services.md`*  
*For user flows, see `user-flows.md`*  
*For technical details, see `technical-spec.md`*
