# Database System - Database Tables Reference

**Last Updated:** 2025-01-27  
**Database:** Supabase PostgreSQL  
**Schema:** `public`

## 📋 Table Overview

The AWAVE app uses 11 core database tables organized into the following categories:

### Core User Tables
1. `user_profiles` - User account and profile information
2. `user_sessions` - Audio playback session tracking
3. `user_favorites` - User's favorite sound mixes

### Subscription & Payment Tables
4. `subscriptions` - Subscription and trial management

### Content Tables
5. `sound_metadata` - Audio file catalog and metadata
6. `custom_sound_sessions` - User-created custom sound mix configurations

### Settings & Preferences Tables
7. `notification_preferences` - User notification settings

### Analytics Tables
8. `app_usage_analytics` - Usage statistics and analytics
9. `search_analytics` - Search query tracking
10. `notification_logs` - Notification delivery history

### Configuration Tables
11. `sos_config` - SOS feature configuration

---

## 📊 Table Schemas

### 1. user_profiles

**Purpose:** User account and profile information

**Table Name:** `user_profiles`

**Columns:**

| Column Name | Type | Constraints | Default | Description |
|------------|------|-------------|---------|-------------|
| `id` | UUID | PRIMARY KEY | `gen_random_uuid()` | Unique profile identifier |
| `user_id` | UUID | NOT NULL, UNIQUE, FK → auth.users | - | Reference to auth.users.id |
| `first_name` | TEXT | NULL | NULL | User's first name |
| `last_name` | TEXT | NULL | NULL | User's last name |
| `display_name` | TEXT | NULL | NULL | User's display name |
| `avatar_url` | TEXT | NULL | NULL | URL to user's avatar image |
| `timezone` | TEXT | NULL | NULL | User's timezone (e.g., 'Europe/Berlin') |
| `preferred_language` | TEXT | NOT NULL | `'de'` | User's preferred language code |
| `onboarding_completed` | BOOLEAN | NOT NULL | `FALSE` | Whether onboarding is completed |
| `onboarding_data` | JSONB | NULL | NULL | Onboarding flow data (OnboardingData) |
| `onboarding_category_preference` | TEXT | NULL | NULL | Selected category during onboarding |
| `cached_sound_selection` | JSONB | NULL | NULL | Cached sound selection (CachedSoundSelection) |
| `registration_flow_state` | TEXT | NOT NULL | `'initial'` | Current registration flow state |
| `created_at` | TIMESTAMPTZ | NOT NULL | `NOW()` | Profile creation timestamp |
| `updated_at` | TIMESTAMPTZ | NOT NULL | `NOW()` | Last update timestamp |

**Indexes:**
- Primary key on `id`
- Unique constraint on `user_id`
- Index on `user_id` for lookups

**Foreign Keys:**
- `user_id` → `auth.users(id)` ON DELETE CASCADE

**RLS Policies:**
- Users can SELECT their own profile: `user_id = auth.uid()`
- Users can INSERT their own profile: `user_id = auth.uid()`
- Users can UPDATE their own profile: `user_id = auth.uid()`
- Users cannot DELETE their profile (admin only)

**JSONB Field Structures:**

**onboarding_data (OnboardingData):**
```typescript
{
  steps_completed: string[];
  category_preference?: string;
  sound_selection?: string[];
  started_at?: string;
  completed_at?: string;
  preferred_session_type?: 'meditation' | 'sleep' | 'focus' | 'custom';
}
```

**cached_sound_selection (CachedSoundSelection):**
```typescript
{
  category_id: string;
  sound_ids: string[];
  cached_at: string;
  metadata?: {
    total_sounds?: number;
    preference_weight?: number;
  };
}
```

---

### 2. user_sessions

**Purpose:** Audio playback session tracking

**Table Name:** `user_sessions`

**Columns:**

