# Content Database - Feature Documentation

**Feature Name:** Content Database  
**Status:** ⚪ Missing - Needs Migration  
**Priority:** High  
**Source:** OLD-APP (V.1)  
**Last Updated:** 2025-01-27

## 📋 Feature Overview

The Content Database is an extensive library of guided meditation scripts, breathing exercises, body relaxation techniques, visualization journeys, and affirmation content. Each content item has metadata including duration, voice options, category, and associated audio files.

### Description

The OLD-APP contains a comprehensive content database with hundreds of content items organized by:
- **Type:** Text (guided meditation), Music, Nature sounds, Sound effects
- **Category:** Einleitung (Introduction), Atemtechnik (Breathing), Körperentspannung (Body Relaxation), Gedankenstille (Mental Silence), Traumreise (Dream Journey), Hypnose (Hypnosis), Affirmation
- **Topic:** sleep, stress, meditation, trauma, depression, etc.
- **Voice:** Flo, Franca, Marion, Corinna (with individual playtimes)

### User Value

- **Rich Content Library:** Hundreds of pre-recorded guided meditations
- **Multiple Voices:** Choice of voice for personal preference
- **Categorized Content:** Easy navigation by meditation type
- **Topic-Based:** Content organized by use case (sleep, stress, etc.)

---

## 🎯 Functional Requirements

### Core Requirements

#### Content Types
- [ ] Text content (guided meditations, scripts)
- [ ] Music content (background music tracks)
- [ ] Nature sounds (environmental audio)
- [ ] Sound effects (bells, chimes, etc.)

#### Content Categories
- [ ] Einleitung (Introduction) - 8 items
- [ ] Atemtechnik (Breathing Techniques) - 8 items
- [ ] Körperentspannung (Body Relaxation) - 6 items
- [ ] Gedankenstille (Mental Silence) - 3 items
- [ ] Traumreise (Dream Journey) - 11 items
- [ ] Hypnose (Hypnosis) - 7 items
- [ ] Affirmation - 40+ items

#### Content Metadata
- [ ] Name/ID
- [ ] Display name
- [ ] Category
- [ ] Topic
- [ ] Phase type (h1, h2)
- [ ] Duration per voice
- [ ] Audio file references
- [ ] Mix type (one, loop)

#### Content Access
- [ ] Search content by name
- [ ] Filter by category
- [ ] Filter by topic
- [ ] Get content by ID
- [ ] Get audio file path

### User Stories

- As a user, I want to browse meditation content by category so that I can find relevant meditations
- As a user, I want to see content duration for each voice so that I can plan my session
- As a user, I want to search for specific content so that I can quickly find what I need
- As a user, I want content organized by topic so that I can find content for my specific need

### Acceptance Criteria

- [ ] All content from OLD-APP is available
- [ ] Content is searchable and filterable
- [ ] Content metadata is complete
- [ ] Audio files are accessible
- [ ] Content can be used in session generation

---

## 🏗️ Technical Specification

### Source Code Reference (OLD-APP)

**File:** `src/js/content-database.js`

```javascript
// Content structure
function contentDB(name, dbList, h1, h2, type, category, mix, counter, topic, files, playtime) {
  this.name = name;
  this.dbList = dbList;
  this.h1 = h1;
  this.h2 = h2;
  this.type = type;
  this.category = category;
  this.mix = mix;
  this.counter = counter;
  this.topic = topic;
  this.files = files;
  this.playtime = playtime; // {Flo: 46, Franca: 40, Marion: 49, Corinna: 45}
}

// Example content
const Affirmationen = new contentDB(
  "Affirmationen",
  "Affirmationen",
  "Einleitung",
  "Affirmationen",
  "text",
  "Einleitung",
  "one",
  1,
  "user",
  [],
  {Flo: 46, Franca: 40, Marion: 49, Corinna: 45}
);
```

### Content Examples

**Text Content:**
- Affirmationen (Affirmations)
- Körperübung_im_Liegen (Body Exercise Lying)
- Atem_Achtsamkeit (Mindful Breathing)
- Bodyscan_Kurz (Short Body Scan)
- Ballonfahrt (Balloon Journey)
- Countdown_Einsteiger (Beginner Countdown)

