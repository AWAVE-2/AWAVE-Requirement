# Database System - Functional Requirements

## 📋 Core Requirements

### 1. Backend Database (Firestore – current)

*Legacy requirements referred to Supabase; the app uses **Firebase (Firestore, Storage, Auth)** on Google Cloud.*

#### Database Connection
- [x] Firebase/Firestore configured (production)
- [x] Session management via Firebase Auth
- [x] Automatic token refresh (Firebase Auth)
- [x] Secure authentication (Firebase Auth; Apple Sign-In, email/password)
- [ ] Connection health check functionality (Not implemented)
- [x] Error handling for connection failures

#### Database Tables
- [ ] `user_profiles` table with all required fields (App uses Firestore `users` collection)
- [ ] `user_sessions` table for session tracking (App uses Firestore `sessions` collection)
- [ ] `user_favorites` table for favorites management (App uses Firestore `favorites` collection)
- [ ] `subscriptions` table for subscription data (App uses StoreKit, not database)
- [ ] `sound_metadata` table for audio catalog (App uses Firestore `sounds` collection)
- [ ] `custom_sound_sessions` table for custom mixes (App uses Firestore `users/{userId}/mixes` subcollection)
- [ ] `notification_preferences` table for settings (Not implemented)
- [ ] `app_usage_analytics` table for analytics (Not implemented)
- [ ] `search_analytics` table for search tracking (Not implemented)
- [ ] `notification_logs` table for notification history (Not implemented)
- [ ] `sos_config` table for SOS configuration (Not implemented)

#### Row-Level Security (RLS)
- [ ] RLS policies on all user tables (App uses Firebase Security Rules, not RLS)
- [x] User data isolation by user_id (Firebase Security Rules)
- [x] Public read access for sound_metadata (Firebase Security Rules)
- [x] Authenticated write access for user data (Firebase Security Rules)
- [ ] Admin-only access for system tables (Not implemented)

### 2. Local Storage (AsyncStorage)

#### Storage Initialization
- [ ] Storage initialization on app startup (AsyncStorage is React Native - not in Swift)
- [ ] Cache loading from AsyncStorage (AsyncStorage is React Native - not in Swift)
- [ ] Synchronous read API (localStorage-compatible) (AsyncStorage is React Native - not in Swift)
- [ ] Background write persistence (AsyncStorage is React Native - not in Swift)
- [x] Error handling for storage failures

#### Local Storage (Swift Implementation)
- [x] Storage initialization on app startup (UserDefaults, FileManager)
- [x] Cache loading from local storage (UserDefaults, FileManager)
- [x] Onboarding completion status (OnboardingStorageService)
- [x] Onboarding profile data (OnboardingStorageService)
- [x] Audio file caching (FirebaseStorageRepository with local file cache)
- [ ] Last played sound (Not implemented)
- [ ] Mixer tracks configuration (Not implemented)
- [ ] User favorites (local cache) (Not implemented - uses Firestore)
- [ ] Privacy preferences (Not implemented)
- [ ] Selected category (Not implemented)
- [ ] Ordered categories (Not implemented)
- [ ] Session data (Uses Firestore, not local storage)
- [ ] Audio settings (Not implemented)

#### Storage Operations
- [ ] Set item (synchronous cache, async persistence) (AsyncStorage is React Native - not in Swift)
- [ ] Get item (synchronous from cache) (AsyncStorage is React Native - not in Swift)
- [ ] Remove item (synchronous cache, async persistence) (AsyncStorage is React Native - not in Swift)
- [ ] Clear all data (AsyncStorage is React Native - not in Swift)
- [ ] Batch operations (multiGet, multiSet) (AsyncStorage is React Native - not in Swift)
- [ ] JSON serialization/deserialization helpers (AsyncStorage is React Native - not in Swift)

### 3. ProductionBackendService

#### User Profile Management
- [ ] Get user profile by user_id (ProductionBackendService is TypeScript - not in Swift)
- [ ] Create user profile (ProductionBackendService is TypeScript - not in Swift)
- [ ] Update user profile (ProductionBackendService is TypeScript - not in Swift)
- [ ] Profile data validation (ProductionBackendService is TypeScript - not in Swift)
- [ ] Onboarding data storage (ProductionBackendService is TypeScript - not in Swift)
- [ ] Cached sound selection management (ProductionBackendService is TypeScript - not in Swift)

