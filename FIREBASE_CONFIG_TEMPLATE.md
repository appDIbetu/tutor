# Firebase Configuration Setup

## Required Files

To run this app, you need to add the following Firebase configuration files:

### Android
- **File**: `android/app/google-services.json`
- **Source**: Download from Firebase Console → Project Settings → Your Android App
- **Location**: Place in `android/app/` directory

### iOS
- **File**: `ios/Runner/GoogleService-Info.plist`
- **Source**: Download from Firebase Console → Project Settings → Your iOS App
- **Location**: Place in `ios/Runner/` directory

## Setup Instructions

1. **Create Firebase Project**:
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project or use existing one

2. **Add Android App**:
   - Click "Add app" → Android
   - Package name: `advocate.preparation.app`
   - Download `google-services.json`
   - Place in `android/app/` directory

3. **Add iOS App**:
   - Click "Add app" → iOS
   - Bundle ID: `advocate.preparation.app`
   - Download `GoogleService-Info.plist`
   - Place in `ios/Runner/` directory

4. **Enable Authentication**:
   - Go to Authentication → Sign-in method
   - Enable Email/Password and Google Sign-In

## Security Note

These configuration files contain API keys and should **NEVER** be committed to version control. They are already added to `.gitignore`.

## For Production

- Use different Firebase projects for development and production
- Ensure proper Firebase Security Rules are configured
- Monitor Firebase usage and set up billing alerts
