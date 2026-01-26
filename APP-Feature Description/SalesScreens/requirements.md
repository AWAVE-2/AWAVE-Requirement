# Sales Screens - Functional Requirements

## 📋 Core Requirements

### 1. SubscribeScreen - Main Sales Screen

#### Plan Display
- [x] Three subscription plans displayed (weekly, monthly, annual)
- [x] Original prices displayed (€3.99, €11.99, €79.99)
- [x] Discounted prices calculated and displayed
- [x] Daily price calculation and display
- [x] Savings percentage displayed for monthly and annual plans
- [x] Plan features listed for each plan
- [x] Recommended badge on monthly plan ("Meistgewählt")
- [x] Savings badge on annual plan
- [x] Visual selection indicator (animated card border)
- [x] Plan selection state management

#### Trust Elements
- [x] Trial information card displayed
  - [x] 7-day free trial messaging
  - [x] Timeline visualization (Today, Day 5, Day 7)
  - [x] "No charge today" messaging
- [x] Money-back guarantee card displayed
  - [x] 30-day guarantee messaging
  - [x] Clear guarantee description
- [x] Scientific proof section displayed
  - [x] Research statistics (40% less stress, 2x focus)
  - [x] Source citation
- [x] Value proposition section displayed
  - [x] Cost comparison (coaching, medication, AWAVE)
  - [x] Immediate effects checklist
  - [x] Personalization benefits
- [x] Objection handling section displayed
  - [x] Privacy guarantee
  - [x] Easy cancellation
  - [x] Transparent pricing
  - [x] Offline functionality
  - [x] Scientific foundation
  - [x] Flexibility options

#### Discount System
- [x] Shake discount activation available
- [x] Accelerometer shake detection (threshold: 15)
- [x] 20% discount applied on shake
- [x] Visual feedback when discount activated
- [x] Discount persistence across sessions
- [x] Price recalculation with discount
- [x] Fallback for simulators (auto-activate after 5s)

#### Purchase Flow
- [x] Plan selection required before purchase
- [x] "Weiter" (Continue) button initiates purchase
- [x] Plan selection saved to storage before purchase
- [x] IAP product ID mapping (platform-specific)
- [x] Native store purchase dialog
- [x] Purchase processing state (loading indicator)
- [x] Error handling for purchase failures
- [x] User cancellation handling (graceful, no error)
- [x] Navigation after successful purchase

#### UI/UX
- [x] Gradient background (dark purple theme)
- [x] Scrollable content layout
- [x] Close button in header
- [x] Responsive card layout
- [x] Animated plan selection
- [x] Loading states during processing
- [x] Disabled state for continue button during processing

---

### 2. DownsellScreen - Exit-Intent Offer

#### Offer Display
- [x] 30% additional discount offer displayed
- [x] All three plans shown with downsell pricing
- [x] Original prices displayed with strikethrough
- [x] Discounted prices calculated and displayed
- [x] Daily prices recalculated with downsell discount
- [x] Enhanced savings percentages displayed (65%, 75%)
- [x] Plan features displayed for each plan

#### Countdown Timer
- [x] 120-second countdown timer displayed
- [x] Timer countdown updates every second
- [x] Visual timer indicator (icon and text)
- [x] Urgency messaging ("läuft in X Sekunden ab")
- [x] Automatic navigation when timer expires
- [x] Permanent dismissal on timer expiration

#### Exit Prevention
- [x] Confirmation dialog on close attempt
- [x] Dialog title: "Einmaliges Angebot verlassen?"
- [x] Dialog message explaining offer uniqueness
- [x] Two options: "Mit 30% Angebot fortfahren" (cancel) and "Ja, ich bin mir sicher" (confirm)
- [x] Permanent dismissal on confirmed exit
- [x] Navigation to Start screen on dismissal

#### Trust Elements
- [x] Trial information card displayed
- [x] Money-back guarantee card displayed
- [x] Same trust elements as SubscribeScreen

#### Purchase Flow
- [x] Plan selection available
- [x] "Ja, ich will 30% sparen!" button initiates purchase
- [x] Same IAP integration as SubscribeScreen
- [x] Purchase processing state
- [x] Error handling
- [x] User cancellation handling

#### UI/UX
- [x] Same gradient background as SubscribeScreen
- [x] Offer header with icon and title
- [x] Timer container with visual styling
- [x] Decline button at bottom
- [x] Scrollable content layout
- [x] Close button in header

---

### 3. Discount System

