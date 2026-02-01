# SOS Screen & Search Integration - Test Scenarios

## Test Execution Date: 2026-02-01
## Implementation Version: Search Drawer Integration with Real-time SOS Trigger

---

## 🎯 Test Scope

This document covers test scenarios for the integrated SOS detection and search drawer functionality, including:
- Real-time SOS keyword detection (bypassing debounce)
- German SOS keyword support ("selbstmord", "suizid")
- Session generation loading feedback
- Search state cleanup on drawer dismissal

---

## ✅ Critical Path Test Scenarios

### Scenario 1: Real-Time SOS Trigger - English Keywords

**Objective**: Verify SOS triggers immediately when typing English crisis keywords

**Prerequisites**:
- App launched and user on Home tab
- Search drawer accessible

**Test Steps**:
1. Tap search button to open search drawer
2. Type "suicide" in search field
3. Observe timing and response

**Expected Results**:
- ✅ SOS sheet appears **immediately** (< 100ms after typing completes)
- ✅ No 300ms debounce delay occurs
- ✅ Search results **do not appear**
- ✅ SOS screen displays with:
  - "Du bist nicht ALLEIN" title
  - Crisis support message
  - Call button with phone number
  - Resources list (if configured)

**Actual Results**:
- [ ] PASS
- [ ] FAIL - Reason: _______________

**Notes**: _______________

---

### Scenario 2: Real-Time SOS Trigger - German Keywords

**Objective**: Verify newly added German keywords trigger SOS immediately

**Prerequisites**:
- App launched and user on Home tab
- Search drawer accessible

**Test Steps**:
1. Tap search button to open search drawer
2. Type "selbstmord" in search field
3. Observe timing and response
4. Close SOS screen
5. Clear search and type "suizid"
6. Observe timing and response

**Expected Results**:
- ✅ "selbstmord" triggers SOS immediately (< 100ms)
- ✅ "suizid" triggers SOS immediately (< 100ms)
- ✅ Both keywords work case-insensitively ("SELBSTMORD", "Suizid")
- ✅ Keywords work in sentences ("ich denke an selbstmord")
- ✅ No search results appear for either keyword

**Actual Results**:
- [ ] PASS - "selbstmord"
- [ ] PASS - "suizid"
- [ ] PASS - Case insensitive
- [ ] PASS - In sentences
- [ ] FAIL - Reason: _______________

**Notes**: _______________

---

### Scenario 3: SOS Trigger with Partial Keywords

**Objective**: Verify SOS triggers when keyword appears mid-sentence

**Prerequisites**:
- App launched
- Search drawer accessible

**Test Steps**:
1. Open search drawer
2. Type "I'm feeling suicidal"
3. Observe response
4. Close SOS, clear search
5. Type "ich habe suizid gedanken"
6. Observe response

**Expected Results**:
- ✅ "suicidal" (contains "suici") triggers SOS
- ✅ "suizid" in sentence triggers SOS
- ✅ Triggers happen immediately without debounce
- ✅ Entire query is logged for analytics

**Actual Results**:
- [ ] PASS
- [ ] FAIL - Reason: _______________

**Notes**: _______________

---

### Scenario 4: Normal Search with Debounce (Non-SOS)

**Objective**: Verify normal searches still use 300ms debounce for performance

**Prerequisites**:
- App launched
- Search drawer accessible

**Test Steps**:
1. Open search drawer
2. Type "rain" quickly
3. Note timing of search results appearing
4. Clear and type "meditation"
5. Observe debounce delay

**Expected Results**:
- ✅ Search results appear **after** 300ms debounce delay
- ✅ No immediate trigger (unlike SOS)
- ✅ Loading indicator shows during search
- ✅ Results display correctly when loaded

**Actual Results**:
- [ ] PASS
- [ ] FAIL - Reason: _______________

**Notes**: _______________

---

## 🎨 Session Generation Test Scenarios

### Scenario 5: Session Generation with Loading Feedback

**Objective**: Verify session loading shows visual feedback and handles success

**Prerequisites**:
- App launched with network connection
- Search drawer accessible

**Test Steps**:
1. Open search drawer
2. Search for "stress" (a topic with no sound results)
3. Wait for session suggestion to appear
4. Tap the session suggestion card
5. Observe loading state and completion

**Expected Results**:
- ✅ Session suggestion appears with "Vorgeschlagene Session" label
- ✅ Play button shows **ProgressView spinner** immediately on tap
- ✅ Button is **disabled** during loading (prevents double-tap)
- ✅ Session loads successfully
- ✅ Spinner disappears when loaded
- ✅ Drawer **dismisses automatically** on success
- ✅ Session **auto-plays** after loading
- ✅ Mini player appears with session

