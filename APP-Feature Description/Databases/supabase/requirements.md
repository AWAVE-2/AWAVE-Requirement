# Supabase Integration - Functional Requirements

## 📋 Core Requirements

### 1. Supabase Client Configuration

#### Client Initialization
- [x] Supabase client configured with production credentials
- [x] Production URL: `https://api.dripin.ai`
- [x] Anon key configured from environment variables
- [x] Isolated storage adapter for session management
- [x] Automatic token refresh enabled
- [x] PKCE flow for secure authentication
- [x] Realtime WebSocket connection configured
- [x] Custom headers for client identification

#### Storage Isolation
- [x] Supabase session stored separately from app data
- [x] Storage key prefix: `awave.dev.supabase.`
- [x] No conflicts with AWAVE Advanced storage
- [x] Session persistence across app restarts
- [x] Automatic session recovery

#### Connection Management
- [x] Connection health check functionality
- [x] Error handling for connection failures
- [x] Automatic reconnection on failure
- [x] Connection state tracking
- [x] Timeout handling

### 2. Database Tables & Schema

#### Core Tables
- [x] `user_profiles` table with all required fields
- [x] `user_sessions` table for session tracking
- [x] `user_favorites` table for favorites management
- [x] `subscriptions` table for subscription data
- [x] `sound_metadata` table for audio catalog
- [x] `custom_sound_sessions` table for custom mixes
- [x] `notification_preferences` table for settings
- [x] `app_usage_analytics` table for analytics
- [x] `search_analytics` table for search tracking
- [x] `notification_logs` table for notification history
- [x] `sos_config` table for SOS configuration

#### Schema Features
- [x] UUID primary keys on all tables
- [x] Foreign key relationships
- [x] JSONB fields for flexible data
- [x] Automatic timestamps (created_at, updated_at)
- [x] Indexes on frequently queried columns
- [x] Unique constraints where needed
- [x] Default values for optional fields

### 3. Row-Level Security (RLS)

#### RLS Policies
- [x] RLS enabled on all user tables
- [x] User data isolation by user_id
- [x] Public read access for sound_metadata
- [x] Public read access for sos_config
- [x] Authenticated write access for user data
- [x] Admin-only access for system tables
- [x] Policy testing and validation

#### Security Features
- [x] Users can only read their own data
- [x] Users can only update their own data
- [x] Users can only delete their own data
- [x] No cross-user data access possible
- [x] System tables protected from user access

### 4. Real-Time Subscriptions

#### Subscription Setup
- [x] Real-time subscriptions for user_profiles
- [x] Real-time subscriptions for user_favorites
- [x] Real-time subscriptions for user_sessions
- [x] Real-time subscriptions for subscriptions
- [x] Real-time subscriptions for custom_sound_sessions
- [x] Real-time subscriptions for sound_metadata
- [x] Automatic reconnection on failure
- [x] Channel cleanup on unmount

#### Subscription Features
- [x] Filter by user_id for user-specific data
- [x] Listen to INSERT, UPDATE, DELETE events
- [x] React Query cache invalidation on changes
- [x] Error handling for subscription failures
- [x] Performance optimization (events per second limit)

### 5. Storage Integration

#### Storage Buckets
- [x] Audio storage bucket configured
- [x] Public access for free content
- [x] Signed URLs for premium content
- [x] File size limits enforced
- [x] MIME type validation
- [x] Storage path organization

#### Storage Operations
- [x] Upload audio files to storage
- [x] Download audio files from storage
- [x] Generate public URLs for free content
- [x] Generate signed URLs for premium content (1-hour TTL)
- [x] File metadata tracking in database
- [x] Storage path management
- [x] File deletion and cleanup

### 6. Database Operations

#### CRUD Operations
- [x] Create operations for all tables
- [x] Read operations with filtering
- [x] Update operations with validation
- [x] Delete operations with cascade handling
- [x] Batch operations for efficiency
- [x] Upsert operations where needed

#### Query Features
- [x] Filtering by user_id
- [x] Sorting by created_at, updated_at
- [x] Pagination support
- [x] Full-text search on sound_metadata
- [x] Complex queries with joins
- [x] Aggregate queries for analytics

#### RPC Functions
- [x] `calculate_trial_days_remaining` - Trial calculation
- [x] `user_needs_registration` - Registration check
- [x] `getSignedAudioUrl` - Signed URL generation
- [x] Error handling for RPC calls
- [x] Type-safe RPC function calls

### 7. Error Handling

#### Error Types
- [x] Network error handling
- [x] Database error handling
- [x] RLS policy violation handling
- [x] Storage error handling
- [x] Authentication error handling
- [x] Validation error handling

#### Error Recovery
- [x] Automatic retry for transient failures
- [x] User-friendly error messages
- [x] Error logging for debugging
- [x] Graceful degradation
- [x] Offline queue for failed operations

### 8. Performance Optimization

#### Query Optimization
- [x] Indexes on frequently queried columns
- [x] Efficient JSONB queries
- [x] Batch operations for multiple records
- [x] Connection pooling
- [x] Query result caching

#### Real-Time Optimization
- [x] Events per second limit (10 EPS)
- [x] Selective subscription channels
- [x] Channel cleanup on unmount
- [x] Efficient payload handling

#### Storage Optimization
- [x] Signed URL caching
- [x] File metadata caching
- [x] Progressive download support
- [x] Cache optimization for offline access

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
- [x] Public URLs generated instantly
- [x] Signed URLs generated in < 1 second
- [x] File uploads handle large files (> 50MB)
- [x] Download progress tracking works correctly

### Security
- [x] RLS policies prevent unauthorized access
- [x] User data isolated by user_id
- [x] Tokens stored securely
- [x] No sensitive data in logs

---

## 🚫 Non-Functional Requirements

### Performance
- Database queries complete in < 3 seconds
- Real-time updates received within 1 second
- Storage operations complete in < 5 seconds
- Batch operations handle 100+ records efficiently

### Security
- All connections use HTTPS
- Tokens stored securely
- RLS policies enforced on all tables
- No credentials in code or logs

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
- [x] RLS policies on all user tables
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
