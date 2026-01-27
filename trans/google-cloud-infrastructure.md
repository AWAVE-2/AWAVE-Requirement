# Google Cloud Infrastructure

## Infrastructure Overview

```
┌────────────────────────────────────────────────────────────────────────────────┐
│                            Google Cloud Platform                                │
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │                         Global Load Balancer                             │   │
│  │                    (Cloud CDN + Cloud Armor WAF)                         │   │
│  └───────────────────────────────┬─────────────────────────────────────────┘   │
│                                  │                                              │
│         ┌────────────────────────┼────────────────────────┐                    │
│         ▼                        ▼                        ▼                    │
│  ┌─────────────┐         ┌─────────────┐          ┌─────────────┐             │
│  │   Firebase  │         │    Cloud    │          │    Cloud    │             │
│  │    Auth     │         │  Functions  │          │   Storage   │             │
│  │             │         │   (Gen 2)   │          │   (Audio)   │             │
│  │ - Email     │         │             │          │             │             │
│  │ - Google    │         │ - API       │          │ - 3000+     │             │
│  │ - Apple     │         │ - Webhooks  │          │   audio     │             │
│  │ - Anonymous │         │ - Scheduled │          │   files     │             │
│  └──────┬──────┘         └──────┬──────┘          └──────┬──────┘             │
│         │                       │                        │                     │
│         └───────────────────────┼────────────────────────┘                     │
│                                 ▼                                              │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │                         Cloud Firestore                                  │   │
│  │                    (Multi-region: eur3 - Europe)                         │   │
│  │                                                                          │   │
│  │  Collections:                                                            │   │
│  │  ├── users/           User profiles and preferences                      │   │
│  │  ├── sounds/          Sound metadata catalog (3000+ docs)                │   │
│  │  ├── sessions/        Playback session history                           │   │
│  │  ├── favorites/       User favorite sounds                               │   │
│  │  ├── subscriptions/   Subscription and payment records                   │   │
│  │  ├── analytics/       Usage analytics events                             │   │
│  │  └── sos_config/      SOS crisis support configuration                   │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                 │                                              │
│                                 ▼                                              │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │                      BigQuery + Vertex AI                                │   │
│  │                                                                          │   │
│  │  - Analytics data warehouse                                              │   │
│  │  - ML recommendation models                                              │   │
│  │  - User behavior analysis                                                │   │
│  │  - A/B testing infrastructure                                            │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │                      Monitoring & Observability                          │   │
│  │                                                                          │   │
│  │  - Cloud Monitoring (metrics, dashboards, alerts)                        │   │
│  │  - Cloud Logging (centralized logs)                                      │   │
│  │  - Cloud Trace (distributed tracing)                                     │   │
│  │  - Error Reporting (crash analytics)                                     │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
└────────────────────────────────────────────────────────────────────────────────┘
```

---

## Firebase Configuration

### Firebase Project Setup

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login and initialize
firebase login
firebase init

# Select features:
# - Firestore
# - Functions
# - Storage
# - Hosting (for web admin dashboard)
# - Authentication
```

### firebase.json

```json
{
  "firestore": {
    "rules": "firestore.rules",
    "indexes": "firestore.indexes.json"
  },
  "functions": {
    "source": "functions",
    "runtime": "nodejs20",
    "codebase": "awave-functions"
  },
  "storage": {
    "rules": "storage.rules"
  },
  "hosting": {
    "public": "admin-dashboard/dist",
    "rewrites": [
      {
        "source": "/api/**",
        "function": "api"
      }
    ]
  }
}
```

---

## Cloud Firestore Schema

### Collections & Documents

```typescript
// TypeScript interfaces for Firestore documents

// users/{userId}
interface User {
  id: string;
  email: string;
  displayName: string;
  avatarUrl?: string;
  createdAt: Timestamp;
  updatedAt: Timestamp;
  preferences: {
    defaultCategory: string;
    notificationsEnabled: boolean;
    downloadOverWifiOnly: boolean;
    defaultVolume: number;
  };
  stats: {
    totalListeningMinutes: number;
    sessionsCompleted: number;
    streakDays: number;
    lastActiveAt: Timestamp;
  };
  onboardingCompleted: boolean;
}

