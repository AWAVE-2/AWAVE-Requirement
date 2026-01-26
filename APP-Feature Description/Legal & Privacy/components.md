# Legal & Privacy System - Components Inventory

## 📱 Screens

### LegalScreen
**File:** `src/screens/LegalScreen.tsx`  
**Route:** `/profile/legal`  
**Purpose:** Main legal information hub with navigation to all legal documents

**Props:**
```typescript
// No props - uses navigation hook
```

**State:**
- None (stateless component)

**Components Used:**
- `UnifiedHeader` - Header with back button
- `EnhancedCard` - Card-based navigation items
- `AnimatedButton` - Interactive navigation buttons
- `Icon` - Icon components for visual indicators
- `LinearGradient` - Gradient backgrounds for icons
- `ScrollView` - Scrollable content container

**Hooks Used:**
- `useNavigation` - Navigation functionality
- `useTheme` - Theme styling
- `useTranslation` - Internationalization

**Features:**
- Card-based navigation layout
- Internal navigation to Terms, Privacy Policy, Data Privacy
- External links to Impressum and Datenschutz
- Consistent UI with icons and descriptions
- Scrollable content for small screens
- Back navigation support

**User Interactions:**
- Click Terms and Conditions card → Navigate to TermsScreen
- Click App Privacy Policy card → Navigate to PrivacyPolicyScreen
- Click Data Privacy card → Navigate to DataPrivacyScreen
- Click Impressum card → Open external URL in browser
- Click Datenschutz card → Open external URL in browser
- Click back button → Navigate to previous screen

**Navigation Handlers:**
- `handleNavigateToTerms()` - Navigate to TermsAndConditions
- `handleNavigateToPrivacyPolicy()` - Navigate to AppPrivacyPolicy
- `handleNavigateToDataPrivacy()` - Navigate to DataPrivacy
- `handleOpenImprint()` - Open Impressum URL
- `handleOpenDataProtection()` - Open Datenschutz URL
- `handleBack()` - Navigate back

---

### TermsScreen
**File:** `src/screens/TermsScreen.tsx`  
**Route:** `/profile/legal/terms`  
**Purpose:** Display terms and conditions

**State:**
- None (static content)

**Components Used:**
- `UnifiedHeader` - Header with back button
- `EnhancedCard` - Content container card
- `ScrollView` - Scrollable content

**Hooks Used:**
- `useTheme` - Theme styling
- `useNavigation` - Navigation (implicit via header)

**Features:**
- 11 sections of terms content
- Last updated date display
- Scrollable content with proper formatting
- Contact information display
- Consistent typography

**Content Sections:**
1. Anwendungsbereich (Scope of Application)
2. Leistungsbeschreibung (Service Description)
3. Registrierung und Nutzerkonto (Registration and User Account)
4. Abonnements und Zahlungen (Subscriptions and Payments)
5. Kostenlose Testphase (Free Trial Period)
6. Nutzungsrechte und -beschränkungen (Usage Rights and Restrictions)
7. Datenschutz (Data Privacy)
8. Haftungsausschluss (Liability Disclaimer)
9. Kündigung (Termination)
10. Änderungen der Nutzungsbedingungen (Changes to Terms)
11. Anwendbares Recht und Gerichtsstand (Applicable Law and Jurisdiction)

**User Interactions:**
- Scroll content to read all sections
- Click back button → Navigate back to LegalScreen

---

### PrivacyPolicyScreen
**File:** `src/screens/PrivacyPolicyScreen.tsx`  
**Route:** `/profile/legal/privacy-policy`  
**Purpose:** Display app privacy policy

**State:**
- None (static content)

**Components Used:**
- `UnifiedHeader` - Header with back button
- `EnhancedCard` - Content container card
- `ScrollView` - Scrollable content

**Hooks Used:**
- `useTheme` - Theme styling
- `useNavigation` - Navigation (implicit via header)

**Features:**
- 12 sections of privacy policy content
- Last updated date display
- Scrollable content with proper formatting
- Contact information for privacy inquiries
- Consistent typography