**Actual Results**:
- [ ] PASS
- [ ] FAIL - Reason: _______________

**Notes**: _______________

---

### Scenario 6: Session Generation Error Handling

**Objective**: Verify error handling when session loading fails

**Prerequisites**:
- App launched in airplane mode OR network unreliable
- Search drawer accessible

**Test Steps**:
1. Enable airplane mode
2. Open search drawer
3. Search for "anxiety" (triggers session suggestion)
4. Tap session suggestion card
5. Observe error handling

**Expected Results**:
- ✅ Loading spinner appears initially
- ✅ After timeout/failure, spinner disappears
- ✅ Error message displays: "Session konnte nicht geladen werden"
- ✅ Error text is red (AWAVETheme error color)
- ✅ Drawer **remains open** (doesn't dismiss on error)
- ✅ User can retry by tapping again
- ✅ No crash occurs

**Actual Results**:
- [ ] PASS
- [ ] FAIL - Reason: _______________

**Notes**: _______________

---

## 🧹 State Cleanup Test Scenarios

### Scenario 7: Search State Cleanup on Dismissal

**Objective**: Verify search state clears completely when drawer closes

**Prerequisites**:
- App launched
- Search drawer accessible

**Test Steps**:
1. Open search drawer
2. Search for "rain"
3. Wait for results to appear
4. Close drawer by:
   - a) Swiping down, OR
   - b) Tapping X button, OR
   - c) Tapping backdrop
5. Re-open search drawer
6. Observe initial state

**Expected Results**:
- ✅ Search field is **empty** when reopened
- ✅ No results from previous search visible
- ✅ No loading state persists
- ✅ No error messages visible
- ✅ Search tips show (empty state content)
- ✅ All state is fresh

**Actual Results**:
- [ ] PASS - Swipe down
- [ ] PASS - X button
- [ ] PASS - Backdrop tap
- [ ] FAIL - Reason: _______________

**Notes**: _______________

---

### Scenario 8: Session Loading State Cleanup

**Objective**: Verify session loading state clears when drawer closes

**Prerequisites**:
- App launched
- Search drawer accessible

**Test Steps**:
1. Open search drawer
2. Search for "focus" (session suggestion)
3. Tap session suggestion (start loading)
4. **While loading**, close drawer
5. Re-open search drawer
6. Search for "focus" again

**Expected Results**:
- ✅ Loading spinner stops when drawer closes
- ✅ No loading state persists when reopening
- ✅ Session suggestion appears fresh (no loading)
- ✅ Error message (if any) is cleared
- ✅ Can tap suggestion again without issues

**Actual Results**:
- [ ] PASS
- [ ] FAIL - Reason: _______________

**Notes**: _______________

---

## 🔄 Drawer Stacking Test Scenarios

### Scenario 9: SOS Over Search Drawer Stacking

**Objective**: Verify SOS drawer correctly overlays search drawer

**Prerequisites**:
- App launched
- Search drawer accessible

**Test Steps**:
1. Open search drawer
2. Type "suicide" to trigger SOS
3. Observe drawer stacking
4. Close SOS screen
5. Observe search drawer state

**Expected Results**:
- ✅ SOS sheet opens **over** search drawer
- ✅ Search drawer visible underneath (dimmed)
- ✅ Both drawers animate smoothly
- ✅ Closing SOS returns to search drawer
- ✅ Search query "suicide" still visible in field
- ✅ No navigation stack issues

**Actual Results**:
- [ ] PASS
- [ ] FAIL - Reason: _______________

**Notes**: _______________

---

### Scenario 10: Multiple SOS Triggers

**Objective**: Verify handling of multiple rapid SOS triggers

**Prerequisites**:
- App launched
- Search drawer accessible

**Test Steps**:
1. Open search drawer
2. Type "suicide"
3. Wait for SOS to open
4. Close SOS
5. Immediately type "selbstmord"
6. Observe response
7. Close and type "suizid"

**Expected Results**:
- ✅ Each keyword triggers SOS correctly
- ✅ No duplicate SOS screens stack
- ✅ Each trigger replaces previous state
- ✅ No memory leaks or crashes
- ✅ SOS screen content loads each time

**Actual Results**:
- [ ] PASS
- [ ] FAIL - Reason: _______________

**Notes**: _______________

---

## 📱 Cross-Platform Test Scenarios

