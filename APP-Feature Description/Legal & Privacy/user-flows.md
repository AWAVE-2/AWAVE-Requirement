# Legal & Privacy System - User Flows

## 🔄 Primary User Flows

### 1. Access Legal Information Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Navigate to Profile Screen
   └─> Display Profile Options
       └─> Show "Rechtliches" option

2. Click "Rechtliches"
   └─> Navigate to LegalScreen
       └─> Display Legal Hub
           └─> Show all legal document cards
               ├─> Terms and Conditions
               ├─> App Privacy Policy
               ├─> Data Privacy (GDPR)
               ├─> Impressum (External)
               └─> Datenschutz (External)

3. Select Document
   └─> Navigate to selected screen
       └─> Display document content
```

**Success Path:**
- User accesses legal information
- Content is displayed correctly
- Navigation works smoothly

**Alternative Paths:**
- User clicks external link → Opens in browser
- User clicks back → Returns to previous screen

---

### 2. View Terms & Conditions Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Navigate to LegalScreen
   └─> Display Legal Hub

2. Click "Allgemeine Geschäftsbedingungen"
   └─> Navigate to TermsScreen
       └─> Display Terms Content
           └─> Show header with back button
               └─> Show scrollable content
                   └─> Display 11 sections:
                       ├─> Anwendungsbereich
                       ├─> Leistungsbeschreibung
                       ├─> Registrierung und Nutzerkonto
                       ├─> Abonnements und Zahlungen
                       ├─> Kostenlose Testphase
                       ├─> Nutzungsrechte und -beschränkungen
                       ├─> Datenschutz
                       ├─> Haftungsausschluss
                       ├─> Kündigung
                       ├─> Änderungen der Nutzungsbedingungen
                       └─> Anwendbares Recht und Gerichtsstand

3. Scroll Content
   └─> Read all sections
       └─> View contact information

4. Click Back Button
   └─> Navigate back to LegalScreen
```

**Success Path:**
- Terms content is displayed
- All sections are readable
- Navigation works correctly

**Alternative Paths:**
- User scrolls to read all content
- User navigates back without reading

---

### 3. View Privacy Policy Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Navigate to LegalScreen
   └─> Display Legal Hub

2. Click "App-Datenschutzrichtlinie"
   └─> Navigate to PrivacyPolicyScreen
       └─> Display Privacy Policy Content
           └─> Show header with back button
               └─> Show scrollable content
                   └─> Display 12 sections:
                       ├─> Verantwortlicher
                       ├─> Erhobene Daten
                       ├─> Zwecke der Datenverarbeitung
                       ├─> Rechtsgrundlagen
                       ├─> Datenweitergabe
                       ├─> Internationale Datenübertragung
                       ├─> Speicherdauer
                       ├─> Ihre Rechte
                       ├─> Datensicherheit
                       ├─> Cookies und Tracking
                       ├─> Minderjährige
                       └─> Änderungen der Datenschutzerklärung

3. Scroll Content
   └─> Read all sections
       └─> View privacy contact information

4. Click Back Button
   └─> Navigate back to LegalScreen
```

**Success Path:**
- Privacy policy content is displayed
- All sections are readable
- Contact information is accessible

**Alternative Paths:**
- User reads specific sections only
- User navigates back early

---

### 4. Manage Privacy Preferences Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Navigate to Profile Screen
   └─> Display Profile Options

2. Click "Datenschutz-Einstellungen"
   └─> Navigate to PrivacySettingsScreen
       └─> Load existing preferences
           ├─> Found → Display saved preferences
           └─> Not Found → Display defaults (all true)
               └─> Show privacy settings screen
                   ├─> Header with description
                   ├─> Data Collection Section
                   │   ├─> Health Data checkbox
                   │   └─> Analytics Data checkbox
                   ├─> Marketing Settings Section
                   │   └─> Marketing Communication checkbox
                   └─> Save Button

3. Modify Preferences
   └─> Toggle checkboxes
       └─> Update component state immediately
           └─> Visual feedback on checkbox change

4. Click "Datenschutzeinstellungen speichern"
   └─> Save preferences to AsyncStorage
       ├─> Success → Show success alert
       │   └─> "Ihre Datenschutzeinstellungen wurden erfolgreich aktualisiert."
       └─> Error → Show error alert
           └─> "Failed to save preferences. Please try again."

5. Click Back Button
   └─> Navigate back to Profile Screen
```