**Content Sections:**
1. Verantwortlicher (Controller)
2. Erhobene Daten (Data Collected)
3. Zwecke der Datenverarbeitung (Purposes of Data Processing)
4. Rechtsgrundlagen (Legal Basis)
5. Datenweitergabe (Data Sharing)
6. Internationale Datenübertragung (International Data Transfer)
7. Speicherdauer (Storage Duration)
8. Ihre Rechte (Your Rights)
9. Datensicherheit (Data Security)
10. Cookies und Tracking (Cookies and Tracking)
11. Minderjährige (Minors)
12. Änderungen der Datenschutzerklärung (Changes to Privacy Policy)

**User Interactions:**
- Scroll content to read all sections
- Click back button → Navigate back to LegalScreen

---

### DataPrivacyScreen
**File:** `src/screens/DataPrivacyScreen.tsx`  
**Route:** `/profile/legal/data-privacy`  
**Purpose:** GDPR-compliant data privacy information with preference controls

**State:**
- `verificationStatus: 'pending' | 'verifying' | 'success' | 'error'`
- `healthDataConsent: boolean` - Health data consent
- `analyticsConsent: boolean` - Analytics consent
- `marketingConsent: boolean` - Marketing consent
- `isLoading: boolean` - Loading state

**Components Used:**
- `UnifiedHeader` - Header with back button
- `Accordion` - Collapsible GDPR sections
- `AnimatedButton` - Save button
- Custom `Checkbox` - Privacy preference checkboxes
- `ScrollView` - Scrollable content

**Hooks Used:**
- `useNavigation` - Navigation functionality
- `useTheme` - Theme styling
- `useTranslation` - Internationalization
- `useState` - Component state management
- `useEffect` - Side effects (load preferences)

**Features:**
- 12 accordion sections for GDPR information
- Protected badge display
- Policy header with description
- Privacy preferences section
- Save preferences functionality
- Load preferences on mount
- Success/error alerts

**GDPR Sections:**
1. Controller (Verantwortlicher) - defaultOpen
2. Data Collected (Erhobene Daten)
3. How We Collect Data (Wie wir Daten sammeln)
4. Third-Party Services (Drittanbieter)
5. Legal Basis (Rechtsgrundlage)
6. Data Storage (Datenspeicherung)
7. User Accounts (Nutzerkonten)
8. Health Data (Gesundheitsdaten)
9. Notifications (Benachrichtigungen)
10. Tracking (Tracking)
11. User Rights (Nutzerrechte)
12. Validity (Gültigkeit)

**Privacy Preferences:**
- Data Collection Section (defaultOpen)
  - Health Data checkbox
  - Analytics Data checkbox
- Marketing Section
  - Marketing Communication checkbox
- Save Button

**Methods:**
- `loadPreferences()` - Load preferences from AsyncStorage
- `handleSavePreferences()` - Save preferences to AsyncStorage
- `handleBack()` - Navigate back

**User Interactions:**
- Expand/collapse accordion sections
- Toggle privacy preference checkboxes
- Click save button → Save preferences
- Click back button → Navigate back

---

### PrivacySettingsScreen
**File:** `src/screens/PrivacySettingsScreen.tsx`  
**Route:** `/profile/privacy-settings`  
**Purpose:** Dedicated privacy preference management screen

**State:**
- `healthDataConsent: boolean` - Health data consent
- `analyticsConsent: boolean` - Analytics consent
- `marketingConsent: boolean` - Marketing consent
- `isLoading: boolean` - Loading state

**Components Used:**
- `UnifiedHeader` - Header with back button
- `EnhancedCard` - Card containers for sections
- `AnimatedButton` - Save button
- Custom `Checkbox` - Privacy preference checkboxes
- `LinearGradient` - Gradient backgrounds
- `Icon` - Icon components
- `ScrollView` - Scrollable content

**Hooks Used:**
- `useNavigation` - Navigation functionality
- `useTheme` - Theme styling
- `useTranslation` - Internationalization
- `useState` - Component state management
- `useEffect` - Side effects (load preferences)

**Features:**
- Header with icon and description
- Data collection section with checkboxes
- Marketing settings section with checkbox
- Save button for preferences
- Success/error alerts

**Sections:**
- Header Section
  - Icon with gradient background
  - Title and description
- Data Collection Section
  - Section description
  - Health Data checkbox
  - Analytics Data checkbox
- Marketing Settings Section
  - Section title and description
  - Marketing Communication checkbox
