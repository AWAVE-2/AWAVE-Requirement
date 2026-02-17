# Navigation System - User Flows

## 🔄 Primary User Flows

### 1. App Launch Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. App Launches
   └─> IndexScreen Renders
       └─> Preloader Component Shows
           └─> Animation Plays (3s)

2. Preloader Completes
   └─> onboardingStorage.loadOnboardingState()
       ├─> Onboarding Completed → Continue
       │   └─> navigation.navigate('MainTabs')
       │       └─> TabNavigator Loads
       │           └─> Initial Tab Determined
       │               ├─> From route params (if provided)
       │               ├─> From onboarding storage
       │               └─> Default to 'schlafen'
       │
       ├─> Profile Exists, Onboarding Incomplete → Continue
       │   └─> navigation.navigate('OnboardingSlides', { startAtSlide: 4 })
       │       └─> Show Questionnaire Only (Slide 5)
       │
       └─> First Time User → Continue
           └─> navigation.navigate('OnboardingSlides')
               └─> Show Full Onboarding (Slides 1-6)
```

**Success Path:**
- Onboarding completed → Navigate to MainTabs
- Profile exists → Show questionnaire only
- First time → Show full onboarding

**Edge Cases:**
- Storage read failure → Default to onboarding
- Invalid state → Default to onboarding
- App update → State migration

---

### 2. Onboarding Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Navigate to OnboardingSlides
   └─> Display Slide 1
       └─> Show Navigation Controls

2. Swipe Through Slides (1-4)
   └─> Update Slide Index
       └─> Show Next/Previous Buttons

3. Reach Slide 5 (Questionnaire)
   └─> Display Category Selection
       └─> User Selects Category
           └─> Save Selection to Storage
               └─> onboardingStorage.saveSelectedCategory(categoryId)

4. Complete Slide 6 (Final)
   └─> Mark Onboarding Complete
       └─> Save Profile Data
           └─> navigation.navigate('MainTabs', { initialTab: selectedCategory })
               └─> TabNavigator Opens with Selected Tab
```

**Success Path:**
- Complete all slides
- Select category
- Navigate to MainTabs with selected tab

**Alternative Paths:**
- Skip onboarding → Navigate to MainTabs
- Partial completion → Resume from last slide
- Category selection → Preserved in navigation

---

### 3. Tab Navigation Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User on MainTabs Screen
   └─> CustomNavbar Displays
       └─> Shows 5 Tabs:
           ├─> Category Tabs (3): schlafen, stress, leichtigkeit
           └─> Utility Tabs (2): search, profile

2. User Presses Category Tab (e.g., "Stress")
   └─> handleTabPress('stress')
       ├─> Update CategoryContext
       │   └─> handleCategorySelect('stress')
       └─> Update TabNavigator State
           └─> setActiveTab('stress')
               └─> renderActiveScreen()
                   └─> Render RuheScreen
                       └─> Tab Visual Update
                           └─> Active Tab Highlighted

3. User Presses Another Category Tab
   └─> Same Flow as Step 2
       └─> Previous Screen Unmounts
           └─> New Screen Renders
```

**Success Path:**
- Tab press → Screen switch
- Active tab highlighted
- Smooth transition

**State Management:**
- Tab state persists during modal open
- Last active tab tracked before search
- Tab state recovered on app restart

---

### 4. Search Drawer Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User Presses Search Tab
   └─> handleSearchPress()
       ├─> Save Current Active Tab
       │   └─> setLastActiveTabBeforeSearch(activeTab)
       └─> Open SearchDrawer
           └─> setSearchDrawerOpen(true)
               └─> SearchDrawer Renders (Bottom Sheet)
                   └─> User Can Search Sounds

2. User Selects Sound
   └─> handleSoundSelect(sound)
       ├─> Close SearchDrawer
       │   └─> setSearchDrawerOpen(false)
       └─> Open Audio Player
           └─> Sound Plays

3. User Closes SearchDrawer (X Button)
   └─> handleReturnToLastTab()
       ├─> Restore Last Active Tab
       │   └─> setActiveTab(lastActiveTabBeforeSearch)
       └─> Close SearchDrawer
           └─> setSearchDrawerOpen(false)
               └─> Return to Previous Screen
```

**Success Path:**
- Search tab → Drawer opens
- Sound selection → Player opens
- Close → Return to last tab

**Alternative Paths:**
- SOS triggered → SOSDrawer overlays SearchDrawer
- No last tab → Return to default tab
- Drawer closed → Tab state restored

---

### 5. SOS Drawer Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User in SearchDrawer
   └─> Triggers SOS (via SearchDrawer)
       └─> handleSOSTriggered(config)
           ├─> Save SOS Config
           │   └─> setSOSConfig(config)
           ├─> Close SearchDrawer Temporarily
           │   └─> setSearchDrawerOpen(false)
           └─> Open SOSDrawer
               └─> setSOSDrawerOpen(true)
                   └─> SOSDrawer Renders (Full Height)
                       └─> Shows Emergency Resources

