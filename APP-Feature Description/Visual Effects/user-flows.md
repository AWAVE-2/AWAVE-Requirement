# Visual Effects System - User Flows

## 🔄 Primary User Flows

### 1. Screen Navigation with Transitions

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Navigate to New Screen
   └─> AnimatedScreenTransition mounts
       └─> Check direction prop
           ├─> 'left' → Slide from right
           ├─> 'right' → Slide from left
           └─> 'none' → No animation
               └─> Apply transition
                   ├─> translateX animation
                   └─> opacity animation
                       └─> Complete in 300ms
                           └─> Screen visible
```

**Success Path:**
- Smooth slide transition
- Opacity fade-in
- 60fps performance
- No visual glitches

**Error Paths:**
- No direction specified → No animation
- Performance issue → Fallback to instant

---

### 2. Component Mount Animation

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Component Renders
   └─> AnimatedView mounts
       └─> Check animation prop
           ├─> 'fade' → Opacity 0→1
           ├─> 'slide-up' → TranslateY + opacity
           ├─> 'slide-down' → TranslateY + opacity
           ├─> 'scale' → Scale + opacity (spring)
           └─> 'none' → No animation
               └─> Apply animation
                   ├─> Check delay prop
                   │   └─> Wait for delay
                   └─> Start animation
                       ├─> Use native driver
                       └─> Complete in duration
                           └─> Component visible
```

**Success Path:**
- Smooth animation
- Correct timing
- 60fps performance

**Error Paths:**
- Invalid animation type → Fallback to fade
- Performance issue → Reduce animation complexity

---

### 3. Audio Player Visualization

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Audio Player Opens
   └─> AudioPlayerBackground mounts
       └─> Initialize animations
           ├─> Primary mesh: 80s rotation
           ├─> Secondary mesh: 65s rotation
           ├─> Tertiary mesh: 100s rotation
           ├─> 6 floating blobs: 40s-140s
           └─> Central glow: 15s pulse
               └─> All animations start
                   └─> Background visible

2. Audio Starts Playing
   └─> AudioPlayerVisualization mounts
       └─> Initialize animations
           ├─> 3 floating orbs start
           ├─> Gradient sweep starts
           └─> Waveform bars ready
               └─> isPlaying becomes true
                   └─> Waveform bars animate
                       ├─> Random heights (20-60px)
                       ├─> Staggered timing
                       └─> Continuous loop
                           └─> Visualization active

3. User Toggles Visualization
   └─> onToggleVisualization called
       └─> showVisualization toggles
           ├─> true → Show waveform bars
           └─> false → Show title/description
               └─> Smooth transition
```

**Success Path:**
- All animations start smoothly
- Waveform bars animate in real-time
- Toggle works instantly
- Performance remains good

**Error Paths:**
- Animation initialization fails → Fallback to static
- Performance issue → Reduce particle count

---

### 4. Interactive Element Press Feedback

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User Presses Button
   └─> InteractiveTouchableOpacity detects press
       └─> Check enableAnimation prop
           ├─> false → No animation
           └─> true → Continue
               └─> Check animation preset
                   ├─> 'scale' → Scale animation
                   ├─> 'opacity' → Opacity animation
                   ├─> 'translate' → Translate animation
                   └─> 'combined' → Multiple animations
                       └─> Apply animation
                           ├─> Check enableHaptic prop
                           │   └─> true → Trigger haptic
                           └─> Animation completes
                               └─> Visual feedback complete

2. User Releases Button
   └─> onPressOut triggered
       └─> Reverse animation
           └─> Return to original state
               └─> Animation complete
```

**Success Path:**
- Immediate visual feedback
- Smooth animation
- Haptic feedback (if enabled)
- Quick response time

**Error Paths:**
- Animation fails → Fallback to opacity change
- Haptic unavailable → Silent failure

---

### 5. Glass Morphism Effect Application

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Component Renders with GlassMorphism
   └─> GlassMorphism component mounts
       └─> Check platform
           ├─> iOS → Use BlurView with native blur
           ├─> Android → Use BlurView with Material blur
           └─> Other → Use fallback View
               └─> Apply intensity
                   ├─> 'light' → Low opacity/blur
                   ├─> 'medium' → Medium opacity/blur
                   ├─> 'heavy' → High opacity/blur
                   └─> 'ultra' → Maximum opacity/blur
                       └─> Apply variant
                           ├─> 'default' → Standard
                           ├─> 'card' → Card shadows
                           ├─> 'navigation' → Nav shadows
                           └─> 'modal' → Modal shadows
                               └─> Glass effect visible
```

**Success Path:**
- Platform-specific blur works
- Correct intensity applied
- Variant shadows applied
- Visual effect matches design

**Error Paths:**
- Blur unavailable → Fallback to semi-transparent
- Platform detection fails → Default to iOS

---

### 6. Gradient Overlay Application

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Component Renders with GradientOverlay
   └─> GradientOverlay component mounts
       └─> Check colors prop
           ├─> Provided → Use custom colors
           └─> Not provided → Use theme colors
               └─> Check direction prop
                   ├─> 'horizontal' → Left to right
                   ├─> 'vertical' → Top to bottom
                   └─> 'diagonal' → Top-left to bottom-right
                       └─> Apply intensity/opacity
                           └─> Gradient overlay visible
```