// sounds/{soundId}
interface Sound {
  id: string;
  name: string;
  description: string;
  category: 'sleep' | 'focus' | 'relax' | 'flow';
  subcategory: string;
  duration: number; // seconds
  fileUrl: string; // Cloud Storage path
  thumbnailUrl: string;
  waveformData: number[]; // Pre-computed waveform
  tags: string[];
  isPremium: boolean;
  playCount: number;
  createdAt: Timestamp;
  updatedAt: Timestamp;
  metadata: {
    bpm?: number;
    key?: string;
    mood?: string;
    isProcedural: boolean;
    proceduralType?: 'waves' | 'rain' | 'noise' | 'binaural';
  };
}

// sessions/{sessionId}
interface Session {
  id: string;
  userId: string;
  startedAt: Timestamp;
  endedAt?: Timestamp;
  duration: number; // seconds actually listened
  mix: {
    sounds: Array<{
      soundId: string;
      volume: number;
    }>;
    name?: string;
  };
  category: string;
  completed: boolean;
  rating?: number;
}

// favorites/{favoriteId}
interface Favorite {
  id: string;
  usereId: string;
  soundId?: string;
  mixId?: string;
  type: 'sound' | 'mix';
  createdAt: Timestamp;
}

// subscriptions/{subscriptionId}
interface Subscription {
  id: string;
  userId: string;
  productId: string;
  status: 'active' | 'expired' | 'cancelled' | 'trial';
  platform: 'ios' | 'android' | 'web';
  originalTransactionId: string;
  expiresAt: Timestamp;
  trialEndsAt?: Timestamp;
  createdAt: Timestamp;
  updatedAt: Timestamp;
  receiptData?: string; // Encrypted
}

// analytics/{eventId}
interface AnalyticsEvent {
  id: string;
  userId: string;
  eventType: string;
  eventData: Record<string, any>;
  timestamp: Timestamp;
  sessionId?: string;
  deviceInfo: {
    platform: string;
    osVersion: string;
    appVersion: string;
    deviceModel: string;
  };
}
```

### Firestore Security Rules

```javascript
// firestore.rules
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {

    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    function isPremiumUser() {
      return isAuthenticated() &&
        exists(/databases/$(database)/documents/subscriptions/$(request.auth.uid)) &&
        get(/databases/$(database)/documents/subscriptions/$(request.auth.uid)).data.status == 'active';
    }

    // Users collection
    match /users/{userId} {
      allow read: if isOwner(userId);
      allow create: if isAuthenticated() && request.auth.uid == userId;
      allow update: if isOwner(userId);
      allow delete: if false; // Soft delete only

      // User's private subcollections
      match /private/{document=**} {
        allow read, write: if isOwner(userId);
      }
    }

    // Sounds collection (public read, admin write)
    match /sounds/{soundId} {
      allow read: if isAuthenticated();
      allow write: if false; // Admin only via Cloud Functions

      // Premium sounds require subscription
      allow read: if resource.data.isPremium == false ||
                    (resource.data.isPremium == true && isPremiumUser());
    }

    // Sessions collection
    match /sessions/{sessionId} {
      allow read: if isOwner(resource.data.userId);
      allow create: if isAuthenticated() &&
                      request.resource.data.userId == request.auth.uid;
      allow update: if isOwner(resource.data.userId) &&
                      request.resource.data.userId == resource.data.userId;
      allow delete: if false;
    }

    // Favorites collection
    match /favorites/{favoriteId} {
      allow read: if isOwner(resource.data.userId);
      allow create: if isAuthenticated() &&
                      request.resource.data.userId == request.auth.uid;
      allow delete: if isOwner(resource.data.userId);
    }

    // Subscriptions (read-only for users, managed by Cloud Functions)
    match /subscriptions/{userId} {
      allow read: if isOwner(userId);
      allow write: if false; // Managed by Cloud Functions
    }

    // Analytics (write-only for users)
    match /analytics/{eventId} {
      allow read: if false; // Admin only via BigQuery
      allow create: if isAuthenticated() &&
                      request.resource.data.userId == request.auth.uid;
    }

    // SOS Config (public read)
    match /sos_config/{document=**} {
      allow read: if isAuthenticated();
      allow write: if false; // Admin only
    }
  }
}
```

### Firestore Indexes

```json
// firestore.indexes.json
{
  "indexes": [
    {
      "collectionGroup": "sounds",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "category", "order": "ASCENDING" },
        { "fieldPath": "playCount", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "sounds",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "tags", "arrayConfig": "CONTAINS" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "sessions",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "userId", "order": "ASCENDING" },
        { "fieldPath": "startedAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "sessions",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "userId", "order": "ASCENDING" },
        { "fieldPath": "category", "order": "ASCENDING" },
        { "fieldPath": "startedAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "analytics",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "userId", "order": "ASCENDING" },
        { "fieldPath": "timestamp", "order": "DESCENDING" }
      ]
    }
  ],
  "fieldOverrides": [
    {
      "collectionGroup": "sounds",
      "fieldPath": "tags",
      "indexes": [
        { "order": "ASCENDING", "queryScope": "COLLECTION" },
        { "arrayConfig": "CONTAINS", "queryScope": "COLLECTION" }
      ]
    }
  ]
}
```

---

## Cloud Storage Configuration

### Storage Structure

```
awave-audio-bucket/
├── sounds/
│   ├── sleep/
│   │   ├── ocean-waves-001.mp3
│   │   ├── gentle-rain-002.mp3
│   │   └── ...
│   ├── focus/
│   ├── relax/
│   └── flow/
├── thumbnails/
│   ├── sounds/
│   └── categories/
├── waveforms/
│   └── {soundId}.json
└── user-uploads/
    └── {userId}/
        └── custom-mixes/