| Column Name | Type | Constraints | Default | Description |
|------------|------|-------------|---------|-------------|
| `id` | UUID | PRIMARY KEY | `gen_random_uuid()` | Unique session identifier |
| `user_id` | UUID | NOT NULL, FK → auth.users | - | Reference to auth.users.id |
| `session_start` | TIMESTAMPTZ | NOT NULL | `NOW()` | Session start timestamp |
| `session_end` | TIMESTAMPTZ | NULL | NULL | Session end timestamp |
| `duration_minutes` | INTEGER | NULL | NULL | Session duration in minutes |
| `sounds_played` | JSONB | NULL | NULL | Array of sounds played (SessionSoundsPlayed[]) |
| `session_type` | ENUM | NOT NULL | `'custom'` | Type of session |
| `completed` | BOOLEAN | NOT NULL | `FALSE` | Whether session was completed |
| `device_info` | JSONB | NULL | NULL | Device information (DeviceInfo) |
| `created_at` | TIMESTAMPTZ | NOT NULL | `NOW()` | Session creation timestamp |

**Indexes:**
- Primary key on `id`
- Index on `user_id` for user queries
- Index on `created_at` for ordering

**Foreign Keys:**
- `user_id` → `auth.users(id)` ON DELETE CASCADE

**RLS Policies:**
- Users can SELECT their own sessions: `user_id = auth.uid()`
- Users can INSERT their own sessions: `user_id = auth.uid()`
- Users can UPDATE their own sessions: `user_id = auth.uid()`
- Users can DELETE their own sessions: `user_id = auth.uid()`

**Enum Values (session_type):**
- `'meditation'`
- `'sleep'`
- `'focus'`
- `'custom'`

**JSONB Field Structures:**

**sounds_played (SessionSoundsPlayed[]):**
```typescript
[
  {
    sound_id: string;
    title?: string;
    category_id?: string;
    volume?: number; // 0-100
    duration_seconds?: number;
    played_at?: string;
  }
]
```

**device_info (DeviceInfo):**
```typescript
{
  platform: 'ios' | 'android' | 'web';
  version: string;
  model?: string;
  app_version?: string;
  os_version?: string;
  screen?: {
    width: number;
    height: number;
  };
  connection_type?: 'wifi' | 'cellular' | 'unknown';
}
```

---

### 3. user_favorites

**Purpose:** User's favorite sound mixes

**Table Name:** `user_favorites`

**Columns:**

| Column Name | Type | Constraints | Default | Description |
|------------|------|-------------|---------|-------------|
| `id` | UUID | PRIMARY KEY | `gen_random_uuid()` | Unique favorite identifier |
| `user_id` | UUID | NOT NULL, FK → auth.users | - | Reference to auth.users.id |
| `sound_id` | TEXT | NULL | NULL | Reference to sound ID |
| `title` | TEXT | NULL | NULL | Favorite title |
| `description` | TEXT | NULL | NULL | Favorite description |
| `image_url` | TEXT | NULL | NULL | Favorite image URL |
| `tracks` | JSONB | NULL | NULL | Array of audio tracks (FavoriteTrack[]) |
| `date_added` | TIMESTAMPTZ | NULL | NULL | When favorite was added |
| `last_used` | TIMESTAMPTZ | NULL | NULL | Last time favorite was used |
| `use_count` | INTEGER | NOT NULL | `0` | Number of times favorite was used |
| `is_public` | BOOLEAN | NOT NULL | `FALSE` | Whether favorite is public |
| `category_id` | TEXT | NULL | NULL | Category ID for the favorite |

**Indexes:**
- Primary key on `id`
- Index on `user_id` for user queries
- Index on `last_used` for ordering (descending, nulls last)

**Foreign Keys:**
- `user_id` → `auth.users(id)` ON DELETE CASCADE

**RLS Policies:**
- Users can SELECT their own favorites: `user_id = auth.uid()`
- Users can INSERT their own favorites: `user_id = auth.uid()`
- Users can UPDATE their own favorites: `user_id = auth.uid()`
- Users can DELETE their own favorites: `user_id = auth.uid()`

**JSONB Field Structures:**

