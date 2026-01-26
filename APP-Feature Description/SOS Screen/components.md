# SOS Screen - Components Inventory

## 📱 Components

### SOSDrawer
**File:** `src/components/SOSDrawer.tsx`  
**Type:** Container Component  
**Purpose:** Full-height drawer wrapper for SOS screen

**Props:**
```typescript
interface SOSDrawerProps {
  isOpen: boolean;
  onClose: () => void;
  sosConfig: SOSConfig;
  onDismiss: () => void;
}
```

**State:** None (stateless wrapper)

**Components Used:**
- `BottomSheet` - Drawer container
- `SOSScreenDrawer` - Main content component

**Hooks Used:**
- `useCallback` - Close handler memoization

**Features:**
- Full-height bottom sheet (maxHeightRatio: 1.0)
- High z-index (300) for overlay
- Swipe-down gesture support
- Close/dismiss callback handling
- Config passing to content component

**User Interactions:**
- Swipe down to close
- Close button (via SOSScreenDrawer)

**Dependencies:**
- `BottomSheet` component
- `SOSScreenDrawer` component
- `SOSConfig` type

---

### SOSScreenDrawer
**File:** `src/components/SOSScreenDrawer.tsx`  
**Type:** Presentational Component  
**Purpose:** Main SOS content screen with all resources

**Props:**
```typescript
interface SOSScreenDrawerProps {
  title: string;
  message: string;
  imageUrl?: string;
  phoneNumber: string;
  chatLink?: string;
  resources: string[];
  onDismiss: () => void;
}
```

**State:** None (presentational)

**Components Used:**
- `AnimatedButton` - Action buttons
- `Icon` - Icons (heart, phone, message-square, x)
- `Image` - Optional image display
- `ScrollView` - Scrollable content
- `View` - Layout containers
- `Text` - Text display

**Hooks Used:**
- `useTheme` - Theme styling

**Features:**
- Scrollable content layout
- Header with close button
- Optional image display
- Title and message sections
- Call button with phone number
- Chat button (conditional)
- Resources list with phone extraction
- Information box
- Phone number extraction from text
- German phone format support

**User Interactions:**
- Click "Sofort anrufen" → Opens phone dialer
- Click "Online-Chat starten" → Opens chat link
- Click resource item (if phone detected) → Calls phone
- Click close button → Dismisses SOS screen
- Scroll content → Views all resources

**Phone Number Extraction:**
- Regex: `/(\+?\d{1,4}[\s-]?)?(\(?\d{1,4}\)?[\s-]?)?(\d{1,4}[\s-]?)*\d{1,9}/g`
- Supports: +49, 0800, 116, 030, etc.
- Returns longest match

**Action Handlers:**
- `handleCall(number?: string)` - Formats and dials phone
- `handleChat()` - Opens chat link
- `extractPhoneNumber(text: string)` - Extracts phone from text

**Styling:**
- Theme-integrated colors
- Responsive layout
- Consistent spacing
- Accessible touch targets

**Dependencies:**
- `useTheme` hook
- `AnimatedButton` component
- `Icon` component
- `Linking` API
- `Alert` API
- `getSolidBackground` utility

---

## 🔗 Component Relationships

### SOSDrawer Component Tree
```
SOSDrawer
└── BottomSheet (maxHeightRatio: 1.0, zIndex: 300)
    └── SOSScreenDrawer
        ├── ScrollView
        │   ├── View (Header)
        │   │   ├── View (Header Left)
        │   │   │   ├── Icon (heart)
        │   │   │   └── Text (Soforthilfe)
        │   │   └── AnimatedButton (Close)
        │   │       └── Icon (x)
        │   ├── View (Image Container) - conditional
        │   │   └── Image
        │   ├── View (Text Section)
        │   │   ├── Text (Title)
        │   │   └── Text (Message)
        │   ├── View (Actions Section)
        │   │   ├── AnimatedButton (Call)
        │   │   │   ├── Icon (phone)
        │   │   │   └── Text (Sofort anrufen: ...)
        │   │   └── AnimatedButton (Chat) - conditional
        │   │       ├── Icon (message-square)
        │   │       └── Text (Online-Chat starten)
        │   ├── View (Resources Section) - conditional
        │   │   ├── Text (Resources Title)
        │   │   └── View (Resources List)
        │   │       └── AnimatedButton (Resource Item) * N
        │   │           ├── Icon (phone) - conditional
        │   │           └── Text (Resource Text)
        │   └── View (Info Box)
        │       └── Text (Info Text)
```