### Scenario 11: iOS Simulator Testing

**Objective**: Verify all functionality on iOS simulator

**Device**: iPhone 15 (iOS 18.2 Simulator)

**Test Steps**:
1. Run all scenarios 1-10 on iOS simulator

**Expected Results**:
- ✅ All scenarios pass on iOS
- ✅ SwiftUI animations are smooth
- ✅ Touch targets work correctly
- ✅ Keyboard behavior is correct
- ✅ Phone dialer opens (simulator limitation okay)

**Actual Results**:
- [ ] PASS
- [ ] FAIL - Scenarios failing: _______________

**Notes**: _______________

---

### Scenario 12: Physical Device Testing

**Objective**: Verify all functionality on physical iPhone/iPad

**Device**: _______________ (iOS ___)

**Test Steps**:
1. Run all scenarios 1-10 on physical device

**Expected Results**:
- ✅ All scenarios pass on device
- ✅ Performance is smooth (60fps)
- ✅ Phone dialer actually opens
- ✅ Network requests work correctly
- ✅ No crashes or freezes

**Actual Results**:
- [ ] PASS
- [ ] FAIL - Scenarios failing: _______________

**Notes**: _______________

---

## 🧪 Edge Case Test Scenarios

### Scenario 13: Rapid Typing Before Debounce

**Objective**: Verify SOS triggers even with rapid typing

**Prerequisites**:
- App launched
- Search drawer accessible

**Test Steps**:
1. Open search drawer
2. Type "suicide" very quickly (< 300ms total)
3. Observe response timing

**Expected Results**:
- ✅ SOS triggers **immediately** after "e" in "suicide"
- ✅ No wait for debounce period
- ✅ Query is interrupted mid-typing
- ✅ SOS shows before user finishes typing

**Actual Results**:
- [ ] PASS
- [ ] FAIL - Reason: _______________

**Notes**: _______________

---

### Scenario 14: Backspacing After SOS Keyword

**Objective**: Verify behavior when user types then deletes SOS keyword

**Prerequisites**:
- App launched
- Search drawer accessible

**Test Steps**:
1. Open search drawer
2. Type "suicide" → SOS opens
3. Close SOS
4. Backspace to "sui"
5. Observe if SOS re-triggers

**Expected Results**:
- ✅ SOS does **not** re-trigger for "sui" (incomplete keyword)
- ✅ SOS only triggers on complete keyword match
- ✅ User can edit query freely after closing SOS
- ✅ No unexpected triggers

**Actual Results**:
- [ ] PASS
- [ ] FAIL - Reason: _______________

**Notes**: _______________

---

### Scenario 15: SOS Keyword Case Variations

**Objective**: Verify case-insensitive SOS detection

**Prerequisites**:
- App launched
- Search drawer accessible

**Test Steps**:
1. Test various case combinations:
   - "SUICIDE"
   - "Suicide"
   - "sUiCiDe"
   - "SELBSTMORD"
   - "Selbstmord"
   - "SUIZID"
   - "Suizid"

**Expected Results**:
- ✅ All case variations trigger SOS
- ✅ Detection is truly case-insensitive
- ✅ Timing is immediate for all variants

**Actual Results**:
- [ ] PASS - All variations work
- [ ] FAIL - Cases failing: _______________

**Notes**: _______________

---

## 📊 Performance Test Scenarios

### Scenario 16: SOS Trigger Latency Measurement

**Objective**: Measure actual latency of SOS trigger

**Prerequisites**:
- App launched
- Stopwatch or screen recording for frame analysis

**Test Steps**:
1. Record screen while typing "suicide"
2. Measure time from last character to SOS appearance
3. Repeat 5 times
4. Calculate average

**Expected Results**:
- ✅ Average latency < 100ms
- ✅ Maximum latency < 150ms
- ✅ Consistent across attempts
- ✅ Significantly faster than 300ms debounce

**Actual Results**:
- Attempt 1: ___ ms
- Attempt 2: ___ ms
- Attempt 3: ___ ms
- Attempt 4: ___ ms
- Attempt 5: ___ ms
- Average: ___ ms
- [ ] PASS
- [ ] FAIL

**Notes**: _______________

---

### Scenario 17: Session Generation Latency

**Objective**: Measure session generation and loading time

**Prerequisites**:
- App launched with good network connection

**Test Steps**:
1. Search for "stress"
2. Time from tapping suggestion to playback start
3. Repeat 3 times
4. Calculate average

**Expected Results**:
- ✅ Average time < 5 seconds
- ✅ Loading indicator visible throughout
- ✅ No timeout errors
- ✅ Smooth transition to playback