**tracks (FavoriteTrack[]):**
```typescript
[
  {
    id: string;
    volume: number; // 0-100
    effects?: AudioEffects;
    title?: string;
    category_id?: string;
  }
]
```

**AudioEffects:**
```typescript
{
  reverb?: number; // 0-100
  delay?: number; // 0-100
  bass?: number; // 0-100
  treble?: number; // 0-100
  compression?: number; // 0-100
  eq_preset?: string;
}
```

---

### 4. subscriptions

**Purpose:** Subscription and trial management

**Table Name:** `subscriptions`

**Columns:**

| Column Name | Type | Constraints | Default | Description |
|------------|------|-------------|---------|-------------|
| `id` | UUID | PRIMARY KEY | `gen_random_uuid()` | Unique subscription identifier |
| `user_id` | UUID | NOT NULL, UNIQUE, FK → auth.users | - | Reference to auth.users.id |
| `stripe_customer_id` | TEXT | NULL | NULL | Stripe customer ID |
| `stripe_subscription_id` | TEXT | NULL | NULL | Stripe subscription ID |
| `plan_type` | ENUM | NOT NULL | - | Type of subscription plan |
| `status` | ENUM | NOT NULL | - | Subscription status |
| `trial_start` | TIMESTAMPTZ | NULL | NULL | Trial start timestamp |
| `trial_end` | TIMESTAMPTZ | NULL | NULL | Trial end timestamp |
| `current_period_start` | TIMESTAMPTZ | NULL | NULL | Current billing period start |
| `current_period_end` | TIMESTAMPTZ | NULL | NULL | Current billing period end |
| `cancel_at_period_end` | BOOLEAN | NOT NULL | `FALSE` | Whether to cancel at period end |
| `trial_days_remaining` | INTEGER | NOT NULL | - | Days remaining in trial |
| `auto_renew` | BOOLEAN | NOT NULL | `TRUE` | Whether subscription auto-renews |
| `selected_plan_price` | NUMERIC | NULL | NULL | Selected plan price |
| `selected_plan_interval` | TEXT | NOT NULL | - | Plan interval (e.g., 'month', 'year') |
| `created_at` | TIMESTAMPTZ | NOT NULL | `NOW()` | Subscription creation timestamp |
| `updated_at` | TIMESTAMPTZ | NOT NULL | `NOW()` | Last update timestamp |

**Indexes:**
- Primary key on `id`
- Unique constraint on `user_id`
- Index on `user_id` for lookups
- Index on `status` for filtering

**Foreign Keys:**
- `user_id` → `auth.users(id)` ON DELETE CASCADE

**RLS Policies:**
- Users can SELECT their own subscription: `user_id = auth.uid()`
- Users can UPDATE limited fields of their subscription: `user_id = auth.uid()`
- Users cannot INSERT subscriptions (system only)
- Users cannot DELETE subscriptions (admin only)

**Enum Values:**

**plan_type:**
- `'free_trial'`
- `'monthly'`
- `'yearly'`

**status:**
- `'active'`
- `'cancelled'`
- `'past_due'`
- `'expired'`
- `'trialing'`

---

### 5. sound_metadata

**Purpose:** Audio file catalog and metadata

**Table Name:** `sound_metadata`

**Columns:**

