# Missing Features Migration from OLD-APP (V.1)

This folder documents features from the original AWAVE app (OLD-APP V.1) that need to be migrated to the React Native iOS app.

## 📋 Overview

The OLD-APP (V.1) is a Capacitor-based web app with extensive audio generation, session management, and content features. This document tracks all features that exist in V.1 but are missing or incomplete in the current React Native implementation.

## 🎯 Migration Priority

### High Priority (Core Features)
1. **Multi-Phase Session System** - Complex session editing with multiple phases
2. **Frequency Generation System** - Binaural, monaural, isochronic beats
3. **Noise Generation System** - White, pink, brown, grey, blue, violet noise
4. **Session Import/Export** - Share sessions as .awave files
5. **Content Database** - Extensive guided meditation and audio content library

### Medium Priority (User Experience)
6. **Preset Sounds Library** - Preloaded audio files and preset configurations per category
7. **Symptom Finder** - AI-like topic detection from user input
8. **Multiple Voice Options** - Flo, Franca, Marion, Corinna voice selection
9. **Live Volume Control** - Real-time volume adjustment during playback
10. **Session Generator** - Topic-based automatic session generation
11. **Preset Frequency Settings** - Gamma, beta, alpha, theta, delta presets

### Low Priority (Advanced Features)
11. **Pro Mode Unlock** - Hidden unlock mechanism
12. **Session Phase Editor** - Advanced phase editing interface
13. **Volume Slider Editor** - Per-phase volume control
14. **Content Editor** - Live content switching during playback

## 📁 Feature Folders

Each missing feature has its own folder with complete documentation:
- `Multi-Phase Session System/`
- `Frequency Generation System/`
- `Noise Generation System/`
- `Session Import Export/`
- `Content Database/`
- `Preset Sounds Library/` - **Preloaded audio files and preset configurations**
- `Symptom Finder/`
- `Multiple Voice Options/`
- `Live Volume Control/`
- `Session Generator/`
- `Preset Frequency Settings/`
- `Pro Mode Unlock/`
- `Session Phase Editor/`
- `Volume Slider Editor/`
- `Content Editor/`

## 🔍 Source Code References

### OLD-APP Repository
- **Repository:** https://github.com/AWAVE-2/OLD-APP
- **Main Entry:** `src/js/main.js`
- **Session Management:** `src/js/session-object.js`
- **Frequency/Noise:** `src/js/generator-frequency-noise.js`
- **Content Database:** `src/js/content-database.js`
- **Session Generator:** `src/js/generator-session-content.js`
- **Live Editor:** `src/js/editor-live.js`
- **Phase Editor:** `src/js/editor-phase.js`

## 📊 Feature Comparison Matrix

| Feature | OLD-APP (V.1) | React Native | Status |
|---------|---------------|--------------|--------|
| Multi-Phase Sessions | ✅ Full | ⚠️ Partial | Missing |
| Frequency Generation | ✅ Full | ❌ None | Missing |
| Noise Generation | ✅ Full | ❌ None | Missing |
| Session Import/Export | ✅ Full | ❌ None | Missing |
| Content Database | ✅ Full | ⚠️ Partial | Missing |
| Symptom Finder | ✅ Full | ❌ None | Missing |
| Multiple Voices | ✅ Full | ❌ None | Missing |
| Live Volume Control | ✅ Full | ⚠️ Partial | Missing |
| Session Generator | ✅ Full | ❌ None | Missing |
| Preset Frequencies | ✅ Full | ❌ None | Missing |
| Preset Sounds Library | ✅ Full | ❌ None | Missing |

## 🚀 Migration Strategy

1. **Phase 1:** Core audio generation (Frequency + Noise)
2. **Phase 2:** Multi-phase session system
3. **Phase 3:** Content database and session generator
4. **Phase 4:** Advanced editing features
5. **Phase 5:** Import/export and sharing

## 📝 Notes

- All features from OLD-APP should be reviewed for React Native compatibility
- Some features may need native module implementations
- Audio generation features require careful performance optimization
- Session format compatibility must be maintained for import/export

---

*Last Updated: 2025-01-27*
*Total Missing Features: 15*
