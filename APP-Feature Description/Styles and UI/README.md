# Styles and UI System - Feature Documentation

**Feature Name:** Styles and UI Design System  
**Status:** ✅ Complete  
**Priority:** High  
**Last Updated:** 2025-01-27

## 📋 Feature Overview

The Styles and UI system provides a comprehensive design system for the AWAVE app, ensuring visual consistency, brand alignment, and React web app parity. It includes a complete theme system with colors, typography, spacing, visual effects, and a reusable component library.

### Description

The Styles and UI system is built to achieve exact parity with the React web app and provides:
- **Complete theme system** with AWAVE brand colors, typography, and spacing
- **Reusable UI components** (Button, Card, Input, etc.) with platform-specific optimizations
- **Visual effects** including glass morphism, gradients, shadows, and animations
- **Design tokens** extracted from the web app's CSS custom properties
- **Platform-specific optimizations** for iOS and Android
- **Accessibility support** with proper touch targets and semantic labels

### User Value

- **Consistent experience** - Same visual design across web and mobile
- **Brand identity** - Accurate AWAVE brand colors and styling
- **Performance** - Optimized components with native drivers
- **Accessibility** - Proper touch targets and screen reader support
- **Developer experience** - Easy-to-use theme hooks and components

---

## 🎯 Core Features

### 1. Theme System
- Complete color palette with AWAVE brand colors
- Typography system with Raleway font family
- Spacing system based on TailwindCSS scale
- Border radius system
- Shadow and elevation system
- Layout specifications

### 2. Visual Effects
- **Glass morphism** - Light, medium, and heavy variants
- **Gradients** - Primary, secondary, background, and glow effects
- **Shadows** - Standard and glow shadow presets
- **Animations** - Fade, slide, scale, and pulse animations

### 3. UI Component Library
- **Button** - Multiple variants (primary, secondary, outline, ghost, destructive)
- **Card** - Default, interactive, glass, and outline variants
- **Input** - Default, search, password, and outline variants
- **Loading** - Spinner and skeleton loaders
- **Progress** - Linear and circular progress indicators
- **Switch** - Toggle switches with animations
- **Slider** - Range sliders with custom styling
- **Toast** - Notification toasts
- **Tabs** - Tab navigation components
- **Icon** - Icon system with Lucide compatibility

### 4. Design Tokens
- Color tokens extracted from web app CSS
- HSL to HEX conversions for React Native compatibility
- Semantic color mappings
- Opacity variants
- Spacing scale
- Typography scale

### 5. Platform Optimizations
- iOS-specific styling (native blur, haptic feedback)
- Android-specific styling (elevation, ripple effects)
- Platform detection utilities
- Native driver optimizations for animations

---

## 🏗️ Architecture

### Technology Stack
- **Theme System:** Custom theme provider with React Context
- **Styling:** React Native StyleSheet with theme integration
- **Animations:** React Native Animated API with native drivers
- **Visual Effects:** LinearGradient, BlurView, and custom components
- **Typography:** Raleway font family (Regular, Medium, SemiBold, Bold)

### Key Components
- `ThemeProvider` - Global theme context provider
- `useTheme` - Hook for accessing theme values
- `useUnifiedTheme` - Unified theme hook with backward compatibility
- UI component library in `src/components/ui/`
- Visual effects components in `src/components/visual-effects/`

---

## 📱 Component Categories

### Core Components
1. **Button** - Primary action buttons with variants
2. **Card** - Container components with glass morphism
3. **Input** - Form input fields with validation states
4. **Icon** - Icon system with Lucide compatibility

### Feedback Components
1. **Loading** - Loading indicators and spinners
2. **Progress** - Progress bars and circular indicators
3. **Toast** - Notification messages
4. **SkeletonLoader** - Content placeholders

### Form Components
1. **Switch** - Toggle switches
2. **Slider** - Range sliders
3. **Select** - Dropdown selectors
4. **RadioGroup** - Radio button groups
5. **Tabs** - Tab navigation

### Layout Components
1. **Card** - Container cards
2. **Accordion** - Collapsible sections
3. **EmptyState** - Empty state displays
4. **ConfirmDialog** - Confirmation dialogs

---

## 🎨 Design System

### Color System
- **AWAVE Brand Colors:**
  - Background: `rgba(18, 3, 20, 1)` (#120314)
  - Primary: `rgba(110, 79, 165, 1)` (#6e4fa5)
  - Secondary: `rgba(45, 112, 140, 1)` (#2d708c)
  - Accent: `rgba(60, 94, 78, 1)` (#3c5e4e)
  - Text: `rgba(255, 255, 255, 1)` (#ffffff)

- **Glass Morphism Colors:**
  - Light: `rgba(255, 255, 255, 0.05)`
  - Medium: `rgba(255, 255, 255, 0.1)`
  - Heavy: `rgba(255, 255, 255, 0.15)`

### Typography
- **Font Family:** Raleway (Regular, Medium, SemiBold, Bold)
- **Font Sizes:** xs (12), sm (14), base (16), lg (18), xl (20), 2xl (24), 3xl (30), 4xl (36), 5xl (48)
- **Font Weights:** thin (100), light (300), normal (400), medium (500), semibold (600), bold (700), extrabold (800), black (900)
- **Line Heights:** tight (1.25), normal (1.5), relaxed (1.75)

### Spacing
- **Scale:** 0, 1 (4px), 2 (8px), 3 (12px), 4 (16px), 5 (20px), 6 (24px), 8 (32px), 10 (40px), 12 (48px), 16 (64px), 20 (80px), 24 (96px)
- **App Padding:** 24px (1.5rem)
- **Component Spacing:** 16px (1rem)
- **Element Spacing:** 8px (0.5rem)

### Border Radius
- **Default:** 12px (0.75rem)
- **Small:** 8px (0.5rem)
- **Large:** 16px (1rem)
- **Full:** 9999px (circular)

---

## 🔄 Integration Points

### Related Features
- **Navigation** - Uses theme colors and spacing
- **Audio Player** - Uses glass morphism and gradients
- **Authentication** - Uses button and input components
- **Profile** - Uses card and form components
- **Settings** - Uses switch and select components

### External Dependencies
- React Native core components
- `react-native-linear-gradient` for gradients
- `@react-native-community/blur` for blur effects (iOS)
- `react-native-reanimated` for advanced animations (optional)

---

## 🧪 Testing Considerations

### Test Cases
- Theme provider context
- Component variants and states
- Visual effects rendering
- Platform-specific styling
- Accessibility properties
- Responsive layouts

### Edge Cases
- Dark mode support (future)
- Dynamic font scaling
- Platform-specific rendering differences
- Performance with many animated components
- Memory usage with gradients and blur effects

---

## 📚 Additional Resources

- [React Native Styling Documentation](https://reactnative.dev/docs/style)
- [React Native Animated API](https://reactnative.dev/docs/animated)
- [Raleway Font Family](https://fonts.google.com/specimen/Raleway)
- [Design Tokens Specification](https://design-tokens.github.io/community-group/format/)

---

## 📝 Notes

- All colors are converted from HSL (web) to HEX (React Native)
- Theme system ensures exact parity with React web app
- Platform-specific optimizations improve performance
- Glass morphism uses platform-native blur where available
- All components support accessibility properties
- Design tokens are the single source of truth for styling

---

*For detailed technical specifications, see `technical-spec.md`*  
*For component details, see `components.md`*  
*For utilities and services, see `services.md`*  
*For styling usage flows, see `user-flows.md`*
