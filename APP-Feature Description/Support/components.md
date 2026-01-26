# Support System - Components Inventory

## 📱 Screens

### SupportScreen
**File:** `src/screens/SupportScreen.tsx`  
**Route:** `/support`  
**Purpose:** Main support screen with contact form and help resources

**Props:** None

**State:**
- `formData: { name, email, subject, message }` - Form data
- `showSubjectPicker: boolean` - Subject picker visibility
- `isSubmitting: boolean` - Submission loading state

**Components Used:**
- `SafeAreaView` - Safe area container
- `ScrollView` - Scrollable content
- `View` - Layout containers
- `Text` - Text display
- `TextInput` - Form inputs
- `AnimatedButton` - Interactive buttons
- `EnhancedCard` - Card components
- `Icon` - Icons
- `LinearGradient` - Gradient backgrounds
- `ActivityIndicator` - Loading spinner
- `Alert` - Alert dialogs

**Hooks Used:**
- `useTheme` - Theme styling
- `useNavigation` - Navigation control

**Features:**
- Contact form with validation
- Subject picker dropdown
- Quick help cards (Getting Started, FAQ)
- Alternative contact methods (Email, Phone)
- Form submission with loading states
- XSS prevention
- Character counting
- Back navigation

**User Interactions:**
- Fill form fields
- Select subject category
- Submit form
- Click quick help cards
- Click email/phone support cards
- Navigate back

**Sections:**
1. **Header** - Title and back button
2. **Quick Help Section** - Getting Started and FAQ cards
3. **Contact Form Section** - Name, email, subject, message fields
4. **Alternative Contact Methods** - Email and phone support cards

---

## 🧩 Components

### ProfileSupportSection
**File:** `src/components/profile/ProfileSupportSection.tsx`  
**Type:** Profile Section Component

**Props:**
```typescript
interface ProfileSupportSectionProps {
  onSignOut?: () => void;
}
```

**State:** None (stateless)

**Components Used:**
- `View` - Layout container
- `Text` - Text display
- `TouchableOpacity` - Interactive elements
- `EnhancedCard` - Card components
- `Icon` - Icons
- `LinearGradient` - Gradient backgrounds
- `InteractiveTouchableOpacity` - Enhanced button

**Hooks Used:**
- `useTheme` - Theme styling
- `useNavigation` - Navigation control
- `useAuth` - Authentication state

**Features:**
- Support section header with icon
- "AWAVE teilen" (Share) card
- "Hilfe & Support" (Help & Support) card
- Sign out button (if authenticated)
- Consistent styling with Profile

**User Interactions:**
- Click share card → Share AWAVE app
- Click support card → Navigate to Support screen
- Click sign out button → Sign out

**Sub-components:**
- Section header with gradient icon
- Share card with icon and description
- Support card with icon and description
- Sign out section (conditional, if authenticated)

---

## 🔗 Component Relationships

### SupportScreen Component Tree
```
SupportScreen
├── SafeAreaView
│   └── View (Header)
│       ├── AnimatedButton (Back)
│       ├── Text (Title)
│       └── View (Placeholder)
│   └── ScrollView
│       ├── View (Quick Help Section)
│       │   ├── View (Section Header)
│       │   │   ├── LinearGradient (Icon Container)
│       │   │   │   └── Icon (HelpCircle)
│       │   │   └── View (Text Container)
│       │   │       ├── Text (Title)
│       │   │       └── Text (Subtitle)
│       │   └── View (Quick Help Cards)
│       │       ├── EnhancedCard (Getting Started)
│       │       │   ├── View (Icon Container)
│       │       │   │   └── Icon (BookOpen)
│       │       │   ├── Text (Title)
│       │       │   └── Text (Description)
│       │       └── EnhancedCard (FAQ)
│       │           ├── View (Icon Container)
│       │           │   └── Icon (Lightbulb)
│       │           ├── Text (Title)
│       │           └── Text (Description)
│       │
│       ├── View (Contact Form Section)
│       │   ├── View (Section Header)
│       │   │   ├── LinearGradient (Icon Container)
│       │   │   │   └── Icon (MessageCircle)
│       │   │   └── View (Text Container)
│       │   │       ├── Text (Title)
│       │   │       └── Text (Subtitle)
│       │   └── View (Form)
│       │       ├── View (Name Input Group)
│       │       │   ├── Text (Label)
│       │       │   └── TextInput (Name)
│       │       ├── View (Email Input Group)
│       │       │   ├── Text (Label)
│       │       │   └── TextInput (Email)
│       │       ├── View (Subject Picker Group)
│       │       │   ├── Text (Label)
│       │       │   ├── AnimatedButton (Picker)
│       │       │   │   ├── Text (Selected/Placeholder)
│       │       │   │   └── Text (Dropdown Icon)
│       │       │   └── View (Picker Options) - conditional
│       │       │       └── AnimatedButton[] (Options)
│       │       ├── View (Message Input Group)
│       │       │   ├── Text (Label)
│       │       │   ├── TextInput (Message - multiline)
│       │       │   └── Text (Character Count)
│       │       └── AnimatedButton (Submit)
│       │           ├── ActivityIndicator - conditional
│       │           └── Text (Submit Text)
│       │
│       └── View (Alternative Contact Methods Section)
│           ├── View (Section Header)
│           │   ├── LinearGradient (Icon Container)
│           │   │   └── Icon (Phone)
│           │   └── View (Text Container)
│           │       ├── Text (Title)
│           │       └── Text (Subtitle)
│           └── View (Contact Cards)
│               ├── AnimatedButton (Email Support)
│               │   └── EnhancedCard
│               │       ├── View (Icon Container)
│               │       │   └── Icon (Mail)
│               │       └── View (Content)
│               │           ├── Text (Title)
│               │           ├── Text (Subtitle)
│               │           ├── Text (Description)
│               │           └── Text (Email Address)
│               └── AnimatedButton (Phone Support)
│                   └── EnhancedCard
│                       ├── View (Icon Container)
│                       │   └── Icon (Phone)
│                       └── View (Content)
│                           ├── Text (Title)
│                           ├── Text (Subtitle)
│                           ├── Text (Description)
│                           └── Text (Phone Number)
```