**Actual Results**:
- Attempt 1: ___ seconds
- Attempt 2: ___ seconds
- Attempt 3: ___ seconds
- Average: ___ seconds
- [ ] PASS
- [ ] FAIL

**Notes**: _______________

---

## 🔍 Regression Test Scenarios

### Scenario 18: Normal Search Still Works

**Objective**: Verify normal search functionality unaffected by changes

**Prerequisites**:
- App launched
- Sound database populated

**Test Steps**:
1. Search for "rain" → verify results appear
2. Search for "meditation" → verify results appear
3. Search for "sleep" → verify results appear
4. Tap a result → verify sound plays

**Expected Results**:
- ✅ All searches return relevant results
- ✅ Debounce works correctly (300ms)
- ✅ Results are sorted by relevance
- ✅ Sound playback works
- ✅ Mini player appears

**Actual Results**:
- [ ] PASS
- [ ] FAIL - Reason: _______________

**Notes**: _______________

---

### Scenario 19: Tab Navigation Preserved

**Objective**: Verify tab history preservation still works

**Prerequisites**:
- App launched

**Test Steps**:
1. Navigate to Library tab
2. Open search drawer
3. Close drawer with X button
4. Verify returned to Library tab
5. Open search from Home tab
6. Close with swipe
7. Verify on Home tab

**Expected Results**:
- ✅ X button returns to previous tab
- ✅ Swipe returns to current tab
- ✅ Tab state preserved correctly
- ✅ No navigation issues

**Actual Results**:
- [ ] PASS
- [ ] FAIL - Reason: _______________

**Notes**: _______________

---

## 📝 Analytics Test Scenarios

### Scenario 20: SOS Search Logging

**Objective**: Verify SOS triggers are logged correctly

**Prerequisites**:
- App launched with analytics enabled
- Access to Firestore analytics collection

**Test Steps**:
1. Type "suicide" to trigger SOS
2. Check Firestore `search_analytics` collection
3. Verify log entry created

**Expected Results**:
- ✅ Log entry created with:
  - `query`: "suicide"
  - `results_count`: 0
  - `sos_triggered`: true
  - `user_id`: (current user or anonymous)
  - `timestamp`: current time

**Actual Results**:
- [ ] PASS
- [ ] FAIL - Reason: _______________
- [ ] SKIP - Analytics not configured

**Notes**: _______________

---

## ✅ Test Summary Template

### Test Execution Summary

**Date**: _______________
**Tester**: _______________
**Build**: _______________
**Device(s)**: _______________

**Results**:
- Total Scenarios: 20
- Passed: ___ / 20
- Failed: ___ / 20
- Skipped: ___ / 20

**Critical Issues Found**:
1. _______________
2. _______________

**Minor Issues Found**:
1. _______________
2. _______________

**Recommendations**:
_______________

**Sign-off**:
- [ ] Ready for Production
- [ ] Needs Fixes (see issues above)
- [ ] Needs Retesting

---

## 🔧 Troubleshooting Guide

### Issue: SOS Not Triggering

**Symptoms**: Typing "suicide" shows search results instead of SOS

**Possible Causes**:
1. Keywords not loaded from keywords.json
2. SOS config not initialized
3. Keyword matching logic error

**Debug Steps**:
1. Check `SearchViewModel.swift:37-47` - SOS check before debounce
2. Verify `keywords.json:3` contains "suicide", "selbstmord", "suizid"
3. Check `checkForSOSTrigger()` implementation
4. Verify `showSOSScreen` state updates

---

### Issue: Session Loading Spinner Not Showing

**Symptoms**: No visual feedback when loading session

**Possible Causes**:
1. `isLoadingSession` state not updating
2. ProgressView conditional not working

**Debug Steps**:
1. Check `SearchDrawerView.swift:10` - state variable exists
2. Check `SearchDrawerView.swift:181` - state set to true
3. Check `SearchDrawerView.swift:221-229` - conditional rendering
4. Verify `disabled` modifier applied

---

### Issue: Search State Not Clearing

**Symptoms**: Previous search visible when reopening drawer

**Possible Causes**:
1. `.onDisappear` not called
2. State variables not reset

**Debug Steps**:
1. Check `SearchDrawerView.swift:87-93` - cleanup handler
2. Verify all state variables cleared
3. Check drawer dismissal triggers `.onDisappear`
4. Test with different close methods (swipe, X, backdrop)

---

*This test scenario document should be updated with actual results after each test execution cycle.*
