import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/biometric_service.dart';

class TestBiometricScreen extends StatefulWidget {
  const TestBiometricScreen({super.key});

  @override
  State<TestBiometricScreen> createState() => _TestBiometricScreenState();
}

class _TestBiometricScreenState extends State<TestBiometricScreen> {
  String _status = 'Ready to test';
  bool _isLoading = false;

  Future<void> _testBiometric() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing biometric availability...';
    });

    try {
      // Test availability
      final isAvailable = await BiometricService.isBiometricAvailable();
      setState(() {
        _status = 'Biometric available: $isAvailable';
      });

      if (isAvailable) {
        setState(() {
          _status = 'Attempting biometric registration...';
        });

        // Test registration
        final result = await BiometricService.registerBiometric();
        setState(() {
          _status = result.success 
              ? 'Biometric registration successful!' 
              : 'Registration failed: ${result.error}';
        });
      }
    } catch (e) {
      setState(() {
        _status = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Test Biometric',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF262626),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                _status,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: const Color(0xFF262626),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _testBiometric,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3D95CE),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Test Biometric',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
