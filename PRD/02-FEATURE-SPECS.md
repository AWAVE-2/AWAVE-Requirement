# AWAVE - Feature-by-Feature Specifications
## Screen-Level Detail for Native iOS Implementation

**Implementation context (Feb 2026):** The app is implemented in **Swift 6.2 / SwiftUI**, **iOS 26.2**. This behaviour is the **baseline for the Android app**. See [docs/ANDROID-NORDSTERN.md](../../ANDROID-NORDSTERN.md) for current feature list and [docs/DOCUMENTATION-INDEX.md](../../DOCUMENTATION-INDEX.md) for recent implementations (navigation, onboarding, session generation, trial, etc.).

---

## F01: Splash Screen

**Source:** `navStartApp()` in `frontend-navigator.js:279`

**Behavior:**
1. Black screen fades out (1s)
2. Splash screen logo fades in (3s)
3. Splash screen fades out (1s)
4. Demo timer initialized: `10:00`
5. Content availability check begins
6. Transitions to Main Menu or Content Loader

**SwiftUI Implementation:**
- `@State` animation sequence with `.opacity` transitions
- Use `Task` with `try await Task.sleep` for timing
- No user interaction during splash

---

## F02: Content Loader

**Source:** `contentCheck()` / `content-loader.js`

**Behavior:**
- Verifies audio assets are available
- Generates file paths for all content items (`generateAllFilePaths()`)
- Shows loading indicator if needed
- Transitions to Main Menu when ready

**SwiftUI Implementation:**
- Verify bundled audio resources at launch
- Use `ProgressView` for loading state
- Cache audio file URLs for session use

---

## F03: Main Menu

**Source:** `navMainMenu()` in `frontend-navigator.js:304`

**Layout:**
- App logo header (Demo with timer / User / Pro variant)
- Menu bar (context: "Menu")
- Two main action buttons:
  - "Meditation" -> Meditation Topics
  - "Soundscapes" -> All Soundscapes
- Background: Default AWAVE theme

**Conditional Elements:**
| User Tier | Menu Items Visible |
|-----------|-------------------|
| Demo      | Meditation, Soundscapes, Favorites, Info |
| User      | Meditation, Soundscapes, Favorites, Info |
| Pro       | Session, Editor, Favorites, Info |

**SwiftUI Implementation:**
- `NavigationStack` with `@EnvironmentObject` for user tier
- `TabView` or custom tab bar for bottom navigation
- `@AppStorage` for user tier persistence

---

## F04: Meditation Topics

**Source:** `navMeditationTopic()` in `frontend-navigator.js:438`

**Layout:**
- Back button (-> Main Menu)
- Grid/list of 10+ topic cards with background images
- Each topic card: image + label
- "Symptom Finder" button at top/bottom

**Topics:** sleep, stress, depression, healing, dream, obe, trauma, meditation, belief, angry

**Interaction:**
1. User taps topic
2. Loading overlay shown (2s)
3. Session generated via `generateSession(topic)`
4. Navigate to User Session Config

**SwiftUI Implementation:**
- `LazyVGrid` with `AsyncImage` or bundled images
- `.sheet` or `NavigationLink` for topic selection
- Loading state with `ProgressView` overlay

---

## F05: Symptom Finder

**Source:** `navMeditationSymptom()` in `frontend-navigator.js:464`

**Layout:**
- Back button (-> Meditation Topics)
- Text input field
- Placeholder: "Ich kann nicht Einschlafen"
- Submit button
- Generate topic button

**Logic:**
1. User enters text
2. `findTopic(input)` matches keywords from `generator-keywords.js`
3. If SOS keywords detected -> SOS Screen
4. If topic matched -> Generate session
5. If no match -> Error dialog with "choose topic" option
6. Hidden Pro unlock: `checkSHA256(input)` validates password

**Keyword Categories (2,655 lines of German keywords):**
- `sos`: Self-harm/crisis terms -> Emergency screen
- `sleep`, `stress`, `depression`, `healing`, `dream`, `obe`, `trauma`, `meditation`, `belief`, `angry`, `problem`

**SwiftUI Implementation:**
- `TextField` with `@FocusState`
- Keyword matching as pure Swift function
- `.alert` for no-match case
- `.fullScreenCover` for SOS screen

---

## F06: SOS Screen

