# Analytics Event Catalog (Firebase Analytics)

All events are logged via **AnalyticsService.shared.log(_:)** and are **gated by AnalyticsConsentService.hasAnalyticsConsent**. If the user has not granted consent, events are dropped silently. Consent is collected during onboarding (AnalyticsConsentToastView) and can be stored in Firestore for logged-in users.

---

## Event list (AnalyticsService.Event)

| Event | Parameters | When logged |
|-------|------------|-------------|
| **screenView** | screen: Screen (home, schlaf, ruhe, imFluss, player, klangwelten, search, profile, onboarding) | On appear of the corresponding screen |
| **sessionStarted** | mode: String, category: String | When playback starts (guided session, Klangwelten, or single sound) |
| **sessionCompleted** | mode, category, durationSeconds: Int | When session ends normally |
| **sessionAbandoned** | mode, category, durationSeconds | When user abandons session before end |
| **sessionResumed** | mode, category | When user resumes (e.g. Weiterhören) |
| **favoriteAdded** | itemType: String, category: String | When user adds a favorite (e.g. session) |
| **favoriteRemoved** | itemType, category | When user removes a favorite |
| **mixSaved** | mode: String, trackCount: Int | When user saves a mix |
| **searchPerformed** | query: String, resultsCount: Int | When user performs a search |
| **sosTriggered** | query: String | When SOS path is triggered from search |
| **trialStarted** | plan: String | When trial starts |
| **purchaseCompleted** | plan: String | When purchase completes |
| **purchaseFailed** | plan, error: String | When purchase fails |
| **subscriptionCancelled** | — | When user cancels subscription |
| **downloadStarted** | soundId: String | When a download starts |
| **downloadCompleted** | soundId | When a download completes |
| **downloadFailed** | soundId, error: String | When a download fails |
| **onboardingCompleted** | category: String | When user completes onboarding (category chosen) |

---

## Consent

- **AnalyticsConsentService** — Stores opt-in in UserDefaults; key `awaveAnalyticsConsent`. Default is false (opt-in). When set, calls **Analytics.setAnalyticsCollectionEnabled(_:)** so Firebase respects the choice.
- **Where consent is collected** — During onboarding (AnalyticsConsentToastView with Ja/Nein). For signed-in users, the choice can be written to Firestore so it can be synced across devices or used by backend.

---

## Implementation

- **AnalyticsService** — AWAVE/AWAVE/Services/AnalyticsService.swift. Singleton; `log(_ event: Event)` checks `AnalyticsConsentService.shared.hasAnalyticsConsent` and, if true, maps the event to a Firebase event name and parameters and calls `Analytics.logEvent(name, parameters:)`.
- **AnalyticsConsentService** — AWAVE/AWAVE/Services/AnalyticsConsentService.swift.

For Android parity, implement the same event set and consent gate (e.g. Firebase Analytics + local/synced consent flag).
