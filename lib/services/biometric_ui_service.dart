import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../widgets/biometric_bottom_sheet.dart';
import 'biometric_service.dart';

class BiometricUIService {
  static final LocalAuthentication _localAuth = LocalAuthentication();

  /// Show biometric registration bottom sheet
  static Future<bool> showRegistrationBottomSheet(BuildContext context) async {
    bool isAuthenticated = false;
    bool isScanning = false;
    bool isSuccess = false;
    bool isError = false;
    String? errorMessage;

    // Check if biometric is available
    final isAvailable = await BiometricService.isBiometricAvailable();
    if (!isAvailable) {
      _showErrorSnackBar(
        context,
        'Biometric authentication is not available on this device',
      );
      return false;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Auto-start registration
            if (!isScanning && !isSuccess && !isError) {
              isScanning = true;
              _performRegistration(
                onResult: (success, error) {
                  setState(() {
                    isScanning = false;
                    if (success) {
                      isSuccess = true;
                      isAuthenticated = true;
                      // Auto-dismiss after success
                      Future.delayed(const Duration(milliseconds: 2000), () {
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      });
                    } else {
                      isError = true;
                      errorMessage = error;
                    }
                  });
                },
              );
            }

            return PopScope(
              canPop: !isScanning,
              child: BiometricBottomSheet(
                title: 'Enable Biometric Authentication',
                subtitle:
                    'Secure your transactions with fingerprint authentication',
                instructionText:
                    'Touch the fingerprint sensor to register your fingerprint',
                isScanning: isScanning,
                isSuccess: isSuccess,
                isError: isError,
                errorMessage: errorMessage,
                onCancel: () {
                  if (!isScanning) {
                    Navigator.of(context).pop();
                  }
                },
                onSuccess: () {
                  isAuthenticated = true;
                  Navigator.of(context).pop();
                },
                onError: () async {
                  // Reset error state and try again
                  setState(() {
                    isError = false;
                    errorMessage = null;
                    isScanning = true;
                  });

                  await _performRegistration(
                    onResult: (success, error) {
                      setState(() {
                        isScanning = false;
                        if (success) {
                          isSuccess = true;
                          isAuthenticated = true;
                          // Auto-dismiss after success
                          Future.delayed(
                            const Duration(milliseconds: 2000),
                            () {
                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }
                            },
                          );
                        } else {
                          isError = true;
                          errorMessage = error;
                        }
                      });
                    },
                  );
                },
              ),
            );
          },
        );
      },
    );

    if (isAuthenticated) {
      _showSuccessSnackBar(
        context,
        'Biometric authentication enabled successfully!',
      );
    }

    return isAuthenticated;
  }

  /// Show biometric authentication bottom sheet for transactions
  static Future<bool> showAuthenticationBottomSheet({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String reason,
  }) async {
    bool isAuthenticated = false;
    bool isScanning = false;
    bool isSuccess = false;
    bool isError = false;
    String? errorMessage;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return WillPopScope(
              onWillPop: () async => !isScanning,
              child: BiometricBottomSheet(
                title: title,
                subtitle: subtitle,
                instructionText: 'Place your finger on the sensor',
                isScanning: isScanning,
                isSuccess: isSuccess,
                isError: isError,
                errorMessage: errorMessage,
                onCancel: () {
                  if (!isScanning) {
                    Navigator.of(context).pop();
                  }
                },
                onSuccess: () {
                  isAuthenticated = true;
                  Navigator.of(context).pop();
                },
                onError: () async {
                  // Reset error state and try again
                  setState(() {
                    isError = false;
                    errorMessage = null;
                    isScanning = true;
                  });

                  await _performAuthentication(
                    reason: reason,
                    onResult: (success, error) {
                      setState(() {
                        isScanning = false;
                        if (success) {
                          isSuccess = true;
                          isAuthenticated = true;
                          // Auto-dismiss after success
                          Future.delayed(
                            const Duration(milliseconds: 1500),
                            () {
                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }
                            },
                          );
                        } else {
                          isError = true;
                          errorMessage = error;
                        }
                      });
                    },
                  );
                },
              ),
            );
          },
        );
      },
    );

    // Start authentication immediately when sheet opens
    if (!isAuthenticated) {
      await Future.delayed(const Duration(milliseconds: 500));

      if (context.mounted) {
        await showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          isDismissible: false,
          enableDrag: false,
          builder: (BuildContext context) {
            return StatefulBuilder(
              builder: (context, setState) {
                // Auto-start scanning
                if (!isScanning && !isSuccess && !isError) {
                  isScanning = true;
                  _performAuthentication(
                    reason: reason,
                    onResult: (success, error) {
                      setState(() {
                        isScanning = false;
                        if (success) {
                          isSuccess = true;
                          isAuthenticated = true;
                          // Auto-dismiss after success
                          Future.delayed(
                            const Duration(milliseconds: 1500),
                            () {
                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }
                            },
                          );
                        } else {
                          isError = true;
                          errorMessage = error;
                        }
                      });
                    },
                  );
                }

                return WillPopScope(
                  onWillPop: () async => !isScanning,
                  child: BiometricBottomSheet(
                    title: title,
                    subtitle: subtitle,
                    instructionText: 'Place your finger on the sensor',
                    isScanning: isScanning,
                    isSuccess: isSuccess,
                    isError: isError,
                    errorMessage: errorMessage,
                    onCancel: () {
                      if (!isScanning) {
                        Navigator.of(context).pop();
                      }
                    },
                    onSuccess: () {
                      isAuthenticated = true;
                      Navigator.of(context).pop();
                    },
                    onError: () async {
                      // Reset error state and try again
                      setState(() {
                        isError = false;
                        errorMessage = null;
                        isScanning = true;
                      });

                      await _performAuthentication(
                        reason: reason,
                        onResult: (success, error) {
                          setState(() {
                            isScanning = false;
                            if (success) {
                              isSuccess = true;
                              isAuthenticated = true;
                              // Auto-dismiss after success
                              Future.delayed(
                                const Duration(milliseconds: 1500),
                                () {
                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                  }
                                },
                              );
                            } else {
                              isError = true;
                              errorMessage = error;
                            }
                          });
                        },
                      );
                    },
                  ),
                );
              },
            );
          },
        );
      }
    }

    return isAuthenticated;
  }

  /// Perform the actual biometric authentication
  static Future<void> _performAuthentication({
    required String reason,
    required Function(bool success, String? error) onResult,
  }) async {
    try {
      final result = await BiometricService.authenticateWithBiometric(
        reason: reason,
        title: 'Biometric Authentication',
      );

      if (result.success) {
        onResult(true, null);
      } else {
        String errorMsg = 'Authentication failed';

        switch (result.errorType) {
          case BiometricErrorType.userCancel:
            errorMsg = 'Authentication was cancelled';
            break;
          case BiometricErrorType.lockedOut:
            errorMsg = 'Too many attempts. Please try again later';
            break;
          case BiometricErrorType.permanentlyLockedOut:
            errorMsg =
                'Biometric authentication is locked. Use device credentials';
            break;
          case BiometricErrorType.notEnrolled:
            errorMsg = 'No fingerprints enrolled on this device';
            break;
          case BiometricErrorType.notAvailable:
            errorMsg = 'Biometric authentication is not available';
            break;
          default:
            errorMsg = result.error ?? 'Authentication failed';
        }

        onResult(false, errorMsg);
      }
    } catch (e) {
      onResult(false, 'An unexpected error occurred');
    }
  }

  /// Show success snackbar
  static void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show error snackbar
  static void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Perform the actual biometric registration
  static Future<void> _performRegistration({
    required Function(bool success, String? error) onResult,
  }) async {
    try {
      final result = await BiometricService.registerBiometric();

      if (result.success) {
        onResult(true, null);
      } else {
        String errorMsg = 'Registration failed';

        switch (result.errorType) {
          case BiometricErrorType.userCancel:
            errorMsg = 'Registration was cancelled';
            break;
          case BiometricErrorType.lockedOut:
            errorMsg = 'Too many attempts. Please try again later';
            break;
          case BiometricErrorType.permanentlyLockedOut:
            errorMsg =
                'Biometric authentication is locked. Use device credentials';
            break;
          case BiometricErrorType.notEnrolled:
            errorMsg = 'No fingerprints enrolled on this device';
            break;
          case BiometricErrorType.notAvailable:
            errorMsg = 'Biometric authentication is not available';
            break;
          default:
            errorMsg = result.error ?? 'Registration failed';
        }

        onResult(false, errorMsg);
      }
    } catch (e) {
      onResult(false, 'An unexpected error occurred');
    }
  }
}
