# Legal & Privacy System - Technical Specification

## 🏗️ Architecture Overview

### Technology Stack

#### Storage
- **AsyncStorage** - Local storage for privacy preferences
  - Key: `awavePrivacyPreferences`
  - JSON serialization for complex data
  - Persistent across app restarts

#### Navigation
- **React Navigation Stack Navigator** - Screen navigation
  - Stack-based navigation for legal screens
  - Back navigation support
  - Route parameters support

#### UI Components
- **Custom Accordion** - Collapsible content sections
- **EnhancedCard** - Card-based UI components
- **UnifiedHeader** - Consistent header component
- **AnimatedButton** - Interactive buttons
- **Icon** - Icon components from design system

#### External APIs
- **React Native Linking API** - External URL handling
  - URL validation
  - Browser opening
  - Error handling

#### State Management
- **React Hooks** - useState, useEffect for local state
- **AsyncStorage** - Persistent state storage
- No global state management needed

---

## 📁 File Structure

```
src/
├── screens/
│   ├── LegalScreen.tsx              # Main legal hub
│   ├── TermsScreen.tsx               # Terms and conditions
│   ├── PrivacyPolicyScreen.tsx      # Privacy policy
│   ├── DataPrivacyScreen.tsx        # GDPR compliance
│   └── PrivacySettingsScreen.tsx    # Privacy preferences
├── components/
│   └── ui/
│       └── Accordion.tsx            # Collapsible sections
├── services/
│   └── AWAVEStorage.ts              # Privacy preferences storage
└── translations/
    └── de.ts                        # German translations
```

---

## 🔧 Components

### LegalScreen
**Location:** `src/screens/LegalScreen.tsx`

**Purpose:** Main legal information hub with navigation to all legal documents

**Props:** None (uses navigation hook)

**State:**
- None (stateless component)

**Features:**
- Card-based navigation layout
- Internal navigation to Terms, Privacy Policy, Data Privacy
- External links to Impressum and Datenschutz
- Consistent UI with icons and descriptions
- Scrollable content

**Navigation Handlers:**
- `handleNavigateToTerms()` - Navigate to TermsAndConditions screen
- `handleNavigateToPrivacyPolicy()` - Navigate to AppPrivacyPolicy screen
- `handleNavigateToDataPrivacy()` - Navigate to DataPrivacy screen
- `handleOpenImprint()` - Open external Impressum URL
- `handleOpenDataProtection()` - Open external Datenschutz URL

**Dependencies:**
- `useNavigation` hook
- `useTheme` hook
- `useTranslation` hook
- `Linking` API
- `EnhancedCard` component
- `UnifiedHeader` component
- `AnimatedButton` component
- `Icon` component

---

### TermsScreen
**Location:** `src/screens/TermsScreen.tsx`

**Purpose:** Display terms and conditions

**Props:** None

**State:**
- None (static content)

**Features:**
- 11 sections of terms content
- Last updated date display
- Scrollable content
- Contact information
- Consistent typography

**Content Sections:**
1. Anwendungsbereich
2. Leistungsbeschreibung
3. Registrierung und Nutzerkonto
4. Abonnements und Zahlungen
5. Kostenlose Testphase
6. Nutzungsrechte und -beschränkungen
7. Datenschutz
8. Haftungsausschluss
9. Kündigung
10. Änderungen der Nutzungsbedingungen
11. Anwendbares Recht und Gerichtsstand

**Dependencies:**
- `useTheme` hook
- `UnifiedHeader` component
- `EnhancedCard` component

---

### PrivacyPolicyScreen
**Location:** `src/screens/PrivacyPolicyScreen.tsx`

**Purpose:** Display app privacy policy

**Props:** None

**State:**
- None (static content)

**Features:**
- 12 sections of privacy policy content
- Last updated date display
- Scrollable content
- Contact information for privacy inquiries
- Consistent typography

**Content Sections:**
1. Verantwortlicher
2. Erhobene Daten
3. Zwecke der Datenverarbeitung
4. Rechtsgrundlagen
5. Datenweitergabe
6. Internationale Datenübertragung
7. Speicherdauer
8. Ihre Rechte
9. Datensicherheit
10. Cookies und Tracking
11. Minderjährige
12. Änderungen der Datenschutzerklärung

**Dependencies:**
- `useTheme` hook
- `UnifiedHeader` component
- `EnhancedCard` component

---

### DataPrivacyScreen
**Location:** `src/screens/DataPrivacyScreen.tsx`

**Purpose:** GDPR-compliant data privacy information with preference controls

**Props:** None

**State:**
- `healthDataConsent: boolean` - Health data consent
- `analyticsConsent: boolean` - Analytics consent
- `marketingConsent: boolean` - Marketing consent
- `isLoading: boolean` - Loading state