| Column Name | Type | Constraints | Default | Description |
|------------|------|-------------|---------|-------------|
| `id` | UUID | PRIMARY KEY | `gen_random_uuid()` | Unique metadata identifier |
| `sound_id` | TEXT | NOT NULL, UNIQUE | - | Unique sound identifier |
| `category_id` | TEXT | NOT NULL | - | Category identifier |
| `title` | TEXT | NOT NULL | - | Sound title |
| `description` | TEXT | NULL | NULL | Sound description |
| `keywords` | TEXT[] | NOT NULL | `'{}'` | Array of search keywords |
| `tags` | TEXT[] | NOT NULL | `'{}'` | Array of tags |
| `search_weight` | INTEGER | NOT NULL | `0` | Search relevance weight |
| `file_url` | TEXT | NULL | NULL | Public file URL |
| `file_path` | TEXT | NULL | NULL | Internal file path |
| `bucket_id` | TEXT | NULL | NULL | Storage bucket identifier |
| `storage_path` | TEXT | NULL | NULL | Storage path |
| `file_size` | BIGINT | NULL | NULL | File size in bytes |
| `file_hash` | TEXT | NULL | NULL | File hash for integrity |
| `duration` | INTEGER | NULL | NULL | Duration in seconds |
| `format` | TEXT | NULL | NULL | Audio format (e.g., 'mp3') |
| `bitrate` | INTEGER | NULL | NULL | Audio bitrate |
| `sample_rate` | INTEGER | NULL | NULL | Audio sample rate |
| `channels` | INTEGER | NULL | NULL | Number of audio channels |
| `processed` | BOOLEAN | NULL | `FALSE` | Whether file is processed |
| `waveform_data` | JSONB | NULL | NULL | Waveform visualization data |
| `spectrogram_url` | TEXT | NULL | NULL | Spectrogram image URL |
| `is_public` | BOOLEAN | NULL | `TRUE` | Whether sound is publicly accessible |
| `download_count` | INTEGER | NULL | `0` | Number of downloads |
| `play_count` | INTEGER | NULL | `0` | Number of plays |
| `created_at` | TIMESTAMPTZ | NOT NULL | `NOW()` | Metadata creation timestamp |
| `updated_at` | TIMESTAMPTZ | NOT NULL | `NOW()` | Last update timestamp |

**Indexes:**
- Primary key on `id`
- Unique constraint on `sound_id`
- Index on `category_id` for filtering
- Index on `search_weight` for ordering
- Full-text search index on `title`, `keywords`, `tags`
- GIN index on `keywords` array
- GIN index on `tags` array

**RLS Policies:**
- Public SELECT access (no authentication required)
- Admin-only INSERT, UPDATE, DELETE

**JSONB Field Structures:**

**waveform_data (WaveformData):**
```typescript
{
  amplitudes: number[]; // Array of amplitude values (0-100)
  sample_rate?: number;
  total_samples?: number;
  peak?: number;
  rms?: number;
}
```

---

### 6. custom_sound_sessions

**Purpose:** User-created custom sound mix configurations

**Table Name:** `custom_sound_sessions`

**Columns:**

| Column Name | Type | Constraints | Default | Description |
|------------|------|-------------|---------|-------------|
| `id` | UUID | PRIMARY KEY | `gen_random_uuid()` | Unique session identifier |
| `user_id` | UUID | NOT NULL, FK → auth.users | - | Reference to auth.users.id |
| `category_id` | TEXT | NULL | NULL | Category identifier |
| `title` | TEXT | NULL | NULL | Session title |
| `description` | TEXT | NULL | NULL | Session description |
| `tracks_config` | JSONB | NOT NULL | - | Track configuration (TracksConfig) |
| `swiper_positions` | JSONB | NOT NULL | - | UI swiper positions (SwiperPositions) |
| `created_at` | TIMESTAMPTZ | NOT NULL | `NOW()` | Session creation timestamp |
| `updated_at` | TIMESTAMPTZ | NOT NULL | `NOW()` | Last update timestamp |
| `last_used` | TIMESTAMPTZ | NULL | NULL | Last time session was used |

**Indexes:**
- Primary key on `id`
- Index on `user_id` for user queries
- Index on `last_used` for ordering (descending, nulls last)
- Index on `created_at` for ordering

**Foreign Keys:**
- `user_id` → `auth.users(id)` ON DELETE CASCADE

**RLS Policies:**
- Users can SELECT their own sessions: `user_id = auth.uid()`
- Users can INSERT their own sessions: `user_id = auth.uid()`
- Users can UPDATE their own sessions: `user_id = auth.uid()`
- Users can DELETE their own sessions: `user_id = auth.uid()`

**JSONB Field Structures:**

