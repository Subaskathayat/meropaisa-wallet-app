import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/biometric_service.dart';
import '../services/biometric_ui_service.dart';

class BiometricRegistrationScreen extends StatefulWidget {
  final bool isOptional;
  final VoidCallback? onSkip;
  final VoidCallback? onComplete;

  const BiometricRegistrationScreen({
    super.key,
    this.isOptional = true,
    this.onSkip,
    this.onComplete,
  });

  @override
  State<BiometricRegistrationScreen> createState() =>
      _BiometricRegistrationScreenState();
}

class _BiometricRegistrationScreenState
    extends State<BiometricRegistrationScreen> {
  bool _isLoading = false;
  bool _isBiometricAvailable = false;
  String _biometricType = 'Biometric';

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    final isAvailable = await BiometricService.isBiometricAvailable();
    final availableBiometrics = await BiometricService.getAvailableBiometrics();
    final biometricType = BiometricService.getBiometricTypeName(
      availableBiometrics,
    );

    setState(() {
      _isBiometricAvailable = isAvailable;
      _biometricType = biometricType;
    });
  }

  Future<void> _registerBiometric() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Use the new custom biometric UI
      final isRegistered = await BiometricUIService.showRegistrationBottomSheet(
        context,
      );

      setState(() {
        _isLoading = false;
      });

      if (isRegistered) {
        _showSuccessDialog();
      } else {
        // User cancelled or registration failed
        // No need to show error as the bottom sheet handles it
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('An unexpected error occurred: ${e.toString()}');
    }
  }

  void _showSuccessDialog() {
    showDialog(
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
              child: const Icon(
                Icons.fingerprint,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '$_biometricType Enabled!',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF262626),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Your transactions are now secured with $_biometricType authentication.',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (widget.onComplete != null) {
                widget.onComplete!();
              } else {
                Navigator.of(context).pop();
              }
            },
            child: Text(
              'Continue',
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

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Registration Failed',
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
            onPressed: () => Navigator.of(context).pop(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Secure Your Wallet',
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF3D95CE)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

                  // Biometric Icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3D95CE).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.fingerprint,
                      size: 60,
                      color: Color(0xFF3D95CE),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Title
                  Text(
                    'Enable $_biometricType Authentication',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF262626),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Description
                  Text(
                    'Secure your transactions with $_biometricType authentication. This adds an extra layer of security to your wallet.',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // Benefits
                  _buildBenefitItem(
                    Icons.security,
                    'Enhanced Security',
                    'Protect your money with advanced biometric security',
                  ),

                  const SizedBox(height: 16),

                  _buildBenefitItem(
                    Icons.speed,
                    'Quick Access',
                    'Fast and convenient authentication for transactions',
                  ),

                  const SizedBox(height: 16),

                  _buildBenefitItem(
                    Icons.privacy_tip,
                    'Privacy Protected',
                    'Your biometric data stays secure on your device',
                  ),

                  const SizedBox(height: 48),

                  // Enable Button
                  if (_isBiometricAvailable) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _registerBiometric,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3D95CE),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Enable $_biometricType',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    if (widget.isOptional) ...[
                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: TextButton(
                          onPressed: () {
                            if (widget.onSkip != null) {
                              widget.onSkip!();
                            } else {
                              Navigator.of(context).pop();
                            }
                          },
                          child: Text(
                            'Skip for Now',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF262626),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ] else ...[
                    // Not available message
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.orange[600]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '$_biometricType authentication is not available on this device.',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.orange[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          if (widget.onSkip != null) {
                            widget.onSkip!();
                          } else {
                            Navigator.of(context).pop();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3D95CE),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Continue',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF3D95CE).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF3D95CE), size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF262626),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
