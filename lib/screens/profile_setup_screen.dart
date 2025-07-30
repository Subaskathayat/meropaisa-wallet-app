import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firebase_service.dart';
import '../services/biometric_service.dart';
import 'nav_bar_handler.dart';
import 'biometric_registration_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  final String uid;
  final String phoneNumber;

  const ProfileSetupScreen({
    super.key,
    required this.uid,
    required this.phoneNumber,
  });

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _createProfile() async {
    String name = _nameController.text.trim();

    if (name.isEmpty) {
      _showSnackBar('Please enter your full name');
      return;
    }

    if (name.length < 2) {
      _showSnackBar('Name must be at least 2 characters long');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseService.createUser(
        uid: widget.uid,
        name: name,
        phoneNumber: widget.phoneNumber,
      );

      setState(() {
        _isLoading = false;
      });

      // Navigate to biometric registration or main app
      _navigateToNextStep();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Error creating profile: ${e.toString()}');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _navigateToNextStep() async {
    // Check if biometric is available and offer registration
    final isBiometricAvailable = await BiometricService.isBiometricAvailable();

    if (isBiometricAvailable && mounted) {
      // Navigate to biometric registration screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BiometricRegistrationScreen(
            isOptional: true,
            onSkip: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const NavBarHandler()),
                (route) => false,
              );
            },
            onComplete: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const NavBarHandler()),
                (route) => false,
              );
            },
          ),
        ),
      );
    } else if (mounted) {
      // Navigate directly to main app
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const NavBarHandler()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),

              // Welcome Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF1976D2).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.person_add,
                  size: 50,
                  color: Color(0xFF1976D2),
                ),
              ),

              const SizedBox(height: 40),

              // Title
              Text(
                'Complete Your Profile',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Subtitle
              Text(
                'Please enter your full name to get started with Mero Paisa',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 60),

              // Name Input Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Full Name',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: 'Enter your full name',
                      hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF1976D2),
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      prefixIcon: const Icon(
                        Icons.person_outline,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Initial Balance Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      color: Colors.green[600],
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome Bonus!',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.green[700],
                            ),
                          ),
                          Text(
                            'You\'ll receive ₹50,000 as starting balance',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.green[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Create Profile Button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createProfile,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          'Create Profile',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
