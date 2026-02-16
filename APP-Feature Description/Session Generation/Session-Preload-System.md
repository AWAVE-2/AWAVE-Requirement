# Session Preload System

**Date:** 2026-02-02
**Feature:** Automatic pre-generation of category sessions on first app launch

---

## Overview

The Session Preload System automatically generates sessions for all onboarding categories (Sleep, Stress, Flow) when the app launches for the first time. This eliminates wait time when users first explore category screens and provides a smoother user experience.

---

## How It Works

### 1. First App Launch

When the app launches for the first time, `SessionPreloadService` is triggered in `AppDelegate.didFinishLaunchingWithOptions()`:

```swift
private func preloadCategorySessions() {
    Task { @MainActor in
        let deps = DependencyContainer.shared
        await SessionPreloadService.shared.preloadSessionsIfNeeded(
            sessionRepository: deps.sessionRepository,
            authService: deps.authService
        )
    }
}
```

### 2. Session Generation

The preload service:
- Checks if sessions have already been preloaded (via UserDefaults)
- If not, generates 5 sessions for each category using `CategorySessionGenerator`
- Saves sessions to Firestore if the user is authenticated
- Marks preload as complete to prevent duplicate generation

### 3. Displaying Preloaded Sessions

When users navigate to a category screen (`CategorySessionsView`):
- `CategorySessionsViewModel.loadSessions()` fetches sessions from Firestore
- If sessions exist (preloaded), they are displayed immediately
- If no sessions exist, new ones are generated on demand

---

## Components

### SessionPreloadService

**Location:** `AWAVE/AWAVE/Services/SessionPreloadService.swift`

**Responsibilities:**
- Track preload state using UserDefaults
- Generate sessions for all categories
- Save sessions to Firestore (if authenticated)
- Provide reset functionality for testing

**Key Methods:**
- `preloadSessionsIfNeeded()` - Main preload logic
- `hasPreloaded` - Check if preload completed
- `resetPreloadState()` - Reset for testing

### CategorySessionGenerator

**Location:** `AWAVE/AWAVE/Services/CategorySessionGenerator.swift`

**Responsibilities:**
- Generate 5 varied sessions per category
- Rotate through all available voices
- Use seeded random generation for variety

### Integration Points

1. **AppDelegate** - Triggers preload on first launch
2. **CategorySessionsViewModel** - Loads preloaded sessions
3. **FirestoreSessionRepository** - Stores/retrieves sessions

---

## Data Flow

```
App Launch (First Time)
    ↓
AppDelegate.didFinishLaunchingWithOptions()
    ↓
SessionPreloadService.preloadSessionsIfNeeded()
    ↓
For each category (Sleep, Stress, Flow):
    ↓
CategorySessionGenerator.generateSessions()
    ↓
SessionRepository.saveCategorySessions() [if authenticated]
    ↓
Mark as preloaded in UserDefaults
```

```
User Navigates to Category Screen
    ↓
CategorySessionsViewModel.loadSessions()
    ↓
SessionRepository.fetchCategorySessions()
    ↓
Display preloaded sessions (or generate if empty)
```

---

## Session Structure

Each category gets **5 sessions**, each containing:
- Unique voice (rotating through Franca, Markus, Helene)
- Multiple phases (varies by topic)
- Randomized fantasy journeys
- Varied durations and frequencies

**Example for Sleep category:**
1. Session 1: Voice = Franca
2. Session 2: Voice = Markus
3. Session 3: Voice = Helene
4. Session 4: Voice = Franca
5. Session 5: Voice = Markus

---

## Authentication Handling

### Authenticated Users
- Sessions are generated and saved to Firestore
- Available across devices (synced via Firestore)
- Persist after app reinstall

### Unauthenticated Users
- Sessions are generated locally
- Not saved to Firestore
- Available only on current device
- Lost after app reinstall

---

## Storage

### UserDefaults
- Key: `hasPreloadedCategorySessions`
- Value: Boolean indicating if preload completed
- Used to prevent duplicate preload attempts

### Firestore Structure
```
users/{userId}/categorySessions/{category}/sessions/{sessionId}
```

**Example:**
```
users/abc123/categorySessions/schlafen/sessions/session-1
users/abc123/categorySessions/stress/sessions/session-1
users/abc123/categorySessions/leichtigkeit/sessions/session-1
```

---

## Testing

### Unit Tests

**Location:** `AWAVE/Tests/Services/SessionPreloadServiceTests.swift`

**Tests:**
- `testPreloadSessionsGeneratesAllCategories()` - Verifies all categories get sessions
- `testPreloadSessionsOnlyRunsOnce()` - Ensures idempotency
- `testPreloadSessionsWorksWhenNotAuthenticated()` - Tests offline scenario
- `testResetPreloadState()` - Verifies reset functionality

### Manual Testing

1. **Reset preload state:**
   ```swift
   SessionPreloadService.shared.resetPreloadState()
   ```

2. **Restart app** - Sessions should be generated on launch

3. **Navigate to category screens** - Sessions should load immediately

4. **Check Firestore** - Verify sessions are saved under correct paths

---

## Performance Considerations

### Background Execution
- Preload runs asynchronously using `Task`
- Does not block app startup
- User can interact with app while sessions generate

### Network Optimization
- Uses batch writes to Firestore (all sessions saved at once)
- Only runs once per app installation
- Gracefully handles network errors

### Generation Time
- Approximately 50-100ms per category
- Total preload time: ~150-300ms
- Negligible impact on app launch performance

---

## Troubleshooting

### Sessions Not Appearing

**Check:**
1. Preload state: `SessionPreloadService.shared.hasPreloaded`
2. Firestore data: Verify sessions exist in database
3. Authentication: User must be authenticated for Firestore sync
4. Network: Check network connectivity

**Solution:**
```swift
// Reset and retry
SessionPreloadService.shared.resetPreloadState()
// Restart app
```

### Duplicate Sessions

**Cause:** Preload ran multiple times

**Solution:**
```swift
// Delete existing sessions
await sessionRepository.deleteCategorySessions(
    userId: userId,
    category: "schlafen"
)
// Reset and retry
SessionPreloadService.shared.resetPreloadState()
```

---

## Future Enhancements

### Potential Improvements

1. **Progress Indicator** - Show preload progress during first launch
2. **Background Refresh** - Periodically regenerate sessions for variety
3. **Customization** - Allow users to customize session count/preferences
4. **Analytics** - Track preload success rate and timing
5. **Offline Cache** - Store generated sessions locally for offline access

### Maintenance

- Monitor Firestore storage usage
- Update session generation logic as needed
- Adjust session count based on user feedback
- Optimize batch write performance

---

## Related Documentation

- [Old App Feature Gap Analysis](./Old-App-Feature-Gap-Analysis.md)
- [Session Generator Implementation](../AWAVE/Services/SessionGenerator.swift)
- [Category Session Generator](../AWAVE/Services/CategorySessionGenerator.swift)
- [Firestore Session Repository](../Packages/AWAVEData/Sources/AWAVEData/Repositories/FirestoreSessionRepository.swift)
