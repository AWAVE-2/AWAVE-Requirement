# SOS Screen - Functional Requirements

## 📋 Core Requirements

### 1. SOS Trigger Detection

#### Keyword Detection
- [x] System detects crisis-related keywords in search queries
- [x] Keyword matching is case-insensitive
- [x] Keywords are configurable via database
- [x] Multiple keywords can trigger SOS
- [x] Partial keyword matches supported (query contains keyword)
- [x] Keyword list loaded from `sos_config` table
- [x] Active configuration check (only active configs used)

#### Trigger Behavior
- [x] SOS screen opens automatically when keywords detected
- [x] Search results are bypassed when SOS triggered
- [x] Search drawer closes temporarily when SOS opens
- [x] SOS drawer overlays search drawer (higher z-index)
- [x] Search query is logged with SOS trigger flag
- [x] No search results shown when SOS triggered

### 2. SOS Screen Display

#### Screen Layout
- [x] Full-height bottom sheet (100% screen height)
- [x] Scrollable content for long resource lists
- [x] Header with "Soforthilfe" label and close button
- [x] Optional image display (if configured)
- [x] Title and message section
- [x] Action buttons section (call, chat)
- [x] Resources list section
- [x] Information box at bottom

#### Content Display
- [x] Title displayed from configuration (default: "Du bist nicht ALLEIN")
- [x] Message displayed from configuration
- [x] Image displayed if `image_url` provided
- [x] Phone number displayed in call button
- [x] Chat button displayed if `chat_link` provided
- [x] Resources list displayed (all configured resources)
- [x] Phone numbers extracted from resource text
- [x] Clickable resources (if phone number detected)

### 3. Emergency Actions

#### Phone Call Functionality
- [x] "Sofort anrufen" button with phone number
- [x] Phone number formatted for dialing (spaces/hyphens removed)
- [x] Native phone dialer opens on button press
- [x] Phone number validation before dialing
- [x] Error handling if phone unavailable
- [x] German phone number format support (+49, 0800, 116, etc.)
- [x] Resource items with phone numbers are clickable

#### Chat Link Functionality
- [x] "Online-Chat starten" button (if chat_link configured)
- [x] External browser/app opens chat link
- [x] URL validation before opening
- [x] Error handling if link unavailable
- [x] Button hidden if no chat_link configured

#### Resource Interaction
- [x] Resources displayed as clickable items
- [x] Phone numbers automatically extracted from resource text
- [x] Resources with phone numbers trigger calls
- [x] Resources without phone numbers are display-only
- [x] Phone icon shown for callable resources

### 4. Configuration Management

#### Configuration Loading
- [x] SOS config loaded from `sos_config` database table
- [x] Only active configurations used (`active: true`)
- [x] Most recent config used if multiple active
- [x] Configuration cached for 1 hour
- [x] Cache refresh on expiration
- [x] Fallback to defaults if config unavailable
- [x] Error handling for database failures

#### Configuration Fields
- [x] `keywords` - Array of trigger keywords
- [x] `title` - Screen title text
- [x] `message` - Supportive message text
- [x] `image_url` - Optional image URL
- [x] `phone_number` - Primary emergency phone number
- [x] `chat_link` - Optional chat service URL
- [x] `resources` - Array of additional resource strings
- [x] `active` - Boolean flag for activation

#### Default Values
- [x] Default title: "Du bist nicht ALLEIN"
- [x] Default message: "Wenn du in einer Krise bist oder sofortige Unterstützung brauchst, sind diese professionellen Hilfsangebote für dich da."
- [x] Default phone: "0800 111 0 111"
- [x] Default resources: Empty array
- [x] Default image: None (optional)

### 5. Navigation & Integration

#### Drawer Management
- [x] SOS drawer opens over search drawer
- [x] Search drawer closes when SOS opens
- [x] Search drawer reopens when SOS closes
- [x] Smooth transition between drawers
- [x] Swipe-down gesture to close SOS
- [x] Close button dismisses SOS
- [x] Z-index management (SOS: 300, Search: default)

#### Search Integration
- [x] Search hook detects SOS keywords
- [x] Search results bypassed when SOS triggered
- [x] Search query cleared when SOS closes
- [x] Search state preserved during SOS display
- [x] SOS state cleared after dismissal

### 6. Analytics & Tracking

#### Search Analytics
- [x] Search queries logged to `search_analytics` table
- [x] SOS trigger flag included in analytics
- [x] Results count logged (0 when SOS triggered)
- [x] User ID associated (when authenticated)
- [x] Anonymous tracking supported
- [x] Timestamp recorded

#### Analytics Fields
- [x] `user_id` - User identifier (nullable)
- [x] `search_query` - Original search query
- [x] `results_count` - Number of results (0 for SOS)
- [x] `sos_triggered` - Boolean flag
- [x] `created_at` - Timestamp

---

## 🎯 User Stories

### As a user in crisis, I want to:
- Find help quickly by searching for crisis-related terms
- See professional support resources immediately
- Call a crisis hotline with one tap
- Access online chat support if available
- See multiple support options in one place
- Close the SOS screen easily when done

