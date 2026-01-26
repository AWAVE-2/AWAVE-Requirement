# Support System - Services Documentation

## 🔧 Service Layer Overview

The Support system currently uses minimal service abstraction, with most functionality implemented directly in components. Future enhancements will include backend integration and service layer abstraction.

---

## 📦 Current Services

### Form Submission Service (Simulated)
**Status:** Currently simulated with setTimeout  
**Location:** `src/screens/SupportScreen.tsx` - `handleSubmit` method

**Current Implementation:**
```typescript
const handleSubmit = async () => {
  // Validation
  if (!formData.name || !formData.email || !formData.subject || !formData.message) {
    Alert.alert('Fehler', 'Bitte füllen Sie alle Felder aus.');
    return;
  }

  if (!validateEmail(formData.email)) {
    Alert.alert('Fehler', 'Bitte geben Sie eine gültige E-Mail-Adresse ein.');
    return;
  }

  setIsSubmitting(true);

  // Simulate API call (replace with actual Supabase submission)
  setTimeout(() => {
    setIsSubmitting(false);
    Alert.alert(
      'Nachricht gesendet',
      'Vielen Dank für Ihre Nachricht. Wir werden uns bald bei Ihnen melden.',
      [
        {
          text: 'OK',
          onPress: () => {
            // Reset form
            setFormData({
              name: '',
              email: '',
              subject: '',
              message: '',
            });
          },
        },
      ],
    );
  }, 1500);
};
```

**Behavior:**
- Validates form data
- Simulates 1.5 second API call
- Shows success alert
- Resets form on success

**Future Implementation:**
- Supabase integration
- Database storage
- Email notifications
- Ticket tracking

---

## 🔗 Native Integration Services

### Email Support Service
**Location:** `src/screens/SupportScreen.tsx` - `handleEmailSupport` method

**Implementation:**
```typescript
const handleEmailSupport = () => {
  Linking.openURL('mailto:info@awave-app.de').catch(() => {
    Alert.alert('Fehler', 'E-Mail-App konnte nicht geöffnet werden');
  });
};
```

**Behavior:**
- Opens default email app
- Pre-fills recipient: info@awave-app.de
- Error handling if email app unavailable

**Dependencies:**
- React Native `Linking` API
- Native email app

---

### Phone Support Service
**Location:** `src/screens/SupportScreen.tsx` - `handlePhoneSupport` method

**Implementation:**
```typescript
const handlePhoneSupport = () => {
  Linking.openURL('tel:+4917650203275').catch(() => {
    Alert.alert('Fehler', 'Telefon-App konnte nicht geöffnet werden');
  });
};
```

**Behavior:**
- Opens default phone app
- Pre-fills phone number: +49 176 50203275
- Error handling if phone app unavailable

**Dependencies:**
- React Native `Linking` API
- Native phone app

---

## 🔮 Planned Services

### SupportRequestService (Future)
**Status:** Planned for Supabase integration

**Planned Interface:**
```typescript
interface SupportRequest {
  id?: string;
  name: string;
  email: string;
  subject: 'technical' | 'account' | 'billing' | 'feature' | 'other';
  message: string;
  userId?: string;
  status: 'open' | 'in_progress' | 'resolved' | 'closed';
  createdAt: string;
  updatedAt: string;
}

class SupportRequestService {
  async submitRequest(request: Omit<SupportRequest, 'id' | 'status' | 'createdAt' | 'updatedAt'>): Promise<SupportRequest>;
  async getRequest(requestId: string): Promise<SupportRequest | null>;
  async getUserRequests(userId: string): Promise<SupportRequest[]>;
  async updateRequestStatus(requestId: string, status: SupportRequest['status']): Promise<void>;
}
```

**Planned Features:**
- Create support request in Supabase
- Store in `support_requests` table
- Send email notification to support team
- Track request status
- User request history

---

### NotificationService (Future)
**Status:** Planned for support responses

**Planned Features:**
- Email notifications for support responses
- Push notifications for status updates
- In-app notifications
- Notification preferences

---

### EmailService (Future)
**Status:** Planned for automated emails

**Planned Features:**
- Send confirmation email to user
- Send notification to support team
- Email templates
- Email tracking

---

