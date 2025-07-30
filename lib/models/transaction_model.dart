import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String transactionId;
  final String senderId;
  final String receiverId;
  final double amount;
  final String type;
  final DateTime timestamp;
  final String? note;
  final String? receiverName;
  final String? senderName;

  TransactionModel({
    required this.transactionId,
    required this.senderId,
    required this.receiverId,
    required this.amount,
    required this.type,
    required this.timestamp,
    this.note,
    this.receiverName,
    this.senderName,
  });

  // Convert TransactionModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'transactionId': transactionId,
      'senderId': senderId,
      'receiverId': receiverId,
      'amount': amount,
      'type': type,
      'timestamp': Timestamp.fromDate(timestamp),
      'note': note,
      'receiverName': receiverName,
      'senderName': senderName,
    };
  }

  // Create TransactionModel from Firestore document
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      transactionId: map['transactionId'] ?? '',
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      type: map['type'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      note: map['note'],
      receiverName: map['receiverName'],
      senderName: map['senderName'],
    );
  }

  // Create TransactionModel from Firestore DocumentSnapshot
  factory TransactionModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return TransactionModel.fromMap(data);
  }

  // Check if current user is sender
  bool isSender(String currentUserId) {
    return senderId == currentUserId;
  }

  // Check if current user is receiver
  bool isReceiver(String currentUserId) {
    return receiverId == currentUserId;
  }

  // Get the other party's name for display
  String getOtherPartyName(String currentUserId) {
    if (isSender(currentUserId)) {
      return receiverName ?? receiverId;
    } else {
      return senderName ?? senderId;
    }
  }

  // Get transaction type for display
  String getDisplayType(String currentUserId) {
    switch (type) {
      case 'transfer':
        return isSender(currentUserId) ? 'Sent' : 'Received';
      case 'top-up':
        return 'Top-up';
      case 'electricity':
        return 'Electricity Bill';
      case 'water':
        return 'Water Bill';
      case 'internet':
        return 'Internet Bill';
      case 'mobile':
        return 'Mobile Top-up';
      case 'traffic_fine':
        return 'Traffic Fine';
      case 'movie_ticket':
        return 'Movie Ticket';
      case 'bus_ticket':
        return 'Bus Ticket';
      case 'airline':
        return 'Airline Ticket';
      case 'hotel':
        return 'Hotel Booking';
      default:
        return type;
    }
  }
}