### ProfileSupportSection Component Tree
```
ProfileSupportSection
└── View (Container)
    ├── View (Section Header)
    │   ├── LinearGradient (Icon Container)
    │   │   └── Icon (LifeBuoy)
    │   └── View (Text Container)
    │       ├── Text (Title)
    │       └── Text (Description)
    │
    └── View (Links Container)
        ├── TouchableOpacity (Share Card)
        │   └── EnhancedCard
        │       └── View (Link Row)
        │           ├── View (Icon Container)
        │           │   └── Icon (Share2)
        │           ├── View (Text Container)
        │           │   ├── Text (Title)
        │           │   └── Text (Description)
        │           └── Icon (ChevronRight)
        │
        ├── TouchableOpacity (Support Card)
        │   └── EnhancedCard
        │       └── View (Link Row)
        │           ├── View (Icon Container)
        │           │   └── Icon (HelpCircle)
        │           ├── View (Text Container)
        │           │   ├── Text (Title)
        │           │   └── Text (Description)
        │           └── Icon (ChevronRight)
        │
        └── View (Sign Out Card) - conditional
            └── EnhancedCard
                ├── View (Section Header)
                │   ├── LinearGradient (Icon Container)
                │   │   └── Icon (LogOut)
                │   └── Text (Title)
                ├── Text (Description)
                └── InteractiveTouchableOpacity (Sign Out Button)
                    └── Text (Button Text)
```

---

## 🎨 Styling

### Theme Integration
All components use the theme system via `useTheme` hook:
- Colors: `theme.colors.primary`, `theme.colors.textPrimary`, `theme.colors.backgroundCard`, etc.
- Typography: `theme.typography.fontFamily.regular`, `theme.typography.fontFamily.medium`, etc.
- Spacing: Consistent padding and margins

### Design Tokens
**Colors:**
- Primary: Theme primary color
- Text: `textPrimary`, `textSecondary`, `textMuted`
- Background: `awave.background`, `backgroundCard`
- Border: `border`
- Destructive: `destructive` (for sign out)

**Typography:**
- Font Family: Raleway (Regular, Medium, SemiBold, Bold)
- Font Sizes: 12px, 14px, 16px, 18px, 20px
- Line Heights: Adjusted for readability

**Spacing:**
- Section gaps: 32px
- Form gaps: 20px
- Card padding: 16px
- Border radius: 12px, 16px (PROFILE_RADIUS)

### Component-Specific Styling
**SupportScreen:**
- Container: Full screen with SafeAreaView
- Header: Fixed height with border
- Sections: Spaced with 32px gap
- Cards: Gradient backgrounds with border radius

**ProfileSupportSection:**
- Container: Margin bottom 16px
- Section header: Row layout with icon and text
- Link cards: Full width with gradient backgrounds
- Sign out card: Red gradient with border

---

## 🔄 State Management

### Local State
**SupportScreen:**
- Form data (name, email, subject, message)
- Subject picker visibility
- Submission loading state

**ProfileSupportSection:**
- No local state (stateless component)

### Context State
- `AuthContext` - Authentication state (used in ProfileSupportSection)
- `ThemeContext` - Theme state (used in both components)

### Navigation State
- Managed by React Navigation
- Stack navigation for Support screen
- Tab navigation for Profile screen

---

## 🧪 Testing Considerations

### Component Tests
- Form field rendering
- Input validation
- Subject picker functionality
- Character counting
- Button interactions
- Card interactions
- Navigation triggers

### Integration Tests
- Form submission flow
- Email/phone link opening
- Navigation flows
- Error handling
- Loading states

### E2E Tests
- Complete form submission
- Contact method interactions
- Navigation from Profile
- Error scenarios
- Edge cases

---

## 📊 Component Metrics

### Complexity
- **SupportScreen:** High (form, validation, multiple sections)
- **ProfileSupportSection:** Low (simple navigation links)

### Reusability
- **SupportScreen:** Low (specific to support feature)
- **ProfileSupportSection:** Medium (reusable profile section pattern)

### Dependencies
- Both components depend on theme system
- Both components depend on navigation
- SupportScreen depends on Linking API
- ProfileSupportSection depends on Auth context

---

*For service dependencies, see `services.md`*  
*For user flows, see `user-flows.md`*  
*For technical details, see `technical-spec.md`*
