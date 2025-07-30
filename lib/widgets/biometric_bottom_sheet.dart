import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BiometricBottomSheet extends StatefulWidget {
  final String title;
  final String subtitle;
  final String instructionText;
  final VoidCallback? onCancel;
  final VoidCallback? onSuccess;
  final VoidCallback? onError;
  final bool isScanning;
  final bool isSuccess;
  final bool isError;
  final String? errorMessage;

  const BiometricBottomSheet({
    super.key,
    required this.title,
    required this.subtitle,
    required this.instructionText,
    this.onCancel,
    this.onSuccess,
    this.onError,
    this.isScanning = false,
    this.isSuccess = false,
    this.isError = false,
    this.errorMessage,
  });

  @override
  State<BiometricBottomSheet> createState() => _BiometricBottomSheetState();
}

class _BiometricBottomSheetState extends State<BiometricBottomSheet>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _successController;
  late AnimationController _errorController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    
    // Pulse animation for scanning state
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Success animation
    _successController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    // Error animation
    _errorController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _successController,
      curve: Curves.elasticOut,
    ));

    _colorAnimation = ColorTween(
      begin: const Color(0xFF3D95CE),
      end: Colors.green,
    ).animate(_successController);

    if (widget.isScanning) {
      _startPulseAnimation();
    }
  }

  @override
  void didUpdateWidget(BiometricBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isScanning && !oldWidget.isScanning) {
      _startPulseAnimation();
    } else if (!widget.isScanning && oldWidget.isScanning) {
      _pulseController.stop();
    }
    
    if (widget.isSuccess && !oldWidget.isSuccess) {
      _pulseController.stop();
      _successController.forward();
    }
    
    if (widget.isError && !oldWidget.isError) {
      _pulseController.stop();
      _errorController.forward();
    }
  }

  void _startPulseAnimation() {
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _successController.dispose();
    _errorController.dispose();
    super.dispose();
  }

  Color _getIconColor() {
    if (widget.isSuccess) {
      return Colors.green;
    } else if (widget.isError) {
      return Colors.red;
    } else {
      return const Color(0xFF3D95CE);
    }
  }

  IconData _getIcon() {
    if (widget.isSuccess) {
      return Icons.check_circle;
    } else if (widget.isError) {
      return Icons.error;
    } else {
      return Icons.fingerprint;
    }
  }

  String _getStatusText() {
    if (widget.isSuccess) {
      return 'Authentication Successful!';
    } else if (widget.isError) {
      return widget.errorMessage ?? 'Authentication Failed';
    } else if (widget.isScanning) {
      return 'Scanning...';
    } else {
      return widget.instructionText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Title
            Text(
              widget.title,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF262626),
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            // Subtitle
            Text(
              widget.subtitle,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            // Fingerprint Icon with Animation
            AnimatedBuilder(
              animation: Listenable.merge([
                _pulseAnimation,
                _scaleAnimation,
                _colorAnimation,
              ]),
              builder: (context, child) {
                double scale = 1.0;
                if (widget.isScanning) {
                  scale = _pulseAnimation.value;
                } else if (widget.isSuccess) {
                  scale = _scaleAnimation.value;
                }
                
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _getIconColor().withValues(alpha: 0.1),
                      border: Border.all(
                        color: _getIconColor().withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      _getIcon(),
                      size: 60,
                      color: _getIconColor(),
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // Status Text
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _getStatusText(),
                key: ValueKey(_getStatusText()),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: widget.isError 
                      ? Colors.red[700] 
                      : widget.isSuccess 
                          ? Colors.green[700]
                          : const Color(0xFF262626),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Action Buttons
            if (!widget.isSuccess) ...[
              Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: TextButton(
                      onPressed: widget.onCancel,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                  
                  if (widget.isError) ...[
                    const SizedBox(width: 16),
                    
                    // Try Again Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Reset error state and try again
                          if (widget.onError != null) {
                            widget.onError!();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3D95CE),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Try Again',
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
            ] else ...[
              // Success - Auto dismiss or continue button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onSuccess,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
            
            // Bottom padding for safe area
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}