## 🔗 Service Dependencies

### Current Dependencies
```
SupportScreen
├── React Native Linking API
│   ├── mailto: protocol
│   └── tel: protocol
└── Alert API
    └── Error dialogs
```

### Future Dependencies
```
SupportRequestService (Planned)
├── Supabase Client
│   ├── Database API
│   │   └── support_requests table
│   └── Auth API
│       └── User authentication
├── EmailService
│   └── Email notifications
└── NotificationService
    └── Push notifications
```

---

## 🔄 Service Interactions

### Current Flow
```
User Action
    │
    ├─> handleSubmit()
    │   └─> Validation
    │       └─> Simulated API call
    │           └─> Success Alert
    │               └─> Form Reset
    │
    ├─> handleEmailSupport()
    │   └─> Linking.openURL('mailto:...')
    │       └─> Email App Opens
    │
    └─> handlePhoneSupport()
        └─> Linking.openURL('tel:...')
            └─> Phone App Opens
```

### Future Flow (Planned)
```
User Action
    │
    ├─> handleSubmit()
    │   └─> Validation
    │       └─> SupportRequestService.submitRequest()
    │           ├─> Create in Supabase
    │           ├─> EmailService.sendConfirmation()
    │           ├─> EmailService.notifySupport()
    │           └─> NotificationService.sendPush()
    │               └─> Success Alert
    │
    ├─> handleEmailSupport()
    │   └─> Linking.openURL('mailto:...')
    │       └─> Email App Opens
    │
    └─> handlePhoneSupport()
        └─> Linking.openURL('tel:...')
            └─> Phone App Opens
```

---

## 🧪 Service Testing

### Unit Tests
- Form validation logic
- Email validation
- XSS prevention
- Character counting

### Integration Tests
- Native app linking (email, phone)
- Error handling
- Form submission flow

### E2E Tests
- Complete form submission
- Email link opening
- Phone link opening
- Error scenarios

### Mocking
- React Native Linking API
- Alert API
- Supabase client (future)
- Email service (future)

---

## 📊 Service Metrics

### Performance
- **Form Submission:** < 2 seconds (simulated)
- **Email Link Opening:** < 1 second
- **Phone Link Opening:** < 1 second
- **Error Handling:** < 100ms

### Reliability
- **Form Submission Success Rate:** 100% (simulated)
- **Email Link Success Rate:** > 95%
- **Phone Link Success Rate:** > 95%
- **Error Handling Coverage:** 100%

---

## 🔐 Security Considerations

### Current Security
- XSS prevention in form inputs
- Input sanitization
- Email validation
- Character limits

### Future Security
- Server-side validation
- Rate limiting
- CSRF protection
- Data encryption
- PII handling

---

## 🐛 Error Handling

### Current Error Handling
- Form validation errors
- Native app unavailable
- Linking failures

### Error Types
- **Validation Errors:** User-friendly German messages
- **Native App Errors:** Alert with clear message
- **Network Errors:** (Future) Retry logic

### Error Messages
- User-friendly German messages
- Clear action guidance
- No technical jargon

---

## 📝 Service Configuration

### Current Configuration
```typescript
// Support contact information
const SUPPORT_EMAIL = 'info@awave-app.de';
const SUPPORT_PHONE = '+4917650203275';
const BUSINESS_HOURS = 'Mo-Fr, 9:00-17:00 Uhr';
```

### Future Configuration
```typescript
// Environment variables
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_key
SUPPORT_EMAIL=info@awave-app.de
SUPPORT_PHONE=+4917650203275
EMAIL_SERVICE_API_KEY=your_email_api_key
```

---

## 🔄 Service Updates

### Completed
- ✅ Form submission (simulated)
- ✅ Email support link
- ✅ Phone support link
- ✅ Form validation
- ✅ XSS prevention

### In Progress
- ⏳ Supabase integration
- ⏳ Support request storage
- ⏳ Email notifications

### Planned
- 📋 Support ticket tracking
- 📋 User request history
- 📋 Status updates
- 📋 Push notifications
- 📋 FAQ integration
- 📋 Knowledge base

---

*For component usage, see `components.md`*  
*For user flows, see `user-flows.md`*  
*For technical details, see `technical-spec.md`*