**Features:**
- 12 accordion sections for GDPR information
- Protected badge display
- Policy header with description
- Privacy preferences section
- Save preferences functionality
- Load preferences on mount

**GDPR Sections:**
1. Controller (Verantwortlicher)
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

**Methods:**
- `loadPreferences()` - Load preferences from AsyncStorage
- `handleSavePreferences()` - Save preferences to AsyncStorage
- `handleBack()` - Navigate back

**Dependencies:**
- `useNavigation` hook
- `useTheme` hook
- `useTranslation` hook
- `AsyncStorage`
- `Accordion` component
- `UnifiedHeader` component
- `AnimatedButton` component
- Custom `Checkbox` component

---

### PrivacySettingsScreen
**Location:** `src/screens/PrivacySettingsScreen.tsx`

**Purpose:** Dedicated privacy preference management screen

**Props:** None

**State:**
- `healthDataConsent: boolean` - Health data consent
- `analyticsConsent: boolean` - Analytics consent
- `marketingConsent: boolean` - Marketing consent
- `isLoading: boolean` - Loading state

**Features:**
- Header with icon and description
- Data collection section with checkboxes
- Marketing settings section with checkbox
- Save button for preferences
- Success/error alerts

**Methods:**
- `loadPreferences()` - Load preferences from AsyncStorage
- `handleSavePreferences()` - Save preferences to AsyncStorage
- `handleBack()` - Navigate back

**Dependencies:**
- `useNavigation` hook
- `useTheme` hook
- `useTranslation` hook
- `AsyncStorage`
- `EnhancedCard` component
- `UnifiedHeader` component
- `AnimatedButton` component
- Custom `Checkbox` component

---

### Accordion Component
**Location:** `src/components/ui/Accordion.tsx`

**Purpose:** Collapsible content section component

**Props:**
```typescript
interface AccordionProps {
  title: string;
  icon?: string;
  defaultOpen?: boolean;
  children: React.ReactNode;
}
```

**Features:**
- Expand/collapse functionality
- Icon support
- Default open state
- Smooth animations
- Theme integration

**Usage:**
```typescript
<Accordion title="Section Title" icon="🏢" defaultOpen>
  <Text>Content here</Text>
</Accordion>
```

---

### Checkbox Component
**Location:** `src/screens/PrivacySettingsScreen.tsx` and `src/screens/DataPrivacyScreen.tsx`

**Purpose:** Custom checkbox component for privacy preferences

**Props:**
```typescript
interface CheckboxProps {
  checked: boolean;
  onPress: () => void;
  color?: string;
}
```

**Features:**
- Custom styling
- Color customization
- Checkmark display
- Theme integration
- Touch feedback

---

## 🔌 Services

### AWAVEStorage Service
**Location:** `src/services/AWAVEStorage.ts`

**Purpose:** Privacy preferences storage service

**Interface:**
```typescript
interface PrivacyPreferences {
  healthDataConsent: boolean;
  analyticsConsent: boolean;
  marketingConsent: boolean;
  lastUpdated: string;
}
```

**Methods:**

**`setPrivacyPreferences(preferences: PrivacyPreferences): Promise<void>`**
- Stores privacy preferences in AsyncStorage
- Key: `awavePrivacyPreferences`
- JSON serialization
- Error handling

**`getPrivacyPreferences(): Promise<PrivacyPreferences | null>`**
- Retrieves privacy preferences from AsyncStorage
- Returns null if not found
- JSON deserialization
- Error handling

**Storage Key:**
- `awavePrivacyPreferences` - Privacy preferences data

---

## 🪝 Hooks

### useNavigation
**Purpose:** React Navigation hook for screen navigation

**Usage:**
```typescript
const navigation = useNavigation();
navigation.navigate('Legal' as never);
```

### useTheme
**Purpose:** Theme provider hook for styling

**Usage:**
```typescript
const theme = useTheme();
const color = theme.colors.textPrimary;
```

### useTranslation
**Purpose:** Translation context hook for i18n

**Usage:**
```typescript
const t = useTranslation();
const title = t.legal.title;
```

---

## 🔐 Privacy Preferences Implementation

### Storage Structure
```typescript
interface PrivacyPreferences {
  healthDataConsent: boolean;    // Health data collection consent
  analyticsConsent: boolean;      // Analytics data collection consent
  marketingConsent: boolean;      // Marketing communication consent
  lastUpdated: string;            // ISO timestamp of last update
}
```

### Storage Key
- `awavePrivacyPreferences` - Single key for all preferences

