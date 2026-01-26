# Search Drawer - Feature Documentation

**Feature Name:** Search Drawer & Intelligent Search  
**Status:** ✅ Complete  
**Priority:** High  
**Last Updated:** 2025-01-27

## 📋 Feature Overview

The Search Drawer provides a comprehensive search interface for discovering sounds within the AWAVE app. It features intelligent search capabilities with SOS trigger detection, real-time results, and seamless integration with the audio player system.

### Description

The Search Drawer is a bottom sheet component that slides up from the bottom of the screen, providing users with a powerful search interface to find sounds by keywords, tags, or descriptions. It includes:

- **Intelligent search** with Supabase backend integration
- **Real-time search results** with debounced input
- **SOS trigger detection** for crisis-related queries
- **Responsive design** for phones and tablets
- **Keyboard-aware layout** for optimal input experience
- **Search analytics** tracking for insights

### User Value

- **Quick discovery** - Find sounds instantly with intelligent search
- **Crisis support** - Automatic SOS detection for mental health emergencies
- **Seamless experience** - Smooth animations and responsive interactions
- **Smart results** - Relevance-ranked results based on multiple criteria
- **Accessibility** - Keyboard-friendly with clear visual feedback

---

## 🎯 Core Features

### 1. Search Interface
- Bottom sheet drawer that slides up from bottom
- Search input with icon and clear button
- Real-time search with 300ms debounce
- Auto-focus on open
- Responsive height (85% phones, 60% tablets)

### 2. Intelligent Search
- **Supabase integration** - Server-side search with full-text capabilities
- **Multi-field matching** - Searches title, description, keywords, and tags
- **Relevance scoring** - Client-side ranking based on match quality
- **Result limiting** - Top 6 most relevant results
- **Search weight** - Considers sound popularity and relevance

### 3. SOS Trigger Detection
- **Keyword matching** - Detects crisis-related search queries
- **Automatic trigger** - Opens SOS drawer when keywords match
- **Configurable keywords** - Loaded from database (sos_config table)
- **Seamless transition** - Search drawer closes, SOS drawer opens
- **Return flow** - Search drawer reopens when SOS closes

### 4. Search Results Display
- **Loading states** - Skeleton loaders during search
- **Empty states** - Helpful messages when no results found
- **Result cards** - Sound information with icons and descriptions
- **Play functionality** - Direct sound selection from results
- **Result count** - Shows number of matching sounds

### 5. Search Analytics
- **Query logging** - Tracks all search queries
- **Result tracking** - Records number of results returned
- **SOS tracking** - Logs when SOS is triggered
- **User association** - Links searches to user accounts
- **Anonymous support** - Tracks searches for non-authenticated users

### 6. Navigation Integration
- **Tab preservation** - Remembers active tab before opening search
- **Return navigation** - X button returns to last active tab
- **Smooth transitions** - Coordinated with TabNavigator
- **Modal overlay** - Proper z-index layering with other drawers

---

## 🏗️ Architecture

### Technology Stack
- **UI Framework:** React Native with TypeScript
- **Backend:** Supabase (PostgreSQL full-text search)
- **State Management:** React Hooks (useState, useEffect, useCallback)
- **Animations:** React Native Reanimated (via BottomSheet)
- **Search Logic:** Custom hook (useIntelligentSearch)

### Key Components
- `SearchDrawer` - Main search interface component
- `SearchResults` - Results display component
- `BottomSheet` - Reusable bottom sheet container
- `useIntelligentSearch` - Search logic hook
- `ProductionBackendService` - Backend integration service

---

## 📱 Screens

1. **SearchDrawer** - Main search interface (bottom sheet)
   - Opens from TabNavigator via search button
   - Contains search input, results, and header
   - Handles SOS trigger detection and navigation

---

## 🔄 User Flows

### Primary Flows
1. **Search Flow** - Open Drawer → Type Query → View Results → Select Sound
2. **SOS Trigger Flow** - Type Crisis Query → SOS Detected → SOS Drawer Opens
3. **Empty Results Flow** - Type Query → No Results → Show Suggestions
4. **Navigation Flow** - Open Search → Close → Return to Last Tab

### Alternative Flows
- **Quick Search** - Type → Results → Select (minimal interaction)
- **Refined Search** - Type → Clear → Type New Query
- **SOS Return** - SOS Opens → Close → Search Reopens

---

## 🔐 Security Features

- Search queries logged securely
- User privacy maintained (anonymous search support)
- SOS keywords configurable via database
- No sensitive data exposed in search results

---

## 📊 Integration Points

### Related Features
- **TabNavigator** - Opens/closes search drawer
- **SOS Drawer** - Triggered by search queries
- **Audio Player** - Sound selection from results
- **Library** - Related sound discovery
- **Categories** - Category-based filtering (future)

### External Services
- Supabase Database (sound_metadata table)
- Supabase Database (sos_config table)
- Supabase Database (search_analytics table)

---

## 🧪 Testing Considerations

### Test Cases
- Search query input and debouncing
- Search results display and selection
- SOS trigger detection
- Empty state handling
- Loading state display
- Navigation flows
- Keyboard interactions
- Responsive design (phone/tablet)

### Edge Cases
- Network connectivity issues
- Empty search queries
- Very long search queries
- Special characters in queries
- Rapid typing (debounce handling)
- SOS config not loaded
- No search results

---

## 📚 Additional Resources

- [Supabase Full-Text Search Documentation](https://supabase.com/docs/guides/database/full-text-search)
- [React Native Reanimated](https://docs.swmansion.com/react-native-reanimated/)
- [React Native Gesture Handler](https://docs.swmansion.com/react-native-gesture-handler/)

---

## 📝 Notes

- Search debounce is set to 300ms for optimal UX
- Results are limited to top 6 for performance
- SOS keywords are case-insensitive
- Search analytics are logged asynchronously (non-blocking)
- Bottom sheet height adapts to device size
- Search drawer z-index is 200 (SOS drawer is 300)

---

*For detailed technical specifications, see `technical-spec.md`*  
*For user flow diagrams, see `user-flows.md`*  
*For component details, see `components.md`*  
*For service dependencies, see `services.md`*