**tracks_config (TracksConfig):**
```typescript
{
  tracks: MixerTrack[];
  master_volume?: number; // 0-100
  crossfade_duration?: number; // seconds
  loop?: boolean;
}
```

**MixerTrack:**
```typescript
{
  id: string;
  title: string;
  file_url: string;
  volume: number; // 0-100
  pan?: number; // -100 to 100, -100 = left, 100 = right
  solo?: boolean;
  mute?: boolean;
  effects?: AudioEffects;
  color?: string; // UI color
}
```

**swiper_positions (SwiperPositions):**
```typescript
{
  [trackId: string]: {
    x: number; // 0-100
    y: number; // 0-100
    z_index?: number;
  };
}
```

---

### 7. notification_preferences

**Purpose:** User notification settings

**Table Name:** `notification_preferences`

**Columns:**

| Column Name | Type | Constraints | Default | Description |
|------------|------|-------------|---------|-------------|
| `id` | UUID | PRIMARY KEY | `gen_random_uuid()` | Unique preference identifier |
| `user_id` | UUID | NOT NULL, UNIQUE, FK → auth.users | - | Reference to auth.users.id |
| `push_notifications` | BOOLEAN | NOT NULL | `TRUE` | Enable push notifications |
| `email_notifications` | BOOLEAN | NOT NULL | `TRUE` | Enable email notifications |
| `marketing_emails` | BOOLEAN | NOT NULL | `FALSE` | Enable marketing emails |
| `reminder_notifications` | BOOLEAN | NOT NULL | `TRUE` | Enable reminder notifications |
| `achievement_notifications` | BOOLEAN | NOT NULL | `TRUE` | Enable achievement notifications |
| `trial_reminder_notifications` | BOOLEAN | NOT NULL | `TRUE` | Enable trial reminder notifications |
| `preferred_notification_time` | TEXT | NULL | NULL | Preferred notification time (e.g., '09:00') |
| `created_at` | TIMESTAMPTZ | NOT NULL | `NOW()` | Preference creation timestamp |
| `updated_at` | TIMESTAMPTZ | NOT NULL | `NOW()` | Last update timestamp |

**Indexes:**
- Primary key on `id`
- Unique constraint on `user_id`

**Foreign Keys:**
- `user_id` → `auth.users(id)` ON DELETE CASCADE

**RLS Policies:**
- Users can SELECT their own preferences: `user_id = auth.uid()`
- Users can INSERT their own preferences: `user_id = auth.uid()`
- Users can UPDATE their own preferences: `user_id = auth.uid()`
- Users cannot DELETE preferences (admin only)

---

### 8. app_usage_analytics

**Purpose:** Usage statistics and analytics

**Table Name:** `app_usage_analytics`

**Columns:**

| Column Name | Type | Constraints | Default | Description |
|------------|------|-------------|---------|-------------|
| `id` | UUID | PRIMARY KEY | `gen_random_uuid()` | Unique analytics identifier |
| `user_id` | UUID | NOT NULL, FK → auth.users | - | Reference to auth.users.id |
| `date` | DATE | NOT NULL | - | Analytics date |
| `total_session_time` | INTEGER | NOT NULL | `0` | Total session time in seconds |
| `sessions_started` | INTEGER | NOT NULL | `0` | Number of sessions started |
| `sessions_completed` | INTEGER | NOT NULL | `0` | Number of sessions completed |
| `favorite_sounds_used` | JSONB | NULL | NULL | Favorite sounds usage (FavoriteSoundsUsed) |
| `features_used` | JSONB | NULL | NULL | Features usage (FeaturesUsed) |
| `retention_score` | NUMERIC | NULL | NULL | User retention score |
| `created_at` | TIMESTAMPTZ | NOT NULL | `NOW()` | Analytics creation timestamp |

**Indexes:**
- Primary key on `id`
- Index on `user_id` for user queries
- Index on `date` for time-based queries
- Unique constraint on (`user_id`, `date`)

