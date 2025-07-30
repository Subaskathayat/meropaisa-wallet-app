import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  static User? get currentUser => _auth.currentUser;

  // Get current user ID
  static String? get currentUserId => _auth.currentUser?.uid;

  // Authentication Methods

  // Send OTP to phone number
  static Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      timeout: const Duration(seconds: 60),
    );
  }

  // Verify OTP and sign in
  static Future<UserCredential?> verifyOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      throw e;
    }
  }

  // Sign out
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // User Management Methods

  // Create new user in Firestore
  static Future<void> createUser({
    required String uid,
    required String name,
    required String phoneNumber,
  }) async {
    final user = UserModel(
      uid: uid,
      name: name,
      phoneNumber: phoneNumber,
      balance: 50000.0, // Initial balance as per requirements
      createdAt: DateTime.now(),
    );

    await _firestore.collection('users').doc(uid).set(user.toMap());
  }

  // Get user data
  static Future<UserModel?> getUser(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();

      if (doc.exists) {
        return UserModel.fromSnapshot(doc);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Check if user exists
  static Future<bool> userExists(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // Update user profile
  static Future<void> updateUserProfile(
    String uid,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _firestore.collection('users').doc(uid).update(updates);
    } catch (e) {
      throw e;
    }
  }

  // Get user by phone number
  static Future<UserModel?> getUserByPhoneNumber(String phoneNumber) async {
    try {
      QuerySnapshot query = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return UserModel.fromSnapshot(query.docs.first);
      }
      return null;
    } catch (e) {
      throw e;
    }
  }

  // Update user balance
  static Future<void> updateUserBalance(String uid, double newBalance) async {
    await _firestore.collection('users').doc(uid).update({
      'balance': newBalance,
    });
  }

  // Transaction Methods

  // Create a new transaction
  static Future<void> createTransaction(TransactionModel transaction) async {
    await _firestore
        .collection('transactions')
        .doc(transaction.transactionId)
        .set(transaction.toMap());
  }

  // Transfer money between users
  static Future<bool> transferMoney({
    required String senderId,
    required String receiverId,
    required double amount,
    String? note,
  }) async {
    try {
      return await _firestore.runTransaction((transaction) async {
        // Get sender and receiver documents
        DocumentReference senderRef = _firestore
            .collection('users')
            .doc(senderId);
        DocumentReference receiverRef = _firestore
            .collection('users')
            .doc(receiverId);

        DocumentSnapshot senderSnapshot = await transaction.get(senderRef);
        DocumentSnapshot receiverSnapshot = await transaction.get(receiverRef);

        if (!senderSnapshot.exists || !receiverSnapshot.exists) {
          throw Exception('User not found');
        }

        UserModel sender = UserModel.fromSnapshot(senderSnapshot);
        UserModel receiver = UserModel.fromSnapshot(receiverSnapshot);

        // Check if sender has sufficient balance
        if (sender.balance < amount) {
          throw Exception('Insufficient balance');
        }

        // Update balances
        transaction.update(senderRef, {'balance': sender.balance - amount});
        transaction.update(receiverRef, {'balance': receiver.balance + amount});

        // Create transaction record
        final transactionModel = TransactionModel(
          transactionId: DateTime.now().millisecondsSinceEpoch.toString(),
          senderId: senderId,
          receiverId: receiverId,
          amount: amount,
          type: 'transfer',
          timestamp: DateTime.now(),
          note: note,
          senderName: sender.name,
          receiverName: receiver.name,
        );

        transaction.set(
          _firestore
              .collection('transactions')
              .doc(transactionModel.transactionId),
          transactionModel.toMap(),
        );

        return true;
      });
    } catch (e) {
      throw e;
    }
  }

  // Get user transactions
  static Future<List<TransactionModel>> getUserTransactions(
    String userId,
  ) async {
    try {
      QuerySnapshot senderQuery = await _firestore
          .collection('transactions')
          .where('senderId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      QuerySnapshot receiverQuery = await _firestore
          .collection('transactions')
          .where('receiverId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      List<TransactionModel> transactions = [];

      for (var doc in senderQuery.docs) {
        transactions.add(TransactionModel.fromSnapshot(doc));
      }

      for (var doc in receiverQuery.docs) {
        transactions.add(TransactionModel.fromSnapshot(doc));
      }

      // Sort by timestamp descending
      transactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return transactions;
    } catch (e) {
      throw e;
    }
  }

  // Process utility payment
  static Future<bool> processUtilityPayment({
    required String userId,
    required double amount,
    required String type,
    required String serviceId,
  }) async {
    try {
      return await _firestore.runTransaction((transaction) async {
        DocumentReference userRef = _firestore.collection('users').doc(userId);
        DocumentSnapshot userSnapshot = await transaction.get(userRef);

        if (!userSnapshot.exists) {
          throw Exception('User not found');
        }

        UserModel user = UserModel.fromSnapshot(userSnapshot);

        // Check if user has sufficient balance
        if (user.balance < amount) {
          throw Exception('Insufficient balance');
        }

        // Update user balance
        transaction.update(userRef, {'balance': user.balance - amount});

        // Create transaction record
        final transactionModel = TransactionModel(
          transactionId: DateTime.now().millisecondsSinceEpoch.toString(),
          senderId: userId,
          receiverId: '${type}_biller',
          amount: amount,
          type: type,
          timestamp: DateTime.now(),
          note: 'Service ID: $serviceId',
          senderName: user.name,
          receiverName: type.toUpperCase(),
        );

        transaction.set(
          _firestore
              .collection('transactions')
              .doc(transactionModel.transactionId),
          transactionModel.toMap(),
        );

        return true;
      });
    } catch (e) {
      throw e;
    }
  }

  // Load money to wallet
  static Future<bool> loadMoney({
    required String userId,
    required double amount,
    required String method,
  }) async {
    try {
      return await _firestore.runTransaction((transaction) async {
        DocumentReference userRef = _firestore.collection('users').doc(userId);
        DocumentSnapshot userSnapshot = await transaction.get(userRef);

        if (!userSnapshot.exists) {
          throw Exception('User not found');
        }

        UserModel user = UserModel.fromSnapshot(userSnapshot);

        // Update user balance
        double newBalance = user.balance + amount;
        transaction.update(userRef, {'balance': newBalance});

        // Create transaction record
        TransactionModel transactionModel = TransactionModel(
          transactionId: _firestore.collection('transactions').doc().id,
          senderId: 'load_money_$method',
          receiverId: userId,
          amount: amount,
          type: 'load_money',
          timestamp: DateTime.now(),
          note: 'Money loaded via $method',
          senderName: method.toUpperCase(),
          receiverName: user.name,
        );

        transaction.set(
          _firestore
              .collection('transactions')
              .doc(transactionModel.transactionId),
          transactionModel.toMap(),
        );

        return true;
      });
    } catch (e) {
      rethrow;
    }
  }
}
