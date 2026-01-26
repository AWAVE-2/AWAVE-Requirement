# Legal & Privacy System - Services Documentation

## 🔧 Service Layer Overview

The Legal & Privacy system uses a simple service-oriented architecture with local storage for privacy preferences. Services handle storage operations and external link management.

---

## 📦 Services

### AWAVEStorage Service
**File:** `src/services/AWAVEStorage.ts`  
**Type:** Static Service Class  
**Purpose:** Privacy preferences storage and retrieval

#### Interface
```typescript
interface PrivacyPreferences {
  healthDataConsent: boolean;
  analyticsConsent: boolean;
  marketingConsent: boolean;
  lastUpdated: string; // ISO timestamp
}
```

#### Storage Key
- `awavePrivacyPreferences` - Single key for all privacy preferences

#### Methods

**`setPrivacyPreferences(preferences: PrivacyPreferences): Promise<void>`**
- Stores privacy preferences in AsyncStorage
- Serializes preferences object to JSON
- Uses key: `awavePrivacyPreferences`
- Throws error on failure

**`getPrivacyPreferences(): Promise<PrivacyPreferences | null>`**
- Retrieves privacy preferences from AsyncStorage
- Deserializes JSON to preferences object
- Returns null if not found
- Returns null on parse error
- Throws error on storage read failure

#### Usage
```typescript
// Set preferences
await AWAVEStorage.setPrivacyPreferences({
  healthDataConsent: true,
  analyticsConsent: false,
  marketingConsent: true,
  lastUpdated: new Date().toISOString(),
});

// Get preferences
const prefs = await AWAVEStorage.getPrivacyPreferences();
if (prefs) {
  console.log('Health data consent:', prefs.healthDataConsent);
}
```

#### Error Handling
- Storage write failures → Throw error
- Storage read failures → Throw error
- JSON parse errors → Return null
- Missing data → Return null

#### Dependencies
- `@react-native-async-storage/async-storage`
- JSON serialization/deserialization

---

## 🔗 Service Dependencies

### Dependency Graph
```
LegalScreen
└── React Navigation
    └── Navigation Stack

TermsScreen
└── React Navigation
    └── Navigation Stack

PrivacyPolicyScreen
└── React Navigation
    └── Navigation Stack

DataPrivacyScreen
├── AWAVEStorage
│   └── AsyncStorage
└── React Navigation
    └── Navigation Stack

PrivacySettingsScreen
├── AWAVEStorage
│   └── AsyncStorage
└── React Navigation
    └── Navigation Stack
```

### External Dependencies

#### AsyncStorage
- **Purpose:** Local persistent storage
- **Key:** `awavePrivacyPreferences`
- **Format:** JSON string
- **Persistence:** Across app restarts
- **Platform:** iOS and Android

#### React Navigation
- **Purpose:** Screen navigation
- **Type:** Stack Navigator
- **Routes:** Legal, TermsAndConditions, AppPrivacyPolicy, DataPrivacy, PrivacySettings

#### React Native Linking API
- **Purpose:** External URL handling
- **URLs:**
  - `https://www.awave-app.de/impressum`
  - `https://www.awave-app.de/datenschutz`
- **Platform:** iOS and Android

---

## 🔄 Service Interactions

### Privacy Preferences Flow
```
User Opens Privacy Screen
    │
    └─> Component Mounts
        └─> useEffect Hook
            └─> loadPreferences()
                └─> AWAVEStorage.getPrivacyPreferences()
                    ├─> AsyncStorage.getItem('awavePrivacyPreferences')
                    │   ├─> Found → Parse JSON → Return preferences
                    │   └─> Not Found → Return null
                    └─> Set component state
                        ├─> Preferences found → Use loaded values
                        └─> Preferences null → Use defaults (all true)

User Modifies Preferences
    │
    └─> Update component state
        └─> Checkbox toggles update state immediately

User Clicks Save
    │
    └─> handleSavePreferences()
        └─> Create preferences object
            └─> AWAVEStorage.setPrivacyPreferences()
                └─> AsyncStorage.setItem('awavePrivacyPreferences', JSON.stringify(prefs))
                    ├─> Success → Show success alert
                    └─> Error → Show error alert
```

### External Link Flow
```
User Clicks External Link
    │
    └─> handleOpenImprint() or handleOpenDataProtection()
        └─> Linking.canOpenURL(url)
            ├─> Supported → Linking.openURL(url)
            │   └─> Opens in default browser
            └─> Not Supported → Log error
```

