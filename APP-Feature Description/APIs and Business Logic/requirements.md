# APIs and Business Logic - Functional Requirements

## 📋 Core Requirements

### 1. Backend Service Layer

#### ProductionBackendService
- [ ] Unified API service for all backend operations (TypeScript - not in Swift)
- [ ] Authentication methods (signUp, signIn, signOut, getCurrentUser) (TypeScript - not in Swift)
- [ ] User profile management (get, create, update) (TypeScript - not in Swift)
- [ ] Session tracking (start, end, get user sessions) (TypeScript - not in Swift)
- [ ] Sound metadata operations (get, search) (TypeScript - not in Swift)
- [ ] Subscription management (get, create, check trial) (TypeScript - not in Swift)
- [ ] Favorites management (get, add, remove, update usage) (TypeScript - not in Swift)
- [ ] Custom sound sessions (get, create, update, delete) (TypeScript - not in Swift)
- [ ] Notification preferences (get, update) (TypeScript - not in Swift)
- [ ] Audio file URL generation (signed URLs, public URLs) (TypeScript - not in Swift)
- [ ] SOS configuration retrieval (TypeScript - not in Swift)
- [ ] Search analytics logging (TypeScript - not in Swift)
- [ ] Real-time subscriptions (profile, subscription changes) (TypeScript - not in Swift)
- [ ] Health check functionality (TypeScript - not in Swift)
- [ ] Account deletion support (TypeScript - not in Swift)

#### Error Handling
- [ ] All API calls wrapped in `safeApiCall` (TypeScript - not in Swift)
- [x] Network connectivity checks before API calls
- [x] User-friendly error messages
- [x] Error logging for debugging
- [x] Graceful degradation on errors
- [ ] Retry logic for transient failures (partial - not fully implemented)

#### Data Validation
- [x] Input validation before API calls
- [x] Type checking for all parameters
- [x] Required field validation
- [x] Data transformation and normalization

### 2. Business Logic Hooks

#### useProductionAuth
- [ ] Authentication state management (React hook - not in Swift)
- [ ] Session retrieval and validation (React hook - not in Swift)
- [ ] User profile loading (React hook - not in Swift)
- [ ] Registration status checking (React hook - not in Swift)
- [ ] Subscription data loading (React hook - not in Swift)
- [ ] Trial days calculation (React hook - not in Swift)

#### useUserProfile
- [ ] Comprehensive user data loading (React hook - not in Swift)
- [ ] Profile, subscription, notification preferences (React hook - not in Swift)
- [ ] Default preference creation (React hook - not in Swift)
- [ ] Category preference application (React hook - not in Swift)
- [ ] Profile update operations (React hook - not in Swift)
- [ ] Subscription status tracking (React hook - not in Swift)

#### useSessionTracking
- [x] Session creation and management (FirestoreSessionTracker)
- [x] Progress tracking (FirestoreSessionTracker)
- [x] Session completion (FirestoreSessionTracker)
- [ ] Session cancellation (not implemented)
- [x] Session statistics calculation (FirestoreSessionTracker)

#### useIntelligentSearch
- [x] Advanced search functionality (FirestoreSoundRepository.searchSounds)
- [ ] SOS keyword detection (not implemented)
- [x] Search result scoring and ranking (client-side filtering)
- [ ] Search analytics logging (not implemented)
- [ ] SOS configuration loading (not implemented)
- [ ] Search suggestions (not implemented)

#### useFavoritesManagement
- [x] Favorites list retrieval (FirestoreFavoritesRepository)
- [x] Add favorite operation (FirestoreFavoritesRepository)
- [x] Remove favorite operation (FirestoreFavoritesRepository)
- [ ] Update favorite usage tracking (not implemented)
- [x] Favorites state management (FirestoreFavoritesRepository)

#### useSubscriptionManagement
- [ ] Subscription data loading (StoreKitManager exists but different API)
- [ ] Plan change operations (StoreKitManager exists but different API)
- [ ] Subscription cancellation (StoreKitManager exists but different API)
- [ ] Subscription reactivation (StoreKitManager exists but different API)
- [ ] Payment history retrieval (not implemented)
- [ ] Proration calculation (not implemented)

#### useCustomSounds
- [x] Custom sound sessions loading (FirestoreCustomMixRepository)
- [x] Session creation (FirestoreCustomMixRepository)
- [x] Session updates (FirestoreCustomMixRepository)
- [x] Session deletion (FirestoreCustomMixRepository)
- [x] Session state management (FirestoreCustomMixRepository)

