# Support System - Technical Specification

## 🏗️ Architecture Overview

### Technology Stack

#### Core Framework
- **React Native** - Mobile app framework
- **TypeScript** - Type safety
- **React Navigation** - Navigation system
- **React Native Linking** - Native app integration

#### UI Components
- **EnhancedCard** - Card component with gradient support
- **AnimatedButton** - Interactive button component
- **Icon** - Icon system (Lucide React Native)
- **LinearGradient** - Gradient backgrounds

#### State Management
- **React Hooks** - useState for local state
- **React Navigation** - Navigation state
- **Theme Context** - Global theme access

---

## 📁 File Structure

```
src/
├── screens/
│   └── SupportScreen.tsx              # Main support screen
├── components/
│   └── profile/
│       └── ProfileSupportSection.tsx  # Profile integration
└── navigation/
    └── index.tsx                      # Navigation routes
```

---

## 🔧 Components

### SupportScreen
**Location:** `src/screens/SupportScreen.tsx`

**Purpose:** Main support screen with contact form and help resources

**Props:** None (uses navigation params)

**State:**
```typescript
{
  formData: {
    name: string;
    email: string;
    subject: SubjectOption;
    message: string;
  };
  showSubjectPicker: boolean;
  isSubmitting: boolean;
}
```

**Subject Options:**
```typescript
type SubjectOption = 'technical' | 'account' | 'billing' | 'feature' | 'other' | '';

const SUBJECT_OPTIONS: SubjectItem[] = [
  { value: 'technical', label: 'Technisches Problem' },
  { value: 'account', label: 'Konto-Probleme' },
  { value: 'billing', label: 'Abrechnung' },
  { value: 'feature', label: 'Feature-Anfrage' },
  { value: 'other', label: 'Sonstiges' },
];
```

**Features:**
- Contact form with validation
- Subject picker dropdown
- Quick help cards
- Alternative contact methods (email, phone)
- Form submission handling
- XSS prevention
- Character counting

**Methods:**
- `handleInputChange(field, value)` - Input change handler with sanitization
- `handleSubjectSelect(subject)` - Subject selection handler
- `validateEmail(email)` - Email validation
- `handleSubmit()` - Form submission
- `handleEmailSupport()` - Open email app
- `handlePhoneSupport()` - Open phone app
- `goBack()` - Navigation handler
- `getSubjectLabel(value)` - Get subject label

**Dependencies:**
- `useTheme` hook
- `useNavigation` hook
- `AnimatedButton` component
- `EnhancedCard` component
- `Icon` component
- `Linking` API

---

### ProfileSupportSection
**Location:** `src/components/profile/ProfileSupportSection.tsx`

**Purpose:** Support section in Profile screen

**Props:**
```typescript
interface ProfileSupportSectionProps {
  onSignOut?: () => void;
}
```

**Features:**
- Support navigation link
- Share AWAVE functionality
- Sign out button (if authenticated)
- Consistent styling with Profile

**Methods:**
- `handleShare()` - Share AWAVE app
- `handleSupport()` - Navigate to Support screen
- `handleSignOut()` - Sign out handler

**Dependencies:**
- `useAuth` context
- `useNavigation` hook
- `useTheme` hook
- `EnhancedCard` component
- `Icon` component

---

## 🔌 Services

### Form Submission Service (Future)
**Status:** Currently simulated, planned for Supabase integration

**Planned Implementation:**
```typescript
interface SupportRequest {
  name: string;
  email: string;
  subject: SubjectOption;
  message: string;
  userId?: string;
  timestamp: string;
}

async function submitSupportRequest(request: SupportRequest): Promise<void> {
  // Supabase integration
  // Store in support_requests table
  // Send notification to support team
}
```

---

## 🪝 Hooks

### useTheme
**Location:** `src/design-system/ThemeProvider.tsx`

**Usage:** Global theme access for consistent styling

**Returns:**
```typescript
{
  colors: ColorTokens;
  typography: TypographyTokens;
  spacing: SpacingTokens;
}
```

### useNavigation
**Location:** `@react-navigation/native`

**Usage:** Navigation control

**Methods:**
- `navigate(route, params)`
- `goBack()`
- `canGoBack()`

### useAuth
**Location:** `src/contexts/AuthContext.tsx`

**Usage:** Authentication state (used in ProfileSupportSection)

