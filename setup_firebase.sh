#!/bin/bash

# Firebase Setup Script for Legal Practice App
# Run this script after creating your Firebase project

echo "🔥 Firebase Setup Script for Legal Practice App"
echo "=============================================="

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    exit 1
fi

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "📦 Installing Firebase CLI..."
    npm install -g firebase-tools
fi

echo "✅ Prerequisites check passed"
echo ""

# Get project details
read -p "Enter your Firebase Project ID: " PROJECT_ID
read -p "Enter your Android package name (e.g., advocate.preparation.app): " PACKAGE_NAME
read -p "Enter your iOS bundle ID (e.g., advocate.preparation.app): " BUNDLE_ID

echo ""
echo "📱 Setting up Android configuration..."

# Create Android configuration template
cat > android_config_template.txt << EOF
# Android Configuration Steps:
1. Download google-services.json from Firebase Console
2. Place it in android/app/ directory
3. Add to android/app/build.gradle:
   apply plugin: 'com.google.gms.google-services'
4. Add to android/build.gradle dependencies:
   classpath 'com.google.gms:google-services:4.4.0'
5. Add to android/app/build.gradle dependencies:
   implementation platform('com.google.firebase:firebase-bom:32.7.0')
   implementation 'com.google.firebase:firebase-auth'
   implementation 'com.google.android.gms:play-services-auth:20.7.0'
EOF

echo "📱 Setting up iOS configuration..."

# Create iOS configuration template
cat > ios_config_template.txt << EOF
# iOS Configuration Steps:
1. Download GoogleService-Info.plist from Firebase Console
2. Place it in ios/Runner/ directory
3. Add to ios/Runner/Info.plist:
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
EOF

echo "🌐 Setting up Web configuration..."

# Create web configuration template
cat > web_config_template.txt << EOF
# Web Configuration Steps:
1. Add Firebase SDK to web/index.html:
   <script src="https://www.gstatic.com/firebasejs/9.0.0/firebase-app.js"></script>
   <script src="https://www.gstatic.com/firebasejs/9.0.0/firebase-auth.js"></script>
2. Add Firebase config object to web/index.html
3. Update lib/core/services/api_service.dart with your server URL
EOF

echo "🔧 Updating Flutter configuration..."

# Update pubspec.yaml if needed
if ! grep -q "firebase_core" pubspec.yaml; then
    echo "📦 Firebase dependencies already added to pubspec.yaml"
else
    echo "✅ Firebase dependencies found in pubspec.yaml"
fi

# Create environment configuration
cat > .env.template << EOF
# Environment Configuration Template
# Copy this to .env and fill in your values

FIREBASE_PROJECT_ID=$PROJECT_ID
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYOUR_PRIVATE_KEY\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@$PROJECT_ID.iam.gserviceaccount.com
GOOGLE_CLIENT_ID=your-web-client-id-from-oauth-config
API_BASE_URL=https://your-server.com/api
EOF

echo "📋 Creating setup checklist..."

cat > setup_checklist.md << EOF
# Firebase Setup Checklist

## Firebase Console Setup
- [ ] Create Firebase project: $PROJECT_ID
- [ ] Enable Authentication
- [ ] Enable Email/Password sign-in
- [ ] Enable Google sign-in
- [ ] Configure OAuth consent screen
- [ ] Download google-services.json (Android)
- [ ] Download GoogleService-Info.plist (iOS)
- [ ] Download service account key (Server)

## Android Setup
- [ ] Place google-services.json in android/app/
- [ ] Update android/app/build.gradle
- [ ] Update android/build.gradle
- [ ] Test Android build

## iOS Setup
- [ ] Place GoogleService-Info.plist in ios/Runner/
- [ ] Update ios/Runner/Info.plist
- [ ] Test iOS build

## Web Setup
- [ ] Add Firebase SDK to web/index.html
- [ ] Add Firebase config object
- [ ] Test web build

## Server Setup
- [ ] Install Firebase Admin SDK
- [ ] Configure service account
- [ ] Test ID token verification
- [ ] Update API endpoints

## Testing
- [ ] Test email/password sign-up
- [ ] Test email/password sign-in
- [ ] Test Google sign-in
- [ ] Test logout
- [ ] Test profile completion
- [ ] Test API calls with ID token

## Project Details
- Project ID: $PROJECT_ID
- Android Package: $PACKAGE_NAME
- iOS Bundle ID: $BUNDLE_ID
EOF

echo ""
echo "✅ Setup templates created!"
echo ""
echo "📁 Files created:"
echo "   - android_config_template.txt"
echo "   - ios_config_template.txt"
echo "   - web_config_template.txt"
echo "   - .env.template"
echo "   - setup_checklist.md"
echo ""
echo "🚀 Next steps:"
echo "   1. Follow the setup checklist"
echo "   2. Download configuration files from Firebase Console"
echo "   3. Place them in the correct directories"
echo "   4. Update your server configuration"
echo "   5. Test the authentication flow"
echo ""
echo "📖 For detailed instructions, see FIREBASE_SETUP_GUIDE.md"
echo ""
echo "🔗 Firebase Console: https://console.firebase.google.com/"
echo "🔗 Google Cloud Console: https://console.cloud.google.com/"
