import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String phoneNumber;
  final double balance;
  final DateTime createdAt;
  final String? profilePhotoUrl;
  final bool biometricEnabled;
  final bool biometricRegistered;
  final DateTime? biometricRegisteredAt;
  final DateTime? biometricDisabledAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.phoneNumber,
    required this.balance,
    required this.createdAt,
    this.profilePhotoUrl,
    this.biometricEnabled = false,
    this.biometricRegistered = false,
    this.biometricRegisteredAt,
    this.biometricDisabledAt,
  });

  // Convert UserModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'phoneNumber': phoneNumber,
      'balance': balance,
      'createdAt': Timestamp.fromDate(createdAt),
      'profilePhotoUrl': profilePhotoUrl,
      'biometricEnabled': biometricEnabled,
      'biometricRegistered': biometricRegistered,
      'biometricRegisteredAt': biometricRegisteredAt != null
          ? Timestamp.fromDate(biometricRegisteredAt!)
          : null,
      'biometricDisabledAt': biometricDisabledAt != null
          ? Timestamp.fromDate(biometricDisabledAt!)
          : null,
    };
  }

  // Create UserModel from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      balance: (map['balance'] ?? 0).toDouble(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      profilePhotoUrl: map['profilePhotoUrl'],
      biometricEnabled: map['biometricEnabled'] ?? false,
      biometricRegistered: map['biometricRegistered'] ?? false,
      biometricRegisteredAt: _parseDateTime(map['biometricRegisteredAt']),
      biometricDisabledAt: _parseDateTime(map['biometricDisabledAt']),
    );
  }

  // Helper method to parse DateTime from various formats
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;

    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        print('Error parsing DateTime from string: $value, error: $e');
        return null;
      }
    }

    return null;
  }

  // Create UserModel from Firestore DocumentSnapshot
  factory UserModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return UserModel.fromMap(data);
  }

  // Copy with method for updating user data
  UserModel copyWith({
    String? uid,
    String? name,
    String? phoneNumber,
    double? balance,
    DateTime? createdAt,
    String? profilePhotoUrl,
    bool? biometricEnabled,
    bool? biometricRegistered,
    DateTime? biometricRegisteredAt,
    DateTime? biometricDisabledAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      balance: balance ?? this.balance,
      createdAt: createdAt ?? this.createdAt,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      biometricRegistered: biometricRegistered ?? this.biometricRegistered,
      biometricRegisteredAt:
          biometricRegisteredAt ?? this.biometricRegisteredAt,
      biometricDisabledAt: biometricDisabledAt ?? this.biometricDisabledAt,
    );
  }
}
