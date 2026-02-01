# Notifications System - Functional Requirements

## 📋 Core Requirements

### 1. Notification Preferences Management

#### Preference Categories
- [x] Push notifications toggle (enable/disable)
- [x] Email notifications toggle (enable/disable)
- [x] Trial reminder notifications toggle
- [x] Favorites updates notifications toggle
- [x] New content notifications toggle
- [x] System updates notifications toggle

#### Preference Storage
- [ ] Preferences stored in Supabase database (Not implemented - app uses Firebase)
- [ ] User-specific preferences (one record per user) (Not implemented)
- [ ] Automatic preference creation for new users (Not implemented)
- [ ] Default preferences (all enabled except marketing) (Not implemented)
- [ ] Preference updates persist immediately (Not implemented)
- [ ] Local caching for offline access (Not implemented)

#### Preference UI
- [x] Dedicated notification preferences screen
- [x] Clear descriptions for each preference type
- [x] Toggle switches for each preference
- [x] Loading states during fetch/save
- [x] Error handling and user feedback
- [x] Optimistic UI updates

### 2. Trial Reminder Notifications

#### Trial Status Detection
- [x] Check user subscription status
- [x] Detect active trial subscriptions
- [x] Calculate days remaining until trial expiration
- [x] Determine if reminder should be sent (3 days before)
- [x] Handle edge cases (no subscription, expired trial)

#### Reminder Sending Logic
- [ ] Check if reminder was already sent (prevent duplicates) (Not implemented)
- [ ] Verify user preference (trial_reminders_enabled) (Not implemented)
- [ ] Send reminder only if enabled and not already sent (Not implemented)
- [ ] Log notification to database (Not implemented)
- [ ] Mark reminder as sent in local storage (Not implemented)
- [ ] Handle errors gracefully (Not implemented)

#### Reminder Content
- [x] Dynamic message based on days remaining
- [x] German language support
- [x] Clear call-to-action
- [x] Notification type: 'trial_reminder'

#### Reminder Timing
- [x] Check on app launch (after authentication)
- [x] Check on user sign-in
- [x] 3-day threshold before expiration
- [x] One reminder per trial period

### 3. Notification Logging

#### Log Storage
- [ ] Store all sent notifications in database (Not implemented)
- [ ] Track notification type (Not implemented)
- [ ] Record user ID (Not implemented)
- [ ] Store notification message (Not implemented)
- [ ] Timestamp recording (sent_at) (Not implemented)
- [ ] User-specific log access (Not implemented)

#### Log Data
- [x] Notification type identifier
- [x] User ID reference
- [x] Message content
- [x] Sent timestamp
- [x] Created timestamp

### 4. User Interface

#### NotificationPreferencesScreen
- [x] Display all notification preferences
- [x] Section-based organization (General, Content)
- [x] Toggle switches for each preference
- [x] Loading state during data fetch
- [x] Empty state for unauthenticated users
- [x] Error state handling
- [x] Save confirmation feedback

#### AccountSettingsScreen Integration
- [x] Quick push notification toggle
- [x] Description text
- [x] Immediate save on toggle
- [x] Visual feedback

#### ProfileScreen Integration
- [ ] Notification preferences display (Not implemented)
- [ ] Quick toggle functionality (Not implemented)
- [ ] Sync with backend preferences (Not implemented)
- [ ] Update via useUserProfile hook (Not applicable - React hook, not in Swift)

### 5. Preference Synchronization

#### Data Loading
- [ ] Load preferences on screen mount (Not implemented)
- [ ] Load preferences on user authentication (Not implemented)
- [ ] Create defaults if preferences don't exist (Not implemented)
- [ ] Handle loading errors gracefully (Not implemented)

#### Data Saving
- [ ] Save preferences immediately on toggle (Not implemented)
- [ ] Optimistic UI updates (Not implemented)
- [ ] Revert on save failure (Not implemented)
- [ ] Error feedback to user (Not implemented)
- [ ] Success confirmation (Not implemented)

#### Default Preferences
- [ ] push_notifications_enabled: true (Not implemented)
- [ ] email_notifications_enabled: true (Not implemented)
- [ ] trial_reminders_enabled: true (Not implemented)
- [ ] favorites_updates_enabled: true (Not implemented)
- [ ] new_content_enabled: true (Not implemented)
- [ ] system_updates_enabled: true (Not implemented)

---

## 🎯 User Stories

### As a user, I want to:
- Control which notifications I receive so I'm not overwhelmed
- Receive trial expiration reminders so I don't lose access unexpectedly
- See clear descriptions of each notification type so I understand what I'm enabling
- Have my preferences saved automatically so I don't lose my settings
- Access notification settings easily from multiple places in the app

### As a user on trial, I want to:
- Be reminded when my trial is about to expire so I can decide to subscribe
- Receive only one reminder per trial period so I'm not spammed
- Control whether I receive trial reminders so I can opt-out if desired

### As a new user, I want to:
- Have sensible default notification preferences so I don't need to configure everything
- Understand what each notification type means before enabling it

---

## ✅ Acceptance Criteria