**Success Path:**
- Preferences are loaded correctly
- User modifies preferences
- Preferences are saved successfully
- Success message is shown

**Error Paths:**
- Storage failure → Show error message
- Load failure → Use default values
- Save failure → Show error, allow retry

---

### 5. Review GDPR Information Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Navigate to LegalScreen
   └─> Display Legal Hub

2. Click "Datenschutz (DSGVO)"
   └─> Navigate to DataPrivacyScreen
       └─> Load existing preferences
           └─> Display GDPR Information
               ├─> Protected Badge
               ├─> Policy Header
               └─> 12 Accordion Sections:
                   ├─> Controller (defaultOpen)
                   ├─> Data Collected
                   ├─> How We Collect Data
                   ├─> Third-Party Services
                   ├─> Legal Basis
                   ├─> Data Storage
                   ├─> User Accounts
                   ├─> Health Data
                   ├─> Notifications
                   ├─> Tracking
                   ├─> User Rights
                   └─> Validity

3. Expand Accordion Sections
   └─> Click section header
       └─> Section expands/collapses
           └─> Smooth animation
               └─> Content is displayed

4. Review Privacy Preferences Section
   └─> Scroll to Privacy Settings
       └─> View Data Collection Section (defaultOpen)
           ├─> Health Data checkbox
           └─> Analytics Data checkbox
       └─> Expand Marketing Section
           └─> Marketing Communication checkbox

5. Modify Preferences (Optional)
   └─> Toggle checkboxes
       └─> Update state

6. Click "Datenschutzeinstellungen speichern"
   └─> Save preferences
       └─> Show success alert

7. Click Back Button
   └─> Navigate back to LegalScreen
```

**Success Path:**
- GDPR information is displayed
- Accordions work correctly
- Preferences can be modified
- Preferences are saved

**Alternative Paths:**
- User reads sections without modifying preferences
- User modifies preferences and saves
- User navigates back without saving

---

### 6. Access External Legal Pages Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Navigate to LegalScreen
   └─> Display Legal Hub

2. Click "Impressum" or "Datenschutz"
   └─> Validate URL
       └─> Linking.canOpenURL(url)
           ├─> Supported → Continue
           └─> Not Supported → Log error
               └─> Return (no action)

3. Open External URL
   └─> Linking.openURL(url)
       └─> Opens in default browser
           └─> User views external page

4. User Returns to App
   └─> App state preserved
       └─> User can continue using app
```

**Success Path:**
- External link opens in browser
- User can view external content
- App state is preserved

**Error Paths:**
- URL not supported → Error logged, no action
- Network error → Browser may show error
- App state may be lost (OS behavior)

---

## 🔀 Alternative Flows

### Signup Terms Acceptance Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Navigate to Signup Screen
   └─> Display Signup Options

2. View Terms Text
   └─> Display terms acceptance text
       └─> Show links to:
           ├─> Terms and Conditions
           └─> Privacy Policy

3. Click Terms Link
   └─> Navigate to TermsScreen
       └─> Display Terms Content
           └─> User reads terms

4. Click Back Button
   └─> Navigate back to Signup Screen

5. Click Privacy Policy Link
   └─> Navigate to PrivacyPolicyScreen
       └─> Display Privacy Policy Content
           └─> User reads privacy policy

6. Click Back Button
   └─> Navigate back to Signup Screen

7. Complete Signup
   └─> User accepts terms implicitly
       └─> Continue with registration
```

**Use Cases:**
- User reviews terms before signup
- User reviews privacy policy before signup
- User makes informed decision

---

### Quick Privacy Access Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Navigate to Profile Screen
   └─> Display Profile Options

2. Click "Datenschutz-Einstellungen"
   └─> Navigate to PrivacySettingsScreen
       └─> Quick access to privacy preferences
           └─> Modify and save preferences
               └─> Return to Profile
```

**Use Cases:**
- Quick privacy preference changes
- Direct access from profile
- No need to go through legal hub

---

### Privacy Preference Persistence Flow