### 3. Domain Services

#### SearchService
- [x] Full-text search with filters (FirestoreSoundRepository - client-side)
- [ ] SOS configuration loading and caching (not implemented)
- [ ] SOS trigger keyword detection (not implemented)
- [ ] Search suggestions generation (not implemented)
- [ ] Popular searches retrieval (not implemented)
- [ ] Search analytics logging (not implemented)
- [x] Category-based search (FirestoreSoundRepository)

#### SubscriptionService
- [ ] Subscription retrieval (StoreKitManager exists but different API)
- [ ] Payment history retrieval (not implemented)
- [ ] Plan change operations (StoreKitManager exists but different API)
- [ ] Subscription cancellation (StoreKitManager exists but different API)
- [ ] Subscription reactivation (not implemented)
- [ ] Proration calculation (not implemented)

#### CategoryService
- [x] Primary categories fetching (FirestoreSoundRepository)
- [x] Sound metadata fetching per category (FirestoreSoundRepository)
- [x] Data merging with fallbacks (implemented)
- [x] Error handling with graceful degradation (implemented)

#### SessionTrackingService
- [x] Session statistics calculation (FirestoreSessionTracker)
- [ ] Most played sounds retrieval (not implemented)
- [ ] Weekly activity data (not implemented)
- [ ] Streak calculation (not implemented)
- [ ] Session aggregation (not implemented)

#### OfflineQueueService
- [ ] Offline operation queuing (not implemented)
- [ ] Queue processing on network reconnect (not implemented)
- [ ] Retry logic with max attempts (not implemented)
- [ ] Queue status monitoring (not implemented)
- [ ] Automatic initialization (not implemented)

### 4. Data Management

#### Supabase Integration
- [ ] Database connection and queries (App uses Firebase, not Supabase)
- [ ] Storage bucket access (App uses Firebase Storage, not Supabase)
- [ ] Authentication integration (App uses Firebase Auth, not Supabase)
- [ ] Real-time subscriptions (Not implemented)
- [ ] Edge function invocations (Not implemented)
- [ ] RPC function calls (Not implemented)

#### Firebase Integration (Actual Implementation)
- [x] Database connection and queries (Firestore)
- [x] Storage bucket access (Firebase Storage)
- [x] Authentication integration (Firebase Auth)
- [ ] Real-time subscriptions (Not implemented)
- [ ] Cloud function invocations (Not implemented)

#### Local Storage
- [ ] AsyncStorage for caching (React Native - not in Swift)
- [x] Session data persistence (Firestore)
- [x] User preferences storage (Firestore)
- [ ] Offline queue storage (Not implemented)
- [x] Cache expiration management (FirebaseStorageRepository with local file cache)

#### Error Handling
- [x] Centralized error handler utility
- [x] Network diagnostics service
- [x] Error transformation and messaging
- [x] Error logging and monitoring

### 5. Analytics & Tracking

#### Search Analytics
- [ ] Search query logging (Not implemented)
- [ ] Results count tracking (Not implemented)
- [ ] SOS trigger detection logging (Not implemented)
- [ ] User ID association (Not implemented)

#### Session Analytics
- [x] Session start/end tracking (FirestoreSessionTracker)
- [x] Progress updates (FirestoreSessionTracker)
- [x] Duration calculation (FirestoreSessionTracker)
- [x] Completion status tracking (FirestoreSessionTracker)

#### App Usage Analytics
- [ ] Feature usage tracking (Not implemented)
- [ ] User interaction logging (Not implemented)
- [ ] Performance metrics (Not implemented)

### 6. Storage & Downloads

#### Audio File Management
- [ ] Signed URL generation (Not implemented - uses Firebase Storage directly)
- [ ] Public URL generation (Not implemented - uses Firebase Storage directly)
- [ ] Download progress tracking (Not implemented)
- [x] Local file caching (FirebaseStorageRepository)
- [ ] Storage quota management (Not implemented)
- [ ] Background download support (Not implemented)

---

## 🎯 User Stories

### As a developer, I want to:
- Use a unified service layer for all API operations
- Have consistent error handling across all features
- Access reusable hooks for common business logic
- Track analytics for user behavior
- Support offline operations seamlessly

### As a user, I want to:
- Have my data sync across devices
- Continue using the app offline
- See clear error messages when something fails
- Have my preferences saved automatically
- Experience fast and reliable data loading

---

## ✅ Acceptance Criteria