- Save Button

**Methods:**
- `loadPreferences()` - Load preferences from AsyncStorage
- `handleSavePreferences()` - Save preferences to AsyncStorage
- `handleBack()` - Navigate back

**User Interactions:**
- Toggle health data consent checkbox
- Toggle analytics consent checkbox
- Toggle marketing consent checkbox
- Click save button → Save preferences
- Click back button → Navigate back

---

## 🧩 Components

### Accordion Component
**File:** `src/components/ui/Accordion.tsx`  
**Type:** Reusable UI Component

**Props:**
```typescript
interface AccordionProps {
  title: string;
  icon?: string;
  children: React.ReactNode;
  defaultOpen?: boolean;
}
```

**State:**
- `isOpen: boolean` - Expanded/collapsed state

**Features:**
- Expand/collapse functionality
- Icon support (emoji or text)
- Default open state option
- Smooth animations with LayoutAnimation
- Theme integration
- Touch feedback

**Usage:**
```typescript
<Accordion title="Section Title" icon="🏢" defaultOpen>
  <Text>Content here</Text>
</Accordion>
```

**User Interactions:**
- Click header → Toggle expand/collapse
- Smooth animation on state change

**Dependencies:**
- `useTheme` hook
- React Native `LayoutAnimation`
- Platform-specific animation setup

---

### Checkbox Component
**File:** `src/screens/PrivacySettingsScreen.tsx` and `src/screens/DataPrivacyScreen.tsx`  
**Type:** Custom UI Component

**Props:**
```typescript
interface CheckboxProps {
  checked: boolean;
  onPress: () => void;
  color?: string;
}
```

**State:**
- None (controlled component)

**Features:**
- Custom styling (not native checkbox)
- Color customization
- Checkmark display when checked
- Theme integration
- Touch feedback with AnimatedButton

**Usage:**
```typescript
<Checkbox
  checked={healthDataConsent}
  onPress={() => setHealthDataConsent(!healthDataConsent)}
  color="#10B981"
/>
```

**User Interactions:**
- Click checkbox → Toggle checked state
- Visual feedback on press

**Dependencies:**
- `useTheme` hook
- `AnimatedButton` component

---

## 🔗 Component Relationships

### LegalScreen Component Tree
```
LegalScreen
├── SafeAreaView
│   └── UnifiedHeader
│       └── Back Button
│   └── ScrollView
│       └── View (Content)
│           ├── View (Header Section)
│           │   ├── LinearGradient (Icon Container)
│           │   │   └── Icon (Shield)
│           │   ├── Text (Title)
│           │   └── Text (Description)
│           └── View (Legal Links Section)
│               ├── AnimatedButton (Terms)
│               │   └── EnhancedCard
│               │       └── View (Card Row)
│               │           ├── LinearGradient (Icon)
│               │           ├── View (Content)
│               │           │   ├── Text (Label)
│               │           │   └── Text (Description)
│               │           └── Text (Chevron)
│               ├── AnimatedButton (Privacy Policy)
│               ├── AnimatedButton (Data Privacy)
│               ├── AnimatedButton (Impressum - External)
│               └── AnimatedButton (Datenschutz - External)
```

### DataPrivacyScreen Component Tree
```
DataPrivacyScreen
├── SafeAreaView
│   └── UnifiedHeader
│   └── ScrollView
│       └── View (Content)
│           ├── View (Protected Badge)
│           │   ├── Text (Icon)
│           │   └── View (Content)
│           │       ├── Text (Title)
│           │       └── Text (Description)
│           ├── View (Policy Header)
│           │   ├── Text (Title)
│           │   └── Text (Description)
│           ├── View (GDPR Sections)
│           │   ├── Accordion (Controller) - defaultOpen
│           │   ├── Accordion (Data Collected)
│           │   ├── Accordion (How We Collect)
│           │   ├── Accordion (Third-Party)
│           │   ├── Accordion (Legal Basis)
│           │   ├── Accordion (Data Storage)
│           │   ├── Accordion (User Accounts)
│           │   ├── Accordion (Health Data)
│           │   ├── Accordion (Notifications)
│           │   ├── Accordion (Tracking)
│           │   ├── Accordion (User Rights)
│           │   └── Accordion (Validity)
│           └── View (Privacy Settings)
│               ├── Text (Title)
│               ├── Accordion (Data Collection) - defaultOpen
│               │   ├── Checkbox (Health Data)
│               │   └── Checkbox (Analytics)
│               ├── Accordion (Marketing)
│               │   └── Checkbox (Marketing)
│               └── AnimatedButton (Save)
```

