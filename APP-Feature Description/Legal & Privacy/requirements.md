# Legal & Privacy System - Functional Requirements

## 📋 Core Requirements

### 1. Legal Information Hub

#### Legal Screen
- [x] User can access legal information from profile screen
- [x] Display all legal document options in card-based layout
- [x] Internal navigation to Terms, Privacy Policy, and Data Privacy
- [x] External links to Impressum and Datenschutz
- [x] Consistent UI with icons and descriptions
- [x] Back navigation to profile
- [x] Scrollable content for small screens

#### Navigation
- [x] Terms and Conditions navigation
- [x] App Privacy Policy navigation
- [x] Data Privacy (GDPR) navigation
- [x] External link handling for Impressum
- [x] External link handling for Datenschutz
- [x] URL validation before opening external links

### 2. Terms & Conditions

#### Content Display
- [x] Display complete terms of service
- [x] 11 sections covering all aspects
- [x] Last updated date display
- [x] Scrollable content with proper formatting
- [x] Consistent typography and spacing
- [x] Contact information display

#### Sections Required
- [x] Anwendungsbereich (Scope of Application)
- [x] Leistungsbeschreibung (Service Description)
- [x] Registrierung und Nutzerkonto (Registration and User Account)
- [x] Abonnements und Zahlungen (Subscriptions and Payments)
- [x] Kostenlose Testphase (Free Trial Period)
- [x] Nutzungsrechte und -beschränkungen (Usage Rights and Restrictions)
- [x] Datenschutz (Data Privacy)
- [x] Haftungsausschluss (Liability Disclaimer)
- [x] Kündigung (Termination)
- [x] Änderungen der Nutzungsbedingungen (Changes to Terms)
- [x] Anwendbares Recht und Gerichtsstand (Applicable Law and Jurisdiction)

### 3. Privacy Policy

#### Content Display
- [x] Display complete privacy policy
- [x] 12 sections covering all aspects
- [x] Last updated date display
- [x] Scrollable content with proper formatting
- [x] Contact information for privacy inquiries

#### Sections Required
- [x] Verantwortlicher (Controller)
- [x] Erhobene Daten (Data Collected)
- [x] Zwecke der Datenverarbeitung (Purposes of Data Processing)
- [x] Rechtsgrundlagen (Legal Basis)
- [x] Datenweitergabe (Data Sharing)
- [x] Internationale Datenübertragung (International Data Transfer)
- [x] Speicherdauer (Storage Duration)
- [x] Ihre Rechte (Your Rights)
- [x] Datensicherheit (Data Security)
- [x] Cookies und Tracking (Cookies and Tracking)
- [x] Minderjährige (Minors)
- [x] Änderungen der Datenschutzerklärung (Changes to Privacy Policy)

### 4. GDPR Compliance (Data Privacy)

#### Documentation Display
- [x] Display comprehensive GDPR-compliant information
- [x] 12 accordion sections for easy navigation
- [x] Protected badge display
- [x] Policy header with description
- [x] Expandable/collapsible sections
- [x] Icons for each section

#### GDPR Sections Required
- [x] Controller (Verantwortlicher)
- [x] Data Collected (Erhobene Daten)
- [x] How We Collect Data (Wie wir Daten sammeln)
- [x] Third-Party Services (Drittanbieter)
- [x] Legal Basis (Rechtsgrundlage)
- [x] Data Storage (Datenspeicherung)
- [x] User Accounts (Nutzerkonten)
- [x] Health Data (Gesundheitsdaten)
- [x] Notifications (Benachrichtigungen)
- [x] Tracking (Tracking)
- [x] User Rights (Nutzerrechte)
- [x] Validity (Gültigkeit)

#### Privacy Preferences Integration
- [x] Display privacy settings section within GDPR screen
- [x] Health data consent checkbox
- [x] Analytics consent checkbox
- [x] Marketing consent checkbox
- [x] Save preferences functionality
- [x] Load existing preferences on screen load
- [x] Success confirmation on save

### 5. Privacy Settings

#### Settings Display
- [x] Dedicated privacy settings screen
- [x] Header with icon and description
- [x] Data collection section
- [x] Marketing settings section
- [x] Save button for preferences

#### Privacy Preferences
- [x] Health data consent toggle
- [x] Analytics consent toggle
- [x] Marketing consent toggle
- [x] Default values (all true/opt-in)
- [x] Load preferences from storage on mount
- [x] Save preferences to storage
- [x] Success alert on save
- [x] Error handling for save failures

#### Data Collection Section
- [x] Section description
- [x] Health data checkbox with description
- [x] Analytics data checkbox with description
- [x] Visual feedback for checkbox states

#### Marketing Settings Section
- [x] Section title and description
- [x] Marketing communication checkbox
- [x] Clear description of marketing consent

### 6. Privacy Preferences Storage

#### Storage Requirements
- [x] Store preferences in AsyncStorage
- [x] Storage key: `awavePrivacyPreferences`
- [x] Store health data consent
- [x] Store analytics consent
- [x] Store marketing consent
- [x] Store last updated timestamp
- [x] Load preferences on app start (where needed)
- [x] Persist preferences across app restarts

