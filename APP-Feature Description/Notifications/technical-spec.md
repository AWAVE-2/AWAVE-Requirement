# Notifications System - Technical Specification

## 🏗️ Architecture Overview

### Technology Stack

#### Backend
- **Supabase Database** - Primary data storage
  - `notification_preferences` table - User notification preferences
  - `notification_logs` table - Notification audit trail
  - `user_subscriptions` table - Trial status checking
  - Row Level Security (RLS) policies for data isolation

#### Local Storage
- **AsyncStorage** - Local caching and reminder tracking
  - Trial reminder sent flag (per user)
  - Last trial check timestamp
  - Local preference cache (optional)

#### State Management
- **React Context API** - Global auth state (for user context)
- **Custom Hooks** - `useUserProfile` for preference management
- **React State** - Local component state for UI

#### Services Layer
- `NotificationService` - Core notification logic
- `ProductionBackendService` - Supabase integration
- `AuthContext` - Trial reminder checking integration

---

## 📁 File Structure

```
src/
├── services/
│   └── NotificationService.ts          # Core notification service
├── screens/
│   ├── NotificationPreferencesScreen.tsx  # Main preferences UI
│   ├── AccountSettingsScreen.tsx          # Quick toggle
│   └── ProfileScreen.tsx                 # Profile integration
├── hooks/
│   └── useUserProfile.ts                 # Preference management hook
├── contexts/
│   └── AuthContext.tsx                   # Trial reminder integration
└── integrations/
    └── supabase/
        └── client.ts                     # Supabase client
```

---

## 🔧 Components

### NotificationPreferencesScreen
**Location:** `src/screens/NotificationPreferencesScreen.tsx`

**Purpose:** Dedicated screen for managing all notification preferences

**Props:** None (uses route params)

**State:**
- `loading: boolean` - Loading state during data fetch
- `saving: boolean` - Saving state during preference update
- `preferences: NotificationPreferences | null` - Current preferences

**Features:**
- Load preferences on mount
- Display all preference categories
- Toggle switches for each preference
- Optimistic UI updates
- Error handling and user feedback
- Loading and empty states

**Sections:**
1. **General Settings**
   - Push notifications
   - Email notifications

2. **Content Notifications**
   - Trial reminders
   - Favorites updates
   - New content
   - System updates

**Dependencies:**
- `NotificationService` - Preference operations
- `useAuth` - User authentication
- `useTheme` - Theme styling

---

### AccountSettingsScreen (Notification Section)
**Location:** `src/screens/AccountSettingsScreen.tsx`

**Purpose:** Quick push notification toggle in account settings

**State:**
- `pushNotifications: boolean` - Push notification state

**Features:**
- Quick toggle for push notifications
- Description text
- Immediate save on toggle
- Visual feedback

**Dependencies:**
- `useAuth` - User authentication
- `useTheme` - Theme styling

---

### ProfileScreen (Notification Integration)
**Location:** `src/screens/ProfileScreen.tsx`

**Purpose:** Notification preferences display and quick toggle

**State:**
- `notificationsEnabled: boolean` - Notification state
- `notificationPreferences: NotificationPreferences | null` - Full preferences

**Features:**
- Display notification preferences
- Quick toggle functionality
- Sync with backend preferences
- Update via useUserProfile hook

**Dependencies:**
- `useUserProfile` - Preference management
- `useAuth` - User authentication
- `useTheme` - Theme styling

---

## 🔌 Services

### NotificationService
**Location:** `src/services/NotificationService.ts`

**Type:** Static Class Service

**Purpose:** Core notification logic and preference management

#### Interfaces

**NotificationPreferences:**
```typescript
interface NotificationPreferences {
  user_id: string;
  push_notifications_enabled: boolean;
  email_notifications_enabled: boolean;
  trial_reminders_enabled: boolean;
  favorites_updates_enabled: boolean;
  new_content_enabled: boolean;
  system_updates_enabled: boolean;
}
```

**TrialStatus:**
```typescript
interface TrialStatus {
  isTrialing: boolean;
  trialEndsAt: string | null;
  daysRemaining: number;
  shouldSendReminder: boolean;
}
```

#### Methods