**Source:** `navSymptomSOS()` in `frontend-navigator.js:486`

**Layout:**
- Full-screen emergency information
- No menu bar
- Back button (clears input, returns to symptom finder)
- Confirm button (same behavior)

**Content:** Emergency contact information / crisis resources

**SwiftUI Implementation:**
- `fullScreenCover` presentation
- Clear input on dismiss
- Consider adding actual emergency numbers (112 DE, Telefonseelsorge)

---

## F07: User Session Config

**Source:** `navUserSessionConfig()` in `frontend-navigator.js:507`

**Layout:**
- Session overview with topic background theme
- Voice selector (if session contains text)
- Voice preview button (play/stop demo audio)
- Frequency toggle (if session contains frequency content)
- "Start Session" button
- "Regenerate Session" button (for topic-generated sessions)
- "Edit Session" button (Pro only)
- Back button (-> Meditation Topics)

**Conditional Elements:**
- Voice controls: hidden if no text content in any phase
- Frequency controls: hidden if no frequency content in any phase
- Edit button: Pro users only
- Regenerate button: topic-generated sessions only
- "Other Favorite" button: user-saved sessions

**SwiftUI Implementation:**
- `ScrollView` with themed background
- Audio preview via `AVAudioPlayer`
- Pre-session charging recommendation dialog

---

## F08: Soundscapes Browser

**Source:** `navAllSoundscapes()` in `frontend-navigator.js:577`

**Layout:**
- Back button (-> Main Menu)
- 4 category cards: Music, Nature, Frequency, Noise
- Each category -> detail grid

**Detail Views** (`navSoundscapeDetails`):
- Grid of items within selected category
- Each item creates a single-phase "soundscape" session
- Tapping item -> generates soundscape session -> Live Player

**SwiftUI Implementation:**
- `NavigationStack` with grid layouts
- Each soundscape item as `Button` that configures session and navigates

---

## F09: Live Player

**Source:** `navLivePlayer()` in `frontend-navigator.js:651`

**Layout:**
- Minimal "Live" header
- No menu bar
- Topic-themed background
- Progress bar (animated width)
- Session timer (countdown)
- Play/Pause toggle button
- Audio controls per track:
  - Track name + folder icon (tap to change content)
  - Volume slider
- Footer: Exit, Restart, EEG toggle

**Guided Session Controls:**
- Text, Music, Nature visible
- Frequency, Noise, Sound hidden

**Soundscape Controls:**
- Text hidden
- Music, Nature, Frequency, Noise, Sound visible
- Sound hidden if category is "Wecker"

**Live Content Change (Overlay):**
- Tap folder icon on any track -> modal overlay
- Browse and select new content for that track
- Content swap takes effect immediately

**Playback Logic:**
1. `startSession()` initializes all tracks
2. `startPhase(1)` begins first phase
3. Timer ticks every second via `createTimer()`
4. Progress bar animates to match elapsed time
5. At phase end -> auto-advance to next phase
6. At session end -> After Session screen
7. Pause: all audio paused, fades paused, sweep paused
8. Resume: all audio resumed, fades continued, sweep continued (with 100ms delay for freq/noise)

**SwiftUI Implementation:**
- `@StateObject` AudioEngine managing all tracks
- Custom `ProgressView` with animated bar
- `Timer.publish` for countdown
- `.sheet` for content change overlays
- `.onDisappear` cleanup

---

## F10: After Session

**Source:** `navAfterSession()` in `frontend-navigator.js:815`

**Layout:**
- Completion or abort icon
- Status message:
  - Completed: "SESSION ERFOLGREICH ABGESCHLOSSEN"
  - Aborted: "SESSION ABGEBROCHEN"
- Save to favorites prompt
- Buttons:
  - Save to Favorites
  - Exit to Menu
  - Edit Session (Pro only)
  - Export Session (Pro only)

**SwiftUI Implementation:**
- `VStack` with conditional content
- `.alert` for save name input

---

## F11: Favorites

**Source:** `navFavorites()` in `frontend-navigator.js:332`

**Layout:**
- Back button (-> previous page)
- List of saved sessions (newest first)
- Each item: session name + delete icon + navigate arrow
- Empty state: "--- Keine Favoriten vorhanden ---"
- Import button (hidden file input)
- Delete All button (with confirmation)

