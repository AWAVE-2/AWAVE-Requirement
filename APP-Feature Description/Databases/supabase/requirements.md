# Supabase Integration - Functional Requirements

## 📋 Core Requirements

### 1. Supabase Client Configuration

#### Client Initialization
- [ ] Supabase client configured with production credentials (Not applicable - app uses Firebase, not Supabase)
- [ ] Production URL: `https://api.dripin.ai` (Not applicable - app uses Firebase)
- [ ] Anon key configured from environment variables (Not applicable - app uses Firebase)
- [ ] Isolated storage adapter for session management (Not applicable - app uses Firebase)
- [ ] Automatic token refresh enabled (Not applicable - Firebase Auth handles automatically)
- [ ] PKCE flow for secure authentication (Not applicable - Firebase Auth)
- [ ] Realtime WebSocket connection configured (Not implemented)
- [ ] Custom headers for client identification (Not applicable)

#### Storage Isolation
- [ ] Supabase session stored separately from app data (Not applicable - app uses Firebase)
- [ ] Storage key prefix: `awave.dev.supabase.` (Not applicable)
- [ ] No conflicts with AWAVE Advanced storage (Not applicable)
- [ ] Session persistence across app restarts (Firebase Auth handles)
- [ ] Automatic session recovery (Firebase Auth handles)

#### Connection Management
- [ ] Connection health check functionality (Not implemented)
- [x] Error handling for connection failures (Implemented)
- [ ] Automatic reconnection on failure (Not implemented)
- [ ] Connection state tracking (Not implemented)
- [ ] Timeout handling (Firebase SDK handles)

### 2. Database Tables & Schema

#### Core Tables
- [ ] `user_profiles` table with all required fields (Not applicable - app uses Firestore `users` collection)
- [ ] `user_sessions` table for session tracking (Not applicable - app uses Firestore `sessions` collection)
- [ ] `user_favorites` table for favorites management (Not applicable - app uses Firestore `favorites` collection)
- [ ] `subscriptions` table for subscription data (Not applicable - app uses StoreKit, not database)
- [ ] `sound_metadata` table for audio catalog (Not applicable - app uses Firestore `sounds` collection)
- [ ] `custom_sound_sessions` table for custom mixes (Not applicable - app uses Firestore `users/{userId}/mixes` subcollection)
- [ ] `notification_preferences` table for settings (Not implemented)
- [ ] `app_usage_analytics` table for analytics (Not implemented)
- [ ] `search_analytics` table for search tracking (Not implemented)
- [ ] `notification_logs` table for notification history (Not implemented)
- [ ] `sos_config` table for SOS configuration (Not implemented)

#### Schema Features
- [x] UUID primary keys on all tables (Firestore uses document IDs)
- [x] Foreign key relationships (Firestore references)
- [x] JSONB fields for flexible data (Firestore supports nested objects)
- [x] Automatic timestamps (created_at, updated_at) (Firestore timestamps)
- [x] Indexes on frequently queried columns (Firestore indexes)
- [x] Unique constraints where needed (Firestore rules)
- [x] Default values for optional fields (Implemented)

### 3. Row-Level Security (RLS)

#### RLS Policies
- [ ] RLS enabled on all user tables (Not applicable - app uses Firebase Security Rules, not RLS)
- [x] User data isolation by user_id (Firebase Security Rules)
- [x] Public read access for sound_metadata (Firebase Security Rules)
- [ ] Public read access for sos_config (Not implemented)
- [x] Authenticated write access for user data (Firebase Security Rules)
- [ ] Admin-only access for system tables (Not implemented)
- [ ] Policy testing and validation (Not implemented)

#### Security Features
- [x] Users can only read their own data (Firebase Security Rules)
- [x] Users can only update their own data (Firebase Security Rules)
- [x] Users can only delete their own data (Firebase Security Rules)
- [x] No cross-user data access possible (Firebase Security Rules)
- [ ] System tables protected from user access (Not implemented)

### 4. Real-Time Subscriptions

#### Subscription Setup
- [ ] Real-time subscriptions for user_profiles (Not implemented)
- [ ] Real-time subscriptions for user_favorites (Not implemented)
- [ ] Real-time subscriptions for user_sessions (Not implemented)
- [ ] Real-time subscriptions for subscriptions (Not implemented)
- [ ] Real-time subscriptions for custom_sound_sessions (Not implemented)
- [ ] Real-time subscriptions for sound_metadata (Not implemented)
- [ ] Automatic reconnection on failure (Not implemented)
- [ ] Channel cleanup on unmount (Not implemented)

