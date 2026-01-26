# Feature Mapping - Code to Feature Folders

This document maps all screens, components, services, and hooks to their respective feature folders.

## 📱 Screens Mapping

### Authentication/
- `src/screens/AuthScreen.tsx` - Main authentication screen
- `src/screens/SignupScreen.tsx` - User registration
- `src/screens/EmailVerificationScreen.tsx` - Email verification
- `src/screens/ForgotPasswordScreen.tsx` - Password recovery
- `src/screens/ResetPasswordScreen.tsx` - Password reset

### Onboarding/
- `src/screens/OnboardingSlidesScreen.tsx` - 6-slide onboarding flow

### Index & Landing/
- `src/screens/IndexScreen.tsx` - App entry point

### Category Screens/
- `src/screens/SchlafScreen.tsx` - Sleep category screen
- `src/screens/RuheScreen.tsx` - Rest/Stress category screen
- `src/screens/ImFlussScreen.tsx` - Flow/Lightness category screen

### Klangwelten/
- `src/screens/KlangweltenScreen.tsx` - Sound world exploration

### Library/
- `src/screens/LibraryScreen.tsx` - User's audio library

### Stats & Analytics/
- `src/screens/StatsScreen.tsx` - User statistics dashboard

### Subscription & Payment/
- `src/screens/SubscribeScreen.tsx` - Subscription plans
- `src/screens/DownsellScreen.tsx` - Subscription downsell

### Profile View/
- `src/screens/ProfileScreen.tsx` - User profile

### Settings/
- `src/screens/AccountSettingsScreen.tsx` - Account settings
- `src/screens/PrivacySettingsScreen.tsx` - Privacy settings
- `src/screens/NotificationPreferencesScreen.tsx` - Notification preferences

### Legal & Privacy/
- `src/screens/LegalScreen.tsx` - Legal information
- `src/screens/TermsScreen.tsx` - Terms and conditions
- `src/screens/PrivacyPolicyScreen.tsx` - Privacy policy
- `src/screens/DataPrivacyScreen.tsx` - Data privacy information

### Support/
- `src/screens/SupportScreen.tsx` - Support and help

## 🧩 Components Mapping

### Authentication/
- `src/components/auth/AuthForm.tsx`
- `src/components/auth/SocialAuthButton.tsx`
- `src/components/auth/PasswordStrengthIndicator.tsx`
- `src/components/auth/AppleLogo.tsx`
- `src/components/auth/GoogleLogo.tsx`

### Onboarding/
- `src/components/onboarding/OnboardingIcons.tsx`

### Main Navigation/
- `src/components/navigation/TabNavigator.tsx`
- `src/components/navigation/NavBar.tsx`
- `src/components/navigation/UnifiedHeader.tsx`

### Major Audioplayer/
- `src/components/audio-player/` (all files)
- `src/components/AudioPlayerEnhanced.tsx`
- `src/components/AudioPlayerLayout.tsx`
- `src/components/AudioPlayerScreen.tsx`
- `src/components/AudioMixer.tsx`
- `src/components/MiniPlayerStrip.tsx`
- `src/components/AudioPlayerLongPressIndicator.tsx`

### Klangwelten/
- `src/components/klangwelten/SoundCarousel.tsx`

### Library/
- `src/components/SoundLibraryPicker.tsx`

### Sound Search/
- `src/components/SearchDrawer.tsx`
- `src/components/SearchResults.tsx`
- `src/components/sound/SoundSearchBar.tsx`

### SOS Screen/
- `src/components/SOSDrawer.tsx`
- `src/components/SOSScreenDrawer.tsx`

### Favorite Functionality/
- `src/components/AudioPlayerFavoriteButton.tsx`
- `src/components/sound/SoundCard.tsx` (favorite functionality)

### Category Screens/
- `src/components/screens/CategoryScreenBase.tsx`
- `src/components/CategoryCard.tsx`
- `src/components/sound/SoundCard.tsx`
- `src/components/sound/SoundGridView.tsx`
- `src/components/sound/SoundList.tsx`
- `src/components/sound/CategoryHeader.tsx`
- `src/components/AddNewSoundDrawer.tsx`
- `src/components/CategorySoundDrawer.tsx`

### Stats & Analytics/
- `src/components/stats/` (all files)
  - `BadgeDisplay.tsx`
  - `HealthStats.tsx`
  - `MeditationChart.tsx`
  - `MoodTracker.tsx`
  - `MostUsedSounds.tsx`
  - `StatsSummary.tsx`
  - `SummaryStats.tsx`
  - `TimePeriodTabs.tsx`

### Subscription & Payment/
- `src/components/subscription/` (all files)
- `src/components/payment/` (all files)

### Profile View/
- `src/components/profile/` (all files)