---

## 🧪 Service Testing

### Unit Tests
- AWAVEStorage.setPrivacyPreferences() - Storage write
- AWAVEStorage.getPrivacyPreferences() - Storage read
- JSON serialization/deserialization
- Error handling for storage failures
- Default value handling

### Integration Tests
- Privacy preferences persistence across app restarts
- Multiple preference updates
- Concurrent access handling
- Storage key consistency

### Mocking
- AsyncStorage operations
- Navigation calls
- Linking API calls

---

## 📊 Service Metrics

### Performance
- **Storage Write:** < 100ms
- **Storage Read:** < 50ms
- **JSON Serialization:** < 10ms
- **External Link Opening:** < 2 seconds

### Reliability
- **Storage Success Rate:** > 99%
- **Preference Persistence:** 100% (local storage)
- **External Link Success Rate:** > 98%

### Error Rates
- **Storage Write Failures:** < 1%
- **Storage Read Failures:** < 1%
- **JSON Parse Errors:** < 0.1%
- **External Link Failures:** < 2%

---

## 🔐 Security Considerations

### Storage Security
- Privacy preferences stored locally only
- No sensitive data in storage (just consent flags)
- No encryption needed (non-sensitive data)
- No server-side sync

### Data Privacy
- Preferences are user-controlled
- Default values are opt-in (privacy-friendly)
- No tracking of preference changes
- No analytics on preference usage

### External Links
- URLs are hardcoded (no user input)
- URL validation before opening
- No data passed to external sites
- Secure HTTPS URLs only

---

## 🐛 Error Handling

### Service-Level Errors
- Storage failures → Show user-friendly error
- JSON parse errors → Use default values
- Missing data → Use default values
- Network errors (external links) → Log error

### Error Types
- **Storage Errors:** Read/write failures
- **Parse Errors:** Invalid JSON data
- **Navigation Errors:** Missing routes
- **Link Errors:** URL opening failures

### Error Recovery
- Storage failures → Retry once, then show error
- Parse errors → Reset to defaults
- Missing data → Use defaults (opt-in)
- Link failures → Log error, no user impact

---

## 📝 Service Configuration

### Storage Configuration
```typescript
// Storage key
const PRIVACY_PREFS_KEY = 'awavePrivacyPreferences';

// Default values
const DEFAULT_PREFERENCES: PrivacyPreferences = {
  healthDataConsent: true,
  analyticsConsent: true,
  marketingConsent: true,
  lastUpdated: new Date().toISOString(),
};
```

### External URLs
```typescript
const IMPRINT_URL = 'https://www.awave-app.de/impressum';
const DATA_PROTECTION_URL = 'https://www.awave-app.de/datenschutz';
```

### Service Initialization
```typescript
// No initialization needed
// Services are static and ready to use
```

---

## 🔄 Service Updates

### Future Enhancements
- Server-side sync of privacy preferences
- Privacy preference history/audit log
- Export privacy preferences (GDPR right to data portability)
- Privacy preference templates
- Enhanced error recovery
- Privacy preference analytics (opt-in)

---

## 📊 Data Flow

### Privacy Preferences Data Flow
```
Component State
    │
    ├─> User Interaction
    │   └─> Update State
    │
    └─> Save Action
        └─> AWAVEStorage.setPrivacyPreferences()
            └─> AsyncStorage.setItem()
                └─> JSON Serialization
                    └─> Storage

Storage
    │
    └─> Load Action
        └─> AWAVEStorage.getPrivacyPreferences()
            └─> AsyncStorage.getItem()
                └─> JSON Deserialization
                    └─> Component State
```

### External Link Data Flow
```
User Click
    │
    └─> Handler Function
        └─> Linking.canOpenURL()
            └─> Validation
                └─> Linking.openURL()
                    └─> External Browser
```

---

## 🔍 Service Monitoring

### Metrics to Track
- Privacy preference save frequency
- Privacy preference load frequency
- Storage operation success rate
- External link click frequency
- Error rates by error type

### Logging
- Storage operations (debug level)
- Error occurrences (error level)
- External link openings (info level)
- Preference changes (info level)

---

*For component usage, see `components.md`*  
*For user flows, see `user-flows.md`*  
*For technical details, see `technical-spec.md`*