#### Shake Discount
- [x] Accelerometer sensor integration
- [x] Shake detection threshold (speed > 15)
- [x] 20% discount calculation
- [x] Discount activation feedback
- [x] Discount status storage (AsyncStorage)
- [x] Discount persistence across sessions
- [x] Price updates with discount applied
- [x] Visual indicator when discount active
- [x] Fallback for simulators

#### Downsell Discount
- [x] 30% additional discount calculation
- [x] Applied to all plans on downsell screen
- [x] Combined with base plan discounts
- [x] Price recalculation
- [x] Visual indication of downsell pricing

#### Discount Persistence
- [x] Discount status saved to AsyncStorage
- [x] Discount status retrieved on screen load
- [x] Discount applied automatically if previously activated
- [x] Discount cleared after successful purchase (optional)

---

### 4. Plan Selection & Pricing

#### Plan Options
- [x] Weekly plan: €3.99/week
- [x] Monthly plan: €11.99/month (recommended)
- [x] Annual plan: €79.99/year
- [x] Default selection: Monthly plan

#### Price Calculations
- [x] Daily price calculation (price / days)
- [x] Savings percentage calculation
  - [x] Monthly: 30% savings vs weekly
  - [x] Annual: 61% savings vs weekly
- [x] Discounted price calculation
  - [x] Base discount (monthly: 30%, annual: 61%)
  - [x] Shake discount: 20% additional
  - [x] Downsell discount: 30% additional
- [x] Original price display with strikethrough when discounted

#### Plan Features
- [x] Weekly plan features:
  - [x] Vollzugriff auf alle Klänge
  - [x] Personalisierte Empfehlungen
  - [x] Download für Offline-Nutzung
  - [x] Wissenschaftlich fundierte Frequenzen
- [x] Monthly plan features:
  - [x] Alles im wöchentlichen Plan
  - [x] Spare 30% gegenüber wöchentlich
  - [x] Zugang zu Premium-Sammlungen
  - [x] Priority Support
- [x] Annual plan features:
  - [x] Alles im monatlichen Plan
  - [x] Spare 61% gegenüber wöchentlich
  - [x] Prioritätszugang zu neuen Funktionen
  - [x] Persönlicher Meditationscoach
  - [x] Exklusive Soundbibliothek

---

### 5. Trust Elements

#### Trial Information
- [x] "7 Tage kostenlos testen" title
- [x] "Keine Abbuchung heute. Jederzeit kündbar." subtitle
- [x] Timeline visualization:
  - [x] Today: Sofortiger Vollzugriff
  - [x] Day 5: Erinnerungs-Mail
  - [x] Day 7: Abo beginnt
- [x] Visual timeline with dots and connecting lines

#### Money-Back Guarantee
- [x] Shield icon display
- [x] "30 Tage Geld-zurück-Garantie" title
- [x] Guarantee description text
- [x] Visual styling (green theme)

#### Scientific Proof
- [x] "Wissenschaftlich bestätigt" title
- [x] Statistics display:
  - [x] 40% Weniger Stress
  - [x] 2x Mehr Fokus
- [x] Source citation text
- [x] Visual grid layout with icons

#### Value Propositions
- [x] "Unser Werteversprechen an dich" title
- [x] Subtitle: "Weniger als ein Kaffee täglich"
- [x] Three value cards:
  - [x] Cost comparison
  - [x] Immediate effects
  - [x] Personalization
- [x] Check marks for benefits
- [x] Visual icons for each value

#### Objection Handling
- [x] "Deine Sicherheit & Flexibilität" title
- [x] Six objection cards:
  - [x] Datenschutz garantiert
  - [x] Einfache Kündigung
  - [x] Transparente Preise
  - [x] Funktioniert offline
  - [x] Wissenschaftlich fundiert
  - [x] Flexibilität
- [x] Each card with icon, title, and description
- [x] Color-coded styling

---

## 🎯 User Stories

### As a potential subscriber, I want to:
- See clear pricing for all subscription plans so I can make an informed decision
- Understand the value proposition so I know what I'm getting
- See trust elements (guarantee, proof) so I feel confident purchasing
- Activate a discount by shaking my device so I can get a better deal
- Compare plans side-by-side so I can choose the best option
- See daily price breakdown so I understand the real cost

### As a user considering leaving, I want to:
- See a special exit-intent offer so I can reconsider my decision
- Understand the urgency (countdown) so I know the offer is limited
- Have the option to dismiss the offer permanently if I'm sure
- See the same plan options with better pricing so I can still purchase

