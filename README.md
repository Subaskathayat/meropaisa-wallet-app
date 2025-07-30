# Mero Paisa Wallet - Flutter Money Wallet App

A comprehensive Flutter mobile money wallet application with Firebase backend for peer-to-peer transfers, utility payments, and QR code functionality.

## Features

### 🔐 Authentication
- Phone number OTP authentication via Firebase Auth
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
- Clean, modern Material Design interface
- Google Fonts (Poppins) typography
- Gradient backgrounds and smooth animations
- Responsive design for various screen sizes

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
│   └── firebase_service.dart # Firebase operations service
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

3. **Firebase Setup** (For production)
   - Create a new Firebase project at https://console.firebase.google.com
   - Enable Authentication with Phone Number sign-in
   - Create a Firestore database
   - Download and replace `firebase_options.dart` with your configuration
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)

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

## Security Features

- Firebase Authentication for secure user management
- Firestore security rules (to be configured)
- Input validation and sanitization
- Balance verification before transactions
- Atomic database transactions

## Demo Limitations

This is a demonstration app with the following limitations:
- Uses placeholder Firebase configuration
- Utility payments are simulated (no real service integration)
- No actual money handling
- Limited error handling for production scenarios

## Future Enhancements

- Real payment gateway integration
- Push notifications for transactions
- Biometric authentication
- Transaction receipts and PDF generation
- Multi-language support
- Dark mode theme
- Advanced analytics and reporting

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is for educational purposes. Please ensure proper licensing for production use.

## Support

For support and questions, please refer to the in-app support section or contact the development team.