### Preference Management
- [x] User can view all notification preferences
- [x] User can toggle any preference on/off
- [x] Preferences save within 2 seconds
- [x] Preferences persist across app restarts
- [x] Default preferences created for new users
- [x] Loading states shown during fetch/save

### Trial Reminders
- [x] Reminder sent exactly 3 days before trial expiration
- [x] Reminder sent only once per trial period
- [x] Reminder respects user preference (trial_reminders_enabled)
- [x] Reminder logged to database
- [x] Reminder check runs on app launch and sign-in

### User Interface
- [x] All preferences visible on dedicated screen
- [x] Clear descriptions for each preference
- [x] Toggle switches work immediately
- [x] Error messages are user-friendly
- [x] Loading indicators shown during operations

### Data Persistence
- [x] Preferences stored in database
- [x] Preferences sync on app launch
- [x] Preferences update immediately on change
- [x] Default preferences created automatically

---

## 🚫 Non-Functional Requirements

### Performance
- Preference loading completes in < 1 second
- Preference saving completes in < 2 seconds
- Trial status check completes in < 1 second
- No UI blocking during preference operations

### Security
- User can only access their own preferences
- Preferences protected by RLS policies
- Notification logs accessible only to user
- Secure database storage

### Usability
- Clear descriptions for all notification types
- Intuitive toggle switches
- Immediate visual feedback
- Error messages are helpful and actionable

### Reliability
- Network errors handled gracefully
- Database errors don't crash the app
- Preferences revert on save failure
- Default preferences always created if missing

---

## 🔄 Edge Cases

### Missing Preferences
- [x] New user has no preferences → Create defaults automatically
- [x] Preferences deleted → Recreate defaults
- [x] Database error on fetch → Show error, allow retry

### Trial Reminder Edge Cases
- [x] Trial already expired → No reminder sent
- [x] Trial expires in > 3 days → No reminder sent
- [x] Reminder already sent → No duplicate reminder
- [x] User disabled trial reminders → No reminder sent
- [x] No active subscription → No reminder sent

### Network Issues
- [x] Offline during preference save → Show error, revert change
- [x] Offline during preference load → Show cached data or error
- [x] Network timeout → Show error, allow retry

### Concurrent Updates
- [x] Multiple preference toggles → Process sequentially
- [x] Preference update during load → Wait for load, then update
- [x] App restart during save → Preferences saved correctly

### Data Validation
- [x] Invalid preference value → Reject update, show error
- [x] Missing user ID → Show error, require authentication
- [x] Database constraint violation → Handle gracefully

---

## 📊 Success Metrics

- Preference update success rate > 99%
- Trial reminder delivery rate > 95%
- Default preference creation rate: 100%
- Average preference load time < 1 second
- Average preference save time < 2 seconds
- User preference customization rate > 60%

---

## 🔐 Security Requirements

### Data Access
- [x] Users can only view/edit their own preferences
- [ ] RLS policies enforce user isolation (Not applicable - app uses Firebase Security Rules, not RLS)
- [x] Notification logs are user-specific
- [x] No sensitive data in logs

### Data Storage
- [x] Preferences stored securely in database
- [x] Local cache for offline access only
- [x] No plaintext sensitive data
- [x] Audit trail for compliance

---

## 🌐 Localization

### German Language Support
- [x] All UI text in German
- [x] Notification messages in German
- [x] Error messages in German
- [x] Preference descriptions in German

### Text Content
- [x] "Benachrichtigungen" (Notifications)
- [x] "Push-Benachrichtigungen" (Push Notifications)
- [x] "E-Mail-Benachrichtigungen" (Email Notifications)
- [x] "Testphasen-Erinnerungen" (Trial Reminders)
- [x] "Favoriten-Updates" (Favorites Updates)
- [x] "Neue Inhalte" (New Content)
- [x] "System-Updates" (System Updates)

---

## 📱 Platform Requirements

### iOS
- [x] Native Switch component
- [x] SafeAreaView support
- [x] ScrollView for long content
- [x] Theme integration

### Android
- [x] Native Switch component
- [x] SafeAreaView support
- [x] ScrollView for long content
- [x] Theme integration

---

## 🔄 Integration Requirements

### Authentication Integration
- [ ] Check trial reminders on sign-in (Not implemented)
- [ ] Load preferences on authentication (Not implemented)
- [ ] Create defaults for new users (Not implemented)
- [ ] Clear preferences on sign-out (optional) (Not implemented)

### Subscription Integration
- [ ] Check subscription status for trial reminders (Not implemented)
- [ ] Query user_subscriptions table (Not applicable - app uses StoreKit, not database table)
- [ ] Calculate trial expiration date (Not implemented)
- [ ] Handle subscription status changes (Not implemented)

### Profile Integration
- [ ] Display notification preferences in profile (Not implemented)
- [ ] Quick toggle in profile screen (Not implemented)
- [ ] Sync with backend preferences (Not implemented)
- [ ] Update via useUserProfile hook (Not applicable - React hook, not in Swift)

---

## 📝 Notes

- Trial reminders are currently logged to database but not sent as push notifications (future enhancement)
- Default preferences enable all notification types for maximum engagement
- Preference updates use optimistic UI for better UX
- Notification logs are stored for analytics and compliance purposes
- All preferences are boolean toggles (no granular scheduling yet)
