# Session Import/Export - Feature Documentation

**Feature Name:** Session Import/Export  
**Status:** ⚪ Missing - Needs Migration  
**Priority:** High  
**Source:** OLD-APP (V.1)  
**Last Updated:** 2025-01-27

## 📋 Feature Overview

The Session Import/Export feature allows users to save their custom sessions as .awave files and share them with other users. Sessions can be exported from the app and imported back, maintaining full compatibility with the session structure.

### Description

In OLD-APP (V.1), users can:
- Export sessions as base64-encoded JSON files with .awave extension
- Import sessions from .awave files
- Share sessions with other users
- Save sessions to device storage (Capacitor Filesystem)
- Validate session compatibility before import

### User Value

- **Session Sharing:** Share custom sessions with friends and family
- **Backup:** Save sessions locally for backup
- **Portability:** Move sessions between devices
- **Community:** Build a library of shared sessions

---

## 🎯 Functional Requirements

### Core Requirements

#### Export Session
- [ ] Export session as .awave file
- [ ] Base64 encode session JSON
- [ ] Include session metadata (name, version, etc.)
- [ ] Save to device storage
- [ ] Share via system share sheet
- [ ] Validate session before export

#### Import Session
- [ ] Select .awave file from device
- [ ] Read and decode file
- [ ] Validate session format
- [ ] Check version compatibility
- [ ] Import session to favorites/library
- [ ] Handle import errors gracefully

#### Session Format
- [ ] AWAVE-Session identifier
- [ ] Version number
- [ ] Session configuration
- [ ] All phase data
- [ ] Audio element references

### User Stories

- As a user, I want to export my session so that I can share it with others
- As a user, I want to import a session file so that I can use sessions created by others
- As a user, I want to validate imported sessions so that I know they're compatible
- As a user, I want to save sessions locally so that I can backup my favorites

### Acceptance Criteria

- [ ] Sessions can be exported as .awave files
- [ ] Exported files can be imported successfully
- [ ] Version compatibility is checked
- [ ] Import errors are handled gracefully
- [ ] Sessions can be shared via system share sheet
- [ ] File format is documented

---

## 🏗️ Technical Specification

### Source Code Reference (OLD-APP)

**File:** `src/js/main.js` (lines 168-225)

```javascript
// Export session
$(".btnExportSession").on('click', function exportSession(){
  let now = new Date();
  let placeholder = "Session "+day+"."+month+"."+year;
  
  // Show name-session popUp
  confirmMessage(
    "Session als AWAVE-Favorit teilen",
    "Bitte gib dieser Session einen Namen:",
    "TEILEN",
    "ABBRECHEN",
    placeholder,
    async function (confirmed) {
      if (confirmed) {
        session[0].name = $('#message input').val().trim() || placeholder;
        session[0].topic = "user";
        
        const sessionString = JSON.stringify(session);
        const thisSession = window.btoa(sessionString);
        
        if ('Capacitor' in window) {
          const fileName = session[0].name.replace(/[^\w\säöüß]/g, "") + '.awave';
          const sessionWriteResult = await window.Capacitor.Plugins.Filesystem.writeFile({
            path: fileName,
            data: thisSession,
            directory: Directory.Documents
          });
          // Share file
        }
      }
    }
  );
});

// Import session
$('#importInput').change(function (event) {
  var file = event.target.files[0];
  var reader = new FileReader();
  
  reader.onload = function (e) {
    var fileContents = e.target.result;
    checkInput(window.atob(fileContents));
  };
  
  reader.readAsText(file);
});

function checkInput(input){
  let checkInputContent = input.match("AWAVE-Session");
  
  if( checkInputContent !== null ){
    let checkSessionVersion = input.match(version);
    
    if( checkSessionVersion !== null ){
      newSession = JSON.parse(input);
      refreshSession(newSession,"import",1);
    } else {
      // Version mismatch error
    }
  } else {
    // Invalid file error
  }
}
```

### File Format

```json
{
  "AWAVE-Session": true,
  "version": 1.3,
  "name": "Session Name",
  "config": { ... },
  "phases": [ ... ]
}
```

Base64 encoded, saved as `.awave` file.

### Components Needed

- `SessionExportModal.tsx` - Export session dialog
- `SessionImportModal.tsx` - Import session dialog
- `SessionShareSheet.tsx` - System share sheet integration
- `SessionFilePicker.tsx` - File picker for import

### Services Needed

- `SessionImportExportService.ts` - Import/export logic
- `SessionValidationService.ts` - Session validation
- `FileSystemService.ts` - File operations (React Native)

### Hooks Needed

- `useSessionExport.ts` - Export functionality
- `useSessionImport.ts` - Import functionality
- `useFileSystem.ts` - File system operations

### Data Models

```typescript
interface ExportedSession {
  "AWAVE-Session": boolean;
  version: number;
  name: string;
  config: SessionConfig;
  phases: SessionPhase[];
}

interface ImportResult {
  success: boolean;
  session?: ExportedSession;
  error?: string;
}
```

### React Native Implementation

**iOS:**
- Use `react-native-share` for sharing
- Use `react-native-document-picker` for file selection
- Use `react-native-fs` for file operations

**Android:**
- Use `react-native-share` for sharing
- Use `react-native-document-picker` for file selection
- Use `react-native-fs` for file operations

---

## 🔄 User Flows

### Primary Flow: Export Session

1. User creates/edits session
2. User taps export button
3. System shows name input dialog
4. User enters session name (or uses default)
5. User confirms export
6. System encodes session to base64
7. System saves as .awave file
8. System shows share sheet
9. User shares file

### Primary Flow: Import Session

1. User taps import button
2. System shows file picker
3. User selects .awave file
4. System reads file
5. System decodes base64
6. System validates session format
7. System checks version compatibility
8. System imports session to library
9. System shows success message

### Error Flow: Invalid File

1. User selects invalid file
2. System shows error message
3. User can try again

### Error Flow: Version Mismatch

1. User imports old version session
2. System detects version mismatch
3. System shows compatibility error
4. User is informed of incompatibility

---

## 🎨 UI/UX Specifications

### Visual Design

- Export button in session editor
- Import button in library/favorites
- Modal dialogs for export/import
- Progress indicator during file operations
- Success/error messages

### Interactions

- Tap to export/import
- Text input for session name
- File picker for import
- Share sheet for export
- Cancel option at all steps

### Platform-Specific Notes

- **iOS:** Use native share sheet
- **Android:** Use Android share intent

---

## 📱 Platform Compatibility

- **iOS:** ❌ Not Supported - Needs implementation
- **Android:** ❌ Not Supported - Needs implementation

### Version Requirements

- iOS: 13.0+
- Android: API 21+

### Required Libraries

- `react-native-share` - For sharing files
- `react-native-document-picker` - For file selection
- `react-native-fs` - For file operations
- `base64-js` - For base64 encoding/decoding

---

## 🔗 Related Features

- [Multi-Phase Session System](../Multi-Phase%20Session%20System/)
- [Library](../../Library/)
- [Favorite Functionality](../../Favorite%20Functionality/)

---

## 📚 Additional Resources

- OLD-APP Source: `src/js/main.js` (lines 168-225)
- React Native Share: https://github.com/react-native-share/react-native-share
- React Native Document Picker: https://github.com/rnmods/react-native-document-picker

---

## 📝 Notes

- File format should maintain backward compatibility
- Consider adding session preview before import
- May want to add session marketplace in future
- File size could be large for complex sessions
- Consider compression for large sessions

---

*Migration Priority: High*
*Estimated Complexity: Medium*
*Dependencies: File System, Session Structure*
