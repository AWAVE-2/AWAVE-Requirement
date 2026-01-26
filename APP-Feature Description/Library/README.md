# Library System - Feature Documentation

**Feature Name:** Library & Sound Management  
**Status:** ✅ Complete  
**Priority:** High  
**Last Updated:** 2025-01-27

## 📋 Feature Overview

The Library system provides comprehensive sound management capabilities for the AWAVE app. It enables users to browse, search, filter, and manage their audio library with favorites, category filtering, subscription-based access control, and mix creation functionality.

### Description

The Library system is built on Supabase and provides:
- **Complete sound catalog** - Access to all production sounds in the database
- **Advanced search** - Full-text search across titles, descriptions, tags, and keywords
- **Category filtering** - Filter sounds by category (Nature, Rain, Ocean, Forest, Meditation, Sleep, White Noise)
- **Favorites management** - Add/remove favorites with real-time sync
- **Subscription-based access** - Premium content locking based on subscription tier
- **Mix creation** - Select up to 4 sounds to create custom mixes
- **Offline support** - Download sounds for offline playback
- **Library statistics** - Track total and accessible sounds

### User Value

- **Discovery** - Browse and discover new sounds easily
- **Organization** - Filter and search to find specific sounds quickly
- **Personalization** - Save favorites for quick access
- **Flexibility** - Create custom mixes from library sounds
- **Offline access** - Download sounds for offline use
- **Transparency** - Clear visibility of accessible vs. locked content

---

## 🎯 Core Features

### 1. Sound Catalog Browsing
- Display all available sounds from Supabase
- Real-time metadata loading
- Category-based organization
- Subscription tier filtering
- Locked content indicators

### 2. Search Functionality
- Full-text search across multiple fields
- Search in titles, descriptions, tags, and keywords
- Real-time search results
- Case-insensitive matching
- Combined with category filtering

### 3. Category Filtering
- Filter by category (All, Nature, Rain, Ocean, Forest, Meditation, Sleep, White Noise)
- Visual category indicators with icons
- Active category highlighting
- Combined with search queries

### 4. Favorites Management
- Add sounds to favorites
- Remove sounds from favorites
- Real-time favorite status updates
- Sync with Supabase backend
- Visual favorite indicators

### 5. Subscription-Based Access
- Filter content by subscription tier
- Lock premium content for non-premium users
- Visual lock indicators
- Statistics showing accessible vs. total sounds
- Paywall prompts for locked content

### 6. Mix Creation Mode
- Select mode for creating custom mixes
- Select up to 4 sounds
- Visual selection indicators
- Selection counter display
- Mix creation action button

### 7. Library Statistics
- Total sounds count
- Accessible sounds count (based on subscription)
- Subscription tier display
- Real-time statistics updates

---

## 🏗️ Architecture

### Technology Stack
- **Backend:** Supabase Database & Storage
- **State Management:** React Hooks (useState, useMemo, useCallback)
- **Storage:** AsyncStorage for local caching
- **File System:** React Native FS for offline downloads
- **Audio Management:** SupabaseAudioLibraryManager

### Key Components
- `LibraryScreen` - Main library interface
- `useFavoritesManagement` - Favorites state management hook
- `SupabaseAudioLibraryManager` - Audio file management service
- `ProductionBackendService` - Backend API integration
- `SoundLibraryPicker` - Sound selection component

---

## 📱 Screens

1. **LibraryScreen** (`/library`) - Main library screen with browsing, search, and filtering
2. **SoundLibraryPicker** - Modal component for sound selection in other contexts

---

## 🔄 User Flows

### Primary Flows
1. **Browse Library** - Open Library → View All Sounds → Filter by Category → Select Sound
2. **Search Sounds** - Open Library → Enter Search Query → View Results → Select Sound
3. **Add Favorite** - Browse/Search → Click Heart Icon → Sound Added to Favorites
4. **Create Mix** - Open Library → Enable Select Mode → Select 4 Sounds → Create Mix
5. **Access Locked Content** - View Locked Sound → Click → See Paywall → Upgrade Prompt

### Alternative Flows
- **Offline Download** - Select Sound → Download → Available Offline
- **Category Navigation** - Select Category → View Category Sounds → Search Within Category
- **Favorite Management** - View Favorites → Remove Favorite → Update Library

---

## 🔐 Security Features

- Subscription tier validation
- Premium content access control
- User authentication required for favorites
- Secure Supabase API calls
- Network connectivity checks

---

## 📊 Integration Points

### Related Features
- **Favorites** - Favorites management integration
- **Subscription** - Subscription tier checking and paywall
- **Audio Player** - Sound playback integration
- **Mix Creation** - Multi-sound selection for mixer
- **Offline Support** - Download and cache management

### External Services
- Supabase Database (sound_metadata table)
- Supabase Storage (audio files)
- ProductionBackendService (API layer)
- Subscription Service (tier checking)

---

## 🧪 Testing Considerations

### Test Cases
- Sound catalog loading
- Search functionality
- Category filtering
- Favorites add/remove
- Subscription tier filtering
- Mix creation mode
- Locked content handling
- Offline download
- Error handling (network, empty results, etc.)

### Edge Cases
- Network connectivity issues
- Empty search results
- No sounds in category
- Maximum mix selection (4 sounds)
- Subscription tier changes
- Favorites sync failures

---

## 📚 Additional Resources

- [Supabase Database Documentation](https://supabase.com/docs/guides/database)
- [Supabase Storage Documentation](https://supabase.com/docs/guides/storage)
- [React Native FS Documentation](https://github.com/itinance/react-native-fs)

---

## 📝 Notes

- Library loads all sounds from Supabase on mount
- Favorites sync with Supabase in real-time
- Subscription tier checked on user authentication
- Mix creation limited to 4 sounds maximum
- Offline downloads managed by SupabaseAudioLibraryManager
- Search is case-insensitive and matches partial strings

---

*For detailed technical specifications, see `technical-spec.md`*  
*For user flow diagrams, see `user-flows.md`*  
*For component details, see `components.md`*  
*For service dependencies, see `services.md`*