```
System Event                   System Response
─────────────────────────────────────────────────────────
1. User Saves Preferences
   └─> Preferences stored in AsyncStorage
       └─> Key: 'awavePrivacyPreferences'
           └─> JSON serialized data

2. App Restart
   └─> User opens Privacy Settings or Data Privacy screen
       └─> Component mounts
           └─> useEffect hook triggers
               └─> loadPreferences() called
                   └─> AWAVEStorage.getPrivacyPreferences()
                       └─> AsyncStorage.getItem()
                           ├─> Found → Parse JSON → Set state
                           └─> Not Found → Use defaults
                               └─> Display preferences
```

**Automatic Behavior:**
- Preferences persist across app restarts
- No user action required
- Seamless experience

---

## 🚨 Error Flows

### Storage Error Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User Modifies Preferences
   └─> Update component state

2. User Clicks Save
   └─> handleSavePreferences() called
       └─> AWAVEStorage.setPrivacyPreferences()
           └─> AsyncStorage.setItem()
               ├─> Success → Show success alert
               └─> Error → Catch error
                   └─> Show error alert
                       └─> "Failed to save preferences. Please try again."
                           └─> User can retry
```

**Error Messages:**
- "Failed to save preferences. Please try again."
- User can retry the save operation

---

### Load Preferences Error Flow

```
System Event                   System Response
─────────────────────────────────────────────────────────
1. Component Mounts
   └─> loadPreferences() called
       └─> AWAVEStorage.getPrivacyPreferences()
           └─> AsyncStorage.getItem()
               ├─> Success → Parse JSON
               │   ├─> Valid JSON → Set state
               │   └─> Invalid JSON → Use defaults
               └─> Error → Catch error
                   └─> Use defaults (all true)
                       └─> Log error for debugging
```

**Error Handling:**
- Storage errors → Use default values
- Parse errors → Use default values
- Missing data → Use default values
- User experience is not disrupted

---

### External Link Error Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User Clicks External Link
   └─> handleOpenImprint() or handleOpenDataProtection()
       └─> Linking.canOpenURL(url)
           ├─> Supported → Linking.openURL(url)
           │   ├─> Success → Opens in browser
           │   └─> Error → Log error
           │       └─> No user-facing error
           └─> Not Supported → Log error
               └─> No user-facing error
```

**Error Handling:**
- URL validation prevents most errors
- Errors are logged for debugging
- No user-facing error messages
- Graceful degradation

---

## 🔄 State Transitions

### Privacy Preferences States

```
Default (Not Set)
    │
    └─> Load Preferences
        ├─> Found → Loaded State
        └─> Not Found → Default State (all true)
            │
            └─> User Modifies
                └─> Modified State
                    │
                    └─> Save
                        ├─> Success → Saved State
                        └─> Error → Modified State (retry)
```

### Accordion States

```
Collapsed → User Clicks → Expanded
    │                            │
    └─> User Clicks ←────────────┘
```

---

## 📊 Flow Diagrams

### Complete Legal Information Access Journey

```
Profile Screen
    │
    ├─> Click "Rechtliches"
    │   └─> LegalScreen
    │       ├─> Click "Terms" → TermsScreen
    │       ├─> Click "Privacy Policy" → PrivacyPolicyScreen
    │       ├─> Click "Data Privacy" → DataPrivacyScreen
    │       ├─> Click "Impressum" → External Browser
    │       └─> Click "Datenschutz" → External Browser
    │
    └─> Click "Datenschutz-Einstellungen"
        └─> PrivacySettingsScreen
            └─> Modify Preferences → Save
```

---

## 🎯 User Goals

### Goal: Understand Legal Terms
- **Path:** Profile → Legal → Terms
- **Time:** ~5 minutes
- **Steps:** 3 taps, scroll to read

### Goal: Control Privacy
- **Path:** Profile → Privacy Settings → Modify → Save
- **Time:** ~30 seconds
- **Steps:** 3 taps, toggle checkboxes, save

### Goal: Review GDPR Rights
- **Path:** Profile → Legal → Data Privacy → Expand Sections
- **Time:** ~10 minutes
- **Steps:** 3 taps, expand accordions, read content

---

*For component interactions, see `components.md`*  
*For service calls, see `services.md`*  
*For technical details, see `technical-spec.md`*
