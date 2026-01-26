# Support System - User Flows

## 🔄 Primary User Flows

### 1. Contact Form Submission Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Navigate to Support Screen
   └─> Display Support Screen
       └─> Show contact form
           └─> Show quick help cards
               └─> Show alternative contact methods

2. Enter Name
   └─> Validate input
       └─> Sanitize input (XSS prevention)
           └─> Update form state

3. Enter Email
   └─> Validate email format
       └─> Sanitize input (XSS prevention)
           └─> Update form state

4. Select Subject
   └─> Click subject picker
       └─> Show dropdown with options
           └─> Select subject category
               └─> Close dropdown
                   └─> Update form state

5. Enter Message
   └─> Show character count (X/1000)
       └─> Sanitize input (XSS prevention)
           └─> Update form state
               └─> Update character count in real-time

6. Click "Nachricht senden"
   └─> Validate all fields
       ├─> Empty field → Show error alert
       ├─> Invalid email → Show error alert
       └─> Valid → Continue
           └─> Show loading state
               └─> Disable submit button
                   └─> Simulate API call (1.5s)
                       ├─> Error → Show error alert
                       └─> Success → Continue
                           └─> Show success alert
                               └─> Reset form
                                   └─> Hide loading state
```

**Success Path:**
- All fields valid
- Form submitted successfully
- Success message shown
- Form reset

**Error Paths:**
- Empty fields → Show validation error
- Invalid email → Show validation error
- Message too long → Prevent submission
- Network error → Show error (future)

---

### 2. Email Support Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Navigate to Support Screen
   └─> Display Support Screen

2. Scroll to "Alternative Kontaktmöglichkeiten"
   └─> Display email and phone support cards

3. Click "E-Mail Support" Card
   └─> Call handleEmailSupport()
       └─> Linking.openURL('mailto:info@awave-app.de')
           ├─> Email app unavailable → Show error alert
           └─> Email app available → Continue
               └─> Open default email app
                   └─> Pre-fill recipient (info@awave-app.de)
                       └─> User composes email
```

**Success Path:**
- Email app opens
- Recipient pre-filled
- User sends email

**Error Paths:**
- Email app unavailable → Show error alert
- Linking fails → Show error alert

---

### 3. Phone Support Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Navigate to Support Screen
   └─> Display Support Screen

2. Scroll to "Alternative Kontaktmöglichkeiten"
   └─> Display email and phone support cards

3. Click "Telefon Support" Card
   └─> Call handlePhoneSupport()
       └─> Linking.openURL('tel:+4917650203275')
           ├─> Phone app unavailable → Show error alert
           └─> Phone app available → Continue
               └─> Open default phone app
                   └─> Pre-fill phone number (+49 176 50203275)
                       └─> User initiates call
```

**Success Path:**
- Phone app opens
- Phone number pre-filled
- User makes call

**Error Paths:**
- Phone app unavailable → Show error alert
- Linking fails → Show error alert

---

### 4. Quick Help Access Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Navigate to Support Screen
   └─> Display Support Screen

2. View "Schnelle Hilfe" Section
   └─> Display Getting Started and FAQ cards

3. Click "Erste Schritte" Card
   └─> (Future: Navigate to Getting Started guide)
       └─> Currently: No action (placeholder)

4. Click "FAQ" Card
   └─> (Future: Navigate to FAQ screen)
       └─> Currently: No action (placeholder)
```

**Current Behavior:**
- Cards are displayed but not interactive
- Placeholder for future implementation

**Future Behavior:**
- Navigate to Getting Started guide
- Navigate to FAQ screen

---

## 🔀 Alternative Flows

### Navigation from Profile Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Navigate to Profile Screen
   └─> Display Profile Screen
       └─> Show ProfileSupportSection

2. View "Support" Section
   └─> Display support section header
       └─> Show "Hilfe & Support" card

3. Click "Hilfe & Support" Card
   └─> Call handleSupport()
       └─> navigation.navigate('Support')
           └─> Navigate to Support Screen
               └─> Display Support Screen
```

**Navigation:**
- Profile → Support
- Back button returns to Profile

---

### Back Navigation Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. On Support Screen
   └─> Click back button
       └─> Call goBack()
           ├─> navigation.canGoBack() → true
           │   └─> navigation.goBack()
           │       └─> Return to previous screen
           └─> navigation.canGoBack() → false
               └─> navigation.navigate('Profile')
                   └─> Navigate to Profile screen
```

**Behavior:**
- If back history exists → Go back
- If no back history → Navigate to Profile

---

### Subject Picker Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Click Subject Picker
   └─> Toggle showSubjectPicker
       └─> Show dropdown with options
           └─> Display 5 subject options

2. Select Subject Option
   └─> Call handleSubjectSelect(subject)
       └─> Update formData.subject
           └─> Set showSubjectPicker to false
               └─> Hide dropdown
                   └─> Display selected subject label