### As a user searching normally, I want to:
- Not see SOS screen for non-crisis searches
- Have normal search results for regular queries
- Not be interrupted by SOS for unrelated searches

### As an administrator, I want to:
- Configure SOS keywords via database
- Update support resources without app updates
- Control which configuration is active
- Monitor SOS trigger frequency via analytics
- Customize messaging and resources

---

## ✅ Acceptance Criteria

### SOS Trigger
- [x] SOS triggers within 1 second of keyword detection
- [x] Keywords match case-insensitively
- [x] Multiple keywords can trigger SOS
- [x] Partial matches work (query contains keyword)
- [x] Non-crisis searches show normal results

### SOS Screen Display
- [x] Screen opens full-height immediately
- [x] All configured content displays correctly
- [x] Image loads if URL provided
- [x] Phone number displays correctly
- [x] Chat button shows only if link configured
- [x] Resources list displays all items
- [x] Scroll works for long content

### Emergency Actions
- [x] Phone call initiates within 2 seconds
- [x] Phone number formats correctly
- [x] Chat link opens in external app/browser
- [x] Resource phone numbers extract correctly
- [x] Error messages show if action unavailable
- [x] Actions work on both iOS and Android

### Configuration
- [x] Config loads within 3 seconds on app start
- [x] Cache reduces database calls
- [x] Active config selected correctly
- [x] Defaults used if config unavailable
- [x] Config updates reflect after cache expiry

### Navigation
- [x] Smooth transition between search and SOS
- [x] SOS overlays search correctly
- [x] Close returns to search
- [x] Swipe gesture works
- [x] Multiple open/close cycles work

---

## 🚫 Non-Functional Requirements

### Performance
- SOS screen opens in < 1 second after trigger
- Configuration loads in < 3 seconds
- Phone call initiates in < 2 seconds
- Cache reduces database calls by 90%+
- Smooth animations (60fps)

### Reliability
- SOS always available (even if config fails)
- Default values ensure functionality
- Error handling prevents crashes
- Network failures handled gracefully
- Cache fallback works

### Usability
- Clear, supportive messaging
- Large, accessible buttons
- Easy dismissal
- Intuitive navigation
- Professional appearance

### Privacy
- No sensitive data stored
- Anonymous tracking supported
- User identification optional
- No personal information required
- Secure database access

---

## 🔄 Edge Cases

### Configuration Issues
- [x] No configuration available → Use defaults
- [x] Configuration load fails → Use defaults
- [x] Multiple active configs → Use most recent
- [x] Empty keywords array → No triggers
- [x] Cache expired → Reload from database
- [x] Invalid image URL → Hide image gracefully

### Action Failures
- [x] Phone unavailable → Show error alert
- [x] Invalid phone number → Show error alert
- [x] Chat link unavailable → Show error alert
- [x] Invalid chat URL → Show error alert
- [x] No phone app installed → Show error alert

### Search Integration
- [x] Empty search query → No SOS trigger
- [x] Keyword in middle of query → Still triggers
- [x] Multiple keywords → Triggers once
- [x] Keyword as substring → Triggers correctly
- [x] Case variations → All trigger correctly

### Navigation Edge Cases
- [x] SOS opened while search loading → Wait for search
- [x] Multiple rapid triggers → Handle gracefully
- [x] App backgrounded during SOS → Preserve state
- [x] Network loss during config load → Use cache/defaults
- [x] Drawer already open → Replace smoothly

---

## 📊 Success Metrics

- SOS trigger detection accuracy > 95%
- SOS screen load time < 1 second
- Phone call success rate > 99%
- Chat link open success rate > 95%
- Configuration cache hit rate > 80%
- User satisfaction with SOS feature > 4.5/5
- Average time to access help < 5 seconds

---

## 🔐 Security & Privacy

### Data Protection
- [x] No sensitive search queries stored permanently
- [x] Analytics data anonymized when possible
- [x] User ID optional in analytics
- [x] No personal information required
- [x] Secure database access (RLS policies)

### Access Control
- [x] SOS accessible without authentication
- [x] Configuration admin-controlled
- [x] Database access secured
- [x] No user data exposed
- [x] Privacy-first design

---

## 📝 Configuration Schema

### Database Table: `sos_config`

```typescript
{
  id: string;                    // UUID primary key
  keywords: string[];            // Array of trigger keywords
  title: string;                 // Screen title
  message: string;                // Supportive message
  image_url: string | null;      // Optional image URL
  phone_number: string;          // Primary phone number
  chat_link: string | null;       // Optional chat URL
  resources: string[] | null;    // Additional resources
  active: boolean;                // Activation flag
  created_at: string;            // Timestamp
  updated_at: string;            // Timestamp
}
```

### Default Configuration

```typescript
{
  title: "Du bist nicht ALLEIN",
  message: "Wenn du in einer Krise bist oder sofortige Unterstützung brauchst, sind diese professionellen Hilfsangebote für dich da.",
  phone_number: "0800 111 0 111",
  resources: [],
  active: true
}
```

---

*For technical implementation details, see `technical-spec.md`*  
*For component structure, see `components.md`*  
*For service integration, see `services.md`*  
*For user flow diagrams, see `user-flows.md`*
