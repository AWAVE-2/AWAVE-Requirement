# Session Based Asynchronous Download of Audio Files - Functional Requirements

## 📋 Core Requirements

### 1. On-Demand Download System

#### Automatic Download on Selection
- [x] System downloads audio file when user selects it for playback
- [x] Check local cache first before downloading
- [x] Download only if file not already available locally
- [x] Prevent duplicate downloads via download queue
- [x] Track download progress with callbacks
- [x] Fallback to streaming if download fails
- [x] Continue playback even if download fails

#### Download Queue Management
- [x] Track active downloads in queue
- [x] Prevent duplicate concurrent downloads for same file
- [x] Return existing download promise if already in progress
- [x] Clean up queue on download completion
- [x] Clean up queue on download failure
- [x] Handle queue errors gracefully

#### Progress Tracking
- [x] Provide progress callbacks during download
- [x] Track bytes written and total bytes
- [x] Calculate progress percentage (0-100)
- [x] Mark download as complete when finished
- [x] Support progress updates every 500ms
- [x] Log progress in development mode

### 2. Metadata Caching System

#### Metadata Loading
- [x] Load complete audio library metadata at app startup
- [x] Load metadata in batches (100 files per batch)
- [x] Handle large catalogs (3000+ files)
- [x] Store metadata in in-memory Map for fast access
- [x] Convert Supabase metadata to AudioFile format
- [x] Track loading progress
- [x] Handle loading errors gracefully

#### Metadata Storage
- [x] Store metadata in memory Map (O(1) lookup)
- [x] Include all searchable fields (title, description, tags)
- [x] Include file metadata (size, duration, category)
- [x] Include storage information (local path, remote URL)
- [x] Include download status (isDownloaded)
- [x] Include search weight for relevance sorting

#### Metadata Search
- [x] Search uses cached metadata (no network calls)
- [x] Search by title, description, and tags
- [x] Filter by category
- [x] Sort by relevance, duration, or title
- [x] Apply result limits
- [x] Return results in < 50ms

#### Real-Time Metadata Sync
- [x] Subscribe to Supabase real-time changes
- [x] Handle INSERT events (new files)
- [x] Handle UPDATE events (file changes)
- [x] Handle DELETE events (file removal)
- [x] Update in-memory cache automatically
- [x] No app restart required for updates

### 3. Download Management

#### Download Execution
- [x] Get streaming URL (signed for premium, public for free)
- [x] Create local directory structure if needed
- [x] Download file using react-native-fs
- [x] Track download progress
- [x] Update file metadata on completion
- [x] Save to downloaded files set
- [x] Persist download state to AsyncStorage

#### Local File Management
- [x] Store files in Documents/audio directory
- [x] Organize by category subdirectories
- [x] Verify file existence after download
- [x] Update file size and metadata
- [x] Mark file as downloaded
- [x] Update storage type to 'local'

#### Download Error Handling
- [x] Handle network errors gracefully
- [x] Handle storage errors
- [x] Handle invalid URLs
- [x] Fallback to streaming on error
- [x] Log errors for debugging
- [x] Continue app operation on failure

### 4. Cache Management

#### Cache Size Management
- [x] Enforce 2GB maximum cache size
- [x] Calculate total cache size
- [x] Check available storage space
- [x] Track cache statistics
- [x] Monitor cache hit rate
- [x] Log cache operations

#### Cache Cleanup
- [x] Trigger cleanup when cache exceeds limit
- [x] Use LRU (Least Recently Used) eviction
- [x] Sort files by last access time
- [x] Remove oldest files first
- [x] Clean to 80% capacity
- [x] Update metadata after cleanup
- [x] Save cleanup timestamp

#### Cache Statistics
- [x] Track total downloaded files
- [x] Track total cache size (MB)
- [x] Track available storage space
- [x] Calculate cache hit rate
- [x] Track last cleanup timestamp
- [x] Provide cache stats API

### 5. Background Download Service

#### Category Downloads
- [x] Download all files from specific category
- [x] Support priority categories (music, nature, noise, sound)
- [x] Track download progress per category
- [x] Handle download errors per file
- [x] Continue downloading remaining files on error
- [x] Log download statistics

#### Favorites Downloads
- [x] Download user's favorite sounds
- [x] Trigger after user login
- [x] High priority downloads
- [x] Track download status
- [x] Handle errors gracefully

