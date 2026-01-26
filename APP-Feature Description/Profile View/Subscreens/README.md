# Profile View Subscreens - Documentation Index

**Last Updated:** 2025-01-27

## 📂 Overview

This folder contains comprehensive documentation for all subscreens accessible from the Profile View. Each subscreen has detailed documentation following the same structure as the Authentication feature documentation.

---

## 📱 Available Subscreens

### 1. Account Settings
**Location:** `Account Settings/`  
**Route:** `/account-settings`  
**Purpose:** Email, password, and security settings management

**Documentation:**
- ✅ `README.md` - Feature overview
- ✅ `requirements.md` - Functional requirements
- ✅ `components.md` - Component inventory
- ✅ `services.md` - Service dependencies
- ✅ `user-flows.md` - User flow diagrams
- ✅ `technical-spec.md` - Technical specifications

**Key Features:**
- Email update with validation
- Password change with strength validation
- Biometric login toggle
- Push notification toggle
- Developer settings (dev only)

---

### 2. Legal Pages
**Location:** `Legal Pages/`  
**Route:** `/legal`  
**Purpose:** Legal information hub with links to all legal documents

**Documentation:**
- ✅ `README.md` - Feature overview
- ✅ `requirements.md` - Functional requirements
- ⏳ `components.md` - Component inventory (to be created)
- ⏳ `services.md` - Service dependencies (to be created)
- ⏳ `user-flows.md` - User flow diagrams (to be created)
- ⏳ `technical-spec.md` - Technical specifications (to be created)

**Key Features:**
- Legal hub screen with navigation
- Internal screens: Terms, Privacy Policy, Data Privacy
- External links: Impressum, Data Protection
- Consistent card-based design

**Subscreens:**
- Terms and Conditions (`/legal/terms`)
- App Privacy Policy (`/legal/privacy-policy`)
- Data Privacy (`/legal/data-privacy`)

---

### 3. Privacy Settings
**Location:** `Privacy Settings/`  
**Route:** `/privacy-settings`  
**Purpose:** Privacy preferences and data consent management

**Documentation:**
- ✅ `README.md` - Feature overview
- ⏳ `requirements.md` - Functional requirements (to be created)
- ⏳ `components.md` - Component inventory (to be created)
- ⏳ `services.md` - Service dependencies (to be created)
- ⏳ `user-flows.md` - User flow diagrams (to be created)
- ⏳ `technical-spec.md` - Technical specifications (to be created)

**Key Features:**
- Health data consent toggle
- Analytics consent toggle
- Marketing consent toggle
- Local storage in AsyncStorage
- Save preferences functionality

---

### 4. Support
**Location:** `Support/`  
**Route:** `/support`  
**Purpose:** Support contact form and help resources

**Documentation:**
- ✅ `README.md` - Feature overview
- ⏳ `requirements.md` - Functional requirements (to be created)
- ⏳ `components.md` - Component inventory (to be created)
- ⏳ `services.md` - Service dependencies (to be created)
- ⏳ `user-flows.md` - User flow diagrams (to be created)
- ⏳ `technical-spec.md` - Technical specifications (to be created)

**Key Features:**
- Contact form with subject selection
- Quick help cards (Getting Started, FAQ)
- Alternative contact methods (email, phone)
- Form validation and XSS prevention
- Character counter for message field

---

## 📊 Documentation Status

| Subscreen | README | Requirements | Components | Services | User Flows | Technical Spec |
|-----------|--------|--------------|------------|----------|------------|----------------|
| Account Settings | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Legal Pages | ✅ | ✅ | ⏳ | ⏳ | ⏳ | ⏳ |
| Privacy Settings | ✅ | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ |
| Support | ✅ | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ |

**Legend:**
- ✅ Complete
- ⏳ To be created

---

## 🔗 Navigation Flow

```
Profile Screen
    │
    ├─> Account Section
    │   ├─> Kontoeinstellungen → Account Settings
    │   ├─> Rechtliches → Legal Pages
    │   ├─> Datenschutz-Einstellungen → Privacy Settings
    │   └─> Käufe wiederherstellen → IAP Restoration
    │
    └─> Support Section
        └─> Help & Support → Support
```

---

## 📝 Documentation Structure

Each subscreen follows the same documentation structure:

1. **README.md** - Feature overview, core features, architecture, user flows
2. **requirements.md** - Functional requirements, user stories, acceptance criteria
3. **components.md** - Component inventory, component relationships, styling
4. **services.md** - Service layer overview, service dependencies, interactions
5. **user-flows.md** - Primary user flows, alternative flows, error flows
6. **technical-spec.md** - Technical architecture, file structure, API integration

---

## 🎯 Common Patterns

### Design System
- All screens use `PROFILE_RADIUS = 16` for consistent border radius
- EnhancedCard with gradient variants
- Consistent spacing using `awaveSpacing`
- Theme integration via `useTheme` hook

### Navigation
- UnifiedHeader with back button
- React Navigation routing
- Safe navigation handling

### State Management
- React Hooks (useState, useEffect)
- Context API for global state
- AsyncStorage for local persistence

### Error Handling
- User-friendly error messages
- Toast notifications for feedback
- Graceful error recovery

---

## 📚 Additional Resources

- [Main Profile View Documentation](../README.md)
- [Authentication Feature Documentation](../../Authentication/README.md) (reference pattern)

---

*For detailed documentation of each subscreen, navigate to the respective folder*