**Returns:**
```typescript
{
  isAuthenticated: boolean;
  user: User | null;
  // ... other auth methods
}
```

---

## 🔐 Security Implementation

### XSS Prevention
**Location:** `SupportScreen.tsx` - `handleInputChange`

**Implementation:**
```typescript
const sanitizedValue = value.replace(
  /<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi,
  ''
);
```

**Protection:**
- Removes script tags from all inputs
- Prevents script injection
- Applied to all form fields

### Input Validation
**Email Validation:**
```typescript
const validateEmail = (email: string): boolean => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
};
```

**Character Limits:**
- Name: 100 characters
- Email: 150 characters
- Message: 1000 characters

---

## 🌐 Native Integration

### Email Support
**Implementation:**
```typescript
const handleEmailSupport = () => {
  Linking.openURL('mailto:info@awave-app.de').catch(() => {
    Alert.alert('Fehler', 'E-Mail-App konnte nicht geöffnet werden');
  });
};
```

**Behavior:**
- Opens default email app
- Pre-fills recipient (info@awave-app.de)
- Error handling if email app unavailable

### Phone Support
**Implementation:**
```typescript
const handlePhoneSupport = () => {
  Linking.openURL('tel:+4917650203275').catch(() => {
    Alert.alert('Fehler', 'Telefon-App konnte nicht geöffnet werden');
  });
};
```

**Behavior:**
- Opens default phone app
- Pre-fills phone number (+49 176 50203275)
- Error handling if phone app unavailable

---

## 🎨 Styling

### Theme Integration
All components use the theme system:
- Colors: `theme.colors.primary`, `theme.colors.textPrimary`, etc.
- Typography: `theme.typography.fontFamily`
- Spacing: Consistent padding and margins

### Component Styling
**SupportScreen:**
- SafeAreaView container
- ScrollView for content
- Section-based layout
- Card-based UI components

**ProfileSupportSection:**
- Consistent with Profile styling
- Gradient backgrounds
- Icon containers
- Link cards

### Constants
```typescript
const PROFILE_RADIUS = 16; // Border radius for cards
```

---

## 🔄 State Management

### Local State
**SupportScreen:**
```typescript
const [formData, setFormData] = useState({
  name: '',
  email: '',
  subject: '' as SubjectOption,
  message: '',
});
const [showSubjectPicker, setShowSubjectPicker] = useState(false);
const [isSubmitting, setIsSubmitting] = useState(false);
```

### Navigation State
- Managed by React Navigation
- Stack navigation
- Route params (none currently)

---

## 📱 Platform-Specific Notes

### iOS
- Native mail app integration
- Native phone app integration
- SafeAreaView support
- Haptic feedback (future)

### Android
- Native email app integration
- Native phone app integration
- Back button handling
- Material Design compliance

---

## 🧪 Testing Strategy

### Unit Tests
- Form validation logic
- Email validation
- XSS prevention
- Character counting
- Subject label retrieval

### Integration Tests
- Form submission flow
- Navigation flows
- Native app linking
- Error handling

### E2E Tests
- Complete form submission
- Email link opening
- Phone link opening
- Navigation from Profile
- Error scenarios

---

## 🐛 Error Handling

### Error Types
- Form validation errors
- Native app unavailable
- Linking failures
- Network errors (future)

### Error Messages
- User-friendly German messages
- Clear action guidance
- No technical jargon

### Error Handling Patterns
```typescript
// Native app linking
Linking.openURL(url).catch(() => {
  Alert.alert('Fehler', 'App konnte nicht geöffnet werden');
});

// Form validation
if (!validateEmail(email)) {
  Alert.alert('Fehler', 'Bitte geben Sie eine gültige E-Mail-Adresse ein.');
  return;
}
```

---

## 📊 Performance Considerations

### Optimization
- Lazy loading of components (future)
- Debounced validation (future)
- Efficient re-renders
- Memoization (future)

### Monitoring
- Form submission success rate
- Average form completion time
- Link click-through rate
- Error rates

---

## 🔮 Future Enhancements

### Backend Integration
- Supabase support_requests table
- Email notifications
- Ticket tracking
- Status updates

### Features
- FAQ screen
- Getting Started guide
- Support history
- File attachments
- In-app chat
- Push notifications

---

*For component details, see `components.md`*  
*For service dependencies, see `services.md`*  
*For user flows, see `user-flows.md`*