#### Download Status
- [x] Track if download is in progress
- [x] Get download queue size
- [x] Prevent concurrent downloads
- [x] Provide status API

### 6. Integration with Playback System

#### Playback Integration
- [x] UnifiedAudioPlaybackService triggers downloads
- [x] Priority: Generated > Local > Download > Stream
- [x] Check local file before downloading
- [x] Download if not available locally
- [x] Play downloaded file immediately
- [x] Fallback to streaming if download fails

#### Source Detection
- [x] Detect if sound is generated
- [x] Detect if sound is local
- [x] Detect if sound needs download
- [x] Detect if sound should stream
- [x] Return source type for UI

#### Offline Availability
- [x] Check if sound is available offline
- [x] Generated sounds always available
- [x] Local files available offline
- [x] Streamed files require network

---

## 🎯 User Stories

### As a user, I want to:
- Have files download automatically when I select them so I don't need to manually download
- See instant search results so I can find sounds quickly
- Only download files I actually use so I don't waste storage space
- Have downloads continue in the background so I can keep using the app
- See download progress so I know when files are ready
- Have offline access to downloaded files so I can use the app without internet

### As a user with limited storage, I want to:
- Have old unused files automatically removed so I don't run out of space
- See how much storage I'm using so I can manage my downloads
- Have the app manage cache size automatically so I don't need to worry about it

### As a user experiencing issues, I want to:
- Have downloads fallback to streaming if they fail so I can still play sounds
- Have the app continue working even if downloads fail
- See clear error messages if something goes wrong

---

## ✅ Acceptance Criteria

### On-Demand Download
- [x] File downloads automatically when user selects sound
- [x] Download starts within 1 second of selection
- [x] Progress is tracked and reported
- [x] Playback begins when download completes
- [x] Fallback to streaming if download fails

### Metadata Caching
- [x] Metadata loads within 30 seconds for 3000+ files
- [x] Search results return in < 50ms
- [x] All searchable fields are cached
- [x] Real-time updates work without app restart

### Cache Management
- [x] Cache size stays under 2GB
- [x] Old files are removed when limit reached
- [x] Cleanup reduces cache to 80% capacity
- [x] Cache statistics are accurate

### Background Downloads
- [x] Category downloads complete successfully
- [x] Favorites download after login
- [x] Download status is tracked
- [x] Errors don't block other downloads

---

## 🚫 Non-Functional Requirements

### Performance
- Metadata search completes in < 50ms
- Download starts within 1 second
- Metadata loading completes in < 30 seconds for 3000+ files
- Cache operations don't block UI
- Real-time sync updates don't cause performance issues

### Storage
- Maximum cache size: 2GB
- Automatic cleanup when limit reached
- LRU eviction maintains performance
- Cache statistics tracked accurately

### Reliability
- Downloads gracefully fallback to streaming on failure
- Network errors don't crash the app
- Storage errors are handled gracefully
- Real-time sync failures don't break functionality
- Cache corruption is handled

### Usability
- Downloads happen automatically (no user action required)
- Progress tracking available for UI
- Cache management is transparent to user
- Search is instant (no loading states)
- Offline availability is clear

---

## 🔄 Edge Cases

### Network Issues
- [x] Download fails due to network error → Fallback to streaming
- [x] Network lost during download → Resume or fallback
- [x] Slow network → Progress tracking shows status
- [x] Network timeout → Error handling and fallback

### Storage Issues
- [x] Storage quota exceeded → Cache cleanup triggered
- [x] Insufficient space for download → Error handling
- [x] File system errors → Graceful error handling
- [x] Corrupted cache files → Detection and cleanup

### Concurrent Operations
- [x] Multiple downloads for same file → Queue prevents duplicates
- [x] Download while cache cleanup → Coordination prevents conflicts
- [x] Metadata update during search → Cache update doesn't break search
- [x] App restart during download → Download state recovery

### Metadata Sync Issues
- [x] Real-time sync fails → App continues with cached data
- [x] Metadata update error → Error logged, app continues
- [x] Duplicate metadata updates → Idempotent handling
- [x] Stale metadata → Real-time sync updates cache

---

## 📊 Success Metrics

- On-demand download success rate > 95%
- Metadata search response time < 50ms
- Cache hit rate > 80%
- Download start time < 1 second
- Cache cleanup efficiency > 90%
- Real-time sync success rate > 99%
- Average metadata load time < 30 seconds for 3000+ files
