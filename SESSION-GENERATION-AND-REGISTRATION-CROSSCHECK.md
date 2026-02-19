# Session Generation & Registration Flows – Cross-Check

**Purpose:** Verify that the **new session generation logic** and **registration flows** in the iOS app are fully reflected in the Requirements and that no gaps remain.  
**Date:** 2026-02-16  
**Language:** English  

---

## 1. Scope of the Cross-Check

| Area | Code / Behaviour | Requirements Location |
|------|-------------------|------------------------|
| **Session generation** | SessionGenerator, CategorySessionGenerator, SessionTopic, SessionNameGenerator, SessionContentResolver, Category block, SessionGeneratorView | APP-Feature Description/Session Generation/ |
| **Registration flows** | Preloader → Onboarding → (Auth) → MainTabView; Email verification; Guest path | APP-Feature Description/Authentication/, User Onboarding Screens/, Start Screens/ |

---

## 2. Session Generation – Cross-Check

### 2.1 What Exists in Code (Swift)

| Component | Role | Documented in Requirements? |
|-----------|------|-----------------------------|
| `SessionGenerator` | Multi-phase session from topic, voice, journey, music genre; 11 topics; stages; SAD dual path; min 3 phases; naming | ✓ Yes – base-documentation, refactoring report; **now** [Session Generation/requirements.md](APP-Feature%20Description/Session%20Generation/requirements.md) |
| `CategorySessionGenerator` | 5 sessions per OnboardingCategory; preferences (voice, duration scale, frequency) | ✓ Yes – Category Screens requirements; **now** Session Generation/requirements.md |
| `SessionTopic` / stages / musicGenrePool | 11 topics, stage arrays, genre pools | ✓ Yes – SessionTopicConfig in code; content IDs in base-documentation; **now** Session Generation/requirements.md |
| `SessionNameGenerator` | Fantasy vs non-fantasy names, info text | ✓ Yes – AWAVE-Session-Naming-Logic.md, AWAVE-Session-Generation-Naming.md; **now** requirements.md |
| `SessionContentResolver` | Resolve content IDs to Sound; no category fallback | ✓ Yes – SESSION_GENERATION_AUDIO_LIBRARY_REFACTORING_REPORT.md, base-documentation; **now** requirements.md |
| `SessionContentMapping` | Fallback contentId → sound document ID | ✓ Yes – base-documentation; **now** requirements.md |
| `SessionGeneratorView` | Topic grid, voice, "Session erstellen", initialTopic | ◐ Partial – Category Screens / Search; **now** Session Generation/requirements.md |
| Category block (CategorySessionGeneratorBlock, PersonalizationDrawer) | First-time CTA, drawer, "Neue Sessions generieren", preferences | ✓ Yes – Category Screens/requirements.md; **now** Session Generation/requirements.md |
| Search → session | suggestedTopics (findMatchingTopics), card tap → CategorySessionGenerator.generateSingleSession | ✓ Session drawer: 3 suggestions, X icon, start only via card; Session Generation/requirements.md §3 |

### 2.2 Gaps Addressed by New Documents

- **Session Generation** had no single **requirements.md** with a checklist of functional requirements and pointers to existing docs.  
  → **Created:** [APP-Feature Description/Session Generation/requirements.md](APP-Feature%20Description/Session%20Generation/requirements.md)  
- **Session Generation** had no **README.md** indexing all docs and summarizing the Swift implementation.  
  → **Created:** [APP-Feature Description/Session Generation/README.md](APP-Feature%20Description/Session%20Generation/README.md)  
- **Search → session** and **sound generation** are explicitly marked as not working in Session Generation/requirements.md and in PRD 07/08.

### 2.3 Session Generation – Summary

| Status | Item |
|--------|------|
| ✓ | Topic-based generation (11 topics, stages, naming, content IDs) is implemented and now fully reflected in Session Generation/requirements.md and README.md. |
| ✓ | Category-based generation (5 sessions, preferences) is implemented and documented in Category Screens and Session Generation. |
| ✓ | Content resolution (resolver + mapping, display names, no category fallback) is documented in refactoring report and base-documentation; referenced in requirements.md. |
| ◐ | Search → session: flow exists in code but is **known not working**; documented in requirements.md §3 and PRD 07/08. |
| ✓ | Naming and content-ID docs (AWAVE-Session-Naming-Logic, Session-Content-IDs-Catalog, base-documentation) are linked from requirements.md. |

---

## 3. Registration Flows – Cross-Check