#### Preference Structure
```typescript
interface PrivacyPreferences {
  healthDataConsent: boolean;
  analyticsConsent: boolean;
  marketingConsent: boolean;
  lastUpdated: string; // ISO timestamp
}
```

### 7. External Links

#### Link Handling
- [x] Impressum link: `https://www.awave-app.de/impressum`
- [x] Datenschutz link: `https://www.awave-app.de/datenschutz`
- [x] URL validation before opening
- [x] Open in external browser
- [x] Error handling for unsupported URLs
- [x] Visual indicator for external links (↗ icon)

---

## 🎯 User Stories

### As a user, I want to:
- Access all legal information from one central location
- Read terms and conditions before signing up
- Understand how my data is collected and used
- Control my privacy preferences (health data, analytics, marketing)
- Access GDPR-compliant information about my rights
- Open company legal pages in my browser
- Have my privacy preferences saved and remembered

### As a privacy-conscious user, I want to:
- Opt out of health data collection
- Opt out of analytics tracking
- Opt out of marketing communications
- See clear descriptions of what each preference means
- Have my preferences persist across app sessions

### As a new user, I want to:
- Read terms and conditions during signup
- Understand the privacy policy before creating an account
- Know what data will be collected
- Make informed decisions about privacy settings

---

## ✅ Acceptance Criteria

### Legal Screen
- [x] All legal document options are visible
- [x] Navigation to internal screens works correctly
- [x] External links open in browser
- [x] Back navigation returns to profile
- [x] UI is consistent with app design system

### Terms & Conditions
- [x] All 11 sections are displayed
- [x] Content is scrollable
- [x] Last updated date is shown
- [x] Contact information is accessible
- [x] Typography is readable

### Privacy Policy
- [x] All 12 sections are displayed
- [x] Content is scrollable
- [x] Last updated date is shown
- [x] Contact information is accessible
- [x] Privacy inquiries email is displayed

### GDPR Compliance
- [x] All 12 accordion sections are present
- [x] Sections can be expanded/collapsed
- [x] Privacy preferences are integrated
- [x] Preferences can be saved
- [x] Saved preferences persist

### Privacy Settings
- [x] All three preference toggles are functional
- [x] Preferences load from storage on mount
- [x] Preferences save to storage on button press
- [x] Success alert shows on save
- [x] Error handling works for failures

### External Links
- [x] Impressum link opens in browser
- [x] Datenschutz link opens in browser
- [x] URL validation prevents errors
- [x] External link icon is visible

---

## 🚫 Non-Functional Requirements

### Performance
- Legal screens load in < 1 second
- Privacy preferences save in < 500ms
- External links open in < 2 seconds
- Accordion expand/collapse is smooth (< 200ms)

### Usability
- All legal content is readable
- Navigation is intuitive
- Privacy preferences are easy to understand
- External links are clearly marked
- Success/error messages are clear

### Accessibility
- Text is readable (minimum font size 14px)
- Touch targets are minimum 44x44 points
- Color contrast meets WCAG AA standards
- Screen reader support for all interactive elements

### Reliability
- Privacy preferences persist across app restarts
- External links handle network failures gracefully
- Storage errors are caught and handled
- Missing translations fall back gracefully

---

## 🔄 Edge Cases

### Storage Issues
- [x] Handle AsyncStorage read failures
- [x] Handle AsyncStorage write failures
- [x] Handle corrupted preference data
- [x] Default to opt-in if preferences missing
- [x] Show error messages for storage failures

### Network Issues
- [x] Handle external link opening failures
- [x] Validate URLs before opening
- [x] Show error if URL cannot be opened
- [x] Graceful degradation for network errors

### Navigation Issues
- [x] Handle missing navigation params
- [x] Handle back navigation from root screens
- [x] Prevent navigation loops
- [x] Handle deep link navigation

### Content Issues
- [x] Handle missing translation keys
- [x] Display fallback text for missing content
- [x] Handle long content gracefully
- [x] Ensure scrollable content works on all screen sizes

---

## 📊 Success Metrics

- Legal screen access rate > 5% of users
- Privacy settings usage rate > 10% of users
- Terms acceptance rate during signup > 95%
- Privacy preference save success rate > 99%
- External link open success rate > 98%
- Average time to access legal information < 3 taps

---

## 🔐 Privacy & Compliance Requirements

### GDPR Compliance
- [x] All required GDPR sections are documented
- [x] User rights are clearly explained
- [x] Data collection is transparent
- [x] Legal basis for processing is stated
- [x] Third-party services are disclosed
- [x] Data storage and retention is explained

### Privacy by Design
- [x] Privacy preferences are opt-in by default
- [x] Clear descriptions of what each preference controls
- [x] Easy access to privacy settings
- [x] Preferences are stored securely (local only)
- [x] No sensitive data in logs

### Legal Requirements
- [x] Terms and conditions are complete
- [x] Privacy policy is comprehensive
- [x] Contact information is provided
- [x] Last updated dates are displayed
- [x] External legal pages are accessible

---

## 📝 Notes

- Privacy preferences default to `true` (opt-in) for better UX
- All legal content is currently in German (de)
- External links require internet connection
- Privacy preferences are stored locally only (no sync)
- GDPR documentation is comprehensive and should be reviewed by legal team
- Terms and Privacy Policy should be kept up-to-date with legal changes
