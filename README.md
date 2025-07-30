# 💰 Mero Paisa Wallet - Flutter Digital Wallet App

A comprehensive Flutter mobile money wallet application with Firebase backend, featuring secure biometric authentication, real-time transactions, and modern UI/UX design.

## Features

### 🔐 Security & Authentication
- **Custom Biometric Authentication** - Enhanced fingerprint authentication with custom bottom sheet UI
- **PIN-based Security** - Fallback authentication system
- **Phone number OTP authentication** via Firebase Auth
- **Transaction Authentication** - Multi-layer security for all financial operations
- **Firebase App Check** - Additional security layer
- New user profile setup with initial balance
- Secure user session management

### 💰 Money Management
- Real-time balance display
- Peer-to-peer money transfers
- Transaction history with detailed statements
- Initial welcome bonus of ₹50,000

### 📱 QR Code Functionality
- QR code scanner for instant transfers
- Personal QR code generation for receiving payments
- Camera permission handling

### 🧾 Utility Payments (Simulated)
- Mobile top-up
- Electricity bill payment
- Water bill payment
- Internet bill payment
- Traffic fine payment

### 🎫 Travel & Ticketing (Simulated)
- Airline ticket booking
- Hotel reservations
- Bus ticket booking
- Movie ticket booking

### 📊 Transaction Management
- Complete transaction history
- Visual distinction between sent/received payments
- Transaction filtering and search
- Real-time balance updates

### 🎨 Modern UI/UX
- **Custom Biometric Bottom Sheets** - Animated fingerprint scanning interface
- **Material Design 3** - Modern, intuitive interface
- **Smooth Animations** - Enhanced user experience with pulsing and transition effects
- **Google Fonts (Poppins)** typography
- **Responsive Design** - Works on all screen sizes
- Gradient backgrounds and modern visual elements

## Technology Stack

- **Frontend**: Flutter 3.32.6
- **Backend**: Firebase (Auth, Firestore)
- **State Management**: StatefulWidget with setState
- **UI**: Material Design 3 with custom theming
- **Typography**: Google Fonts (Poppins)
- **QR Code**: qr_code_scanner, qr_flutter
- **Permissions**: permission_handler
- **Formatting**: intl package for currency formatting

## Project Structure

```
lib/
├── main.dart                 # App entry point and Firebase initialization
├── firebase_options.dart     # Firebase configuration
├── models/
│   ├── user_model.dart      # User data model
│   └── transaction_model.dart # Transaction data model
├── services/
│   ├── firebase_service.dart # Firebase operations service
│   ├── biometric_service.dart # Biometric authentication
│   ├── biometric_ui_service.dart # Custom biometric UI
│   └── transaction_auth_service.dart # Transaction security
├── screens/
│   ├── auth_screen.dart     # Phone authentication
│   ├── otp_screen.dart      # OTP verification
│   ├── profile_setup_screen.dart # New user setup
│   ├── nav_bar_handler.dart # Bottom navigation
│   ├── home_screen.dart     # Main dashboard
│   ├── transfer_money_screen.dart # P2P transfers
│   ├── dummy_payment_screen.dart # Utility payments
│   ├── statement_screen.dart # Transaction history
│   ├── qr_scanner_screen.dart # QR code scanner
│   ├── support_screen.dart  # Help and support
│   └── more_screen.dart     # Profile and settings
└── widgets/                 # Reusable UI components
    └── biometric_bottom_sheet.dart # Custom biometric UI
```

## Setup Instructions

