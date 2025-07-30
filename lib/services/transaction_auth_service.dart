import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'biometric_service.dart';
import 'biometric_ui_service.dart';

class TransactionAuthService {
  /// Authenticate user before performing a transaction
  /// Returns true if authentication is successful, false otherwise
  static Future<bool> authenticateTransaction({
    required BuildContext context,
    required String transactionType,
    required double amount,
    String? recipientName,
  }) async {
    try {
      // Check if biometric is enabled
      final isBiometricEnabled = await BiometricService.isBiometricEnabled();
      final isBiometricAvailable =
          await BiometricService.isBiometricAvailable();

      if (isBiometricEnabled && isBiometricAvailable) {
        // Use biometric authentication
        return await _authenticateWithBiometric(
          context: context,
          transactionType: transactionType,
          amount: amount,
          recipientName: recipientName,
        );
      } else {
        // Use PIN authentication as fallback
        return await _authenticateWithPIN(
          context: context,
          transactionType: transactionType,
          amount: amount,
          recipientName: recipientName,
        );
      }
    } catch (e) {
      print('Error in transaction authentication: $e');
      return false;
    }
  }

  /// Authenticate using biometric with fallback to PIN
  static Future<bool> _authenticateWithBiometric({
    required BuildContext context,
    required String transactionType,
    required double amount,
    String? recipientName,
  }) async {
    try {
      // Use the new custom biometric UI
      final isAuthenticated =
          await BiometricUIService.showAuthenticationBottomSheet(
            context: context,
            title: 'Authenticate Transaction',
            subtitle: _getBiometricReason(
              transactionType,
              amount,
              recipientName,
            ),
            reason: _getBiometricReason(transactionType, amount, recipientName),
          );

      if (isAuthenticated) {
        return true;
      } else {
        // Offer PIN fallback
        return await _authenticateWithPIN(
          context: context,
          transactionType: transactionType,
          amount: amount,
          recipientName: recipientName,
        );
      }
    } catch (e) {
      // Fallback to PIN on any error
      return await _authenticateWithPIN(
        context: context,
        transactionType: transactionType,
        amount: amount,
        recipientName: recipientName,
      );
    }
  }

  /// Show fallback dialog offering PIN authentication
  static Future<bool> _showFallbackDialog({
    required BuildContext context,
    required String transactionType,
    required double amount,
    String? recipientName,
    required String reason,
  }) async {
    final shouldUsePIN = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.warning, color: Colors.orange[600], size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              'Authentication Failed',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF262626),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              reason,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF262626),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Would you like to use PIN authentication instead?',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3D95CE),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Use PIN',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldUsePIN == true) {
      return await _authenticateWithPIN(
        context: context,
        transactionType: transactionType,
        amount: amount,
        recipientName: recipientName,
      );
    }

    return false;
  }

  /// Authenticate using PIN (simplified implementation)
  static Future<bool> _authenticateWithPIN({
    required BuildContext context,
    required String transactionType,
    required double amount,
    String? recipientName,
  }) async {
    final TextEditingController pinController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF3D95CE),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              'Enter PIN',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF262626),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getPINReason(transactionType, amount, recipientName),
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF262626),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 8,
              ),
              decoration: InputDecoration(
                hintText: '••••••',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Colors.grey[400],
                  letterSpacing: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF3D95CE)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF3D95CE),
                    width: 2,
                  ),
                ),
                counterText: '',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Simple PIN validation (in real app, this should be more secure)
              if (pinController.text.length == 6) {
                Navigator.of(context).pop(true);
              } else {
                // Show error
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Please enter a 6-digit PIN',
                      style: GoogleFonts.poppins(),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3D95CE),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Confirm',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    pinController.dispose();
    return result ?? false;
  }

  /// Get biometric authentication reason text
  static String _getBiometricReason(
    String transactionType,
    double amount,
    String? recipientName,
  ) {
    switch (transactionType.toLowerCase()) {
      case 'transfer':
        return 'Authenticate to transfer ₹${amount.toStringAsFixed(2)}${recipientName != null ? ' to $recipientName' : ''}';
      case 'load':
        return 'Authenticate to load ₹${amount.toStringAsFixed(2)} to your wallet';
      case 'payment':
        return 'Authenticate to pay ₹${amount.toStringAsFixed(2)}';
      default:
        return 'Authenticate to complete this transaction of ₹${amount.toStringAsFixed(2)}';
    }
  }

  /// Get PIN authentication reason text
  static String _getPINReason(
    String transactionType,
    double amount,
    String? recipientName,
  ) {
    switch (transactionType.toLowerCase()) {
      case 'transfer':
        return 'Enter your PIN to transfer ₹${amount.toStringAsFixed(2)}${recipientName != null ? ' to $recipientName' : ''}';
      case 'load':
        return 'Enter your PIN to load ₹${amount.toStringAsFixed(2)} to your wallet';
      case 'payment':
        return 'Enter your PIN to pay ₹${amount.toStringAsFixed(2)}';
      default:
        return 'Enter your PIN to complete this transaction of ₹${amount.toStringAsFixed(2)}';
    }
  }
}