**Foreign Keys:**
- `user_id` → `auth.users(id)` ON DELETE CASCADE

**RLS Policies:**
- Users can SELECT their own analytics: `user_id = auth.uid()`
- System can INSERT analytics (service role)
- Users cannot UPDATE or DELETE analytics

**JSONB Field Structures:**

**favorite_sounds_used (FavoriteSoundsUsed):**
```typescript
{
  [soundId: string]: {
    play_count: number;
    total_duration?: number; // seconds
    last_played?: string;
  };
}
```

**features_used (FeaturesUsed):**
```typescript
{
  [featureName: string]: {
    usage_count: number;
    first_used?: string;
    last_used?: string;
  };
}
```

---

### 9. search_analytics

**Purpose:** Search query tracking

**Table Name:** `search_analytics`

**Columns:**

| Column Name | Type | Constraints | Default | Description |
|------------|------|-------------|---------|-------------|
| `id` | UUID | PRIMARY KEY | `gen_random_uuid()` | Unique analytics identifier |
| `user_id` | UUID | NULL, FK → auth.users | NULL | Reference to auth.users.id (nullable for anonymous) |
| `search_query` | TEXT | NOT NULL | - | Search query text |
| `results_count` | INTEGER | NOT NULL | `0` | Number of results returned |
| `sos_triggered` | BOOLEAN | NOT NULL | `FALSE` | Whether SOS was triggered |
| `created_at` | TIMESTAMPTZ | NOT NULL | `NOW()` | Analytics creation timestamp |

**Indexes:**
- Primary key on `id`
- Index on `user_id` for user queries
- Index on `created_at` for time-based queries
- Index on `sos_triggered` for filtering

**Foreign Keys:**
- `user_id` → `auth.users(id)` ON DELETE SET NULL

**RLS Policies:**
- Users can SELECT their own search analytics: `user_id = auth.uid() OR user_id IS NULL`
- System can INSERT search analytics (service role)
- Users cannot UPDATE or DELETE analytics

---

### 10. notification_logs

**Purpose:** Notification delivery history

**Table Name:** `notification_logs`

**Columns:**

| Column Name | Type | Constraints | Default | Description |
|------------|------|-------------|---------|-------------|
| `id` | UUID | PRIMARY KEY | `gen_random_uuid()` | Unique log identifier |
| `user_id` | UUID | NOT NULL, FK → auth.users | - | Reference to auth.users.id |
| `notification_type` | TEXT | NOT NULL | - | Type of notification |
| `message` | TEXT | NOT NULL | - | Notification message |
| `sent_at` | TIMESTAMPTZ | NOT NULL | `NOW()` | When notification was sent |
| `created_at` | TIMESTAMPTZ | NOT NULL | `NOW()` | Log creation timestamp |

**Indexes:**
- Primary key on `id`
- Index on `user_id` for user queries
- Index on `sent_at` for time-based queries
- Index on `notification_type` for filtering

**Foreign Keys:**
- `user_id` → `auth.users(id)` ON DELETE CASCADE

**RLS Policies:**
- Users can SELECT their own notification logs: `user_id = auth.uid()`
- System can INSERT notification logs (service role)
- Users cannot UPDATE or DELETE logs

---

### 11. sos_config

**Purpose:** SOS feature configuration

**Table Name:** `sos_config`

**Columns:**

| Column Name | Type | Constraints | Default | Description |
|------------|------|-------------|---------|-------------|
| `id` | UUID | PRIMARY KEY | `gen_random_uuid()` | Unique config identifier |
| `keywords` | TEXT[] | NOT NULL | `'{}'` | Array of trigger keywords |
| `title` | TEXT | NOT NULL | - | SOS title |
| `message` | TEXT | NOT NULL | - | SOS message |
| `image_url` | TEXT | NULL | NULL | SOS image URL |
| `phone_number` | TEXT | NOT NULL | - | Emergency phone number |
| `chat_link` | TEXT | NULL | NULL | Emergency chat link |
| `resources` | TEXT[] | NULL | NULL | Array of resource URLs |
| `active` | BOOLEAN | NOT NULL | `TRUE` | Whether config is active |
| `created_at` | TIMESTAMPTZ | NOT NULL | `NOW()` | Config creation timestamp |
| `updated_at` | TIMESTAMPTZ | NOT NULL | `NOW()` | Last update timestamp |