### 3.1 What Exists in Code (Swift)

| Flow / Component | Implementation | Documented in Requirements? |
|------------------|----------------|-----------------------------|
| Preloader → route by onboarding | RootView, PreloaderView, hasCompletedOnboarding | ✓ Start Screens; User Onboarding; **now** Registration Flows/requirements.md |
| Onboarding slides + category | OnboardingView, OnboardingViewModel, CategorySelectionView, OnboardingStorageService | ✓ User Onboarding Screens/requirements.md; **now** Registration Flows/requirements.md |
| Category → Main Tabs initial tab | TabSelectionService, selectedCategory, MainTabView | ✓ User Onboarding, Category Screens; **now** Registration Flows/requirements.md |
| Sign up / Sign in (email, Apple) | AuthView, AuthViewModel, AuthService | ✓ Authentication/requirements.md; **now** Registration Flows/requirements.md |
| Email verification (screen, deep link, resend) | EmailVerificationView, onOpenURL, applyEmailVerificationActionCode | ✓ Authentication/requirements.md §3; **now** Registration Flows/requirements.md |
| Guest path | isGuestMode, no forced auth after onboarding | ✓ User Onboarding; **now** Registration Flows/requirements.md |
| Onboarding sync for authenticated users | FirestoreUserRepository (onboarding_completed, category, etc.) | ✓ Authentication §6, User Onboarding; **now** Registration Flows/requirements.md |

### 3.2 Gaps Addressed by New Documents

- **Registration** was spread across Authentication, User Onboarding Screens, and Start Screens with no single flow-level document.  
  → **Created:** [APP-Feature Description/Registration Flows/](APP-Feature%20Description/Registration%20Flows/) with **README.md** and **requirements.md** that tie preloader → onboarding → auth → email verification → main app and reference the existing feature requirements.

### 3.3 Registration Flows – Summary

| Status | Item |
|--------|------|
| ✓ | Launch, preloader, and routing by onboarding state are implemented and documented in Start Screens / User Onboarding; flow-level checklist in Registration Flows/requirements.md. |
| ✓ | Onboarding (slides, category, completion, persistence, backend sync) is fully covered in User Onboarding Screens and referenced in Registration Flows. |
| ✓ | Authentication (email, Apple, session, email verification, deep link) is fully covered in Authentication/requirements.md and referenced in Registration Flows. |
| ✓ | Guest path and “no forced auth after onboarding” are reflected in Registration Flows/requirements.md. |
| ◐ | Email authentication is **deprioritized** (known issue PRD 07); requirements still describe implemented behaviour. |

---

## 4. New Documents and Folders Created

| Item | Purpose |
|------|---------|
| **APP-Feature Description/Session Generation/requirements.md** | Functional requirements checklist for session generation (topic, category, UI, resolution, search); references to all existing Session Generation docs. |
| **APP-Feature Description/Session Generation/README.md** | Session Generation overview, Swift implementation summary, and index of all docs in the folder. |
| **APP-Feature Description/Registration Flows/** | New folder for flow-level registration documentation. |
| **APP-Feature Description/Registration Flows/README.md** | Overview of registration flows (preloader, onboarding, auth, email verification, main app) and related feature folders. |
| **APP-Feature Description/Registration Flows/requirements.md** | Flow-level requirements (launch, onboarding, auth, email verification, main app) with references to Authentication and User Onboarding Screens. |
| **docs/Requirements/SESSION-GENERATION-AND-REGISTRATION-CROSSCHECK.md** | This cross-check document. |

---

## 5. Conclusion

- **Session generation:** Logic (topic-based, category-based, content resolution, naming) is implemented and was already partially documented in multiple Session Generation docs. The new **requirements.md** and **README.md** in Session Generation provide a single checklist and index; search→session and sound generation are explicitly marked as not working.  
- **Registration flows:** Preloader, onboarding, auth, and email verification are implemented and documented in Authentication and User Onboarding Screens. The new **Registration Flows** folder and its **requirements.md** provide a single flow-level view and references to those features.  
- **Quercheck:** Both areas are now fully represented in the Requirements; new documents and the Registration Flows folder close the remaining gaps.

---

**Related PRD documents:**  
[07-PRODUCTION-READY-OVERVIEW.md](PRD/07-PRODUCTION-READY-OVERVIEW.md) (known issues), [08-TESTABDECKUNG-UND-UI-TESTS.md](PRD/08-TESTABDECKUNG-UND-UI-TESTS.md) (test coverage and known issues).
