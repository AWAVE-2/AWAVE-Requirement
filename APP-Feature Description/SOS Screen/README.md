# SOS Screen - Feature Documentation

**Feature Name:** SOS Screen & Crisis Support Resources  
**Status:** ✅ Complete  
**Priority:** High  
**Last Updated:** 2025-01-27

## 📋 Feature Overview

The SOS Screen feature provides immediate crisis support resources to users who may be experiencing mental health emergencies or need professional help. The feature is intelligently triggered through search queries containing crisis-related keywords and displays a full-screen drawer with emergency contact information, chat links, and additional resources.

### Description

The SOS Screen system is integrated into the search functionality and provides:
- **Intelligent keyword detection** - Automatically triggers on crisis-related search queries
- **Full-screen crisis resources** - Comprehensive emergency support information
- **Direct action buttons** - One-tap calling and chat access
- **Additional resources** - List of support services with phone number extraction
- **Configurable content** - Admin-configurable via database (keywords, messages, resources)
- **Analytics tracking** - Logs SOS triggers for monitoring and support

### User Value

- **Immediate access** - Crisis resources available instantly when needed
- **Discrete triggering** - Activated through natural search queries
- **Professional support** - Direct access to trained crisis counselors
- **Multiple channels** - Phone and chat options for different preferences
- **Comprehensive resources** - Multiple support services in one place
- **Privacy-focused** - No user tracking of sensitive queries

---

## 🎯 Core Features

### 1. Intelligent SOS Trigger
- Keyword-based detection in search queries
- Case-insensitive matching
- Configurable trigger keywords from database
- Automatic activation when keywords detected
- Seamless transition from search to SOS screen

### 2. SOS Screen Display
- **Full-screen drawer** - Maximum visibility and focus
- **Header with close button** - Easy dismissal
- **Optional image** - Visual support element
- **Title and message** - Configurable supportive messaging
- **Action buttons** - Primary call and chat actions
- **Resources list** - Additional support services
- **Information box** - Encouraging message about seeking help

### 3. Emergency Actions
- **Phone call** - Direct dialing with formatted numbers
- **Chat link** - Opens external chat service
- **Resource calls** - Phone numbers extracted from resource text
- **Error handling** - Graceful fallbacks if actions unavailable

### 4. Configuration Management
- Database-driven configuration
- Active/inactive status control
- Keyword list management
- Customizable messaging
- Resource list updates
- Image URL support
- Cache management (1-hour cache duration)

### 5. Analytics & Tracking
- Search query logging
- SOS trigger detection tracking
- Results count tracking
- User association (when authenticated)
- Anonymous tracking support

---

## 🏗️ Architecture

### Technology Stack
- **Backend:** Supabase Database (`sos_config` table)
- **State Management:** React Hooks (`useIntelligentSearch`)
- **UI Components:** React Native with custom BottomSheet
- **Linking:** React Native Linking API (phone, URLs)
- **Caching:** In-memory cache with 1-hour expiration

### Key Components
- `SOSDrawer` - Full-height drawer wrapper
- `SOSScreenDrawer` - Main SOS content component
- `useIntelligentSearch` - Search hook with SOS detection
- `SearchDrawer` - Search interface with SOS integration
- `TabNavigator` - Navigation coordinator

---

## 📱 Screens

1. **SOSDrawer** - Full-height bottom sheet wrapper (100% height, z-index 300)
2. **SOSScreenDrawer** - Main SOS content screen with all resources
3. **SearchDrawer** - Search interface that triggers SOS (integrated)

---

## 🔄 User Flows

### Primary Flows
1. **SOS Trigger Flow** - Search Query → Keyword Detection → SOS Screen Display
2. **Call Flow** - SOS Screen → Call Button → Phone Dialer
3. **Chat Flow** - SOS Screen → Chat Button → External Chat
4. **Resource Call Flow** - SOS Screen → Resource Item → Phone Dialer
5. **Close Flow** - SOS Screen → Close Button → Return to Search

### Alternative Flows
- **Direct Search** - No keywords → Normal search results
- **Cache Miss** - Config not loaded → Attempt reload → Fallback to defaults
- **Action Unavailable** - Phone/Chat unavailable → Error alert → Continue

---

## 🔐 Security & Privacy Features

- No sensitive data stored locally
- Anonymous search tracking support
- Configurable content (admin-controlled)
- Secure database access (RLS policies)
- No user identification required for access

---

## 📊 Integration Points

### Related Features
- **Search** - SOS triggered through search queries
- **Navigation** - Integrated into TabNavigator drawer system
- **Analytics** - Search analytics include SOS trigger tracking
- **Backend Services** - ProductionBackendService for config loading

### External Services
- Supabase Database (configuration storage)
- Phone dialer (native device functionality)
- External chat services (URL-based)
- Search analytics (tracking)

---

## 🧪 Testing Considerations

### Test Cases
- SOS keyword detection
- SOS screen rendering
- Phone call functionality
- Chat link opening
- Resource phone extraction
- Configuration loading
- Cache behavior
- Error handling (unavailable actions)
- Close/dismiss functionality

### Edge Cases
- No configuration available
- Invalid phone numbers
- Unavailable chat links
- Network errors during config load
- Cache expiration
- Multiple simultaneous triggers

---

## 📚 Additional Resources

- [Supabase Database Documentation](https://supabase.com/docs/guides/database)
- [React Native Linking API](https://reactnative.dev/docs/linking)
- [Crisis Support Resources](https://www.telefonseelsorge.de/)

---

## 📝 Notes

- SOS configuration is cached for 1 hour to reduce database calls
- Default phone number: 0800 111 0 111 (Telefonseelsorge)
- Phone numbers are automatically extracted from resource text
- SOS drawer has higher z-index (300) than SearchDrawer to overlay properly
- Search analytics track SOS triggers for monitoring purposes
- Configuration must be marked `active: true` in database to be used

---

*For detailed technical specifications, see `technical-spec.md`*  
*For user flow diagrams, see `user-flows.md`*  
*For component details, see `components.md`*  
*For service dependencies, see `services.md`*
