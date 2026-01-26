# Database System - Feature Documentation

**Feature Name:** Database & Storage Management  
**Status:** ✅ Complete  
**Priority:** High  
**Last Updated:** 2025-01-27

## 📋 Feature Overview

The Database system provides comprehensive data persistence and management for the AWAVE app. It includes both cloud-based Supabase PostgreSQL database integration and local storage solutions using AsyncStorage, enabling offline-first functionality with seamless synchronization.

### Description

The database system is built on a dual-storage architecture:
- **Supabase PostgreSQL** - Cloud database for user data, profiles, sessions, favorites, and analytics
- **AsyncStorage** - Local key-value storage for offline caching, preferences, and queue management
- **Offline Queue Service** - Automatic synchronization of offline operations when connectivity is restored

### User Value

- **Data Persistence** - All user data securely stored and synchronized across devices
- **Offline Support** - Full app functionality even without internet connection
- **Fast Performance** - Local caching for instant data access
- **Reliability** - Automatic retry and sync mechanisms for failed operations
- **Privacy** - Row-level security (RLS) ensures user data isolation

---

## 🎯 Core Features

### 1. Supabase Database Integration
- PostgreSQL database with real-time capabilities
- 11 core tables for user data management
- Row-level security (RLS) policies
- Real-time subscriptions for live updates
- Automatic API generation

### 2. Local Storage (AsyncStorage)
- Key-value storage for app preferences
- Offline data caching
- Session state persistence
- Registration cache management
- Audio settings storage

### 3. Offline Queue Service
- Automatic operation queuing when offline
- Background synchronization when online
- Retry mechanism with exponential backoff
- Network state monitoring
- Queue status tracking

### 4. Database Tables
- **user_profiles** - User account information and preferences
- **user_sessions** - Audio playback session tracking
- **user_favorites** - User's favorite sound mixes
- **subscriptions** - Subscription and trial management
- **sound_metadata** - Audio file catalog and metadata
- **custom_sound_sessions** - User-created custom sound mixes
- **notification_preferences** - User notification settings
- **app_usage_analytics** - Usage statistics and analytics
- **search_analytics** - Search query tracking
- **notification_logs** - Notification delivery logs
- **sos_config** - SOS feature configuration

### 5. Storage Services
- **ProductionBackendService** - Main database API service
- **AWAVEStorage** - Local storage abstraction layer
- **OfflineQueueService** - Offline operation synchronization
- **storage utility** - localStorage-compatible API wrapper

### 6. Data Types & Schemas
- TypeScript interfaces for all database tables
- JSONB field type definitions
- Runtime validation utilities
- Type-safe database operations

---

## 🏗️ Architecture

### Technology Stack
- **Backend:** Supabase (PostgreSQL)
- **Local Storage:** AsyncStorage
- **Storage Wrapper:** Custom localStorage-compatible API
- **State Management:** React Context API + Hooks
- **Type Safety:** TypeScript with strict typing

### Key Components
- `ProductionBackendService` - Main database service layer
- `AWAVEStorage` - Local storage service
- `OfflineQueueService` - Offline synchronization
- `storage` utility - Synchronous storage wrapper
- Supabase client - Database connection and queries

---

## 📱 Database Tables

### Core Tables
1. **user_profiles** - User account and profile data
2. **user_sessions** - Audio playback sessions
3. **user_favorites** - Favorite sound collections
4. **subscriptions** - Subscription and payment data
5. **sound_metadata** - Audio catalog metadata

### Feature-Specific Tables
6. **custom_sound_sessions** - Custom sound mix configurations
7. **notification_preferences** - Notification settings
8. **app_usage_analytics** - Usage statistics
9. **search_analytics** - Search query analytics
10. **notification_logs** - Notification history
11. **sos_config** - SOS feature configuration

---

## 🔄 Data Flow

### Primary Flows
1. **Online Flow** - Direct database operations → Immediate sync
2. **Offline Flow** - Local operations → Queue → Sync when online
3. **Read Flow** - Check local cache → Fetch from database → Update cache
4. **Write Flow** - Validate → Write to database → Update local cache

### Synchronization
- **Automatic Sync** - Background queue processing
- **Manual Sync** - User-triggered refresh
- **Conflict Resolution** - Server-side wins strategy
- **Retry Logic** - Exponential backoff with max retries

---

## 🔐 Security Features

- Row-level security (RLS) policies on all tables
- User data isolation by user_id
- Secure token storage (isolated from app storage)
- HTTPS for all database connections
- Automatic session management
- PKCE flow for authentication

---

## 📊 Integration Points

### Related Features
- **Authentication** - User profile creation and management
- **Favorites** - Favorite sound storage and retrieval
- **Sessions** - Session tracking and analytics
- **Subscriptions** - Subscription status and trial management
- **Offline Support** - Offline queue and synchronization
- **Analytics** - Usage and search analytics tracking

### External Services
- Supabase Database (PostgreSQL)
- Supabase Storage (audio files)
- Supabase Auth (user authentication)
- Supabase Realtime (live updates)

---

## 🧪 Testing Considerations

### Test Cases
- Database connection and queries
- Local storage read/write operations
- Offline queue functionality
- Synchronization after connectivity restore
- Data type validation
- Error handling and retry logic
- RLS policy enforcement

### Edge Cases
- Network connectivity loss during operations
- Concurrent write operations
- Large data payloads
- Storage quota exceeded
- Database connection timeout
- Invalid data format

---

## 📚 Additional Resources

- [Supabase Documentation](https://supabase.com/docs)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [AsyncStorage Documentation](https://react-native-async-storage.github.io/async-storage/)
- [React Native Storage Best Practices](https://reactnative.dev/docs/asyncstorage)

---

## 📝 Notes

- All database operations use TypeScript types for type safety
- JSONB fields are validated at runtime
- Offline queue has 30-minute expiration for stale operations
- Local storage is initialized on app startup
- Database schema matches production backend exactly
- RLS policies ensure user data privacy

---

*For detailed technical specifications, see `technical-spec.md`*  
*For user flow diagrams, see `user-flows.md`*  
*For component details, see `components.md`*  
*For service dependencies, see `services.md`*
