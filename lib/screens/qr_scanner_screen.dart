import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/firebase_service.dart';
import '../models/user_model.dart';
import 'transfer_money_screen.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController controller = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (!_isProcessing && barcodes.isNotEmpty) {
      final String? code = barcodes.first.rawValue;
      if (code != null) {
        _processQRCode(code);
      }
    }
  }

  Future<void> _processQRCode(String qrData) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Stop the camera temporarily
      await controller.stop();

      // Validate QR code format (should be a user ID)
      if (qrData.isEmpty || qrData.length < 10) {
        _showErrorDialog(
          'Invalid QR Code',
          'This QR code does not contain valid user information.',
        );
        return;
      }

      // Check if it's the current user's own QR code
      if (qrData == FirebaseService.currentUserId) {
        _showErrorDialog(
          'Cannot Transfer to Yourself',
          'You cannot send money to your own account.',
        );
        return;
      }

      // Fetch user details from Firebase
      UserModel? recipient = await FirebaseService.getUser(qrData);

      if (recipient == null) {
        _showErrorDialog(
          'User Not Found',
          'No user found with this QR code. Please try again.',
        );
        return;
      }

      // Navigate to transfer money screen with pre-filled recipient
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TransferMoneyScreen(
              recipientId: recipient.uid,
              recipientName: recipient.name,
            ),
          ),
        );
      }
    } catch (e) {
      _showErrorDialog('Error', 'Failed to process QR code: ${e.toString()}');
    } finally {
      setState(() {
        _isProcessing = false;
      });
      // Restart camera if still on this screen
      if (mounted) {
        await controller.start();
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF262626),
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: const Color(0xFF262626),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Restart camera
              controller.start();
            },
            child: Text(
              'OK',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF3D95CE),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebPlaceholder() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.qr_code_scanner,
                  size: 50,
                  color: Colors.orange[600],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'QR Scanner Not Available',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'QR code scanning is not available on web browsers. Please use the mobile app for QR code functionality.',
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Go Back',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show web placeholder for web platform
    if (kIsWeb) {
      return _buildWebPlaceholder();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Scan QR Code',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF262626),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Mobile Scanner View
          MobileScanner(controller: controller, onDetect: _onDetect),

          // Scanner overlay
          Center(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF3D95CE), width: 4),
                borderRadius: BorderRadius.circular(16),
              ),
              width: 250,
              height: 250,
            ),
          ),

          // Instructions overlay
          Positioned(
            bottom: 100,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Point your camera at a QR code to scan',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Processing indicator
          if (_isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3D95CE)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