**Indexes:**
- Primary key on `id`
- Index on `active` for filtering
- GIN index on `keywords` array

**RLS Policies:**
- Public SELECT access (no authentication required)
- Admin-only INSERT, UPDATE, DELETE

---

## 🔗 Table Relationships

### Entity Relationship Diagram

```
auth.users
    │
    ├─> user_profiles (1:1)
    │
    ├─> user_sessions (1:N)
    │
    ├─> user_favorites (1:N)
    │
    ├─> subscriptions (1:1)
    │
    ├─> custom_sound_sessions (1:N)
    │
    ├─> notification_preferences (1:1)
    │
    ├─> app_usage_analytics (1:N)
    │
    ├─> search_analytics (1:N, nullable)
    │
    └─> notification_logs (1:N)
```

### Foreign Key Relationships

- `user_profiles.user_id` → `auth.users.id` (CASCADE)
- `user_sessions.user_id` → `auth.users.id` (CASCADE)
- `user_favorites.user_id` → `auth.users.id` (CASCADE)
- `subscriptions.user_id` → `auth.users.id` (CASCADE)
- `custom_sound_sessions.user_id` → `auth.users.id` (CASCADE)
- `notification_preferences.user_id` → `auth.users.id` (CASCADE)
- `app_usage_analytics.user_id` → `auth.users.id` (CASCADE)
- `search_analytics.user_id` → `auth.users.id` (SET NULL)
- `notification_logs.user_id` → `auth.users.id` (CASCADE)

---

## 📊 Database Functions (RPC)

### calculate_trial_days_remaining

**Purpose:** Calculate remaining trial days for a user

**Function Name:** `calculate_trial_days_remaining`

**Parameters:**
- `user_uuid` (UUID) - User ID

**Returns:** INTEGER - Number of days remaining

**Usage:**
```sql
SELECT calculate_trial_days_remaining('user-uuid-here');
```

---

### user_needs_registration

**Purpose:** Check if user needs to complete registration

**Function Name:** `user_needs_registration`

**Parameters:**
- `user_uuid` (UUID) - User ID

**Returns:** BOOLEAN - True if registration needed

**Usage:**
```sql
SELECT user_needs_registration('user-uuid-here');
```

---

## 🔐 Row-Level Security (RLS) Summary

### Public Access (No Authentication Required)
- `sound_metadata` - SELECT only
- `sos_config` - SELECT only

### User Access (Authenticated Users)
- `user_profiles` - Own data only
- `user_sessions` - Own data only
- `user_favorites` - Own data only
- `subscriptions` - Own data only (limited UPDATE)
- `custom_sound_sessions` - Own data only
- `notification_preferences` - Own data only
- `app_usage_analytics` - Own data only (SELECT)
- `search_analytics` - Own data only (SELECT)
- `notification_logs` - Own data only (SELECT)

### System Access (Service Role Only)
- All tables - INSERT, UPDATE, DELETE for analytics and logs
- `sound_metadata` - INSERT, UPDATE, DELETE
- `sos_config` - INSERT, UPDATE, DELETE

---

## 📝 Notes

- All tables use UUID primary keys for better distribution
- Timestamps use TIMESTAMPTZ for timezone-aware storage
- JSONB fields are validated at runtime using TypeScript types
- RLS policies ensure user data isolation
- Foreign keys use CASCADE delete to maintain referential integrity
- Indexes are optimized for common query patterns
- Full-text search is available on `sound_metadata` for search functionality

---

*For service layer documentation, see `services.md`*  
*For technical implementation details, see `technical-spec.md`*  
*For user flows, see `user-flows.md`*