**Interactions:**
- Tap session name -> load and navigate (Pro: Editor, User: Config)
- Tap X icon -> confirm delete -> remove from storage
- Import -> file picker -> validate -> add to favorites

**Save Flow:**
1. Prompt for session name (placeholder: current date or session name)
2. Duplicate name handling: append "(2)", "(3)", etc.
3. Deep copy session, reset topic to "user"
4. Store in favorites array

**SwiftUI Implementation:**
- `List` with `swipeActions` for delete
- `.fileImporter` for import
- `@AppStorage` or SwiftData for persistence

---

## F12: Session Editor (Pro Only)

### F12a: New Session

**Source:** `navNewProSession()` in `frontend-navigator.js:901`

**Layout:**
- Create new session button
- Open favorites button
- Import session button

### F12b: Session Overview

**Source:** `navEditSession()` in `frontend-navigator.js:925`

**Layout:**
- Session name heading
- Total duration display
- Phase list:
  - Phase number (Roman numeral display)
  - Phase name (h1)
  - Phase content (h2)
  - Phase duration
  - Chevron for expand
- Active phase shows: gear icon, delete button, move up/down controls
- "Add Phase" button at bottom
- Footer: Save, Export, Start Session

**Phase Operations:**
- Add: appends new phase with 60s silence
- Delete: with confirmation dialog
- Move: swap with adjacent phase (up/down)
- Edit: navigate to Phase Editor

### F12c: Phase Editor

**Source:** `navEditPhase()` in `frontend-navigator.js:1017`

**Layout:**
- Phase header (phase number + timer)
- 6 collapsible editor sections (accordion pattern):
  1. Text (voice content)
  2. Music
  3. Nature
  4. Frequency
  5. Noise
  6. Sound
- Auto-opens first section with content
- Preview button (play/stop all phase audio)
- Footer: Back to Session, Show Session

**Phase Timer Controls:**
- +/- buttons with non-linear steps:
  - 1 min steps (1-5 min)
  - 5 min steps (5-15 min)
  - 10 min steps (15-30 min)
  - 15 min steps (30+ min)
- Locked when text content is `mix: "one"`
- Validation: fadeIn + fadeOut <= duration

**SwiftUI Implementation:**
- `DisclosureGroup` for accordion sections
- Custom stepper controls for timer/fade values
- `@Binding` to session model for real-time updates

---

## F13: Info Menu

**Source:** `navInfoMenu()` in `frontend-navigator.js:365`

**Sub-pages:**
1. Vorbereitung (Preparation guide)
2. Brainwave (Brainwave information)
3. AGB (Terms of use)
4. Datenschutz (Privacy policy)
5. Impressum (Imprint)
6. Haftungsausschluss (Disclaimer)
7. Support
8. Version -> Upgrade view (Demo/User) or Pro panel (Pro)

**SwiftUI Implementation:**
- `List` with `NavigationLink` for each item
- Static content views

---

## F14: Upgrade / Subscription View

**Source:** `viewUpgrade()` in `upgrade-demo.js:325`

**Demo -> User path:**
- Monthly/Yearly plan toggle
- Subscribe button -> StoreKit 2 purchase flow
- Restore purchases button (iOS only)
- Back button (resumes demo timer or restarts if expired)

**User subscription info:**
- Current plan display
- Purchase date
- Pricing info

**SwiftUI Implementation:**
- `SubscriptionStoreView` (StoreKit 2) or custom UI
- `Product` and `Transaction` APIs
- `.subscriptionStatusTask` for real-time status

---

## F15: EEG View

**Source:** `navShowEEG()` in `frontend-navigator.js:763`

**Note:** References to Muse EEG device integration exist in navigation code but actual Muse connectivity appears to be desktop-only (`liveFreeze`, `liveView` constants). The display exists as a placeholder/future feature.

**Recommendation:** Evaluate whether to include EEG view in iOS rewrite or defer.

---

## F16: Dialog System

**Source:** `confirmMessage()` in `selfLib-message.js`

**Pattern:** Modal dialog with:
- Title
- Message (supports HTML)
- Confirm button
- Cancel button
- Optional text input field
- Callback with confirmed boolean

**Used for:** All confirmations, errors, info messages, session naming

**SwiftUI Implementation:**
- Custom `AlertDialog` view modifier
- Support for text input variant
- Consistent styling across all dialogs
