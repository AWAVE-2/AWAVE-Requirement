# Category Tile Selector - Feature Documentation

**Feature Name:** Category Tile Selector  
**Status:** ⚪ Missing - Needs Migration  
**Priority:** High  
**Source:** React APP (Lovalbe)  
**Last Updated:** 2025-01-27

## 📋 Feature Overview

The Category Tile Selector provides an enhanced UI for selecting major categories (Schlafen, Stress, Leichtigkeit) using large, visually appealing tiles with icons, descriptions, and sound previews.

### Description

In the React APP, the category selector uses a tile-based layout where each major category is displayed as a large, interactive tile. This provides a more engaging and intuitive way to select categories compared to a simple list or carousel.

### User Value

- **Visual Appeal:** Large, attractive tiles make category selection more engaging
- **Clear Information:** Each tile shows category name, description, and icon
- **Better UX:** Easier to understand and select categories
- **Mobile-Friendly:** Touch-optimized tile sizes

---

## 🎯 Functional Requirements

### Core Requirements

#### Tile Display
- [ ] Large tile for each major category
- [ ] Category icon/illustration
- [ ] Category title
- [ ] Category description
- [ ] Visual feedback on selection
- [ ] Smooth animations

#### Category Data
- [ ] Schlafen (Sleep) category
- [ ] Stress category
- [ ] Leichtigkeit (Lightness/Ease) category
- [ ] Category-specific content preview
- [ ] Sound count per category

#### Interaction
- [ ] Tap tile to select category
- [ ] Visual highlight on selection
- [ ] Navigate to category screen
- [ ] Smooth transition animation

### User Stories

- As a user, I want to see large category tiles so that I can easily understand what each category offers
- As a user, I want to tap a tile to select a category so that I can quickly navigate to content
- As a user, I want visual feedback when selecting a category so that I know my selection was registered

### Acceptance Criteria

- [ ] All major categories are displayed as tiles
- [ ] Tiles are visually appealing and informative
- [ ] Selection works smoothly
- [ ] Navigation to category screen works
- [ ] Animations are smooth and performant

---

## 🏗️ Technical Specification

### Source Code Reference (React APP)

**File:** `src/components/CategoryTileSelector.tsx`
**Data:** `src/data/majorCategories.ts`

```typescript
// Category structure
export const majorCategories: Category[] = [
  {
    id: 'schlafen',
    title: 'Schlafen',
    description: 'Finde deinen perfekten Schlaf',
    iconUrl: '',
    icon: Moon,
    sounds: [...]
  },
  {
    id: 'stress',
    title: 'Stress',
    description: 'Befrei dich vom Stress',
    iconUrl: '',
    icon: Zap,
    sounds: [...]
  },
  {
    id: 'leichtigkeit',
    title: 'Leichtigkeit',
    description: 'Entfalte dein wahres Ich',
    iconUrl: '',
    icon: Heart,
    sounds: [...]
  }
];
```

### Components Needed

- `CategoryTileSelector.tsx` - Main tile selector component
- `CategoryTile.tsx` - Individual category tile
- `CategoryTileGrid.tsx` - Grid layout for tiles

### Services Needed

- `CategoryService.ts` - Already exists, may need extension
- Category data from `majorCategories.ts`

### Hooks Needed

- `useCategoryManagement.tsx` - Already exists
- May need `useCategoryTiles.ts` for tile-specific logic

### Data Models

```typescript
interface Category {
  id: string;
  title: string;
  description: string;
  iconUrl?: string;
  icon?: React.ComponentType; // Lucide icon
  sounds: Sound[];
}

interface CategoryTileProps {
  category: Category;
  onSelect: (categoryId: string) => void;
  isSelected?: boolean;
}
```

### Styling

- Large tile size (full width on mobile, grid on tablet)
- Rounded corners
- Shadow/elevation
- Gradient backgrounds
- Icon at top
- Title and description below
- Touch feedback (ripple/press effect)

---

## 🔄 User Flows

### Primary Flow: Select Category

1. User opens Start screen
2. System displays category tiles
3. User views available categories
4. User taps a category tile
5. System highlights selected tile
6. System navigates to category screen
7. Category screen displays category content

### Alternative Flow: Browse Categories

1. User opens Start screen
2. User scrolls through category tiles
3. User views different categories
4. User selects desired category

---

## 🎨 UI/UX Specifications

### Visual Design

- **Tile Size:** Full width on mobile, 2-3 columns on tablet
- **Spacing:** Adequate padding between tiles
- **Colors:** Category-specific color schemes
- **Icons:** Large, prominent icons
- **Typography:** Clear title, readable description
- **Shadows:** Subtle elevation for depth

### Interactions

- **Tap:** Select category and navigate
- **Press:** Visual feedback (scale down, opacity change)
- **Swipe:** Scroll through tiles if multiple
- **Long Press:** Show category details (optional)

### Platform-Specific Notes

- **iOS:** Use native touch feedback
- **Android:** Use Material Design ripple effect

### Responsive Design

- **Mobile:** Single column, full-width tiles
- **Tablet:** 2-3 column grid
- **Landscape:** Adjust tile sizes accordingly

---

## 📱 Platform Compatibility

- **iOS:** ⚠️ Partial - Category selection exists but not as tiles
- **Android:** ⚠️ Partial - Same as iOS

### Version Requirements

- iOS: 13.0+
- Android: API 21+

---

## 🔗 Related Features

- [Category Screens](../../Category%20Screens/)
- [Start Screens](../../Start%20Screens/)
- [Main Navigation](../../Main%20Navigation/)
- [Custom Sound Library](../Custom%20Sound%20Library/)

---

## 📚 Additional Resources

- React APP Source: `src/components/CategoryTileSelector.tsx`
- React APP Data: `src/data/majorCategories.ts`
- Current Implementation: Category selection in `Start.tsx`

---

## 📝 Notes

- Current implementation uses carousel, tiles would be an enhancement
- Consider accessibility for tile selection
- Ensure tiles work well with screen readers
- Performance: Lazy load tiles if many categories
- Consider adding category preview sounds

---

*Migration Priority: High*
*Estimated Complexity: Low*
*Dependencies: Category Service, Navigation*