```

### Storage Security Rules

```javascript
// storage.rules
rules_version = '2';

service firebase.storage {
  match /b/{bucket}/o {

    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }

    function isPremiumUser() {
      return request.auth.token.premium == true;
    }

    // Public read for all audio files
    match /sounds/{category}/{fileName} {
      allow read: if isAuthenticated();
      allow write: if false; // Admin only
    }

    // Thumbnails - public read
    match /thumbnails/{allPaths=**} {
      allow read: if true;
      allow write: if false;
    }

    // Waveform data - authenticated read
    match /waveforms/{soundId}.json {
      allow read: if isAuthenticated();
      allow write: if false;
    }

    // User uploads - owner only
    match /user-uploads/{userId}/{allPaths=**} {
      allow read: if request.auth.uid == userId;
      allow write: if request.auth.uid == userId &&
                     request.resource.size < 50 * 1024 * 1024 && // 50MB max
                     request.resource.contentType.matches('audio/.*');
    }
  }
}
```

---

## Cloud Functions

### Function Structure

```
functions/
├── src/
│   ├── index.ts                 # Function exports
│   ├── auth/
│   │   ├── onCreate.ts          # New user setup
│   │   └── onDelete.ts          # User cleanup
│   ├── subscriptions/
│   │   ├── verifyReceipt.ts     # iOS/Android receipt validation
│   │   ├── webhooks.ts          # App Store/Play Store webhooks
│   │   └── checkExpiry.ts       # Scheduled expiry check
│   ├── analytics/
│   │   ├── exportToBigQuery.ts  # Daily export
│   │   └── generateInsights.ts  # ML-based insights
│   ├── notifications/
│   │   ├── sendPush.ts          # Push notification sender
│   │   └── scheduleReminder.ts  # Scheduled reminders
│   └── admin/
│       ├── syncSounds.ts        # Sync sound catalog
│       └── generateWaveforms.ts # Generate waveform data
├── package.json
└── tsconfig.json
```

### Example Cloud Functions

```typescript
// functions/src/index.ts
import * as functions from 'firebase-functions/v2';
import * as admin from 'firebase-admin';

admin.initializeApp();

// Auth triggers
export { onUserCreate } from './auth/onCreate';
export { onUserDelete } from './auth/onDelete';

// Subscription functions
export { verifyAppleReceipt } from './subscriptions/verifyReceipt';
export { handleAppStoreWebhook } from './subscriptions/webhooks';

// Analytics
export { exportAnalyticsToBigQuery } from './analytics/exportToBigQuery';

// Scheduled functions
export { checkSubscriptionExpiry } from './subscriptions/checkExpiry';

// functions/src/auth/onCreate.ts
import { auth } from 'firebase-functions/v2';
import { getFirestore } from 'firebase-admin/firestore';