**Success Path:**
- Correct gradient direction
- Theme colors used if not specified
- Intensity applied correctly
- Smooth gradient rendering

**Error Paths:**
- Invalid colors → Fallback to theme colors
- Direction invalid → Default to diagonal

---

### 7. Glow Effect Application

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Component Renders with GlowEffect
   └─> GlowEffect component mounts
       └─> Check color prop
           ├─> Provided → Use custom color
           └─> Not provided → Use theme primary
               └─> Apply shadow styles
                   ├─> shadowColor: color
                   ├─> shadowOpacity: intensity
                   ├─> shadowRadius: radius
                   └─> elevation: Android support
                       └─> Glow effect visible
```

**Success Path:**
- Correct glow color
- Intensity and radius applied
- Platform-specific elevation
- Visual effect matches design

**Error Paths:**
- Invalid color → Fallback to theme color
- Platform issue → Standard shadow

---

## 🔀 Alternative Flows

### Particle Effect Animation

```
System Event                   System Response
─────────────────────────────────────────────────────────
1. ParticleEffect Mounts
   └─> Initialize particle array
       └─> Create Animated.Value for each particle
           └─> Start loop animations
               ├─> Staggered delays (index * 100ms)
               ├─> Random durations
               └─> Continuous loops
                   └─> Particles animate
                       ├─> Opacity transitions
                       ├─> Scale transitions
                       └─> Translate Y movement
                           └─> Continuous animation

2. Component Unmounts
   └─> Cleanup animations
       └─> Stop all particle animations
           └─> Release resources
```

**Automatic Behavior:**
- Runs continuously
- No user interaction required
- Performance optimized

---

### Wave Animation

```
System Event                   System Response
─────────────────────────────────────────────────────────
1. WaveAnimation Mounts
   └─> Initialize Animated.Value
       └─> Start loop animation
           ├─> Duration: 2000ms / speed
           └─> Continuous loop
               └─> Interpolate translateX
                   └─> Wave motion visible
                       └─> Continuous animation
```

**Automatic Behavior:**
- Runs continuously
- Speed adjustable
- Smooth wave motion

---

## 🚨 Error Flows

### Animation Performance Issue

```
System Event                   System Response
─────────────────────────────────────────────────────────
1. Animation Performance Degrades
   └─> Frame rate drops below 60fps
       └─> Performance monitoring detects issue
           └─> Reduce animation complexity
               ├─> Reduce particle count
               ├─> Simplify animations
               └─> Disable non-essential effects
                   └─> Performance restored
```

**Recovery:**
- Automatic optimization
- Graceful degradation
- User experience maintained

---

### Platform Blur Unavailable

```
System Event                   System Response
─────────────────────────────────────────────────────────
1. BlurView Fails to Initialize
   └─> Platform detection
       └─> Blur unavailable
           └─> Fallback to View
               └─> Apply semi-transparent overlay
                   └─> Visual effect maintained
                       └─> User experience preserved
```

**Recovery:**
- Graceful fallback
- Visual effect maintained
- No user-visible error

---

## 🔄 State Transitions

### Animation States

```
Initial → Animating → Complete
   │          │
   │          └─> Error → Fallback
   │
   └─> Cancelled → Cleanup
```

### Component States

```
Unmounted → Mounting → Mounted
    │          │          │
    │          └─> Error  │
    │                     │
    └─> Unmounting ←──────┘
```

---

## 📊 Flow Diagrams

### Complete Animation Lifecycle

```
Component Mount
    │
    ├─> Initialize Animation Values
    │   └─> Create SharedValue/Animated.Value
    │
    ├─> Setup Animation
    │   ├─> Get duration from animations.ts
    │   ├─> Get easing from animations.ts
    │   └─> Apply preset
    │
    ├─> Start Animation
    │   ├─> Use native driver
    │   └─> Run on UI thread
    │
    ├─> Animation Running
    │   └─> 60fps performance
    │
    └─> Component Unmount
        └─> Cleanup Animation
            └─> Stop and release
```

---

## 🎯 User Goals

### Goal: Smooth Transitions
- **Path:** AnimatedScreenTransition
- **Time:** < 300ms
- **Steps:** Automatic on navigation

### Goal: Visual Feedback
- **Path:** InteractiveTouchableOpacity
- **Time:** < 200ms
- **Steps:** Press → Animation → Release

### Goal: Immersive Experience
- **Path:** AudioPlayerVisualization + Background
- **Time:** Continuous
- **Steps:** Mount → Animate → Continuous loop

---

*For component interactions, see `components.md`*  
*For service calls, see `services.md`*  
*For technical details, see `technical-spec.md`*