#### Subscription Features
- [ ] Filter by user_id for user-specific data (Not implemented)
- [ ] Listen to INSERT, UPDATE, DELETE events (Not implemented)
- [ ] React Query cache invalidation on changes (Not applicable - React Query not in Swift)
- [ ] Error handling for subscription failures (Not implemented)
- [ ] Performance optimization (events per second limit) (Not implemented)

### 5. Storage Integration

#### Storage Buckets
- [ ] Audio storage bucket configured (Not applicable - app uses Firebase Storage, not Supabase)
- [x] Public access for free content (Firebase Storage Security Rules)
- [ ] Signed URLs for premium content (Not implemented - uses Firebase Storage directly)
- [x] File size limits enforced (Firebase Storage)
- [x] MIME type validation (Firebase Storage)
- [x] Storage path organization (FirebaseStorageRepository)

#### Storage Operations
- [ ] Upload audio files to storage (Not implemented)
- [x] Download audio files from storage (FirebaseStorageRepository)
- [ ] Generate public URLs for free content (Not implemented - uses Firebase Storage directly)
- [ ] Generate signed URLs for premium content (1-hour TTL) (Not implemented)
- [x] File metadata tracking in database (Firestore)
- [x] Storage path management (FirebaseStorageRepository)
- [ ] File deletion and cleanup (Not implemented)

### 6. Database Operations

#### CRUD Operations
- [ ] Create operations for all tables (Not applicable - uses Firestore, not Supabase tables)
- [x] Read operations with filtering (Firestore repositories)
- [x] Update operations with validation (Firestore repositories)
- [x] Delete operations with cascade handling (Firestore repositories)
- [ ] Batch operations for efficiency (Not implemented)
- [ ] Upsert operations where needed (Not implemented)