2. User Closes SOSDrawer
   └─> handleSOSClose()
       ├─> Close SOSDrawer
       │   └─> setSOSDrawerOpen(false)
       ├─> Clear SOS Config
       │   └─> setSOSConfig(null)
       └─> Reopen SearchDrawer
           └─> setTimeout(() => setSearchDrawerOpen(true), 100)
               └─> Smooth Transition Back
```

**Success Path:**
- SOS triggered → SOSDrawer opens
- Close → Return to SearchDrawer
- Smooth transition

**State Management:**
- SearchDrawer state preserved
- SOS config passed as parameter
- Smooth transitions between drawers

---

### 6. Library Modal Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User Presses Library Tab (if available)
   └─> handleLibraryPress()
       └─> setLibraryModalOpen(true)
           └─> Modal Renders
               ├─> iOS: formSheet presentation
               └─> Android: Slide up animation
                   └─> LibraryScreen Displays

2. User Browses Library
   └─> Library Content Loads
       └─> User Can Select Sounds

3. User Closes Library Modal
   └─> onClose() Called
       └─> setLibraryModalOpen(false)
           └─> Modal Closes
               └─> Return to Tab Screen
```

**Success Path:**
- Library tab → Modal opens
- Browse library
- Close → Return to tabs

**Platform Differences:**
- iOS: formSheet presentation (half screen)
- Android: Full screen modal

---

### 7. Stack Navigation Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User on MainTabs Screen
   └─> Navigates to Profile Tab
       └─> ProfileScreen Renders

2. User Clicks "Account Settings"
   └─> navigation.navigate('AccountSettings')
       └─> AccountSettingsScreen Pushes onto Stack
           └─> Back Button Available
               └─> UnifiedHeader Shows (Back Variant)

3. User Clicks Back Button
   └─> navigation.goBack()
       └─> AccountSettingsScreen Pops from Stack
           └─> ProfileScreen Renders Again

4. User Swipes Back (iOS/Android Gesture)
   └─> Same as Step 3
       └─> Gesture Navigation Works
```

**Success Path:**
- Navigate forward → Screen pushes
- Navigate back → Screen pops
- Gesture navigation works

**Stack Management:**
- Navigation stack maintained by SwiftUI NavigationStack (iOS); Android should match behaviour
- Back button works on all stack screens
- Gesture navigation enabled

---

### 8. Deep Link Flow - Email Verification

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User Clicks Verification Link in Email
   └─> App Opens (if not running) or Receives Link
       └─> Linking.getInitialURL() or Linking.addEventListener('url')
           └─> URL: awave://email-verification?access_token=...&refresh_token=...

2. EmailVerificationScreen Handles Link
   └─> Parse URL
       ├─> Extract access_token from hash (#) or query (?)
       └─> Extract refresh_token from hash (#) or query (?)
           └─> Check if tokens exist
               ├─> No tokens → Show error
               └─> Tokens exist → Continue
                   └─> setVerificationStatus('verifying')
                       └─> ProductionBackendService.setAuthSession(accessToken, refreshToken)
                           ├─> Error → Show error status
                           └─> Success → Continue
                               └─> setVerificationStatus('success')
                                   └─> setTimeout(() => navigateToStart(), 2000)
                                       └─> navigation.navigate('MainTabs')
```

**Success Path:**
- Link clicked → App opens
- Tokens extracted → Session created
- Navigate to MainTabs

**Error Paths:**
- Invalid tokens → Show error
- Expired tokens → Show error
- Malformed URL → Show error

---

### 9. Deep Link Flow - Password Reset

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User Clicks Reset Link in Email
   └─> App Opens or Receives Link
       └─> URL: awave://password-reset?access_token=...&refresh_token=...

2. ResetPasswordScreen Handles Link
   └─> Parse URL (same as email verification)
       └─> Extract tokens
           └─> Create session
               └─> Display Password Reset Form
                   └─> User Enters New Password
                       └─> Password Strength Validated
                           └─> Update Password
                               └─> Success → Navigate to MainTabs
```

**Success Path:**
- Link clicked → App opens
- Tokens extracted → Session created
- Password reset → Navigate to MainTabs

**Error Paths:**
- Expired link → Show error, offer new request
- Invalid tokens → Show error
- Weak password → Show requirements

---

### 10. Authentication Flow Navigation

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User Needs Authentication
   └─> Navigate to Auth Screen
       └─> navigation.navigate('Auth')
           └─> AuthScreen Renders
               └─> User Can Sign In/Sign Up

2. User Completes Sign Up
   └─> Account Created
       └─> navigation.navigate('EmailVerification')
           └─> EmailVerificationScreen Renders
               └─> User Verifies Email
                   └─> Deep Link Flow (see Flow 8)
                       └─> Navigate to MainTabs

3. User Completes Sign In
   └─> Credentials Validated
       └─> Session Created
           └─> Check Registration Cache
               ├─> Cache exists → Resume to cached selection
               └─> No cache → Navigate to MainTabs
```

**Success Path:**
- Sign up → Email verification → MainTabs
- Sign in → MainTabs (or cached selection)

**Alternative Paths:**
- OAuth sign in → Direct to MainTabs
- Registration cache → Resume to selection

---

## 🔀 Alternative Flows