#### Swift Implementation (FirestoreUserRepository)
- [x] Get user profile by user_id (FirestoreUserRepository.fetchUser)
- [x] Create user profile (FirestoreUserRepository.createUser)
- [x] Update user profile (FirestoreUserRepository.updateUser)
- [x] Profile data validation (Implemented)
- [x] Onboarding data storage (OnboardingStorageService)
- [ ] Cached sound selection management (Not implemented)

#### Session Tracking
- [ ] Start session with type and sounds (ProductionBackendService is TypeScript - not in Swift)
- [ ] End session with duration (ProductionBackendService is TypeScript - not in Swift)
- [ ] Get user sessions (ordered by date) (ProductionBackendService is TypeScript - not in Swift)
- [ ] Session completion tracking (ProductionBackendService is TypeScript - not in Swift)
- [ ] Device info storage (ProductionBackendService is TypeScript - not in Swift)
- [ ] Sounds played tracking (ProductionBackendService is TypeScript - not in Swift)

#### Swift Implementation (FirestoreSessionTracker)
- [x] Start session with type and sounds (FirestoreSessionTracker.startSession)
- [x] End session with duration (FirestoreSessionTracker.endSession)
- [x] Get user sessions (ordered by date) (FirestoreSessionTracker.getSessions)
- [x] Session completion tracking (FirestoreSessionTracker)
- [ ] Device info storage (Not implemented)
- [ ] Sounds played tracking (Not implemented)

#### Favorites Management
- [ ] Get user favorites (ProductionBackendService is TypeScript - not in Swift)
- [ ] Add favorite (ProductionBackendService is TypeScript - not in Swift)
- [ ] Remove favorite (ProductionBackendService is TypeScript - not in Swift)
- [ ] Update favorite usage (use_count, last_used) (ProductionBackendService is TypeScript - not in Swift)
- [ ] Favorites ordered by last_used (ProductionBackendService is TypeScript - not in Swift)

#### Swift Implementation (FirestoreFavoritesRepository)
- [x] Get user favorites (FirestoreFavoritesRepository.getFavorites)
- [x] Add favorite (FirestoreFavoritesRepository.addFavorite)
- [x] Remove favorite (FirestoreFavoritesRepository.removeFavorite)
- [ ] Update favorite usage (use_count, last_used) (Not implemented)
- [ ] Favorites ordered by last_used (Not implemented)

#### Sound Metadata
- [ ] Get all sound metadata (ProductionBackendService is TypeScript - not in Swift)
- [ ] Search sounds by keyword (ProductionBackendService is TypeScript - not in Swift)
- [ ] Filter by category (ProductionBackendService is TypeScript - not in Swift)
- [ ] Order by search_weight (ProductionBackendService is TypeScript - not in Swift)
- [ ] Public access (no authentication required) (ProductionBackendService is TypeScript - not in Swift)

#### Swift Implementation (FirestoreSoundRepository)
- [x] Get all sound metadata (FirestoreSoundRepository.getSounds)
- [x] Search sounds by keyword (FirestoreSoundRepository.searchSounds - client-side)
- [x] Filter by category (FirestoreSoundRepository.getSounds with category filter)
- [ ] Order by search_weight (Not implemented)
- [x] Public access (no authentication required) (Firebase Security Rules)

#### Subscription Management
- [ ] Get user subscription (ProductionBackendService is TypeScript - not in Swift)
- [ ] Create subscription (trial) (ProductionBackendService is TypeScript - not in Swift)
- [ ] Check trial days remaining (RPC function) (ProductionBackendService is TypeScript - not in Swift)
- [ ] Subscription status tracking (ProductionBackendService is TypeScript - not in Swift)

#### Swift Implementation (StoreKitManager)
- [ ] Get user subscription (StoreKitManager exists but different API)
- [ ] Create subscription (trial) (StoreKitManager exists but different API)
- [ ] Check trial days remaining (StoreKitManager exists but different API)
- [ ] Subscription status tracking (StoreKitManager exists but different API)
- [x] Trial period management

#### Custom Sound Sessions
- [ ] Get custom sound sessions (ProductionBackendService is TypeScript - not in Swift)
- [ ] Create custom sound session (ProductionBackendService is TypeScript - not in Swift)
- [ ] Update custom sound session (ProductionBackendService is TypeScript - not in Swift)
- [ ] Delete custom sound session (ProductionBackendService is TypeScript - not in Swift)
- [ ] Tracks configuration storage (JSONB) (ProductionBackendService is TypeScript - not in Swift)
- [ ] Swiper positions storage (JSONB) (ProductionBackendService is TypeScript - not in Swift)