export const onUserCreate = auth.user().onCreate(async (user) => {
  const db = getFirestore();

  // Create user profile
  await db.collection('users').doc(user.uid).set({
    id: user.uid,
    email: user.email,
    displayName: user.displayName || 'Anonymous',
    avatarUrl: user.photoURL,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    preferences: {
      defaultCategory: 'sleep',
      notificationsEnabled: true,
      downloadOverWifiOnly: true,
      defaultVolume: 0.8,
    },
    stats: {
      totalListeningMinutes: 0,
      sessionsCompleted: 0,
      streakDays: 0,
      lastActiveAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    onboardingCompleted: false,
  });

  // Create trial subscription
  await db.collection('subscriptions').doc(user.uid).set({
    id: user.uid,
    userId: user.uid,
    status: 'trial',
    platform: 'ios',
    trialEndsAt: admin.firestore.Timestamp.fromDate(
      new Date(Date.now() + 7 * 24 * 60 * 60 * 1000) // 7 days
    ),
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  console.log(`User profile created for ${user.uid}`);
});

// functions/src/subscriptions/verifyReceipt.ts
import { https } from 'firebase-functions/v2';
import { getFirestore } from 'firebase-admin/firestore';

interface VerifyReceiptRequest {
  receiptData: string;
  productId: string;
}

export const verifyAppleReceipt = https.onCall(async (request) => {
  const { receiptData, productId } = request.data as VerifyReceiptRequest;
  const userId = request.auth?.uid;

  if (!userId) {
    throw new https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  // Verify with Apple
  const verifyUrl = process.env.NODE_ENV === 'production'
    ? 'https://buy.itunes.apple.com/verifyReceipt'
    : 'https://sandbox.itunes.apple.com/verifyReceipt';

  const response = await fetch(verifyUrl, {
    method: 'POST',
    body: JSON.stringify({
      'receipt-data': receiptData,
      password: process.env.APP_STORE_SHARED_SECRET,
      'exclude-old-transactions': true,
    }),
  });

  const result = await response.json();

  if (result.status !== 0) {
    throw new https.HttpsError('invalid-argument', 'Invalid receipt');
  }

  // Extract latest receipt info
  const latestReceipt = result.latest_receipt_info[0];
  const expiresDate = new Date(parseInt(latestReceipt.expires_date_ms));

  // Update subscription in Firestore
  const db = getFirestore();
  await db.collection('subscriptions').doc(userId).set({
    id: userId,
    userId,
    productId,
    status: expiresDate > new Date() ? 'active' : 'expired',
    platform: 'ios',
    originalTransactionId: latestReceipt.original_transaction_id,
    expiresAt: admin.firestore.Timestamp.fromDate(expiresDate),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  }, { merge: true });

  return { success: true, expiresAt: expiresDate.toISOString() };
});

// functions/src/subscriptions/checkExpiry.ts
import { scheduler } from 'firebase-functions/v2';
import { getFirestore } from 'firebase-admin/firestore';
import { getMessaging } from 'firebase-admin/messaging';

export const checkSubscriptionExpiry = scheduler.onSchedule(
  {
    schedule: 'every 1 hours',
    timeZone: 'Europe/Berlin',
  },
  async () => {
    const db = getFirestore();
    const messaging = getMessaging();
    const now = admin.firestore.Timestamp.now();

    // Find expiring subscriptions
    const expiringSnapshot = await db
      .collection('subscriptions')
      .where('status', '==', 'active')
      .where('expiresAt', '<=', now)
      .get();

    const batch = db.batch();

    for (const doc of expiringSnapshot.docs) {
      // Update status to expired
      batch.update(doc.ref, {
        status: 'expired',
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Send expiry notification
      const userDoc = await db.collection('users').doc(doc.id).get();
      const fcmToken = userDoc.data()?.fcmToken;

      if (fcmToken) {
        await messaging.send({
          token: fcmToken,
          notification: {
            title: 'Abo abgelaufen',
            body: 'Dein AWAVE Premium-Abo ist abgelaufen. Erneuere es, um weiter zu geniessen.',
          },
          data: {
            type: 'subscription_expired',
          },
        });
      }
    }

    await batch.commit();
    console.log(`Processed ${expiringSnapshot.size} expired subscriptions`);
  }
);
```

---

## BigQuery Analytics

### Dataset Schema

```sql
-- BigQuery dataset: awave_analytics

-- Table: events
CREATE TABLE awave_analytics.events (
  event_id STRING NOT NULL,
  user_id STRING NOT NULL,
  event_type STRING NOT NULL,
  event_data JSON,
  session_id STRING,
  timestamp TIMESTAMP NOT NULL,
  platform STRING,
  os_version STRING,
  app_version STRING,
  device_model STRING,
  country STRING,
  city STRING
)
PARTITION BY DATE(timestamp)
CLUSTER BY user_id, event_type;

-- Table: sessions
CREATE TABLE awave_analytics.sessions (
  session_id STRING NOT NULL,
  user_id STRING NOT NULL,
  started_at TIMESTAMP NOT NULL,
  ended_at TIMESTAMP,
  duration_seconds INT64,
  sounds ARRAY<STRUCT<sound_id STRING, volume FLOAT64>>,
  category STRING,
  completed BOOL,
  rating INT64
)
PARTITION BY DATE(started_at)
CLUSTER BY user_id, category;

-- Table: user_daily_stats
CREATE TABLE awave_analytics.user_daily_stats (
  date DATE NOT NULL,
  user_id STRING NOT NULL,
  listening_minutes INT64,
  sessions_count INT64,
  sounds_played ARRAY<STRING>,
  categories ARRAY<STRING>
)
PARTITION BY date
CLUSTER BY user_id;
```

### Analytics Queries

```sql
-- Daily active users
SELECT
  DATE(timestamp) as date,
  COUNT(DISTINCT user_id) as dau
FROM awave_analytics.events
WHERE timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY)
GROUP BY date
ORDER BY date DESC;

-- Most popular sounds
SELECT
  sound_id,
  COUNT(*) as play_count,
  COUNT(DISTINCT user_id) as unique_users
FROM awave_analytics.sessions,
UNNEST(sounds) as s
WHERE started_at >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 7 DAY)
GROUP BY sound_id
ORDER BY play_count DESC
LIMIT 20;

-- Retention cohorts
WITH first_seen AS (
  SELECT
    user_id,
    DATE(MIN(timestamp)) as cohort_date
  FROM awave_analytics.events
  GROUP BY user_id
),
user_activity AS (
  SELECT
    user_id,
    DATE(timestamp) as activity_date
  FROM awave_analytics.events
  GROUP BY user_id, DATE(timestamp)
)
SELECT
  f.cohort_date,
  DATE_DIFF(a.activity_date, f.cohort_date, DAY) as days_since_signup,
  COUNT(DISTINCT f.user_id) as users
FROM first_seen f
JOIN user_activity a ON f.user_id = a.user_id
WHERE f.cohort_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
GROUP BY cohort_date, days_since_signup
ORDER BY cohort_date, days_since_signup;
```

---

## Vertex AI Integration

### Recommendation Model

```python
# training/recommendation_model.py
from google.cloud import aiplatform
from google.cloud import bigquery
import tensorflow as tf

def create_recommendation_model():
    """Train a collaborative filtering model for sound recommendations."""

    # Load training data from BigQuery
    client = bigquery.Client()
    query = """
    SELECT
      user_id,
      sound_id,
      COUNT(*) as play_count,
      AVG(rating) as avg_rating
    FROM awave_analytics.sessions,
    UNNEST(sounds) as s
    WHERE started_at >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 90 DAY)
    GROUP BY user_id, sound_id
    """

    df = client.query(query).to_dataframe()

    # Build embedding model
    user_ids = df['user_id'].unique()
    sound_ids = df['sound_id'].unique()

    user_model = tf.keras.Sequential([
        tf.keras.layers.StringLookup(vocabulary=user_ids),
        tf.keras.layers.Embedding(len(user_ids) + 1, 64),
    ])

    sound_model = tf.keras.Sequential([
        tf.keras.layers.StringLookup(vocabulary=sound_ids),
        tf.keras.layers.Embedding(len(sound_ids) + 1, 64),
    ])

    # Train and export
    model = RecommenderModel(user_model, sound_model)
    model.compile(optimizer='adam', loss='mse')

    # Export to Vertex AI
    aiplatform.init(project='awave-prod', location='europe-west4')

    model.save('/tmp/recommendation_model')
    aiplatform.Model.upload(
        display_name='awave-recommender-v1',
        artifact_uri='/tmp/recommendation_model',
        serving_container_image_uri='europe-docker.pkg.dev/vertex-ai/prediction/tf2-cpu.2-12:latest',
    )
```

### iOS Integration

```swift
// Calling Vertex AI endpoint from iOS
class RecommendationService {
    private let endpoint = "https://europe-west4-aiplatform.googleapis.com/v1/projects/awave-prod/locations/europe-west4/endpoints/YOUR_ENDPOINT_ID:predict"

    func getRecommendations(for userId: String) async throws -> [Sound] {
        let token = try await Auth.auth().currentUser?.getIDToken()

        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token ?? "")", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["instances": [["user_id": userId]]]
        request.httpBody = try JSONEncoder().encode(body)

        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(RecommendationResponse.self, from: data)

        return response.predictions.first?.soundIds.compactMap { soundId in
            // Fetch sound details from Firestore
            await soundRepository.getSound(id: soundId)
        } ?? []
    }
}
```

---

## Infrastructure as Code (Terraform)

```hcl
# terraform/main.tf
provider "google" {
  project = "awave-prod"
  region  = "europe-west4"
}

# Cloud Storage bucket for audio files
resource "google_storage_bucket" "audio" {
  name          = "awave-audio-prod"
  location      = "EU"
  storage_class = "STANDARD"

  lifecycle_rule {
    condition {
      age = 365
    }
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
  }

  cors {
    origin          = ["*"]
    method          = ["GET"]
    response_header = ["Content-Type"]
    max_age_seconds = 3600
  }
}

# Cloud CDN for audio delivery
resource "google_compute_backend_bucket" "audio_cdn" {
  name        = "awave-audio-cdn"
  bucket_name = google_storage_bucket.audio.name
  enable_cdn  = true

  cdn_policy {
    cache_mode        = "CACHE_ALL_STATIC"
    default_ttl       = 86400    # 1 day
    max_ttl           = 604800   # 7 days
    serve_while_stale = 86400
  }
}

# Cloud Armor security policy
resource "google_compute_security_policy" "audio_policy" {
  name = "awave-audio-policy"

  rule {
    action   = "allow"
    priority = 1000
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "Allow all traffic"
  }

  rule {
    action   = "deny(403)"
    priority = 2000
    match {
      expr {
        expression = "evaluatePreconfiguredExpr('xss-stable')"
      }
    }
    description = "Block XSS attacks"
  }

  rule {
    action   = "rate_based_ban"
    priority = 3000
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    rate_limit_options {
      conform_action = "allow"
      exceed_action  = "deny(429)"
      rate_limit_threshold {
        count        = 1000
        interval_sec = 60
      }
      ban_duration_sec = 600
    }
    description = "Rate limiting"
  }
}

# BigQuery dataset
resource "google_bigquery_dataset" "analytics" {
  dataset_id    = "awave_analytics"
  friendly_name = "AWAVE Analytics"
  location      = "EU"

  default_table_expiration_ms = 31536000000 # 1 year
}

# Pub/Sub for async processing
resource "google_pubsub_topic" "events" {
  name = "awave-events"
}

resource "google_pubsub_subscription" "events_to_bigquery" {
  name  = "awave-events-to-bigquery"
  topic = google_pubsub_topic.events.name

  bigquery_config {
    table = "${google_bigquery_dataset.analytics.project}:${google_bigquery_dataset.analytics.dataset_id}.events"
  }
}
```

---

## Cost Optimization

| Service | Estimated Monthly Cost | Optimization |
|---------|----------------------|--------------|
| Firestore | $50-200 | Composite indexes, read-through cache |
| Cloud Storage | $20-50 | CDN caching, lifecycle policies |
| Cloud Functions | $10-30 | Cold start optimization, minimal memory |
| Cloud CDN | $10-50 | High cache hit ratio (>95%) |
| BigQuery | $20-100 | Partitioning, clustering, slot reservations |
| Vertex AI | $50-200 | Batch predictions, model optimization |
| **Total** | **$160-630/month** | |

### Free Tier Coverage
- Firestore: 1GB storage, 50K reads/day, 20K writes/day
- Cloud Functions: 2M invocations/month
- Cloud Storage: 5GB storage
- BigQuery: 10GB storage, 1TB queries/month