### Tab State Recovery Flow

```
System Event                   System Response
─────────────────────────────────────────────────────────
1. App Restarts
   └─> TabNavigator Mounts
       └─> getInitialTab() Called
           ├─> Check route params
           │   └─> If initialTab prop exists → Use it
           └─> Check onboarding storage
               └─> onboardingStorage.getSelectedCategory()
                   ├─> Valid category → Use it
                   └─> No category → Default to 'schlafen'
                       └─> setActiveTab(initialTab)
                           └─> Render Appropriate Screen
```

**Recovery Logic:**
- Route params (highest priority)
- Onboarding storage
- Default fallback

---

### Route Protection Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User Attempts to Access Protected Route
   └─> Screen Component Mounts
       └─> Check Authentication State
           ├─> Authenticated → Render Screen
           └─> Not Authenticated → Continue
               └─> navigation.navigate('Auth')
                   └─> AuthScreen Renders
                       └─> User Authenticates
                           └─> Navigate Back to Intended Route
```

**Protected Routes:**
- MainTabs (after onboarding)
- Profile screens
- Subscription screens
- Stats screen

---

### Modal State During Navigation Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. SearchDrawer Open
   └─> User Navigates to Different Tab
       └─> TabNavigator State Updates
           └─> activeTab Changes
               └─> SearchDrawer Remains Open
                   └─> New Tab Screen Renders Behind Drawer

2. User Closes SearchDrawer
   └─> Drawer Closes
       └─> Return to Last Active Tab
           └─> setActiveTab(lastActiveTabBeforeSearch)
               └─> Correct Screen Displays
```

**State Preservation:**
- Modal state independent of tab state
- Last active tab tracked
- Smooth transitions

---

## 🚨 Error Flows

### Invalid Deep Link Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User Clicks Invalid/Expired Link
   └─> App Opens
       └─> Parse URL
           └─> Extract Tokens
               ├─> Tokens Missing → Show Error
               │   └─> "Invalid verification link"
               ├─> Tokens Expired → Show Error
               │   └─> "Link has expired. Please request a new one."
               └─> Malformed URL → Show Error
                   └─> "Unable to process link"
                       └─> Offer to Resend/Request New Link
```

**Error Handling:**
- Clear error messages
- Actionable next steps
- User-friendly language

---

### Navigation During Unmount Flow

```
System Event                   System Response
─────────────────────────────────────────────────────────
1. User Navigates Away
   └─> Component Unmounts
       └─> Navigation Action Pending
           └─> Check if Component Still Mounted
               ├─> Mounted → Execute Navigation
               └─> Unmounted → Cancel Navigation
                   └─> Prevent Memory Leaks
```

**Safety Measures:**
- Component mount checks
- Cleanup on unmount
- Navigation cancellation

---

## 🔄 State Transitions

### Tab State Transitions

```
schlafen → stress → leichtigkeit → profile
   │         │           │            │
   └─────────┴───────────┴────────────┘
              (Tab Switching)
```

### Modal State Transitions

```
Closed → Opening → Open → Closing → Closed
   │        │        │        │        │
   └────────┴────────┴────────┴────────┘
         (Modal Lifecycle)
```

### Navigation Stack Transitions

```
Index → OnboardingSlides → MainTabs → Profile → AccountSettings
   │           │              │          │            │
   └───────────┴──────────────┴──────────┴────────────┘
                    (Stack Navigation)
```

---

## 📊 Flow Diagrams

### Complete App Navigation Journey

```
App Launch
    │
    └─> IndexScreen
        │
        ├─> Onboarding Not Completed
        │   └─> OnboardingSlidesScreen
        │       └─> Complete Onboarding
        │           └─> MainTabs (with selected tab)
        │
        └─> Onboarding Completed
            └─> MainTabs
                │
                ├─> Category Tabs
                │   ├─> SchlafScreen
                │   ├─> RuheScreen
                │   └─> ImFlussScreen
                │
                ├─> Search Tab
                │   └─> SearchDrawer
                │       ├─> Sound Selection → Audio Player
                │       └─> SOS Trigger → SOSDrawer
                │
                ├─> Profile Tab
                │   └─> ProfileScreen
                │       ├─> AccountSettings
                │       ├─> PrivacySettings
                │       ├─> Legal
                │       └─> Support
                │
                └─> Library Tab (if available)
                    └─> Library Modal
```

---

## 🎯 User Goals

### Goal: Quick Navigation
- **Path:** Tab switching
- **Time:** < 100ms
- **Steps:** 1 tap

### Goal: Access Search
- **Path:** Search tab → SearchDrawer
- **Time:** < 300ms
- **Steps:** 1 tap

### Goal: Complete Onboarding
- **Path:** OnboardingSlides → Category Selection → MainTabs
- **Time:** ~2 minutes
- **Steps:** 6 slides + category selection

### Goal: Verify Email
- **Path:** Email link → App → Verification → MainTabs
- **Time:** ~30 seconds
- **Steps:** Click link → Auto-verify → Navigate

---

*For component interactions, see `components.md`*  
*For service calls, see `services.md`*  
*For technical details, see `technical-spec.md`*