**`checkTrialStatus(userId: string): Promise<TrialStatus>`**
- Checks user subscription status
- Calculates days remaining until trial expiration
- Determines if reminder should be sent (3 days threshold)
- Returns trial status object

**`wasTrialReminderSent(userId: string): Promise<boolean>`**
- Checks AsyncStorage for reminder sent flag
- Prevents duplicate reminders
- Returns boolean status

**`markTrialReminderSent(userId: string): Promise<void>`**
- Marks reminder as sent in AsyncStorage
- Stores per-user flag
- Prevents duplicate reminders

**`sendTrialReminder(userId: string, daysRemaining: number): Promise<boolean>`**
- Checks if reminder already sent
- Verifies user preference (trial_reminders_enabled)
- Logs notification to database
- Marks reminder as sent
- Returns success status

**`getNotificationPreferences(userId: string): Promise<NotificationPreferences | null>`**
- Fetches preferences from database
- Creates defaults if not found
- Returns preferences or null

**`createDefaultPreferences(userId: string): Promise<NotificationPreferences | null>`**
- Creates default preference record
- All preferences enabled by default
- Returns created preferences

**`updateNotificationPreferences(userId: string, preferences: Partial<...>): Promise<boolean>`**
- Updates preferences in database
- Partial updates supported
- Returns success status

**`checkAndSendTrialReminder(userId: string): Promise<void>`**
- Main entry point for trial reminder checking
- Checks trial status
- Sends reminder if needed
- Called from app lifecycle

#### Storage Keys
- `notification_trial_reminder_sent_{userId}` - Reminder sent flag
- `notification_last_trial_check_{userId}` - Last check timestamp

#### Dependencies
- `supabase` client
- `AsyncStorage`
- `user_subscriptions` table
- `notification_preferences` table
- `notification_logs` table

---

### useUserProfile Hook
**Location:** `src/hooks/useUserProfile.ts`

**Purpose:** User profile and notification preference management

**Returns:**
```typescript
{
  userProfile: UserProfile | null;
  subscription: Subscription | null;
  notificationPreferences: NotificationPreferences | null;
  loadUserData: (userId: string) => Promise<void>;
  updateUserProfile: (updates: Partial<UserProfile>) => Promise<{data, error}>;
  updateNotificationPreferences: (updates: Partial<NotificationPreferences>) => Promise<{data, error}>;
}
```

**Features:**
- Load user profile data
- Load notification preferences
- Update notification preferences
- Create default preferences if missing
- Alert feedback for updates

**Dependencies:**
- `supabase` client
- `AsyncStorage`
- `notification_preferences` table

---

## 🗄️ Database Schema

### notification_preferences Table

```sql
CREATE TABLE IF NOT EXISTS public.notification_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE,
    push_notifications BOOLEAN NOT NULL DEFAULT TRUE,
    email_notifications BOOLEAN NOT NULL DEFAULT TRUE,
    marketing_emails BOOLEAN NOT NULL DEFAULT FALSE,
    reminder_notifications BOOLEAN NOT NULL DEFAULT TRUE,
    achievement_notifications BOOLEAN NOT NULL DEFAULT TRUE,
    trial_reminder_notifications BOOLEAN NOT NULL DEFAULT TRUE,
    preferred_notification_time TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

**Indexes:**
- `idx_notification_preferences_user_id` on `user_id`

**RLS Policies:**
- Users can manage their own preferences (ALL operations)
- Service role can manage all preferences

**Triggers:**
- `update_notification_preferences_updated_at` - Auto-update timestamp

### notification_logs Table

```sql
CREATE TABLE IF NOT EXISTS public.notification_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    notification_type TEXT NOT NULL,
    title TEXT,
    message TEXT NOT NULL,
    sent_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

**Indexes:**
- `idx_notification_logs_user_id` on `user_id`
- `idx_notification_logs_sent_at` on `sent_at`

**RLS Policies:**
- Users can view their own logs (SELECT)
- Service role can manage all logs (ALL operations)

---

## 🔄 State Management

### NotificationPreferences State
```typescript
{
  loading: boolean;
  saving: boolean;
  preferences: NotificationPreferences | null;
}
```

### Trial Reminder State
```typescript
{
  isTrialing: boolean;
  trialEndsAt: string | null;
  daysRemaining: number;
  shouldSendReminder: boolean;
}
```

