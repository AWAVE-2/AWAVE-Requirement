# APIs and Business Logic - Feature Documentation

**Feature Name:** APIs and Business Logic  
**Status:** ✅ Complete  
**Priority:** High  
**Last Updated:** 2025-01-27

## 📋 Feature Overview

The APIs and Business Logic system provides the complete backend integration layer and business logic orchestration for the AWAVE app. It encompasses all API services, data processing, state management hooks, and business rule implementations that power the application's functionality.

### Description

The APIs and Business Logic system is built on Supabase and provides:
- **Unified backend service layer** - Single source of truth for all API operations
- **Business logic hooks** - Reusable React hooks for complex data operations
- **Service abstractions** - Domain-specific services (audio, subscriptions, search, etc.)
- **Error handling** - Centralized error management and network diagnostics
- **Data synchronization** - Real-time and offline data sync capabilities
- **Analytics integration** - Search, session, and usage analytics
- **Storage management** - Audio file downloads and local storage

### User Value

- **Reliability** - Robust error handling and offline support
- **Performance** - Optimized API calls with caching and batching
- **Consistency** - Unified data access patterns across features
- **Maintainability** - Clear separation of concerns and service boundaries
- **Scalability** - Architecture supports future feature additions

---

## 🎯 Core Features

### 1. Backend Service Layer
- ProductionBackendService - Primary API integration
- Service abstractions for all database operations
- Authentication, profiles, sessions, subscriptions
- Sound metadata and audio file management
- Custom sound sessions and favorites

### 2. Business Logic Hooks
- **useProductionAuth** - Authentication state management
- **useUserProfile** - User profile and subscription data
- **useSessionTracking** - Session lifecycle management
- **useIntelligentSearch** - Advanced search with SOS detection
- **useFavoritesManagement** - Favorites CRUD operations
- **useSubscriptionManagement** - Subscription operations
- **useCustomSounds** - Custom sound session management

### 3. Domain Services
- **Audio Services** - Audio playback, library management, downloads
- **Subscription Service** - Plan management, payments, trials
- **Search Service** - Full-text search, SOS detection, analytics
- **Category Service** - Category and sound data fetching
- **Session Tracking Service** - Session analytics and statistics
- **Offline Queue Service** - Offline operation synchronization

### 4. Data Management
- **Supabase Integration** - Database, storage, auth, realtime
- **AsyncStorage** - Local caching and persistence
- **Error Handling** - Centralized error management
- **Network Diagnostics** - Connectivity monitoring
- **Real-time Sync** - Live data updates via Supabase Realtime

### 5. Analytics & Tracking
- **Search Analytics** - Query tracking and SOS triggers
- **Session Analytics** - Usage statistics and patterns
- **App Usage Analytics** - Feature usage tracking
- **Notification Logs** - Notification delivery tracking

### 6. Storage & Downloads
- **Audio File Management** - Download, caching, offline access
- **Signed URL Generation** - Secure audio file access
- **Background Downloads** - Progressive download support
- **Storage Quota Management** - Local storage optimization

---

## 🏗️ Architecture

### Technology Stack
- **Backend:** Supabase (PostgreSQL, Storage, Auth, Realtime)
- **API Client:** `@supabase/supabase-js`
- **State Management:** React Hooks, Context API
- **Local Storage:** AsyncStorage, React Native FS
- **Error Handling:** Custom error handler utilities
- **Network:** React Native NetInfo

### Key Components
- `ProductionBackendService` - Main API service layer
- `backendConstants` - Table names, RPC functions, error codes
- Custom hooks - Business logic encapsulation
- Domain services - Feature-specific service layers
- Error utilities - Centralized error handling

---

## 📱 Integration Points

### Related Features
- **Authentication** - User auth and session management
- **Audio Player** - Sound metadata and file access
- **Library** - Favorites and custom sounds
- **Search** - Sound search and SOS detection
- **Subscriptions** - Plan management and payments
- **Session Tracking** - Usage analytics
- **Offline Support** - Download and sync operations

### External Services
- **Supabase** - Backend infrastructure
  - Database (PostgreSQL)
  - Storage (S3-compatible)
  - Auth (JWT-based)
  - Realtime (WebSocket subscriptions)
  - Edge Functions (serverless functions)

---

## 🔄 Data Flow

### Primary Flows
1. **Data Fetching** - Service → Supabase → Transform → State
2. **Data Updates** - State → Service → Supabase → Sync → State
3. **Offline Operations** - Action → Queue → Sync on Connection
4. **Real-time Updates** - Supabase → Realtime → Hook → Component

### Error Handling Flow
1. **API Error** → Error Handler → Transform → User Message
2. **Network Error** → Diagnostics → Queue → Retry
3. **Validation Error** → Client-side Check → User Feedback

---

## 🔐 Security Features

- Row-level security (RLS) policies on all tables
- JWT token-based authentication
- Secure token storage in isolated AsyncStorage
- Signed URLs for private audio files
- HTTPS-only API communication
- Input validation and sanitization

---

## 📊 Integration Points

### Database Tables
- `user_profiles` - User account data
- `user_sessions` - Session tracking
- `subscriptions` - Subscription records
- `user_favorites` - Favorite sounds
- `custom_sound_sessions` - Custom sound configurations
- `sound_metadata` - Sound catalog
- `notification_preferences` - User notification settings
- `app_usage_analytics` - Usage tracking
- `search_analytics` - Search query tracking
- `sos_config` - SOS crisis configuration

### RPC Functions
- `calculate_trial_days_remaining` - Trial calculation
- `user_needs_registration` - Registration status check
- `change_subscription_plan` - Plan changes
- `cancel_subscription` - Subscription cancellation
- `reactivate_subscription` - Subscription reactivation

---

## 🧪 Testing Considerations

### Test Cases
- API service method calls
- Error handling and recovery
- Offline queue processing
- Real-time subscription updates
- Data transformation and validation
- Cache expiration and invalidation

### Edge Cases
- Network connectivity issues
- API rate limiting
- Concurrent data updates
- Expired authentication tokens
- Storage quota exceeded
- Invalid data formats

---

## 📚 Additional Resources

- [Supabase Documentation](https://supabase.com/docs)
- [React Native AsyncStorage](https://react-native-async-storage.github.io/async-storage/)
- [React Native NetInfo](https://github.com/react-native-netinfo/react-native-netinfo)

---

## 📝 Notes

- All API calls use `safeApiCall` wrapper for error handling
- Services use explicit column selection to avoid RLS issues
- Real-time subscriptions are cleaned up on unmount
- Offline queue processes automatically on network reconnect
- Cache expiration times vary by data type (30min - 1hr)
- All database operations respect RLS policies

---

*For detailed technical specifications, see `technical-spec.md`*  
*For service dependencies, see `services.md`*  
*For business logic flows, see `user-flows.md`*  
*For hooks and utilities, see `components.md`*