### Default Values
- All preferences default to `true` (opt-in)
- Set when no stored preferences exist
- Applied on first app launch

### Storage Flow
1. User opens Privacy Settings or Data Privacy screen
2. `loadPreferences()` called on mount
3. AsyncStorage.getItem() retrieves stored preferences
4. If found, parse JSON and set state
5. If not found, use default values (all true)
6. User modifies preferences
7. User clicks save
8. `handleSavePreferences()` called
9. Create preferences object with current state
10. AsyncStorage.setItem() stores preferences
11. Show success alert

---

## 🌐 External Link Handling

### Implementation
```typescript
const handleOpenImprint = async () => {
  const url = 'https://www.awave-app.de/impressum';
  const supported = await Linking.canOpenURL(url);
  if (supported) {
    await Linking.openURL(url);
  } else {
    console.error(`Cannot open URL: ${url}`);
  }
};
```

### URLs
- **Impressum:** `https://www.awave-app.de/impressum`
- **Datenschutz:** `https://www.awave-app.de/datenschutz`

### Error Handling
- URL validation before opening
- Check if URL can be opened
- Log errors for debugging
- Graceful failure (no crash)

---

## 📱 Navigation Routes

### Route Definitions
```typescript
type RootStackParamList = {
  Legal: undefined;
  TermsAndConditions: undefined;
  AppPrivacyPolicy: undefined;
  DataPrivacy: undefined;
  PrivacySettings: undefined;
};
```

### Route Registration
```typescript
<Stack.Screen name='Legal' component={LegalScreen} />
<Stack.Screen name='TermsAndConditions' component={TermsScreen} />
<Stack.Screen name='AppPrivacyPolicy' component={PrivacyPolicyScreen} />
<Stack.Screen name='DataPrivacy' component={DataPrivacyScreen} />
<Stack.Screen name='PrivacySettings' component={PrivacySettingsScreen} />
```

### Navigation Paths
- `/profile/legal` - LegalScreen
- `/profile/legal/terms` - TermsScreen
- `/profile/legal/privacy-policy` - PrivacyPolicyScreen
- `/profile/legal/data-privacy` - DataPrivacyScreen
- `/profile/privacy-settings` - PrivacySettingsScreen

---

## 🎨 Styling

### Theme Integration
All components use the theme system:
- Colors: `theme.colors.textPrimary`, `theme.colors.textSecondary`, `theme.colors.awave.primary`
- Typography: `theme.typography.fontFamily`
- Spacing: `awaveSpacing` constants

### Design System Components
- `EnhancedCard` - Card-based layouts
- `UnifiedHeader` - Consistent headers
- `AnimatedButton` - Interactive buttons
- `Icon` - Icon components
- `Accordion` - Collapsible sections

### Responsive Design
- ScrollView for long content
- SafeAreaView for status bar handling
- Consistent padding and margins
- Touch target sizes (min 44x44)

---

## 🧪 Testing Strategy

### Unit Tests
- Privacy preferences storage/retrieval
- Checkbox component interactions
- Accordion expand/collapse
- URL validation logic

### Integration Tests
- Navigation between legal screens
- External link opening
- Preference persistence
- Storage error handling

### E2E Tests
- Complete legal information access flow
- Privacy preference management flow
- External link opening flow
- Terms acceptance during signup

---

## 🐛 Error Handling

### Storage Errors
- AsyncStorage read failures → Use defaults
- AsyncStorage write failures → Show error alert
- Corrupted data → Reset to defaults
- JSON parse errors → Handle gracefully

### Navigation Errors
- Missing routes → Fallback navigation
- Deep link errors → Handle gracefully
- Back navigation from root → Prevent navigation

### External Link Errors
- URL validation failures → Log error
- Browser opening failures → Show error
- Network issues → Handle gracefully

---

## 📊 Performance Considerations

### Optimization
- Lazy loading of legal content (static, no API calls)
- Efficient AsyncStorage operations
- Smooth accordion animations
- Optimized re-renders with React hooks

### Monitoring
- Storage operation performance
- Navigation transition times
- External link opening times
- User interaction response times

---

## 🔄 State Management

### Local State
- Component-level state with useState
- Privacy preferences in component state
- Loading states for async operations
- No global state needed

### Persistent State
- AsyncStorage for privacy preferences
- No server-side sync
- Local-only storage

---

## 📝 Notes

- Privacy preferences are stored locally only
- No API calls for legal content (all static)
- External links require internet connection
- All legal content is in German (de)
- GDPR documentation should be reviewed by legal team
- Terms and Privacy Policy should be kept up-to-date

---

*For component details, see `components.md`*  
*For service dependencies, see `services.md`*  
*For user flows, see `user-flows.md`*