### As a user during purchase, I want to:
- See clear loading states so I know the purchase is processing
- Have my selection saved so I don't lose my choice
- Get clear error messages if something goes wrong
- Cancel gracefully without seeing errors if I change my mind

---

## ✅ Acceptance Criteria

### SubscribeScreen
- [x] All three plans displayed with correct pricing
- [x] Plan selection updates visual state immediately
- [x] Shake discount activates within 2 seconds of shake
- [x] Discount persists across app restarts
- [x] Trust elements display correctly
- [x] Purchase flow initiates native store dialog
- [x] User cancellation doesn't show error
- [x] Screen is scrollable on small devices

### DownsellScreen
- [x] Countdown timer starts at 120 seconds
- [x] Timer updates every second
- [x] Timer expiration navigates away automatically
- [x] Close attempt shows confirmation dialog
- [x] Permanent dismissal prevents screen from showing again
- [x] All plans show downsell pricing
- [x] Purchase flow works same as SubscribeScreen

### Discount System
- [x] Shake discount applies 20% to all prices
- [x] Downsell discount applies 30% to all prices
- [x] Discounts combine correctly (base + additional)
- [x] Discount status persists in AsyncStorage
- [x] Discount visual feedback is clear

### Trust Elements
- [x] All trust elements display correctly
- [x] Timeline visualization is clear
- [x] Statistics are accurate
- [x] Value propositions are compelling
- [x] Objection handling addresses common concerns

---

## 🚫 Non-Functional Requirements

### Performance
- [x] Screen loads in < 2 seconds
- [x] Plan selection updates instantly
- [x] Shake detection responds within 100ms
- [x] Countdown timer updates smoothly (60fps)
- [x] Purchase flow completes in < 30 seconds

### Usability
- [x] Clear visual hierarchy
- [x] Intuitive plan selection
- [x] Obvious discount activation method
- [x] Clear pricing information
- [x] Accessible UI components (min 44x44 touch targets)

### Reliability
- [x] Discount persistence works across app restarts
- [x] Plan selection persists during navigation
- [x] Countdown timer continues even if app backgrounded
- [x] Purchase flow handles network errors gracefully
- [x] Fallback for shake detection on simulators

### Security
- [x] No sensitive data stored locally
- [x] Purchase receipts validated server-side
- [x] Discount status stored securely
- [x] No price manipulation possible client-side

---

## 🔄 Edge Cases

### Shake Detection
- [x] Simulator fallback (auto-activate after 5s)
- [x] Sensor unavailable handling
- [x] Multiple shake attempts (only first activates)
- [x] Shake during purchase processing

### Countdown Timer
- [x] App backgrounded during countdown
- [x] Timer expiration during purchase
- [x] Multiple screen instances (prevented)
- [x] Timer reset on navigation

### Discount Application
- [x] Multiple discount types (combine correctly)
- [x] Discount on already discounted price
- [x] Discount persistence after purchase
- [x] Discount cleared on logout

### Purchase Flow
- [x] Network failure during purchase
- [x] User cancellation (graceful handling)
- [x] Multiple purchase attempts
- [x] Purchase during countdown expiration

### Navigation
- [x] Back button handling
- [x] Close button during processing
- [x] Navigation after purchase
- [x] Deep link to sales screens

---

## 📊 Success Metrics

- Subscription conversion rate from SubscribeScreen
- Downsell conversion rate (exit-intent recovery)
- Shake discount activation rate
- Average time on sales screens
- Plan selection distribution (weekly/monthly/annual)
- Discount usage rate
- Purchase completion rate
- Exit prevention success rate (downsell)

---

## 🔄 State Management

### SubscribeScreen State
- `selectedPlan: SubscriptionPeriod` - Currently selected plan
- `isDiscountApplied: boolean` - Shake discount status
- `isShakingDevice: boolean` - Shake animation state
- `isProcessing: boolean` - Purchase processing state

### DownsellScreen State
- `countdown: number` - Timer countdown (120 seconds)
- `selectedPlan: SubscriptionPeriod` - Selected plan
- `isProcessing: boolean` - Purchase processing state

### Persistent State (AsyncStorage)
- `awaveSelectedPlan` - Selected plan data
- `awaveDiscount` - Discount activation status
- `downsellOfferDismissed` - Permanent dismissal status

---

*For technical implementation details, see `technical-spec.md`*  
*For component specifications, see `components.md`*  
*For user flow diagrams, see `user-flows.md`*