### Integration with SearchDrawer
```
SearchDrawer
├── useIntelligentSearch hook
│   ├── checkForSOSTrigger()
│   └── setShowSOSScreen(true)
└── useEffect
    └── onSOSTriggered(sosConfig)
        └── TabNavigator
            └── SOSDrawer (opens)
```

### Integration with TabNavigator
```
TabNavigator
├── SearchDrawer
│   └── onSOSTriggered callback
└── SOSDrawer
    ├── isOpen: sosDrawerOpen
    ├── sosConfig: sosConfig
    └── onClose: handleSOSClose
```

---

## 🎨 Styling

### Theme Integration
All components use the theme system via `useTheme` hook:
- Colors: `theme.colors.primary`, `theme.colors.text.primary`, `theme.colors.destructive`, etc.
- Typography: `theme.fonts.raleway`
- Spacing: Consistent padding and margins
- Borders: `theme.colors.border`

### Component-Specific Styles

**SOSDrawer:**
- No custom styles (wrapper only)

**SOSScreenDrawer:**
- Container: `flex: 1`
- Header: `flexDirection: 'row'`, `paddingHorizontal: 16`, `paddingVertical: 12`
- Image: `width: '100%'`, `height: 192`, `borderRadius: 12`
- Title: `fontSize: 24`, `fontWeight: '700'`, `textAlign: 'center'`
- Message: `fontSize: 16`, `lineHeight: 24`, `textAlign: 'center'`
- Call Button: `paddingVertical: 16`, `paddingHorizontal: 20`, `borderRadius: 12`
- Chat Button: `paddingVertical: 14`, `paddingHorizontal: 20`, `borderRadius: 12`, `borderWidth: 1`
- Resource Item: `padding: 12`, `borderRadius: 12`, `borderWidth: 1`
- Info Box: `padding: 16`, `borderRadius: 12`, `borderWidth: 1`

### Responsive Design
- ScrollView for long content
- Flexible layout
- Safe area handling
- Keyboard avoidance (not needed for SOS)

### Accessibility
- Semantic labels
- Touch target sizes (min 44x44)
- Color contrast compliance
- Screen reader support
- Accessible button labels

---

## 🔄 State Management

### Local State
- None (presentational components)

### Props State
- `isOpen` - Drawer visibility (from TabNavigator)
- `sosConfig` - Configuration data (from useIntelligentSearch)
- `title`, `message`, etc. - Content props

### Context State
- `useTheme` - Theme context

### Persistent State
- None (no local storage)

---

## 🧪 Testing Considerations

### Component Tests
- Rendering with props
- Button interactions
- Phone number extraction
- Image display (conditional)
- Resource list rendering
- Close button functionality

### Integration Tests
- SOS trigger flow
- Drawer open/close
- Phone call initiation
- Chat link opening
- Navigation integration

### E2E Tests
- Complete user journey
- Error scenarios
- Network failures
- Action unavailability

---

## 📊 Component Metrics

### Complexity
- **SOSDrawer:** Low (simple wrapper)
- **SOSScreenDrawer:** Medium (multiple sections, actions)

### Reusability
- **SOSDrawer:** Medium (specific to SOS use case)
- **SOSScreenDrawer:** High (can be used standalone)

### Dependencies
- All components depend on theme system
- SOSDrawer depends on BottomSheet
- SOSScreenDrawer depends on multiple UI components
- Both depend on Linking API

---

## 🔗 Component Dependencies

### External Dependencies
- `react-native` - Core framework
- `react-native-linear-gradient` - Not used in SOS
- Custom `BottomSheet` - Drawer container
- Custom `AnimatedButton` - Interactive buttons
- Custom `Icon` - Icon display
- `useTheme` hook - Theme access

### Internal Dependencies
- `SOSConfig` type - Configuration interface
- `getSolidBackground` utility - Background helper
- `Linking` API - Phone/URL handling
- `Alert` API - Error messages

---

## 🎯 Component Responsibilities

### SOSDrawer
- **Responsibility:** Drawer container and state management
- **Handles:** Open/close state, config passing
- **Delegates:** Content rendering to SOSScreenDrawer

### SOSScreenDrawer
- **Responsibility:** Content display and user interactions
- **Handles:** Phone calls, chat links, resource interactions
- **Delegates:** Navigation to parent via callbacks

---

*For service dependencies, see `services.md`*  
*For user flows, see `user-flows.md`*  
*For technical details, see `technical-spec.md`*