### Prerequisites
- Flutter SDK 3.32.6 or higher
- Dart SDK 3.8.1 or higher
- Android Studio / VS Code with Flutter extensions
- Firebase project (for production use)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd mero_paisa_wallet
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup** ⚠️ **REQUIRED**

   You need to set up your own Firebase project:

   a. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)

   b. Enable the following services:
      - Authentication (Phone, Email/Password)
      - Firestore Database
      - Storage
      - App Check (recommended)

   c. Download configuration files:
      - `google-services.json` for Android → place in `android/app/`
      - `GoogleService-Info.plist` for iOS → place in `ios/Runner/`

   d. Update `lib/firebase_options.dart` with your Firebase configuration:
      ```dart
      // Replace placeholder values with your actual Firebase config
      static const FirebaseOptions android = FirebaseOptions(
        apiKey: 'YOUR_ANDROID_API_KEY',
        appId: 'YOUR_ANDROID_APP_ID',
        messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
        projectId: 'your-firebase-project-id',
        storageBucket: 'your-firebase-project-id.firebasestorage.app',
      );
      ```

   e. Configure Firestore Security Rules:
      ```javascript
      // Copy rules from firestore_security_rules.txt to your Firebase Console
      ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Android Permissions
The app requires the following permissions (already configured):
- `INTERNET` - For Firebase connectivity
- `CAMERA` - For QR code scanning

## Firebase Database Structure

### Users Collection
```javascript
users/{userId} {
  uid: string,
  name: string,
  phoneNumber: string,
  balance: number,
  createdAt: timestamp
}
```

### Transactions Collection
```javascript
transactions/{transactionId} {
  transactionId: string,
  senderId: string,
  receiverId: string,
  amount: number,
  type: string, // 'transfer', 'electricity', 'mobile', etc.
  timestamp: timestamp,
  note?: string,
  senderName?: string,
  receiverName?: string
}
```

## Key Features Implementation

### Authentication Flow
1. User enters phone number
2. Firebase sends OTP
3. User verifies OTP
4. New users complete profile setup
5. Existing users navigate to home screen

### Money Transfer Process
1. User searches recipient by phone number
2. Enters transfer amount and optional note
3. Firebase transaction ensures atomicity
4. Both user balances updated simultaneously
5. Transaction record created

### QR Code Integration
- Personal QR codes contain user UID
- Scanner validates QR data against user database
- Automatic navigation to transfer screen with pre-filled recipient

### Utility Payment Simulation
- Generic payment interface for all services
- Balance deduction with transaction recording
- Service-specific icons and labels
- Payment confirmation with receipt

## 🔐 Security Features

### Biometric Authentication
- **Custom UI**: Beautiful bottom sheet with animated fingerprint scanning
- **Multiple States**: Scanning, success, error with visual feedback
- **Fallback Support**: Automatic PIN fallback when biometric fails
- **Platform Support**: Works on both Android and iOS

### Transaction Security
- **Multi-layer Authentication**: Biometric + PIN verification
- **Firebase Authentication** for secure user management
- **Firestore security rules** (configured)
- **Firebase App Check**: Additional security layer for API calls
- **Input validation** and sanitization
- **Balance verification** before transactions
- **Atomic database transactions**

## Demo Limitations

This is a demonstration app with the following limitations:
- Uses placeholder Firebase configuration
- Utility payments are simulated (no real service integration)
- No actual money handling
- Limited error handling for production scenarios

## 🚀 Future Enhancements

- Real payment gateway integration
- Push notifications for transactions
- ✅ **Biometric authentication** (COMPLETED)
- Transaction receipts and PDF generation
- Multi-language support
- Dark mode theme
- Advanced analytics and reporting
- Cryptocurrency support
- Investment features

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is for educational purposes. Please ensure proper licensing for production use.

## 📞 Support

For support and questions, please refer to the in-app support section or create an issue in this repository.

---

## ⚠️ Important Security Notice

**This repository contains placeholder Firebase configuration for security reasons.**

- All API keys and sensitive data have been replaced with placeholder values
- You **MUST** set up your own Firebase project and replace the configuration files
- Never commit real API keys, secrets, or sensitive data to public repositories
- The `google-services.json` and `GoogleService-Info.plist` files are excluded from version control
- Use environment variables or secure configuration management for production deployments

**For production use:**
1. Set up your own Firebase project
2. Configure proper security rules
3. Enable Firebase App Check
4. Use secure authentication methods
5. Implement proper error handling and logging
