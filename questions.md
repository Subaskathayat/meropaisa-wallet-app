# Firebase Setup Questions for Mero Paisa Wallet

This file contains questions that need to be answered during the Firebase setup process.

## Project Configuration Questions

### 1. Firebase Project Details
- **Question**: What should be the Firebase project ID? (This will be used in URLs and must be globally unique)
- **Suggested**: `mero-paisa-wallet-[your-initials]` (e.g., `mero-paisa-wallet-sk`)
- **Answer**: [mero-paisa-wallet-sk]

### 2. Project Location
- **Question**: Which region should we use for the Firebase project?
- **Options**:
  - `us-central1` (Iowa, USA) - Default, good performance globally
  - `asia-south1` (Mumbai, India) - Better for South Asian users
  - `europe-west1` (Belgium) - Better for European users
- **Recommended**: `asia-south1` for India-based app
- **Answer**: [us-central]

### 3. Authentication Configuration
- **Question**: Should we enable other authentication methods besides phone number?
- **Options**: Email/Password, Google Sign-in, Anonymous
- **Current Plan**: Phone number only (as per requirements)
- **Answer**: [Phone Number Only and Name]

### 4. Firestore Security Rules
- **Question**: Should we start with test mode (open access) or production mode (secure rules)?
- **Recommendation**: Start with test mode for development, then implement secure rules
- **Answer**: [open access]

### 5. App Bundle ID/Package Name
- **Question**: What should be the Android package name and iOS bundle ID?
- **Current**: `com.example.mero_paisa_wallet`
- **Suggested**: `com.yourcompany.meropaisa` or `com.meropaisa.wallet`
- **Answer**: [com.subas.meropaisa]

## Technical Questions

### 6. Phone Number Authentication
- **Question**: Which country codes should we primarily support?
- **Current**: App is configured for India (+91)
- **Should we add**: Nepal (+977), other SAARC countries?
- **Answer**: [India and Nepal (+91 and +977)]

### 7. Database Structure Confirmation
- **Question**: Are you satisfied with the current Firestore collections structure?
  ```
  users/{userId}
  - uid, name, phoneNumber, balance, createdAt
  
  transactions/{transactionId}
  - transactionId, senderId, receiverId, amount, type, timestamp, note, etc.
  ```
- **Answer**: [yes]

### 8. Initial Balance Configuration
- **Question**: Should the initial balance (₹50,000) be configurable or hardcoded?
- **Current**: Hardcoded in the app
- **Alternative**: Store in Firebase Remote Config
- **Answer**: [Yes, it should be configurable in Firebase Remote Config]

## Development Environment Questions

### 9. Multiple Environments
- **Question**: Do you want separate Firebase projects for development and production?
- **Recommendation**: Yes, for better testing and security
- **Answer**: [yes]

### 10. Team Access
- **Question**: Will other developers need access to the Firebase project?
- **If yes**: Please provide their email addresses for project access
- **Answer**: [no]

---

## Setup Progress Checklist

- [x] Firebase project created (`mero-paisa-wallet-sk`)
- [x] Project Number obtained (802529761829)
- [x] Package name updated (`com.subas.meropaisa`)
- [x] `firebase_options.dart` updated with real API keys
- [x] Authentication enabled (Phone) ✅ **COMPLETED**
- [x] Firestore database created ✅ **COMPLETED**
- [x] Security rules configured (test mode until Aug 2025)
- [x] Android app registered (`1:802529761829:android:f9d0055e0a04942cc6fdcc`)
- [x] All platform apps registered (Web, iOS, macOS, Windows, Android)
- [x] `google-services.json` downloaded and added
- [x] Real API keys updated in `firebase_options.dart`
- [x] Firebase connection tested ✅ **APP RUNNING ON CHROME**
- [ ] Authentication flow tested - **READY FOR TESTING**
- [ ] Database operations tested - **READY FOR TESTING**

---

## Notes
- All sensitive information (API keys, project IDs) should be kept secure
- The placeholder configuration will be replaced with real values
- Testing should be done thoroughly before production deployment