### PrivacySettingsScreen Component Tree
```
PrivacySettingsScreen
├── SafeAreaView
│   └── UnifiedHeader
│   └── ScrollView
│       └── View (Content)
│           ├── View (Header Section)
│           │   ├── LinearGradient (Icon Container)
│           │   ├── Text (Title)
│           │   └── Text (Description)
│           ├── View (Data Collection Section)
│           │   └── EnhancedCard
│           │       ├── Text (Description)
│           │       ├── View (Checkbox Row - Health Data)
│           │       │   ├── Checkbox
│           │       │   └── View (Content)
│           │       │       ├── Text (Label)
│           │       │       └── Text (Description)
│           │       └── View (Checkbox Row - Analytics)
│           │           └── [Same structure]
│           ├── View (Marketing Section)
│           │   ├── LinearGradient (Icon)
│           │   ├── Text (Title)
│           │   ├── Text (Subtitle)
│           │   └── EnhancedCard
│           │       ├── Text (Description)
│           │       └── View (Checkbox Row - Marketing)
│           └── AnimatedButton (Save)
```

---

## 🎨 Styling

### Theme Integration
All components use the theme system via `useTheme` hook:
- Colors: `theme.colors.textPrimary`, `theme.colors.textSecondary`, `theme.colors.awave.primary`
- Typography: `theme.typography.fontFamily`
- Spacing: `awaveSpacing` constants

### Design System Components
- `EnhancedCard` - Card-based layouts with gradients
- `UnifiedHeader` - Consistent header component
- `AnimatedButton` - Interactive buttons with touch feedback
- `Icon` - Icon components from design system
- `LinearGradient` - Gradient backgrounds

### Responsive Design
- ScrollView for long content
- SafeAreaView for status bar handling
- Consistent padding and margins
- Touch target sizes (min 44x44)
- Keyboard avoidance (where needed)

### Accessibility
- Semantic labels
- Touch target sizes (min 44x44)
- Color contrast compliance
- Screen reader support
- Clear visual feedback

---

## 🔄 State Management

### Local State
- Component-level state with useState
- Privacy preferences in component state
- Loading states for async operations
- Accordion expand/collapse state

### Persistent State
- AsyncStorage for privacy preferences
- No server-side sync
- Local-only storage

### State Flow
1. Component mounts
2. useEffect calls loadPreferences()
3. AsyncStorage.getItem() retrieves preferences
4. State updated with loaded preferences (or defaults)
5. User interacts with checkboxes
6. State updated immediately
7. User clicks save
8. handleSavePreferences() called
9. AsyncStorage.setItem() stores preferences
10. Success alert shown

---

## 🧪 Testing Considerations

### Component Tests
- Checkbox interactions
- Accordion expand/collapse
- Navigation handlers
- State updates
- Error handling

### Integration Tests
- Navigation flows
- Storage operations
- External link opening
- Preference persistence

### E2E Tests
- Complete legal information access flow
- Privacy preference management flow
- External link opening flow
- Terms acceptance during signup

---

## 📊 Component Metrics

### Complexity
- **LegalScreen:** Low (navigation hub)
- **TermsScreen:** Low (static content)
- **PrivacyPolicyScreen:** Low (static content)
- **DataPrivacyScreen:** Medium (accordions + preferences)
- **PrivacySettingsScreen:** Medium (preferences management)

### Reusability
- **Accordion:** High (used in DataPrivacyScreen)
- **Checkbox:** Medium (used in PrivacySettingsScreen and DataPrivacyScreen)
- **EnhancedCard:** High (used across multiple screens)

### Dependencies
- All screens depend on theme system
- All screens depend on navigation
- Privacy screens depend on AsyncStorage
- Legal screens depend on Linking API

---

*For service dependencies, see `services.md`*  
*For user flows, see `user-flows.md`*  
*For technical details, see `technical-spec.md`*