### Local Storage State
```typescript
{
  trialReminderSent: boolean;  // AsyncStorage
  lastTrialCheck: number;      // AsyncStorage timestamp
}
```

---

## 🌐 API Integration

### Supabase Queries

#### Get Notification Preferences
```typescript
const { data, error } = await supabase
  .from('notification_preferences')
  .select('*')
  .eq('user_id', userId)
  .single();
```

#### Create Default Preferences
```typescript
const { data, error } = await supabase
  .from('notification_preferences')
  .insert(defaultPreferences)
  .select()
  .single();
```

#### Update Preferences
```typescript
const { error } = await supabase
  .from('notification_preferences')
  .update(preferences)
  .eq('user_id', userId);
```

#### Check Trial Status
```typescript
const { data: subscription, error } = await supabase
  .from('user_subscriptions')
  .select('status, trial_end_date')
  .eq('user_id', userId)
  .eq('status', 'trialing')
  .single();
```

#### Log Notification
```typescript
const { error } = await supabase
  .from('notification_logs')
  .insert({
    user_id: userId,
    notification_type: 'trial_reminder',
    title: 'Deine Testphase endet bald',
    message: `Deine kostenlose Testphase endet in ${daysRemaining} Tagen...`,
    sent_at: new Date().toISOString(),
  });
```

---

## 🔐 Security Implementation

### Row Level Security (RLS)

**notification_preferences:**
- Users can manage their own preferences
- Service role can manage all preferences

**notification_logs:**
- Users can view their own logs
- Service role can manage all logs

### Data Validation
- User ID validation before operations
- Preference value validation (boolean)
- Trial status validation before reminder sending

### Error Handling
- Network errors handled gracefully
- Database errors logged and reported
- User-friendly error messages

---

## 📱 Platform-Specific Notes

### iOS
- Native Switch component
- SafeAreaView for status bar handling
- ScrollView for long content
- Theme integration

### Android
- Native Switch component
- SafeAreaView for status bar handling
- ScrollView for long content
- Theme integration

### AsyncStorage
- Platform-agnostic storage
- Used for reminder tracking
- Local caching support

---

## 🧪 Testing Strategy

### Unit Tests
- NotificationService methods
- Preference creation logic
- Trial status calculation
- Reminder duplicate prevention

### Integration Tests
- Supabase queries
- Preference CRUD operations
- Trial reminder flow
- Error handling

### E2E Tests
- Complete preference update flow
- Trial reminder sending
- Default preference creation
- Error scenarios

---

## 🐛 Error Handling

### Error Types
- Network errors
- Database errors
- Missing preferences
- Invalid user ID
- Trial status errors

### Error Messages
- User-friendly German messages
- Clear action guidance
- Retry options where applicable
- No technical jargon

### Error Recovery
- Automatic retry for transient failures
- Revert optimistic updates on failure
- Show cached data when available
- Graceful degradation

---

## 📊 Performance Considerations

### Optimization
- Lazy loading of preferences
- Optimistic UI updates
- Efficient database queries
- Local caching for offline access

### Monitoring
- Preference update success rate
- Trial reminder delivery rate
- Average load/save times
- Error rates

---

## 🔄 Integration Points

### AuthContext Integration
- Trial reminder checking on sign-in
- User authentication state
- User ID availability

### Subscription Integration
- Trial status checking
- Subscription table queries
- Trial expiration calculation

### Profile Integration
- Preference display
- Quick toggle functionality
- useUserProfile hook usage

---

## 📝 Configuration

### Default Preferences
```typescript
{
  push_notifications_enabled: true,
  email_notifications_enabled: true,
  trial_reminders_enabled: true,
  favorites_updates_enabled: true,
  new_content_enabled: true,
  system_updates_enabled: true,
}
```

### Trial Reminder Threshold
- **Days before expiration:** 3 days
- **Check frequency:** On app launch and sign-in
- **Duplicate prevention:** Per trial period

### Storage Keys
- `notification_trial_reminder_sent_{userId}`
- `notification_last_trial_check_{userId}`

---

*For component details, see `components.md`*  
*For service dependencies, see `services.md`*  
*For user flows, see `user-flows.md`*
