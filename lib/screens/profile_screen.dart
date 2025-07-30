import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../services/firebase_service.dart';
import '../services/image_service.dart';
import '../services/biometric_service.dart';
import '../services/biometric_ui_service.dart';
import '../models/user_model.dart';
import 'biometric_registration_screen.dart';
import '../firebase_diagnostic.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _currentUser;
  bool _isLoading = true;
  bool _isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    try {
      String? userId = FirebaseService.currentUserId;
      if (userId != null) {
        UserModel? user = await FirebaseService.getUser(userId);
        setState(() {
          _currentUser = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Select Photo Source',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF1976D2)),
              title: Text('Camera', style: GoogleFonts.poppins()),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: Color(0xFF1976D2),
              ),
              title: Text('Gallery', style: GoogleFonts.poppins()),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _pickAndUploadImage(ImageSource source) async {
    setState(() {
      _isUploadingPhoto = true;
    });

    try {
      // Pick image
      final XFile? imageFile = await ImageService.pickImage(source: source);
      if (imageFile == null) {
        setState(() {
          _isUploadingPhoto = false;
        });
        return;
      }

      // Show uploading progress
      _showSnackBar('Uploading profile photo...', isError: false);

      // Upload image with enhanced error handling
      final String? photoUrl = await ImageService.updateProfilePhoto(
        imageFile,
        _currentUser?.profilePhotoUrl,
      );

      if (photoUrl != null) {
        // Reload user data to get updated profile
        _loadUserData();
        _showSnackBar('Profile photo updated successfully!', isError: false);
      } else {
        _showSnackBar('Failed to upload profile photo. Please try again.');
      }
    } catch (e) {
      // Enhanced error handling with specific error messages
      String errorMessage = 'Error uploading photo: ';
      if (e.toString().contains('No authenticated user')) {
        errorMessage += 'Please log in again and try.';
      } else if (e.toString().contains('compress')) {
        errorMessage += 'Image processing failed. Try a different image.';
      } else if (e.toString().contains('Upload failed')) {
        errorMessage += 'Network error. Check your connection and try again.';
      } else {
        errorMessage += e.toString();
      }
      _showSnackBar(errorMessage);
    } finally {
      setState(() {
        _isUploadingPhoto = false;
      });
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildProfilePhoto() {
    final String photoUrl = _currentUser?.profilePhotoUrl ?? '';
    final String defaultUrl = ImageService.getDefaultAvatarUrl(
      _currentUser?.name,
      _currentUser?.phoneNumber,
    );

    return Stack(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF1976D2), width: 3),
          ),
          child: ClipOval(
            child: _isUploadingPhoto
                ? Container(
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  )
                : Image.network(
                    ImageService.isValidImageUrl(photoUrl)
                        ? photoUrl
                        : defaultUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.grey[400],
                        ),
                      );
                    },
                  ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _isUploadingPhoto ? null : _showImageSourceDialog,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF1976D2),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(
                _isUploadingPhoto ? Icons.hourglass_empty : Icons.camera_alt,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentUser == null
          ? Center(
              child: Text(
                'Unable to load profile',
                style: GoogleFonts.poppins(fontSize: 16),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Profile Photo Section
                  _buildProfilePhoto(),
                  const SizedBox(height: 24),

                  // User Info Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Personal Information',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow('Name', _currentUser!.name),
                        const SizedBox(height: 12),
                        _buildInfoRow('Phone', _currentUser!.phoneNumber),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          'Balance',
                          '₹${_currentUser!.balance.toStringAsFixed(2)}',
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          'Member Since',
                          '${_currentUser!.createdAt.day}/${_currentUser!.createdAt.month}/${_currentUser!.createdAt.year}',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Biometric Authentication Section
                  _buildBiometricSection(),

                  const SizedBox(height: 24),

                  // Debug Section (only in debug mode)
                  if (kDebugMode) _buildDebugSection(),

                  if (kDebugMode) const SizedBox(height: 24),

                  // Photo Upload Instructions
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue[600],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Profile Photo Tips',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue[800],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• Tap the camera icon to upload a new photo\n'
                          '• Choose from camera or gallery\n'
                          '• Photos are automatically compressed for optimal storage\n'
                          '• Use a clear, well-lit photo for best results',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.blue[700],
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildBiometricSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Security Settings',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Biometric Authentication Row
          FutureBuilder<bool>(
            future: BiometricService.isBiometricAvailable(),
            builder: (context, availableSnapshot) {
              return FutureBuilder<bool>(
                future: BiometricService.isBiometricEnabled(),
                builder: (context, enabledSnapshot) {
                  final isAvailable = availableSnapshot.data ?? false;
                  final isEnabled = enabledSnapshot.data ?? false;

                  return Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3D95CE).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.fingerprint,
                          color: Color(0xFF3D95CE),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Biometric Authentication',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF262626),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isAvailable
                                  ? (isEnabled ? 'Enabled' : 'Disabled')
                                  : 'Not Available',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: isAvailable
                                    ? (isEnabled
                                          ? Colors.green[600]
                                          : Colors.orange[600])
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isAvailable) ...[
                        if (isEnabled) ...[
                          // Disable button
                          TextButton(
                            onPressed: _disableBiometric,
                            child: Text(
                              'Disable',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.red[600],
                              ),
                            ),
                          ),
                        ] else ...[
                          // Enable button
                          TextButton(
                            onPressed: _enableBiometric,
                            child: Text(
                              'Enable',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF3D95CE),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ],
                  );
                },
              );
            },
          ),

          if (_currentUser?.biometricEnabled == true) ...[
            const SizedBox(height: 12),
            Text(
              'Last updated: ${_formatDate(_currentUser?.biometricRegisteredAt)}',
              style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDebugSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bug_report, color: Colors.orange[600], size: 20),
              const SizedBox(width: 8),
              Text(
                'Debug Tools',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Firebase Diagnostics Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FirebaseDiagnosticScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.cloud_done, size: 18),
              label: Text(
                'Firebase Diagnostics',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _enableBiometric() async {
    try {
      // Use the new custom biometric UI
      final isRegistered = await BiometricUIService.showRegistrationBottomSheet(
        context,
      );

      if (isRegistered) {
        setState(() {
          _loadUserData(); // Refresh user data
        });
        _showSnackBar(
          'Biometric authentication enabled successfully!',
          isError: false,
        );
      }
    } catch (e) {
      _showSnackBar(
        'Failed to enable biometric authentication: ${e.toString()}',
      );
    }
  }

  Future<void> _disableBiometric() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Disable Biometric Authentication',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF262626),
          ),
        ),
        content: Text(
          'Are you sure you want to disable biometric authentication? You will need to use your PIN for transaction verification.',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: const Color(0xFF262626),
          ),
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
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Disable',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red[600],
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success = await BiometricService.disableBiometric();
        if (success) {
          setState(() {
            _loadUserData(); // Refresh user data
          });
          _showSnackBar(
            'Biometric authentication disabled successfully!',
            isError: false,
          );
        } else {
          _showSnackBar('Failed to disable biometric authentication');
        }
      } catch (e) {
        _showSnackBar(
          'Failed to disable biometric authentication: ${e.toString()}',
        );
      }
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Never';
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
