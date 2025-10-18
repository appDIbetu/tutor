# Firebase Setup Guide for Legal Practice App

## 1. Create Firebase Project

### Step 1: Go to Firebase Console
1. Visit [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter project name: `legal-practice-app` (or your preferred name)
4. Enable Google Analytics (optional but recommended)
5. Click "Create project"

### Step 2: Configure Project Settings
1. Go to Project Settings (gear icon)
2. Note down your **Project ID** - you'll need this for server configuration

## 2. Add Flutter App to Firebase

### For Android:
1. In Firebase Console, click "Add app" → Android
2. **Package name**: `advocate.preparation.app` (or your actual package name)
3. **App nickname**: `Legal Practice Android`
4. **Debug signing certificate SHA-1**: 
   - Run: `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`
   - Copy the SHA1 fingerprint
5. Click "Register app"
6. Download `google-services.json`
7. Place it in `android/app/` directory

### For iOS:
1. In Firebase Console, click "Add app" → iOS
2. **Bundle ID**: `advocate.preparation.app` (or your actual bundle ID)
3. **App nickname**: `Legal Practice iOS`
4. Click "Register app"
5. Download `GoogleService-Info.plist`
6. Place it in `ios/Runner/` directory

### For Web:
1. In Firebase Console, click "Add app" → Web
2. **App nickname**: `Legal Practice Web`
3. **Firebase Hosting**: Enable if you want to host your web app
4. Click "Register app"
5. Copy the Firebase configuration object

## 3. Enable Authentication

### Step 1: Enable Authentication Service
1. In Firebase Console, go to "Authentication" → "Sign-in method"
2. Click "Get started"
3. Go to "Sign-in method" tab

### Step 2: Enable Email/Password Authentication
1. Click on "Email/Password"
2. Enable "Email/Password" (first option)
3. Optionally enable "Email link (passwordless sign-in)"
4. Click "Save"

### Step 3: Enable Google Sign-In
1. Click on "Google"
2. Enable Google sign-in
3. **Project support email**: Use your email
4. **Web SDK configuration**: 
   - Add your domain (for web app)
   - Copy the Web client ID for server use
5. Click "Save"

### Step 4: Configure OAuth Consent Screen (for Google Sign-In)
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your Firebase project
3. Go to "APIs & Services" → "OAuth consent screen"
4. Choose "External" user type
5. Fill in required fields:
   - **App name**: Legal Practice App
   - **User support email**: Your email
   - **Developer contact**: Your email
6. Add scopes: `email`, `profile`, `openid`
7. Add test users (your email) for development

## 4. Server Configuration

### Step 1: Get Service Account Key
1. In Firebase Console, go to Project Settings → "Service accounts"
2. Click "Generate new private key"
3. Download the JSON file
4. **Keep this file secure** - it gives full access to your Firebase project

### Step 2: Configure Your Backend Server
Create a `.env` file in your server directory:
```env
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYOUR_PRIVATE_KEY\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@your-project-id.iam.gserviceaccount.com
GOOGLE_CLIENT_ID=your-web-client-id-from-oauth-config
```

### Step 3: Install Firebase Admin SDK
For Node.js server:
```bash
npm install firebase-admin
```

For Python server:
```bash
pip install firebase-admin
```

### Step 4: Initialize Firebase Admin in Your Server
```javascript
// Node.js example
const admin = require('firebase-admin');
const serviceAccount = require('./path-to-service-account-key.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: 'your-project-id'
});

// Verify ID tokens
async function verifyToken(idToken) {
  try {
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    return decodedToken;
  } catch (error) {
    console.error('Error verifying token:', error);
    return null;
  }
}
```

## 5. Update Flutter App Configuration

### Step 1: Update android/app/build.gradle
```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        applicationId "advocate.preparation.app"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0"
    }
}

dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-auth'
    implementation 'com.google.android.gms:play-services-auth:20.7.0'
}
```

### Step 2: Update android/build.gradle
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
```

### Step 3: Update android/app/build.gradle
```gradle
apply plugin: 'com.google.gms.google-services'
```

### Step 4: Update iOS Configuration
1. Open `ios/Runner.xcworkspace` in Xcode
2. Add `GoogleService-Info.plist` to Runner target
3. Update `ios/Runner/Info.plist`:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>REVERSED_CLIENT_ID</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>YOUR_REVERSED_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

## 6. Update API Service Configuration

### Step 1: Update lib/core/services/api_service.dart
```dart
class ApiService {
  // Replace with your actual server URL
  static const String baseUrl = 'https://your-server.com/api';
  
  // Rest of the code remains the same
}
```

### Step 2: Test Authentication Flow
1. Run the app: `flutter run`
2. Test email/password sign-up
3. Test email/password sign-in
4. Test Google sign-in
5. Verify ID tokens are generated correctly

## 7. Security Rules (Optional)

### Firestore Security Rules (if using Firestore)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### Realtime Database Rules (if using Realtime Database)
```json
{
  "rules": {
    "users": {
      "$uid": {
        ".read": "$uid === auth.uid",
        ".write": "$uid === auth.uid"
      }
    }
  }
}
```

## 8. Testing Checklist

- [ ] Firebase project created
- [ ] Android app configured with google-services.json
- [ ] iOS app configured with GoogleService-Info.plist
- [ ] Authentication methods enabled (Email/Password, Google)
- [ ] Service account key downloaded for server
- [ ] Server configured with Firebase Admin SDK
- [ ] Flutter app builds and runs
- [ ] Sign-up flow works
- [ ] Sign-in flow works
- [ ] Google sign-in works
- [ ] ID tokens are generated
- [ ] Server can verify ID tokens
- [ ] Logout functionality works

## 9. Common Issues & Solutions

### Issue: Google Sign-In not working
**Solution**: 
- Check SHA-1 fingerprint is correct
- Verify OAuth consent screen is configured
- Ensure Google Services plugin is applied

### Issue: ID token verification fails on server
**Solution**:
- Check service account key is correct
- Verify project ID matches
- Ensure token is not expired

### Issue: Build errors
**Solution**:
- Run `flutter clean && flutter pub get`
- Check all configuration files are in correct locations
- Verify package names match Firebase configuration

## 10. Production Considerations

1. **Security**: Never commit service account keys to version control
2. **Environment**: Use different Firebase projects for dev/staging/production
3. **Monitoring**: Enable Firebase Performance Monitoring
4. **Analytics**: Configure Firebase Analytics for user insights
5. **Backup**: Regular backups of user data
6. **Compliance**: Ensure GDPR/privacy compliance if applicable

## Support
- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Admin SDK](https://firebase.google.com/docs/admin)