#### Swift Implementation (FirestoreCustomMixRepository)
- [x] Get custom sound sessions (FirestoreCustomMixRepository.getMixes)
- [x] Create custom sound session (FirestoreCustomMixRepository.saveMix)
- [x] Update custom sound session (FirestoreCustomMixRepository.saveMix)
- [x] Delete custom sound session (FirestoreCustomMixRepository.deleteMix)
- [x] Tracks configuration storage (Firestore document fields)
- [ ] Swiper positions storage (Not implemented)

#### Notification Preferences
- [ ] Get notification preferences (Not implemented)
- [ ] Update notification preferences (Not implemented)
- [ ] Default preferences creation (Not implemented)
- [ ] Preference persistence (Not implemented)

#### Analytics
- [ ] Log search analytics (Not implemented)
- [ ] Track SOS triggers (Not implemented)
- [ ] Search query storage (Not implemented)
- [ ] Results count tracking (Not implemented)

#### Audio Storage
- [ ] Get signed audio URL (with TTL) (Not implemented - uses Firebase Storage directly)
- [ ] Get public audio URL (Not implemented - uses Firebase Storage directly)
- [x] Storage bucket access (FirebaseStorageRepository)
- [ ] URL expiration handling (Not implemented)

#### Real-time Subscriptions
- [ ] Subscribe to profile changes (Not implemented)
- [ ] Subscribe to subscription changes (Not implemented)
- [ ] Channel cleanup on unsubscribe (Not implemented)
- [ ] Event handling (Not implemented)

### 4. OfflineQueueService

#### Queue Management
- [ ] Add operation to queue (Not implemented)
- [ ] Process queue when online (Not implemented)
- [ ] Retry failed operations (max 3 retries) (Not implemented)
- [ ] Queue status tracking (Not implemented)
- [ ] Clear queue functionality (Not implemented)

#### Operation Types
- [ ] Create operations (Not implemented)
- [ ] Update operations (Not implemented)
- [ ] Delete operations (Not implemented)
- [ ] Operation validation (Not implemented)

#### Network Monitoring
- [x] Network state detection (Implemented)
- [ ] Automatic queue processing on connectivity restore (Not implemented)
- [ ] Network listener setup (Not implemented)
- [ ] Connection state tracking (Not implemented)

#### Error Handling
- [ ] Retry logic with exponential backoff (Not implemented)
- [ ] Max retry limit enforcement (Not implemented)
- [ ] Failed operation logging (Not implemented)
- [ ] Queue persistence across app restarts (Not implemented)

### 5. AWAVEStorage Service

#### Onboarding Data
- [x] Set onboarding completed status (OnboardingStorageService)
- [x] Get onboarding completed status (OnboardingStorageService)
- [x] Set onboarding profile (OnboardingStorageService)
- [x] Get onboarding profile (OnboardingStorageService)

#### Audio Session Data
- [ ] Set last played sound (Not implemented)
- [ ] Get last played sound (Not implemented)
- [ ] Set mixer tracks (Not implemented)
- [ ] Get mixer tracks (Not implemented)

#### User Preferences
- [ ] Set favorites (local cache) (Not implemented - uses Firestore)
- [ ] Get favorites (local cache) (Not implemented - uses Firestore)
- [ ] Set privacy preferences (Not implemented)
- [ ] Get privacy preferences (Not implemented)

#### Category Management
- [ ] Set selected category (Not implemented)
- [ ] Get selected category (Not implemented)
- [ ] Set ordered categories (Not implemented)
- [ ] Get ordered categories (Not implemented)

#### Session Management
- [ ] Set session data (Uses Firestore, not local storage)
- [ ] Get session data (Uses Firestore, not local storage)

#### Audio Settings
- [ ] Set audio settings (volume, fade, crossfade) (Not implemented)
- [ ] Get audio settings (with defaults) (Not implemented)

#### Batch Operations
- [x] Set multiple items
- [x] Get multiple items
- [x] Clear all data

### 6. Data Type Validation

#### JSONB Field Validation
- [x] OnboardingData validation
- [x] DeviceInfo validation
- [x] TracksConfig validation
- [x] SessionSoundsPlayed validation
- [x] FavoriteTrack validation
- [x] WaveformData validation

#### Type Safety
- [x] Swift Codable types for all Firestore models
- [x] Type-safe database queries
- [x] Runtime type checking utilities
- [x] Structured field type definitions

---

## 🎯 User Stories