```

**Subject Options:**
- Technisches Problem (Technical Problem)
- Konto-Probleme (Account Issues)
- Abrechnung (Billing)
- Feature-Anfrage (Feature Request)
- Sonstiges (Other)

---

## 🚨 Error Flows

### Form Validation Error Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Fill Form Partially
   └─> Leave some fields empty

2. Click "Nachricht senden"
   └─> Validate form
       └─> Check required fields
           ├─> All fields filled → Continue
           └─> Empty field → Continue
               └─> Alert.alert('Fehler', 'Bitte füllen Sie alle Felder aus.')
                   └─> Return to form
                       └─> User fills missing fields
```

**Validation Errors:**
- Empty fields → "Bitte füllen Sie alle Felder aus."
- Invalid email → "Bitte geben Sie eine gültige E-Mail-Adresse ein."

---

### Email App Unavailable Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Click "E-Mail Support" Card
   └─> Call handleEmailSupport()
       └─> Linking.openURL('mailto:...')
           └─> Linking fails
               └─> .catch() handler
                   └─> Alert.alert('Fehler', 'E-Mail-App konnte nicht geöffnet werden')
                       └─> Return to Support Screen
```

**Error Handling:**
- Graceful error message
- User can retry or use alternative method

---

### Phone App Unavailable Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Click "Telefon Support" Card
   └─> Call handlePhoneSupport()
       └─> Linking.openURL('tel:...')
           └─> Linking fails
               └─> .catch() handler
                   └─> Alert.alert('Fehler', 'Telefon-App konnte nicht geöffnet werden')
                       └─> Return to Support Screen
```

**Error Handling:**
- Graceful error message
- User can retry or use alternative method

---

## 🔄 State Transitions

### Form State Transitions

```
Empty Form
    │
    ├─> User fills fields
    │   └─> Form Data Updated
    │       └─> Validation Check
    │           ├─> Invalid → Show Error
    │           └─> Valid → Ready to Submit
    │               └─> User clicks Submit
    │                   └─> isSubmitting = true
    │                       └─> API Call (simulated)
    │                           ├─> Error → Show Error Alert
    │                           └─> Success → Show Success Alert
    │                               └─> Reset Form
    │                                   └─> isSubmitting = false
```

### Subject Picker State Transitions

```
No Subject Selected
    │
    └─> User clicks Picker
        └─> showSubjectPicker = true
            └─> Dropdown Visible
                └─> User selects option
                    └─> formData.subject = selected
                        └─> showSubjectPicker = false
                            └─> Dropdown Hidden
                                └─> Selected Label Displayed
```

---

## 📊 Flow Diagrams

### Complete Support Journey

```
Profile Screen
    │
    └─> User clicks "Hilfe & Support"
        └─> Navigate to Support Screen
            │
            ├─> User fills contact form
            │   └─> Submit form
            │       └─> Success → Form reset
            │
            ├─> User clicks email support
            │   └─> Open email app
            │
            ├─> User clicks phone support
            │   └─> Open phone app
            │
            └─> User clicks back
                └─> Return to Profile
```

### Form Submission Journey

```
Support Screen
    │
    └─> Contact Form Section
        │
        ├─> Enter Name
        ├─> Enter Email
        ├─> Select Subject
        ├─> Enter Message
        │
        └─> Click Submit
            │
            ├─> Validation
            │   ├─> Invalid → Show Error
            │   └─> Valid → Continue
            │       │
            │       └─> Submit (simulated)
            │           │
            │           ├─> Error → Show Error
            │           └─> Success → Show Success
            │               └─> Reset Form
```

---

## 🎯 User Goals

### Goal: Contact Support
- **Path:** Support Form → Fill → Submit
- **Time:** ~2 minutes
- **Steps:** 5-6 interactions

### Goal: Quick Contact
- **Path:** Email/Phone Support Card → Click → Native App
- **Time:** < 10 seconds
- **Steps:** 2 interactions

### Goal: Get Help
- **Path:** Quick Help Cards → (Future: Navigate to resources)
- **Time:** < 5 seconds
- **Steps:** 1-2 interactions

---

## 🔮 Future Flows

### Support Ticket Tracking Flow (Planned)

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Submit Support Request
   └─> Create ticket in Supabase
       └─> Send confirmation email
           └─> Show ticket ID
               └─> Navigate to ticket status

2. View Ticket Status
   └─> Display ticket details
       └─> Show status (open, in_progress, resolved)
           └─> Show support team responses
```

### FAQ Navigation Flow (Planned)

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Click "FAQ" Card
   └─> Navigate to FAQ Screen
       └─> Display FAQ categories
           └─> User selects category
               └─> Display FAQ items
                   └─> User clicks question
                       └─> Display answer
```

---

*For component interactions, see `components.md`*  
*For service calls, see `services.md`*  
*For technical details, see `technical-spec.md`*
