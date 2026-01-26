# Account Settings - User Flows

## 🔄 Primary User Flows

### 1. Email Update Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Navigate to Account Settings
   └─> Display Account Settings Screen
       └─> Show current email (read-only)
           └─> Show new email input field

2. Enter New Email
   └─> Validate email format in real-time
       ├─> Invalid format → Disable update button
       └─> Valid format → Enable update button

3. Click "E-Mail aktualisieren"
   └─> Show confirmation dialog
       ├─> User cancels → Return to form
       └─> User confirms → Continue
           └─> Show loading state
               └─> Call updateEmail API
                   ├─> Error → Show error toast
                   └─> Success → Continue
                       └─> Show success toast
                           └─> Update current email display
                               └─> Clear new email input
```

**Success Path:**
- Valid email entered
- Confirmation confirmed
- Email updated successfully
- Success feedback shown

**Error Paths:**
- Invalid email format → Button disabled
- Network error → Error toast shown
- Update failure → Error toast shown

---

### 2. Password Change Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Navigate to Account Settings
   └─> Display Security Section
       └─> Show password input field

2. Enter New Password
   └─> Validate password length in real-time
       ├─> < 10 characters → Disable update button
       └─> >= 10 characters → Enable update button

3. Toggle Password Visibility (Optional)
   └─> Toggle showPassword state
       └─> Update input secureTextEntry prop

4. Click "Passwort aktualisieren"
   └─> Validate password
       ├─> Invalid → Button disabled (cannot proceed)
       └─> Valid → Continue
           └─> Show loading state
               └─> Call updatePassword API
                   ├─> Error → Show error toast
                   └─> Success → Continue
                       └─> Show success toast
                           └─> Clear password input
```

**Success Path:**
- Valid password entered (>= 10 chars)
- Password updated successfully
- Success feedback shown

**Error Paths:**
- Weak password (< 10 chars) → Button disabled
- Network error → Error toast shown
- Update failure → Error toast shown

---

### 3. Biometric Login Toggle Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Navigate to Account Settings
   └─> Display Security Section
       └─> Show biometric toggle switch

2. Toggle Biometric Switch
   └─> Update local state immediately
       └─> Show info toast
           ├─> Enabled → "Biometrische Anmeldung aktiviert"
           └─> Disabled → "Biometrische Anmeldung deaktiviert"
```

**Success Path:**
- Toggle switched
- Immediate feedback via toast
- State updated

**Note:** Backend sync handled separately if needed

---

### 4. Push Notifications Toggle Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Navigate to Account Settings
   └─> Display Security Section
       └─> Show push notifications toggle switch

2. Toggle Push Notifications Switch
   └─> Update local state immediately
       └─> Sync with backend (if implemented)
           └─> State persists
```

**Success Path:**
- Toggle switched
- State updated
- Backend synced (if applicable)

---

### 5. Developer Settings Flow (Dev Only)

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Navigate to Account Settings (Dev Mode)
   └─> Display Developer Settings Section
       └─> Show paywall bypass toggle

2. Toggle Paywall Bypass
   └─> Update AsyncStorage
       └─> Update app-wide state
           └─> Paywall bypassed app-wide
```

**Success Path:**
- Toggle switched
- State persisted in AsyncStorage
- App-wide paywall bypassed

---

## 🔀 Alternative Flows

### Email Update with Cancellation

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Enter New Email
   └─> Email validated

2. Click "E-Mail aktualisieren"
   └─> Show confirmation dialog

3. Click "Abbrechen"
   └─> Close dialog
       └─> Return to form
           └─> Email input preserved
```

---

### Password Visibility Toggle

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Enter Password
   └─> Password hidden (secureTextEntry)

2. Click Eye Icon
   └─> Toggle showPassword state
       └─> Password visible

3. Click Eye-Off Icon
   └─> Toggle showPassword state
       └─> Password hidden
```

---

## 🚨 Error Flows

### Network Error Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Attempt Email/Password Update
   └─> Network request fails
       └─> Show error toast
           └─> "E-Mail konnte nicht aktualisiert werden."
               └─> Form state preserved
                   └─> User can retry
```

---

### Validation Error Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Enter Invalid Email
   └─> Real-time validation
       └─> Email format invalid
           └─> Update button disabled
               └─> User must correct email

2. Enter Weak Password
   └─> Real-time validation
       └─> Password < 10 characters
           └─> Update button disabled
               └─> User must enter longer password
```

---

## 🔄 State Transitions

### Email Update States

```
No Input → Valid Email → Confirming → Updating → Success
    │           │            │            │          │
    │           │            │            │          └─> Clear Form
    │           │            │            └─> Error → Show Error
    │           │            └─> Cancel → Return to Form
    │           └─> Invalid → Disable Button
    └─> Invalid Format → Disable Button
```

### Password Update States

```
No Input → Valid Password → Updating → Success
    │            │              │          │
    │            │              │          └─> Clear Form
    │            │              └─> Error → Show Error
    │            └─> Invalid → Disable Button
    └─> < 10 chars → Disable Button
```

### Toggle States

```
Off → Toggling → On
 │        │        │
 │        │        └─> Toast Feedback
 │        └─> Error → Revert State
 └─> On → Toggling → Off
```

---

## 📊 Flow Diagrams

### Complete Email Update Journey

```
Profile Screen
    │
    └─> Account → Kontoeinstellungen
        └─> Account Settings Screen
            └─> Enter New Email
                └─> Validate Email
                    └─> Click Update
                        └─> Confirm Dialog
                            ├─> Cancel → Return
                            └─> Confirm → Update
                                └─> Success Toast
                                    └─> Email Updated
```

### Complete Password Change Journey

```
Profile Screen
    │
    └─> Account → Kontoeinstellungen
        └─> Account Settings Screen
            └─> Security Section
                └─> Enter New Password
                    └─> Validate Password
                        └─> Toggle Visibility (Optional)
                            └─> Click Update
                                └─> Update Password
                                    └─> Success Toast
                                        └─> Password Updated
```

---

## 🎯 User Goals

### Goal: Update Email Address
- **Path:** Account Settings → Enter Email → Confirm → Update
- **Time:** ~30 seconds
- **Steps:** 4-5 taps

### Goal: Change Password
- **Path:** Account Settings → Enter Password → Update
- **Time:** ~20 seconds
- **Steps:** 3-4 taps

### Goal: Enable Biometric Login
- **Path:** Account Settings → Toggle Switch
- **Time:** < 5 seconds
- **Steps:** 1 tap

---

*For component interactions, see `components.md`*  
*For service calls, see `services.md`*  
*For technical details, see `technical-spec.md`*