### Visual Effects/
- `src/components/animations/` (all files)
- `src/components/visual-effects/` (all files)
- `src/components/AnimatedScreenTransition.tsx`
- `src/components/Preloader.tsx`

### Background Audio/
- `src/components/MiniPlayerStrip.tsx` (background controls)

## 🔧 Services Mapping

### Authentication/
- `src/services/auth.ts`
- `src/services/OAuthService.ts`
- `src/services/SessionManagementService.ts`
- `src/services/RegistrationCacheService.ts`

### Major Audioplayer/
- `src/services/audio.ts`
- `src/services/AudioService.ts`
- `src/services/AudioLibraryManager.ts`
- `src/services/TrackPlayerService.ts`
- `src/services/NativeMultiTrackAudioService.ts`
- `src/services/UnifiedAudioPlaybackService.ts`
- `src/services/SupabasePlaybackService.ts`
- `src/services/SoundGenerationService.ts`

### Library/
- `src/services/SupabaseAudioLibraryManager.ts`
- `src/services/CustomSoundService.ts`

### Sound Search/
- `src/services/SearchService.ts`

### Favorite Functionality/
- `src/services/AWAVEStorage.ts` (favorites storage)

### Category Screens/
- `src/services/CategoryService.ts`

### Stats & Analytics/
- `src/services/analytics.ts`
- `src/services/SessionTrackingService.ts`
- `src/services/SessionPhaseService.ts`

### Session Tracking/
- `src/services/SessionTrackingService.ts`
- `src/services/SessionPhaseService.ts`

### Subscription & Payment/
- `src/services/subscriptions.ts`
- `src/services/SubscriptionService.ts`
- `src/services/IAPService.ts`

### Notifications/
- `src/services/NotificationService.ts`

### Offline Support/
- `src/services/OfflineQueueService.ts`
- `src/services/BackgroundDownloadService.ts`

### Background Audio/
- `src/services/audio.ts` (background audio handling)

### Backend Integration/
- `src/services/BackendService.ts`
- `src/services/ProductionBackendService.ts`
- `src/services/backendConstants.ts`

### Error Handling/
- `src/services/ErrorLoggingService.ts`

### Migration/
- `src/services/MigrationService.ts`

## 🪝 Hooks Mapping

### Authentication/
- `src/hooks/useAuthForm.ts`
- `src/hooks/useOAuth.ts`
- `src/hooks/useProductionAuth.ts`
- `src/hooks/useRegistrationFlow.ts`

### Onboarding/
- `src/hooks/useOnboardingStorage.ts`

### Major Audioplayer/
- `src/hooks/useAudioPlayer.ts`
- `src/hooks/useAudioPlayerGestures.ts`
- `src/hooks/useSoundPlayer.ts`
- `src/hooks/useMultiTrackMixer.ts`
- `src/hooks/audio/useUnifiedAudio.ts`
- `src/hooks/audio/useSupabaseAudio.ts`

### Library/
- `src/hooks/useCustomSounds.ts`

### Sound Search/
- `src/hooks/useSoundSearch.ts`
- `src/hooks/useIntelligentSearch.ts`
- `src/hooks/useDebounce.ts`

### Favorite Functionality/
- `src/hooks/useFavoritesManagement.ts`

### Category Screens/
- `src/hooks/useCategoryManagement.ts`

### Stats & Analytics/
- `src/hooks/useSessionStats.ts`
- `src/hooks/useUserStats.ts`
- `src/hooks/useWeeklyActivity.ts`
- `src/hooks/useMostPlayedSounds.ts`

### Session Tracking/
- `src/hooks/useSessionTracking.ts`
- `src/hooks/useUserSessions.ts`

### Subscription & Payment/
- `src/hooks/useSubscriptionManagement.ts`
- `src/hooks/useSubscriptionForm.ts`
- `src/hooks/useTrialManagement.ts`
- `src/hooks/useTrialStatus.ts`

### Profile View/
- `src/hooks/useUserProfile.ts`
- `src/hooks/useUserManagement.ts`

### Notifications/
- `src/hooks/useRealtimeSync.ts`

### Offline Support/
- `src/hooks/useAsyncStorageBridge.ts`

### Development/
- `src/hooks/useDevSettings.ts`

## 🎨 Design System

### All Features/
- `src/design-system/` - Shared design system (used by all features)
- `src/hooks/useUnifiedTheme.ts` - Theme management

## 📊 Context Providers

### All Features/
- `src/contexts/AuthContext.tsx` - Authentication state
- `src/contexts/CategoryContext.tsx` - Category state
- `src/contexts/LanguageContext.tsx` - Language/localization

---

*This mapping helps developers quickly locate code related to specific features.*
