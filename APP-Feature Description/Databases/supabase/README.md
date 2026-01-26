# Supabase Integration - Feature Documentation

**Feature Name:** Supabase Database & Storage Integration  
**Status:** ✅ Complete  
**Priority:** High  
**Last Updated:** 2025-01-27

## 📋 Feature Overview

The Supabase integration provides the complete backend infrastructure for the AWAVE app, including PostgreSQL database, authentication, real-time subscriptions, and cloud storage. It serves as the single source of truth for all user data, audio metadata, and application state.

### Description

The Supabase integration is built on a production-ready architecture:
- **PostgreSQL Database** - 11 core tables for user data, sessions, favorites, subscriptions, and analytics
- **Supabase Auth** - Secure user authentication with email/password and OAuth providers
- **Supabase Storage** - Cloud storage for audio files with signed URLs and public access
- **Supabase Realtime** - Live data synchronization via WebSocket subscriptions
- **Row-Level Security (RLS)** - Data isolation and security policies
- **Serverless Functions** - Business logic and signed URL generation

### User Value

- **Data Persistence** - All user data securely stored and synchronized across devices
- **Real-Time Updates** - Live synchronization of favorites, sessions, and subscriptions
- **Offline Support** - Local caching with automatic sync when connectivity is restored
- **Fast Performance** - Optimized queries with indexes and connection pooling
- **Privacy & Security** - Row-level security ensures user data isolation
- **Scalability** - Production-ready infrastructure handling thousands of users

---

## 🎯 Core Features

### 1. Database Tables & Schema
- **11 core tables** for comprehensive data management
- **Type-safe operations** with TypeScript interfaces
- **JSONB fields** for flexible data structures
- **Foreign key relationships** ensuring data integrity
- **Automatic timestamps** for created_at and updated_at

### 2. Authentication Integration
- **Supabase Auth** integration with PKCE flow
- **Isolated session storage** preventing conflicts
- **Automatic token refresh** before expiry
- **Secure token management** with isolated storage adapter
- **Session persistence** across app restarts

### 3. Real-Time Subscriptions
- **Live data synchronization** for user profiles
- **Real-time favorites updates** across devices
- **Session tracking updates** in real-time
- **Subscription status changes** synchronized instantly
- **Custom sound sessions** live updates
- **Sound metadata** global updates

### 4. Cloud Storage Integration
- **Audio file storage** in Supabase Storage buckets
- **Signed URLs** for premium content (1-hour TTL)
- **Public URLs** for free content
- **File metadata** tracking in database
- **Download management** with progress tracking
- **Cache optimization** for offline access

### 5. Database Operations
- **CRUD operations** for all tables
- **Complex queries** with filtering and sorting
- **Batch operations** for efficiency
- **RPC functions** for business logic
- **Search functionality** with full-text search
- **Analytics logging** for usage tracking

### 6. Security & Privacy
- **Row-Level Security (RLS)** on all user tables
- **User data isolation** by user_id
- **Public read access** for sound_metadata
- **Admin-only writes** for system tables
- **Secure token storage** isolated from app data
- **HTTPS encryption** for all connections

---

## 🏗️ Architecture

### Technology Stack
- **Backend:** Supabase (PostgreSQL + Auth + Storage + Realtime)
- **Client Library:** `@supabase/supabase-js`
- **Production URL:** `https://api.dripin.ai`
- **Storage Adapter:** Custom isolated AsyncStorage adapter
- **State Management:** React Context API + Hooks
- **Type Safety:** TypeScript with strict typing

### Key Components
- `supabase` client - Main database connection
- `ProductionBackendService` - Database API service layer
- `SupabaseAudioLibraryManager` - Audio file management
- `useRealtimeSync` hook - Real-time data synchronization
- `storage` utility - Local caching layer
- `OfflineQueueService` - Offline operation synchronization

---

## 📱 Database Tables

### Core User Tables
1. **user_profiles** - User account and profile information
2. **user_sessions** - Audio playback session tracking
3. **user_favorites** - User's favorite sound mixes
4. **subscriptions** - Subscription and trial management

### Content Tables
5. **sound_metadata** - Audio file catalog and metadata
6. **custom_sound_sessions** - User-created custom sound mixes

### System Tables
7. **notification_preferences** - User notification settings
8. **app_usage_analytics** - Usage statistics and analytics
9. **search_analytics** - Search query tracking
10. **notification_logs** - Notification delivery logs
11. **sos_config** - SOS feature configuration

---

## 🔄 Data Flow

### Primary Flows
1. **Online Flow** - Direct database operations → Immediate sync
2. **Offline Flow** - Local operations → Queue → Sync when online
3. **Read Flow** - Check local cache → Fetch from database → Update cache
4. **Write Flow** - Validate → Write to database → Update local cache
5. **Real-Time Flow** - Database change → WebSocket → Client update

### Synchronization
- **Automatic Sync** - Background queue processing
- **Real-Time Sync** - WebSocket subscriptions for live updates
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
- Signed URLs for premium content
- Public read access for sound_metadata only

---

## 📊 Integration Points

### Related Features
- **Authentication** - User profile creation and management
- **Favorites** - Favorite sound storage and retrieval
- **Sessions** - Session tracking and analytics
- **Subscriptions** - Subscription status and trial management
- **Offline Support** - Offline queue and synchronization
- **Analytics** - Usage and search analytics tracking
- **Audio Library** - Sound metadata and file management

### External Services
- Supabase Database (PostgreSQL)
- Supabase Storage (audio files)
- Supabase Auth (user authentication)
- Supabase Realtime (live updates)
- Supabase Functions (serverless functions)

---

## 🧪 Testing Considerations

### Test Cases
- Database connection and queries
- Real-time subscription setup and updates
- Storage operations (upload, download, signed URLs)
- RLS policy enforcement
- Token refresh and session management
- Offline queue functionality
- Synchronization after connectivity restore
- Error handling and retry logic

### Edge Cases
- Network connectivity loss during operations
- Concurrent write operations
- Large data payloads
- Storage quota exceeded
- Database connection timeout
- Invalid data format
- Real-time subscription failures
- Token expiry during operations

---

## 📚 Additional Resources

- [Supabase Documentation](https://supabase.com/docs)
- [Supabase JavaScript Client](https://supabase.com/docs/reference/javascript/introduction)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Supabase Realtime](https://supabase.com/docs/guides/realtime)
- [Supabase Storage](https://supabase.com/docs/guides/storage)

---

## 📝 Notes

- All database operations use TypeScript types for type safety
- JSONB fields are validated at runtime
- Offline queue has 30-minute expiration for stale operations
- Real-time subscriptions automatically reconnect on failure
- Storage signed URLs expire after 1 hour
- Database schema matches production backend exactly
- RLS policies ensure user data privacy
- Isolated storage adapter prevents session conflicts

---

*For detailed technical specifications, see `technical-spec.md`*  
*For user flow diagrams, see `user-flows.md`*  
*For component details, see `components.md`*  
*For service dependencies, see `services.md`*  
*For functional requirements, see `requirements.md`*