### Backend Service Layer
- [ ] All API methods use `safeApiCall` wrapper (TypeScript - not in Swift)
- [x] Error messages are user-friendly
- [x] Network errors are handled gracefully
- [x] Data validation occurs before API calls
- [ ] All operations respect RLS policies (Firebase uses Security Rules, not RLS)

### Business Logic Hooks
- [ ] Hooks provide clean API for components (React hooks - not in Swift)
- [x] State management is consistent (Swift @Observable)
- [x] Loading states are tracked
- [x] Error states are handled
- [x] Data is cached appropriately

### Domain Services
- [x] Services are testable and mockable (Protocol-based architecture)
- [x] Services handle errors gracefully
- [x] Services use caching where appropriate
- [x] Services provide clear return types
- [x] Services are documented

### Data Management
- [x] Local storage is isolated per feature (Firestore collections)
- [x] Cache expiration is managed (File-based cache)
- [ ] Offline queue processes automatically (Not implemented)
- [ ] Real-time subscriptions are cleaned up (Not implemented)
- [x] Data synchronization is reliable (Firestore)

### Analytics & Tracking
- [ ] Analytics are logged non-blocking (Not implemented)
- [ ] User privacy is respected (Not implemented)
- [ ] Analytics data is accurate (Not implemented)
- [ ] Performance impact is minimal (Not implemented)

### Storage & Downloads
- [ ] Downloads are resumable (Not implemented)
- [ ] Storage quota is managed (Not implemented)
- [x] File access is secure (Firebase Security Rules)
- [x] Cache is optimized (Local file cache)

---

## 🚫 Non-Functional Requirements

### Performance
- API calls complete in < 3 seconds
- Offline queue processes in < 5 seconds
- Cache lookups are < 100ms
- Real-time updates are < 1 second latency

### Security
- All API calls use HTTPS
- Tokens are stored securely
- RLS policies are enforced
- Input validation prevents injection

### Usability
- Error messages are clear and actionable
- Loading states provide feedback
- Offline mode is transparent
- Data sync is automatic

### Reliability
- Network errors are handled gracefully
- Offline operations are queued
- Retry logic handles transient failures
- Data consistency is maintained

---

## 🔄 Edge Cases

### Network Issues
- [x] Offline detection before API calls
- [ ] Queue operations for offline mode (Not implemented)
- [ ] Automatic retry on reconnect (Not implemented)
- [x] User-friendly error messages

### Data Conflicts
- [x] Last-write-wins for updates (Firestore)
- [ ] Conflict resolution strategies (Not implemented)
- [x] Data validation prevents conflicts
- [x] Error handling for conflicts

### Storage Issues
- [ ] Quota exceeded handling (Not implemented)
- [ ] Cache cleanup on low storage (Not implemented)
- [ ] Download resumption (Not implemented)
- [x] Storage error recovery

### Authentication Issues
- [x] Token expiration handling (Firebase Auth)
- [x] Session refresh on expiry (Firebase Auth)
- [ ] Re-authentication prompts (Not implemented)
- [x] Graceful sign-out on errors

### Concurrent Operations
- [ ] Request deduplication (Not implemented)
- [ ] Queue processing locks (Not implemented)
- [x] State update synchronization (Swift concurrency)
- [x] Race condition prevention (Swift concurrency)

---

## 📊 Success Metrics

- API call success rate > 99%
- Offline queue processing success rate > 95%
- Average API response time < 2 seconds
- Cache hit rate > 80%
- Error recovery rate > 90%
- Real-time update latency < 1 second

---

## 🔧 Configuration

### Environment Variables
- `SUPABASE_URL` - Backend API URL (Not used - app uses Firebase)
- `SUPABASE_ANON_KEY` - Public API key (Not used - app uses Firebase)
- `API_BASE_URL` - Base API endpoint (Not used)
- `SITE_URL` - Website URL (Not used)

### Firebase Configuration (Actual Implementation)
- `GoogleService-Info.plist` - Firebase configuration
- Firebase project settings
- Firestore database rules
- Firebase Storage rules

### Service Configuration
- Cache expiration times (File-based cache)
- Retry attempt limits (Not implemented)
- Queue processing intervals (Not implemented)
- Network timeout values (Firebase SDK defaults)

---

## 📝 Implementation Notes

- All services use Swift for type safety
- Services are protocol-based with concrete implementations
- Error handling is consistent across services
- Logging uses AWAVELogger (os.log)
- Real-time subscriptions not implemented
- Offline queue not implemented
- Uses Firebase (Firestore, Storage, Auth) instead of Supabase
- Architecture: Protocol-oriented with dependency injection