**Music Content:**
- Various music genres for background

**Nature Content:**
- Forest sounds
- Ocean waves
- Rain sounds

**Sound Content:**
- Bells
- Chimes
- Singing bowls

### Components Needed

- `ContentBrowser.tsx` - Browse content library
- `ContentCard.tsx` - Display content item
- `ContentFilter.tsx` - Filter by category/topic
- `ContentSearch.tsx` - Search content
- `ContentDetails.tsx` - View content details

### Services Needed

- `ContentDatabaseService.ts` - Content data management
- `ContentSearchService.ts` - Content search functionality
- `ContentAudioService.ts` - Audio file management

### Hooks Needed

- `useContentDatabase.ts` - Content data access
- `useContentSearch.ts` - Search functionality
- `useContentFilter.ts` - Filtering functionality

### Data Models

```typescript
type ContentType = "text" | "music" | "nature" | "sound";
type ContentCategory = 
  | "Einleitung" 
  | "Atemtechnik" 
  | "Körperentspannung" 
  | "Gedankenstille" 
  | "Traumreise" 
  | "Hypnose" 
  | "Affirmation";

type VoiceName = "Flo" | "Franca" | "Marion" | "Corinna";

interface ContentItem {
  id: string;
  name: string;
  displayName: string;
  category: ContentCategory;
  type: ContentType;
  topic: string;
  headline1: string;
  headline2: string;
  mix: "one" | "loop";
  counter: number;
  audioFiles: string[];
  playtime: Record<VoiceName, number>; // seconds
}

interface ContentDatabase {
  text: ContentItem[];
  music: ContentItem[];
  nature: ContentItem[];
  sound: ContentItem[];
}
```

### Database Structure

Content should be stored in:
- **Supabase:** Content table with all metadata
- **Local:** Cached content for offline access
- **Audio Files:** Stored in Supabase Storage or CDN

---

## 🔄 User Flows

### Primary Flow: Browse Content

1. User opens content browser
2. System displays content by category
3. User selects category
4. System filters content
5. User browses content items
6. User selects content item
7. System shows content details

### Alternative Flow: Search Content

1. User opens content browser
2. User enters search query
3. System searches content names and descriptions
4. System displays results
5. User selects content item

### Alternative Flow: Use Content in Session

1. User creates/edits session phase
2. User opens content selector
3. User browses or searches content
4. User selects content
5. System adds content to phase
6. User saves phase

---

## 🎨 UI/UX Specifications

### Visual Design

- Category tabs for navigation
- Grid/list view of content items
- Content cards with name, category, duration
- Search bar at top
- Filter chips for topics

### Interactions

- Tap category to filter
- Tap content card to view details
- Swipe to see more content
- Pull to refresh content
- Search as you type

### Platform-Specific Notes

- **iOS:** Use native list components
- **Android:** Use RecyclerView for performance

---

## 📱 Platform Compatibility

- **iOS:** ⚠️ Partial - Some content exists, needs full database
- **Android:** ⚠️ Partial - Same as iOS

### Version Requirements

- iOS: 13.0+
- Android: API 21+

---

## 🔗 Related Features

- [Multi-Phase Session System](../Multi-Phase%20Session%20System/)
- [Session Generator](../Session%20Generator/)
- [Multiple Voice Options](../Multiple%20Voice%20Options/)
- [Sound Search](../../Sound%20Search%20/)

---

## 📚 Additional Resources

- OLD-APP Source: `src/js/content-database.js` (1926 lines)
- Content Loader: `src/js/content-loader.js`
- Current Implementation: Partial in various services

---

## 📝 Notes

- Content database is extensive (100+ items)
- Audio files need to be migrated to Supabase Storage
- Content metadata should be in database, not hardcoded
- Consider content versioning for updates
- Need content management system for updates

---

*Migration Priority: High*
*Estimated Complexity: Medium*
*Dependencies: Database, Audio Storage, Search Service*
