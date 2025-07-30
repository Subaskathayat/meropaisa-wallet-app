import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_service.dart';

class BiometricService {
  static final LocalAuthentication _localAuth = LocalAuthentication();
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _biometricRegisteredKey = 'biometric_registered';

  /// Check if biometric authentication is available on the device
  static Future<bool> isBiometricAvailable() async {
    try {
      final bool isAvailable = await _localAuth.isDeviceSupported();
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      return isAvailable && canCheckBiometrics;
    } catch (e) {
      print('Error checking biometric availability: $e');
      return false;
    }
  }

  /// Get available biometric types on the device
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      print('Error getting available biometrics: $e');
      return [];
    }
  }

  /// Check if fingerprint is available specifically
  static Future<bool> isFingerprintAvailable() async {
    try {
      final List<BiometricType> availableBiometrics =
          await getAvailableBiometrics();
      return availableBiometrics.contains(BiometricType.fingerprint) ||
          availableBiometrics.contains(BiometricType.strong) ||
          availableBiometrics.isNotEmpty;
    } catch (e) {
      print('Error checking fingerprint availability: $e');
      return false;
    }
  }

  /// Register/Enable biometric authentication for the user
  static Future<BiometricResult> registerBiometric() async {
    try {
      // Check if biometric is available
      if (!await isBiometricAvailable()) {
        return BiometricResult(
          success: false,
          error: 'Biometric authentication is not available on this device',
          errorType: BiometricErrorType.notAvailable,
        );
      }

      // Authenticate to register
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason:
            'Please verify your identity to enable biometric authentication',
        authMessages: const [
          AndroidAuthMessages(
            signInTitle: 'Enable Biometric Authentication',
            biometricHint: 'Touch the fingerprint sensor',
            biometricNotRecognized: 'Fingerprint not recognized, try again',
            biometricRequiredTitle: 'Fingerprint Required',
            biometricSuccess: 'Fingerprint recognized successfully',
            cancelButton: 'Cancel',
            deviceCredentialsRequiredTitle: 'Device credentials required',
            deviceCredentialsSetupDescription:
                'Please set up device credentials',
            goToSettingsButton: 'Go to Settings',
            goToSettingsDescription:
                'Please set up biometric authentication in settings',
          ),
          IOSAuthMessages(
            cancelButton: 'Cancel',
            goToSettingsButton: 'Go to Settings',
            goToSettingsDescription:
                'Please set up biometric authentication in settings',
            lockOut: 'Please re-enable biometric authentication',
          ),
        ],
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
        // Save biometric registration status
        await _saveBiometricStatus(enabled: true, registered: true);

        // Update user profile in Firebase
        if (FirebaseService.currentUserId != null) {
          await FirebaseService.updateUserProfile(
            FirebaseService.currentUserId!,
            {
              'biometricEnabled': true,
              'biometricRegistered': true,
              'biometricRegisteredAt': DateTime.now().toIso8601String(),
            },
          );
        }

        return BiometricResult(success: true);
      } else {
        return BiometricResult(
          success: false,
          error: 'Biometric authentication was cancelled or failed',
          errorType: BiometricErrorType.userCancel,
        );
      }
    } on PlatformException catch (e) {
      return _handlePlatformException(e);
    } catch (e) {
      return BiometricResult(
        success: false,
        error: 'An unexpected error occurred: ${e.toString()}',
        errorType: BiometricErrorType.unknown,
      );
    }
  }

  /// Authenticate user with biometric
  static Future<BiometricResult> authenticateWithBiometric({
    required String reason,
    String? title,
  }) async {
    try {
      // Check if biometric is enabled for the user
      if (!await isBiometricEnabled()) {
        return BiometricResult(
          success: false,
          error: 'Biometric authentication is not enabled',
          errorType: BiometricErrorType.notEnabled,
        );
      }

      // Check if biometric is available
      if (!await isBiometricAvailable()) {
        return BiometricResult(
          success: false,
          error: 'Biometric authentication is not available',
          errorType: BiometricErrorType.notAvailable,
        );
      }

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason,
        authMessages: [
          AndroidAuthMessages(
            signInTitle: title ?? 'Biometric Authentication',
            biometricHint: 'Touch the fingerprint sensor',
            biometricNotRecognized: 'Fingerprint not recognized, try again',
            biometricRequiredTitle: 'Fingerprint Required',
            biometricSuccess: 'Fingerprint recognized successfully',
            cancelButton: 'Cancel',
            deviceCredentialsRequiredTitle: 'Device credentials required',
            deviceCredentialsSetupDescription:
                'Please set up device credentials',
            goToSettingsButton: 'Go to Settings',
            goToSettingsDescription:
                'Please set up biometric authentication in settings',
          ),
          IOSAuthMessages(
            cancelButton: 'Cancel',
            goToSettingsButton: 'Go to Settings',
            goToSettingsDescription:
                'Please set up biometric authentication in settings',
            lockOut: 'Please re-enable biometric authentication',
          ),
        ],
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );

      return BiometricResult(success: didAuthenticate);
    } on PlatformException catch (e) {
      return _handlePlatformException(e);
    } catch (e) {
      return BiometricResult(
        success: false,
        error: 'An unexpected error occurred: ${e.toString()}',
        errorType: BiometricErrorType.unknown,
      );
    }
  }

  /// Disable biometric authentication
  static Future<bool> disableBiometric() async {
    try {
      await _saveBiometricStatus(enabled: false, registered: false);

      // Update user profile in Firebase
      if (FirebaseService.currentUserId != null) {
        await FirebaseService.updateUserProfile(
          FirebaseService.currentUserId!,
          {
            'biometricEnabled': false,
            'biometricDisabledAt': DateTime.now().toIso8601String(),
          },
        );
      }

      return true;
    } catch (e) {
      print('Error disabling biometric: $e');
      return false;
    }
  }

  /// Check if biometric is enabled for the current user
  static Future<bool> isBiometricEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_biometricEnabledKey) ?? false;
    } catch (e) {
      print('Error checking biometric enabled status: $e');
      return false;
    }
  }

  /// Check if biometric is registered for the current user
  static Future<bool> isBiometricRegistered() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_biometricRegisteredKey) ?? false;
    } catch (e) {
      print('Error checking biometric registered status: $e');
      return false;
    }
  }

  /// Save biometric status to local storage
  static Future<void> _saveBiometricStatus({
    required bool enabled,
    required bool registered,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_biometricEnabledKey, enabled);
      await prefs.setBool(_biometricRegisteredKey, registered);
    } catch (e) {
      print('Error saving biometric status: $e');
    }
  }

  /// Handle platform exceptions and convert to BiometricResult
  static BiometricResult _handlePlatformException(PlatformException e) {
    switch (e.code) {
      case 'NotAvailable':
        return BiometricResult(
          success: false,
          error: 'Biometric authentication is not available on this device',
          errorType: BiometricErrorType.notAvailable,
        );
      case 'NotEnrolled':
        return BiometricResult(
          success: false,
          error: 'No biometric credentials are enrolled on this device',
          errorType: BiometricErrorType.notEnrolled,
        );
      case 'LockedOut':
        return BiometricResult(
          success: false,
          error:
              'Biometric authentication is temporarily locked. Please try again later',
          errorType: BiometricErrorType.lockedOut,
        );
      case 'PermanentlyLockedOut':
        return BiometricResult(
          success: false,
          error:
              'Biometric authentication is permanently locked. Please use device credentials',
          errorType: BiometricErrorType.permanentlyLockedOut,
        );
      case 'UserCancel':
        return BiometricResult(
          success: false,
          error: 'Biometric authentication was cancelled',
          errorType: BiometricErrorType.userCancel,
        );
      case 'UserFallback':
        return BiometricResult(
          success: false,
          error: 'User chose to use fallback authentication',
          errorType: BiometricErrorType.userFallback,
        );
      case 'MissingPluginException':
        return BiometricResult(
          success: false,
          error:
              'Biometric authentication is not properly configured. Please restart the app and try again.',
          errorType: BiometricErrorType.unknown,
        );
      default:
        String errorMessage = 'Biometric authentication failed';
        if (e.message?.contains('FragmentActivity') == true) {
          errorMessage =
              'Biometric authentication configuration error. Please restart the app and try again.';
        } else if (e.message != null) {
          errorMessage = 'Biometric authentication failed: ${e.message}';
        }
        return BiometricResult(
          success: false,
          error: errorMessage,
          errorType: BiometricErrorType.unknown,
        );
    }
  }

  /// Get user-friendly biometric type name
  static String getBiometricTypeName(List<BiometricType> types) {
    if (types.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    } else if (types.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (types.contains(BiometricType.iris)) {
      return 'Iris';
    } else if (types.contains(BiometricType.strong)) {
      return 'Biometric';
    } else if (types.contains(BiometricType.weak)) {
      return 'Biometric';
    } else {
      return 'Biometric';
    }
  }
}

/// Result class for biometric operations
class BiometricResult {
  final bool success;
  final String? error;
  final BiometricErrorType? errorType;

  BiometricResult({required this.success, this.error, this.errorType});
}

/// Enum for different types of biometric errors
enum BiometricErrorType {
  notAvailable,
  notEnrolled,
  notEnabled,
  lockedOut,
  permanentlyLockedOut,
  userCancel,
  userFallback,
  unknown,
}
