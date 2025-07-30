# 🧪 Firebase Testing Guide - Mero Paisa Wallet

## 🎉 **SETUP COMPLETE!**

✅ **Firebase Project**: `mero-paisa-wallet-sk`  
✅ **Authentication**: Phone number enabled  
✅ **Firestore**: Database created (test mode)  
✅ **App Status**: Running on Chrome  
✅ **All Configurations**: Complete and tested  

---

## 🚀 **TESTING CHECKLIST**

### **Phase 1: Basic Firebase Connection** ✅
- [x] App launches without Firebase errors
- [x] Hot restart works (Firebase initialized correctly)
- [x] Authentication screen displays

### **Phase 2: Phone Authentication Testing**
- [ ] **Test 1**: Enter phone number (India: +91 format)
- [ ] **Test 2**: Receive OTP (check browser console for test OTP)
- [ ] **Test 3**: Verify OTP and complete authentication
- [ ] **Test 4**: New user profile setup
- [ ] **Test 5**: Existing user login

### **Phase 3: Database Operations Testing**
- [ ] **Test 6**: User profile creation in Firestore
- [ ] **Test 7**: Balance display (₹50,000 initial)
- [ ] **Test 8**: User data persistence across sessions

### **Phase 4: Money Transfer Testing**
- [ ] **Test 9**: Search for recipient by phone number
- [ ] **Test 10**: Transfer money between users
- [ ] **Test 11**: Balance updates for both users
- [ ] **Test 12**: Transaction record creation

### **Phase 5: Transaction History Testing**
- [ ] **Test 13**: View transaction history
- [ ] **Test 14**: Sent/received transaction distinction
- [ ] **Test 15**: Transaction details display

### **Phase 6: Utility Payment Testing**
- [ ] **Test 16**: Mobile top-up payment
- [ ] **Test 17**: Electricity bill payment
- [ ] **Test 18**: Balance deduction
- [ ] **Test 19**: Transaction recording

### **Phase 7: QR Code Testing**
- [ ] **Test 20**: QR scanner (mobile only - web shows message)
- [ ] **Test 21**: Personal QR code generation
- [ ] **Test 22**: QR code contains correct user ID

---

## 📱 **HOW TO TEST**

### **Current App URL**: 
The app is running at: **http://localhost:XXXX** (check Chrome tab)

### **Testing Phone Authentication**:

1. **For Testing on Web** (Chrome):
   - Phone authentication on web requires reCAPTCHA
   - Use test phone numbers if configured
   - Check browser console for any Firebase errors

2. **Test Phone Numbers** (if configured in Firebase Console):
   - Go to Firebase Console → Authentication → Sign-in method → Phone
   - Add test phone numbers with test verification codes

3. **Real Phone Testing**:
   - Use your actual phone number
   - You should receive real SMS OTP
   - Enter the 6-digit code received

### **Testing Database Operations**:

1. **Check Firestore Console**:
   - Go to: https://console.firebase.google.com/project/mero-paisa-wallet-sk/firestore
   - Watch for new documents being created
   - Verify user and transaction data

2. **Test Multiple Users**:
   - Use different phone numbers
   - Test transfers between users
   - Verify balance updates

---

## 🔍 **DEBUGGING TIPS**

### **Check Browser Console**:
- Open Chrome DevTools (F12)
- Look for Firebase errors in Console tab
- Check Network tab for API calls

### **Common Issues & Solutions**:

1. **"Firebase not initialized"**:
   - Hot restart the app (press 'R' in terminal)
   - Check firebase_options.dart has correct project ID

2. **Phone authentication not working**:
   - Check if phone provider is enabled in Firebase Console
   - Verify phone number format (+91 for India)
   - Check reCAPTCHA settings

3. **Database permission denied**:
   - Verify user is authenticated
   - Check Firestore rules (currently in test mode)
   - Ensure user ID matches document path

4. **QR scanner not working**:
   - Expected on web (shows message)
   - Works only on mobile platforms

---

## 📊 **FIREBASE CONSOLE MONITORING**

### **Authentication Console**:
https://console.firebase.google.com/project/mero-paisa-wallet-sk/authentication/users

**Monitor**:
- New user registrations
- Authentication attempts
- User activity

### **Firestore Console**:
https://console.firebase.google.com/project/mero-paisa-wallet-sk/firestore/data

**Monitor**:
- User document creation
- Transaction document creation
- Balance updates
- Data structure

### **Usage Analytics**:
https://console.firebase.google.com/project/mero-paisa-wallet-sk/analytics

**Track**:
- App usage
- Authentication events
- Database operations

---

## 🎯 **SUCCESS CRITERIA**

### **✅ Authentication Success**:
- User can enter phone number
- OTP is sent and received
- User can verify OTP
- Profile is created/loaded
- User stays logged in

### **✅ Database Success**:
- User data appears in Firestore
- Balance is displayed correctly
- Transactions are recorded
- Data persists across sessions

### **✅ Transfer Success**:
- Can search users by phone
- Can transfer money
- Balances update correctly
- Transaction history shows transfers

### **✅ Overall Success**:
- All core features work
- No Firebase errors
- Data consistency maintained
- Good user experience

---

## 🚀 **NEXT STEPS AFTER TESTING**

1. **If Tests Pass**:
   - Deploy production security rules
   - Set up proper error handling
   - Configure production environment
   - Plan mobile app deployment

2. **If Tests Fail**:
   - Check debugging tips above
   - Review Firebase Console logs
   - Update configuration as needed
   - Re-test specific features

---

**🎉 Ready to test! The app is running and Firebase is fully configured. Start with Phase 2 (Phone Authentication) and work through each phase systematically.**