### As a user, I want to:
- Have my data automatically saved so I don't lose my preferences
- Access my favorites even when offline
- Have my session data tracked automatically
- See my usage statistics over time
- Have my custom sound mixes saved and synced across devices

### As a developer, I want to:
- Have type-safe database operations
- Handle offline scenarios gracefully
- Monitor database performance
- Track data synchronization status
- Debug storage issues easily

### As a system, I need to:
- Automatically sync offline operations when online (Not implemented – no offline queue)
- Validate all data before storage
- Enforce security policies (Firebase Security Rules)
- Handle connection failures gracefully
- Maintain data consistency

---

## ✅ Acceptance Criteria

### Database Connection
- [x] Connection established in < 2 seconds
- [x] Health check succeeds when online
- [x] Graceful degradation when offline
- [x] Automatic reconnection on network restore

### Local Storage
- [x] Storage initialized before app render
- [x] Synchronous reads from cache
- [x] Background writes don't block UI
- [x] Data persists across app restarts

### Offline Queue
- [ ] Operations queued when offline (Not implemented)
- [ ] Queue processed automatically when online (Not implemented)
- [ ] Failed operations retried up to 3 times (Not implemented)
- [ ] Queue status available for debugging (Not implemented)

### Data Operations
- [x] All CRUD operations supported
- [x] Type-safe queries with Swift
- [x] Error handling for all operations
- [x] Data validation before storage

### Synchronization
- [ ] Offline operations synced when online (Offline queue not implemented)
- [ ] Conflict resolution (server wins) (Not implemented)
- [ ] Retry logic for transient failures (Not implemented)
- [ ] Queue status tracking (Not implemented)

---

## 🚫 Non-Functional Requirements

### Performance
- Database queries complete in < 3 seconds
- Local storage reads are synchronous (< 1ms)
- Queue processing doesn't block UI
- Background writes don't impact performance

### Security
- All database connections use HTTPS
- Firebase Security Rules enforce data isolation
- Tokens stored securely (Keychain / isolated storage)
- No sensitive data in local storage

### Usability
- Offline functionality transparent to user
- Automatic sync without user intervention
- Clear error messages for failures
- Data persistence across app restarts

### Reliability
- Network errors handled gracefully
- Automatic retry for transient failures
- Queue persistence across app restarts
- Data validation prevents corruption

### Scalability
- Database queries optimized with indexes
- Batch operations for efficiency
- Connection pooling for performance
- Efficient JSONB field storage

---

## 🔄 Edge Cases

### Network Issues
- [x] Offline detection before operations
- [x] Queue operations when offline
- [x] Automatic sync when online
- [x] Connection timeout handling

### Storage Issues
- [x] Storage quota exceeded handling
- [x] Corrupted data detection
- [x] Storage initialization failures
- [x] Cache invalidation

### Data Validation
- [x] Invalid JSONB structure detection
- [x] Missing required fields
- [x] Type mismatch handling
- [x] Data format validation

### Concurrent Operations
- [x] Prevent concurrent queue processing
- [x] Handle simultaneous writes
- [x] Conflict resolution
- [x] Transaction safety

### Error Recovery
- [x] Retry failed operations
- [x] Log errors for debugging
- [x] Graceful degradation
- [x] User-friendly error messages

---

## 📊 Success Metrics

- Database connection success rate > 99%
- Offline queue sync success rate > 95%
- Average query time < 2 seconds
- Storage operation success rate > 99%
- Data synchronization latency < 5 seconds
- Queue processing time < 1 second per operation

---

## 🔐 Security Requirements

### Data Privacy
- [x] Firebase Security Rules on user collections
- [x] User data isolated by user_id
- [x] No cross-user data access
- [x] Secure token storage

### Data Integrity
- [x] Input validation before storage
- [x] Type checking for all operations
- [x] Document structure validation
- [x] Referential consistency where applicable

### Access Control
- [x] Authenticated access for user data
- [x] Public read access for sound_metadata
- [ ] Admin-only access for system tables (Not implemented)
- [x] Role-based access via Firebase Security Rules

---

## 📝 Data Migration

### Migration Support
- [x] Schema migration scripts
- [x] Data migration utilities
- [x] Version tracking
- [x] Rollback capabilities

### Backward Compatibility
- [x] Handle missing fields gracefully
- [x] Default values for new fields
- [x] Type coercion where appropriate
- [x] Legacy data format support

---

*For technical implementation details, see `technical-spec.md`*  
*For service layer documentation, see `services.md`*  
*For user flow diagrams, see `user-flows.md`*
