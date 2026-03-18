# Authentication System - Technical Specification (Swift / Firebase)

**Implementation:** Native iOS (Swift 6.2, SwiftUI, iOS 26.2). Backend: **Firebase Auth** and **Firestore**. No Supabase. This document describes the current iOS implementation; Android will use Firebase Auth with Google Sign-In Android SDK (Apple Sign-In is iOS-only).

---

## Architecture Overview

### Technology Stack

- **Firebase Auth** — Email/password, Apple Sign-In, Google Sign-In; session management; token refresh. Email verification and password reset are supported by the backend; some UI flows (e.g. forgot password) may be pending.
- **Apple Sign-In** — AuthenticationServices (native) + Firebase Auth Apple provider. Implemented via `AppleSignInHelper`; nonce, credential exchange, profile creation in Firestore.
- **Google Sign-In** — Google Sign-In SDK + Firebase Auth Google provider. Implemented via `GoogleSignInService`; presenting UI, ID token + access token, credential exchange; URL callback via `handleURL`.
- **State** — SwiftUI, `@Observable` (AuthViewModel). RootView listens to Firebase Auth state and drives navigation (signed-in vs signed-out).
- **Storage** — User data and profile in Firestore; tokens managed by Firebase Auth SDK.

### Key Components

| Component | Location | Role |
|-----------|----------|------|
| AuthView | AWAVE/Features/Auth/AuthView.swift | Main auth screen: login/signup toggle, email/password form, Apple button, Google button |
| AuthViewModel | AWAVE/Features/Auth/AuthViewModel.swift | Sign in/up with email, `signInWithApple()`, `signInWithGoogle()`; loading/error state; user-facing error messages |
| AppleSignInHelper | AWAVE/Features/Auth/Utilities/AppleSignInHelper.swift | Starts Sign in with Apple; nonce generation; ASAuthorizationController delegate; returns idToken + nonce for Firebase |
| GoogleSignInService | AWAVEData/Sources/AWAVEData/Auth/GoogleSignInService.swift | `signIn()` async: present Google UI, get idToken + accessToken, create Firebase credential, `Auth.auth().signIn(with: credential)`; static `handleURL(_:)` for callback |
| AuthService | AWAVEData/Sources/AWAVEData/Auth/AuthService.swift | Firebase Auth wrapper: signUp, signIn, signInWithApple(idToken:rawNonce:fullName:), signInWithGoogle (if used), signOut; session lifecycle |
| AuthServiceProtocol | AWAVEData/Sources/AWAVEData/Auth/AuthServiceProtocol.swift | Protocol for auth operations (testability) |
| FirestoreUserRepository | AWAVEData | Creates/updates user profile in Firestore after sign-in (e.g. on Apple/Google success); used by RootView auth listener |

---

## File Structure (Swift)

```
AWAVE/
├── AWAVE/
│   ├── Features/
│   │   └── Auth/
│   │       ├── AuthView.swift           # Main auth UI (login/signup, Apple + Google buttons)
│   │       ├── AuthViewModel.swift      # Auth actions, state, error handling
│   │       ├── MailClientOption.swift   # Mail client preference (if used)
│   │       └── Utilities/
│   │           └── AppleSignInHelper.swift  # Apple Sign-In flow, nonce, delegate
│   └── Navigation/
│       └── RootView.swift               # Auth state listener; shows AuthView or main app
AWAVE/Packages/AWAVEData/
└── Sources/AWAVEData/
    └── Auth/
        ├── AuthService.swift            # Firebase Auth: signUp, signIn, signInWithApple, signOut
        ├── AuthServiceProtocol.swift
        └── GoogleSignInService.swift    # Google Sign-In UI + Firebase credential
```

Profile surfaces (e.g. ProfileAuthCard) also offer Apple and Google sign-in using the same AuthViewModel and flows.

---

## Apple Sign-In Flow

1. **Entry:** User taps "Mit Apple anmelden" in AuthView or ProfileAuthCard → `AuthViewModel.signInWithApple()`.
2. **AppleSignInHelper.signIn()** — Generates nonce, creates `ASAuthorizationAppleIDRequest` (scopes: fullName, email), sets nonce (SHA256), presents `ASAuthorizationController`.
3. **Delegate** — On success, receives `ASAuthorizationCredential`; reads `identityToken` (JWT) and `authorizationCode`; maps to `AppleSignInResult` (idToken, nonce, fullName). On cancel, resumes with cancellation error (no user-facing error).
4. **AuthViewModel** — Calls `authService.signInWithApple(idToken:rawNonce:fullName:)` which creates `OAuthProvider.credential(withProviderID:idToken:rawNonce:accessToken:)` and `Auth.auth().signIn(with: credential)`.
5. **After sign-in** — Firebase Auth state change; RootView auth listener runs; FirestoreUserRepository creates/updates user document in Firestore. User sees main app.

---

## Google Sign-In Flow

1. **Entry:** User taps "Mit Google anmelden" in AuthView or ProfileAuthCard → `AuthViewModel.signInWithGoogle()`.
2. **GoogleSignInService.signIn()** — Uses `FirebaseApp.app()?.options.clientID` for `GIDConfiguration`; gets root view controller from window scene; calls `GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)`.
3. **Result** — Receives `GIDSignInResult` with `user`; reads `user.idToken?.tokenString` and `user.accessToken.tokenString`; builds `GoogleAuthProvider.credential(withIDToken:accessToken:)`; calls `Auth.auth().signIn(with: credential)`.
4. **Callback URL** — App must call `GoogleSignInService.handleURL(_:)` from `SceneDelegate` or `AppDelegate` `open url` so Google SDK can complete the flow.
5. **After sign-in** — Same as Apple: Firebase Auth state change, RootView, FirestoreUserRepository profile create/update, main app.

---

## Email/Password Flow

- **Sign up:** AuthView signup mode → AuthViewModel calls `authService.signUp(email:password:)` (Firebase `createUser`). On success, auth state updates; optional onboarding/category selection.
- **Sign in:** AuthView login mode → `authService.signIn(email:password:)` (Firebase `signIn`). Session and token refresh handled by Firebase Auth.

---

## Error Handling

- **AuthViewModel** maps errors to user-facing strings (German/English): Firebase errors, GoogleSignInServiceError, Apple cancellation. Apple cancel and Google cancel are treated as idle (no error alert).
- **GoogleSignInService** throws: `missingClientID`, `missingRootViewController`, `missingIDToken` when configuration or result is invalid.

---

## Android Note

- **Google Sign-In:** Use Firebase Auth with Google Sign-In Android SDK (Play Services). Same Firebase project; Android OAuth client ID in Firebase Console.
- **Apple Sign-In:** Not applicable on Android; only email/password and Google need to be implemented for parity on Android.

---

*Legacy: An earlier version of this document described a React/TypeScript + Supabase stack. That stack is obsolete; the current iOS app and this spec use Swift and Firebase only.*
