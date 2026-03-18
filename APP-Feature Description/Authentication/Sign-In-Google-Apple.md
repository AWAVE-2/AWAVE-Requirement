# Sign-In with Google and Apple (iOS)

Short reference for the implemented OAuth flows. For full technical detail see [technical-spec.md](technical-spec.md).

---

## Entry points

- **AuthView** — Dedicated auth screen (login/signup) with "Mit Apple anmelden" and "Mit Google anmelden" buttons. Used when the user is not signed in and opens auth from onboarding or profile.
- **ProfileAuthCard** — Compact auth card on the Profile screen with the same Apple and Google buttons. Used when the user is not signed in and taps to sign in from Profile.

Both call **AuthViewModel.signInWithApple()** or **AuthViewModel.signInWithGoogle()**.

---

## Google Sign-In

1. User taps "Mit Google anmelden" → **AuthViewModel.signInWithGoogle()**.
2. **GoogleSignInService.signIn()** — Uses Firebase `clientID` for `GIDConfiguration`; gets root view controller; calls `GIDSignIn.sharedInstance.signIn(withPresenting:)`. Google SDK presents its UI.
3. On success: `user.idToken` + `user.accessToken` → **GoogleAuthProvider.credential(withIDToken:accessToken:)** → **Auth.auth().signIn(with: credential)**.
4. **URL callback:** App must call **GoogleSignInService.handleURL(_:)** from SceneDelegate/AppDelegate `open url` so the Google SDK can complete the flow.
5. After sign-in: Firebase Auth state change → RootView listener → **FirestoreUserRepository** creates/updates user document → user sees main app.

**Errors:** GoogleSignInService throws `missingClientID`, `missingRootViewController`, `missingIDToken`; AuthViewModel maps these and Firebase errors to user-facing messages. User cancel is treated as idle (no error).

**Android:** Use Firebase Auth with Google Sign-In Android SDK (same Firebase project; add Android OAuth client in Firebase Console).

---

## Apple Sign-In

1. User taps "Mit Apple anmelden" → **AuthViewModel.signInWithApple()**.
2. **AppleSignInHelper.signIn()** — Generates nonce; creates **ASAuthorizationAppleIDRequest** (scopes: fullName, email); sets nonce (SHA256); presents **ASAuthorizationController**.
3. **Delegate** — On success: `identityToken` (JWT) + nonce + fullName → **AppleSignInResult**. On cancel: resume with cancellation error (no alert).
4. **AuthViewModel** — Calls **authService.signInWithApple(idToken:rawNonce:fullName:)** → **OAuthProvider.credential(withProviderID:idToken:rawNonce:accessToken:)** → **Auth.auth().signIn(with: credential)**.
5. After sign-in: same as Google (Firebase state, RootView, FirestoreUserRepository, main app).

**Android:** Apple Sign-In is not available on Android; only Google and email/password apply for Android parity.

---

## Profile creation

After any OAuth success, **FirestoreUserRepository** creates or updates the user document in Firestore (e.g. `users/{uid}`) so profile and subscription logic can use the same user record. Triggered by the auth state listener in RootView.

---

## Error and cancellation handling

- **Apple cancel** — ASAuthorizationError.canceled or NSError 1001 in Apple domain → AuthViewModel sets state to idle; no error message.
- **Google cancel** — User dismisses Google UI without signing in → treated as idle.
- **Network / credential errors** — AuthViewModel maps to localized strings (DE/EN) and sets state to `.error(message)`.
