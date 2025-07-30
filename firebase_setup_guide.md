# Firebase Setup Guide for Mero Paisa Wallet

This guide will walk you through setting up Firebase for the Mero Paisa wallet app.

## Prerequisites ✅

- [x] Flutter SDK installed
- [x] Firebase CLI installed (version 14.11.1)
- [x] FlutterFire CLI installed (version 1.3.1)
- [ ] Google account for Firebase Console access
- [ ] Answers to questions in `questions.md`

## Step 1: Answer Configuration Questions

Before proceeding, please fill out the answers in `questions.md`. The most critical ones are:

1. **Firebase Project ID** (must be globally unique)
2. **Project Region** (recommended: asia-south1 for India)
3. **App Package Name** (current: com.example.mero_paisa_wallet)

## Step 2: Firebase Console Setup

### 2.1 Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Enter project name: "Mero Paisa Wallet"
4. Project ID: Use the ID from your `questions.md` answer
5. Choose your preferred region
6. Enable/Disable Google Analytics (recommended: Enable)
7. Click "Create project"

### 2.2 Enable Authentication

1. In Firebase Console, go to "Authentication"
2. Click "Get started"
3. Go to "Sign-in method" tab
4. Enable "Phone" provider
5. Configure phone number sign-in settings
6. Save changes

### 2.3 Create Firestore Database

1. Go to "Firestore Database"
2. Click "Create database"
3. Choose "Start in test mode" (for development)
4. Select your preferred region (same as project region)
5. Click "Done"

## Step 3: Manual Flutter Configuration (Due to CLI Issues)

Since the FlutterFire CLI is experiencing connectivity issues, we'll configure manually:

### 3.1 Firebase Project Status ✅
- **Project Created**: `mero-paisa-wallet-sk`
- **Project Number**: `802529761829`
- **Console URL**: https://console.firebase.google.com/project/mero-paisa-wallet-sk/overview

### 3.2 Add Android App to Firebase Project

1. Go to Firebase Console: https://console.firebase.google.com/project/mero-paisa-wallet-sk/overview
2. Click "Add app" → Select Android
3. Enter package name: `com.subas.meropaisa`
4. Enter app nickname: "Mero Paisa Android"
5. Click "Register app"
6. Download `google-services.json`
7. Place it in `android/app/` directory

### 3.3 Get Real API Keys

1. In Firebase Console, go to Project Settings (gear icon)
2. Scroll down to "Your apps" section
3. Click on the Android app you just created
4. Copy the configuration values
5. Update `lib/firebase_options.dart` with real values

## Step 4: Manual Configuration Steps

### 4.1 Android Configuration

1. The `google-services.json` file should be automatically placed in `android/app/`
2. Verify the file exists and contains your project configuration
3. Update `android/app/build.gradle` if needed (usually automatic)

### 4.2 iOS Configuration (if needed)

1. The `GoogleService-Info.plist` should be placed in `ios/Runner/`
2. Add the file to Xcode project
3. Update iOS configuration if needed

### 4.3 Update Package Name (Optional)

If you want to change from `com.example.mero_paisa_wallet`:

1. Update `android/app/build.gradle`
2. Update `android/app/src/main/AndroidManifest.xml`
3. Update iOS bundle identifier
4. Re-run flutterfire configure

## Step 5: Firestore Security Rules

Replace the default rules with these production-ready rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own user document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Transactions can be read by sender or receiver
    match /transactions/{transactionId} {
      allow read: if request.auth != null && 
        (request.auth.uid == resource.data.senderId || 
         request.auth.uid == resource.data.receiverId);
      allow create: if request.auth != null && 
        request.auth.uid == request.resource.data.senderId;
    }
  }
}
```

## Step 6: Test the Setup

### 6.1 Test Firebase Connection

```bash
flutter run
```

Check if the app starts without Firebase connection errors.

### 6.2 Test Authentication

1. Try to register with a phone number
2. Verify OTP is sent and received
3. Complete profile setup
4. Check if user is created in Firestore

### 6.3 Test Database Operations

1. Try money transfer between users
2. Check transaction history
3. Verify utility payments work
4. Confirm data appears in Firestore Console

## Step 7: Production Considerations

### 7.1 Security Rules
- Replace test mode rules with production rules
- Test all operations still work
- Verify unauthorized access is blocked

### 7.2 Phone Authentication
- Configure authorized domains
- Set up reCAPTCHA for web (if applicable)
- Test with real phone numbers

### 7.3 Monitoring
- Enable Firebase Analytics
- Set up Crashlytics
- Monitor authentication metrics

## Troubleshooting

### Common Issues

1. **"Default Firebase app not initialized"**
   - Check `firebase_options.dart` is properly imported
   - Verify `Firebase.initializeApp()` is called

2. **Phone authentication not working**
   - Check phone number format (+977 for Nepal)
   - Verify phone provider is enabled
   - Check Firebase Console for error logs

3. **Firestore permission denied**
   - Check security rules
   - Verify user is authenticated
   - Check user ID matches document path

4. **Build errors after adding Firebase**
   - Run `flutter clean`
   - Run `flutter pub get`
   - Check Android/iOS configuration files

### Getting Help

- Check Firebase Console logs
- Review Flutter debug console
- Check `questions.md` for configuration issues
- Verify all setup steps completed

## Next Steps After Setup

1. Test all app features thoroughly
2. Update security rules for production
3. Set up proper error handling
4. Configure backup and monitoring
5. Plan for scaling and performance optimization

---

**Note**: Keep your Firebase configuration files secure and never commit sensitive keys to version control.