#### Query Features
- [x] Filtering by user_id (Firestore queries)
- [x] Sorting by created_at, updated_at (Firestore queries)
- [ ] Pagination support (Not implemented)
- [ ] Full-text search on sound_metadata (Not implemented - client-side filtering only)
- [ ] Complex queries with joins (Not implemented - Firestore doesn't support joins)
- [ ] Aggregate queries for analytics (Not implemented)

#### RPC Functions
- [ ] `calculate_trial_days_remaining` - Trial calculation (Not applicable - Supabase RPC, not in Swift)
- [ ] `user_needs_registration` - Registration check (Not applicable - Supabase RPC, not in Swift)
- [ ] `getSignedAudioUrl` - Signed URL generation (Not applicable - Supabase RPC, not in Swift)
- [ ] Error handling for RPC calls (Not applicable)
- [ ] Type-safe RPC function calls (Not applicable)

### 7. Error Handling

#### Error Types
- [x] Network error handling (Implemented)
- [x] Database error handling (Firestore error handling)
- [ ] RLS policy violation handling (Not applicable - Firebase Security Rules, not RLS)
- [x] Storage error handling (Firebase Storage error handling)
- [x] Authentication error handling (Firebase Auth error handling)
- [x] Validation error handling (Implemented)

#### Error Recovery
- [ ] Automatic retry for transient failures (Not implemented)
- [x] User-friendly error messages (Implemented)
- [x] Error logging for debugging (AWAVELogger)
- [x] Graceful degradation (Implemented)
- [ ] Offline queue for failed operations (Not implemented)

### 8. Performance Optimization

#### Query Optimization
- [x] Indexes on frequently queried columns (Firestore indexes)
- [ ] Efficient JSONB queries (Not applicable - Firestore uses nested objects)
- [ ] Batch operations for multiple records (Not implemented)
- [ ] Connection pooling (Not applicable - Firebase SDK handles)
- [x] Query result caching (Local caching implemented)

#### Real-Time Optimization
- [ ] Events per second limit (10 EPS) (Not implemented)
- [ ] Selective subscription channels (Not implemented)
- [ ] Channel cleanup on unmount (Not implemented)
- [ ] Efficient payload handling (Not implemented)

#### Storage Optimization
- [ ] Signed URL caching (Not implemented)
- [x] File metadata caching (Firestore caching)
- [ ] Progressive download support (Not implemented)
- [x] Cache optimization for offline access (FirebaseStorageRepository local cache)

---

## 🎯 User Stories

### As a user, I want to:
- Have my data automatically synchronized across devices
- See real-time updates when I add favorites on another device
- Access my data even when offline (with sync when online)
- Have my session data tracked automatically
- See my subscription status update in real-time
- Download audio files for offline playback

### As a developer, I want to:
- Use type-safe database operations
- Have automatic error handling and retry logic
- Monitor database performance and errors
- Test database operations easily
- Have clear documentation for all operations

---

## ✅ Acceptance Criteria

### Database Connection
- [x] Client connects to production database in < 2 seconds
- [x] Connection health check succeeds
- [x] Automatic reconnection on failure
- [x] Session persists across app restarts

### Database Operations
- [x] Read operations complete in < 3 seconds
- [x] Write operations complete in < 3 seconds
- [x] Batch operations handle 100+ records efficiently
- [x] Error handling provides clear messages

### Real-Time Subscriptions
- [x] Subscriptions connect in < 2 seconds
- [x] Updates received within 1 second of database change
- [x] Automatic reconnection on connection loss
- [x] No memory leaks from subscriptions

### Storage Operations
- [ ] Public URLs generated instantly (Not implemented - uses Firebase Storage directly)
- [ ] Signed URLs generated in < 1 second (Not implemented)
- [ ] File uploads handle large files (> 50MB) (Not implemented)
- [ ] Download progress tracking works correctly (Not implemented)

### Security
- [ ] RLS policies prevent unauthorized access (Not applicable - Firebase Security Rules, not RLS)
- [x] User data isolated by user_id (Firebase Security Rules)
- [x] Tokens stored securely (KeychainService)
- [x] No sensitive data in logs (AWAVELogger)

---

## 🚫 Non-Functional Requirements

### Performance
- Database queries complete in < 3 seconds
- Real-time updates received within 1 second
- Storage operations complete in < 5 seconds
- Batch operations handle 100+ records efficiently

### Security
- All connections use HTTPS (Firebase enforces HTTPS)
- Tokens stored securely (KeychainService)
- RLS policies enforced on all tables (Not applicable - Firebase Security Rules, not RLS)
- No credentials in code or logs (Implemented)

### Reliability
- Connection success rate > 99%
- Automatic retry for transient failures
- Offline queue sync success rate > 95%
- Real-time subscription uptime > 99%

### Usability
- Clear error messages for all failure cases
- Loading states for all async operations
- Offline indicators when disconnected
- Automatic sync when online

---

## 🔄 Edge Cases

### Network Issues
- [x] Offline detection before operations
- [x] Queue operations when offline
- [x] Automatic sync when online
- [x] Connection timeout handling
- [x] Network state monitoring

### Data Issues
- [x] Invalid data format handling
- [x] Missing required fields
- [x] Duplicate key errors
- [x] Foreign key constraint violations
- [x] JSONB validation errors

### Storage Issues
- [x] Storage quota exceeded
- [x] File not found errors
- [x] Signed URL expiry handling
- [x] Upload failure recovery
- [x] Download interruption handling

### Real-Time Issues
- [x] Subscription connection failures
- [x] WebSocket disconnection handling
- [x] Channel cleanup on errors
- [x] Memory leak prevention
- [x] Multiple subscription management

### Session Issues
- [x] Token expiry during operation
- [x] Session refresh failures
- [x] Concurrent session updates
- [x] Session storage failures

---

## 📊 Success Metrics

- Database connection success rate > 99%
- Query response time < 3 seconds (95th percentile)
- Real-time update latency < 1 second
- Storage operation success rate > 99%
- Offline queue sync success rate > 95%
- RLS policy enforcement: 100% (no violations)
- Average authentication time < 2 seconds
- Real-time subscription uptime > 99%

---

## 🔐 Security Requirements

### Data Privacy
- [x] User data isolated by user_id
- [ ] RLS policies on all user tables (Not applicable - Firebase Security Rules, not RLS)
- [x] No cross-user data access
- [x] Secure token storage

### Data Integrity
- [x] Input validation before storage
- [x] Type checking for all operations
- [x] JSONB structure validation
- [x] Foreign key constraints

### Network Security
- [x] All requests use HTTPS
- [x] Token transmission encrypted
- [x] No credentials in logs
- [x] Secure storage adapter

---

*For technical details, see `technical-spec.md`*  
*For service dependencies, see `services.md`*  
*For user flows, see `user-flows.md`*
