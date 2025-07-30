import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/firebase_service.dart';
import '../services/transaction_auth_service.dart';
import '../models/user_model.dart';

class DummyPaymentScreen extends StatefulWidget {
  final String serviceType;
  final String serviceName;

  const DummyPaymentScreen({
    super.key,
    required this.serviceType,
    required this.serviceName,
  });

  @override
  State<DummyPaymentScreen> createState() => _DummyPaymentScreenState();
}

class _DummyPaymentScreenState extends State<DummyPaymentScreen> {
  final TextEditingController _serviceIdController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  UserModel? _currentUser;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  @override
  void dispose() {
    _serviceIdController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _loadCurrentUser() async {
    try {
      String? userId = FirebaseService.currentUserId;
      if (userId != null) {
        UserModel? user = await FirebaseService.getUser(userId);
        setState(() {
          _currentUser = user;
        });
      }
    } catch (e) {
      _showSnackBar('Error loading user data');
    }
  }

  void _processPayment() async {
    String serviceId = _serviceIdController.text.trim();
    String amountText = _amountController.text.trim();

    if (serviceId.isEmpty) {
      _showSnackBar('Please enter ${_getServiceIdLabel()}');
      return;
    }

    if (amountText.isEmpty) {
      _showSnackBar('Please enter amount');
      return;
    }

    double? amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      _showSnackBar('Please enter a valid amount');
      return;
    }

    if (amount > (_currentUser?.balance ?? 0)) {
      _showSnackBar('Insufficient balance');
      return;
    }

    // Authenticate transaction before proceeding
    final isAuthenticated =
        await TransactionAuthService.authenticateTransaction(
          context: context,
          transactionType: 'payment',
          amount: amount,
          recipientName: widget.serviceName,
        );

    if (!isAuthenticated) {
      return; // User cancelled or authentication failed
    }

    setState(() {
      _isLoading = true;
    });

    try {
      bool success = await FirebaseService.processUtilityPayment(
        userId: FirebaseService.currentUserId!,
        amount: amount,
        type: widget.serviceType,
        serviceId: serviceId,
      );

      setState(() {
        _isLoading = false;
      });

      if (success) {
        _showSuccessDialog(amount, serviceId);
      } else {
        _showSnackBar('Payment failed. Please try again.');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Error: ${e.toString()}');
    }
  }

  void _showSuccessDialog(double amount, String serviceId) {
    final formatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(Icons.check, size: 40, color: Colors.green),
            ),
            const SizedBox(height: 24),
            Text(
              'Payment Successful!',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${formatter.format(amount)} paid for ${widget.serviceName}',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '${_getServiceIdLabel()}: $serviceId',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(
              'Done',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1976D2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getServiceIdLabel() {
    switch (widget.serviceType) {
      case 'mobile':
        return 'Mobile Number';
      case 'electricity':
        return 'Consumer Number';
      case 'water':
        return 'Consumer Number';
      case 'internet':
        return 'Customer ID';
      case 'traffic_fine':
        return 'Challan Number';
      case 'movie_ticket':
        return 'Booking ID';
      case 'bus_ticket':
        return 'Ticket ID';
      case 'airline':
        return 'PNR Number';
      case 'hotel':
        return 'Booking ID';
      default:
        return 'Service ID';
    }
  }

  String _getServiceIdHint() {
    switch (widget.serviceType) {
      case 'mobile':
        return 'Enter mobile number';
      case 'electricity':
        return 'Enter consumer number';
      case 'water':
        return 'Enter consumer number';
      case 'internet':
        return 'Enter customer ID';
      case 'traffic_fine':
        return 'Enter challan number';
      case 'movie_ticket':
        return 'Enter booking ID';
      case 'bus_ticket':
        return 'Enter ticket ID';
      case 'airline':
        return 'Enter PNR number';
      case 'hotel':
        return 'Enter booking ID';
      default:
        return 'Enter service ID';
    }
  }

  IconData _getServiceIcon() {
    switch (widget.serviceType) {
      case 'mobile':
        return Icons.phone_android;
      case 'electricity':
        return Icons.electrical_services;
      case 'water':
        return Icons.water_drop;
      case 'internet':
        return Icons.wifi;
      case 'traffic_fine':
        return Icons.local_police;
      case 'movie_ticket':
        return Icons.movie;
      case 'bus_ticket':
        return Icons.directions_bus;
      case 'airline':
        return Icons.flight;
      case 'hotel':
        return Icons.hotel;
      default:
        return Icons.payment;
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.serviceName,
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Service Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF1976D2).withOpacity(0.1),
                    const Color(0xFF42A5F5).withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1976D2),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Icon(
                      _getServiceIcon(),
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.serviceName,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1976D2),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pay your ${widget.serviceName.toLowerCase()} bill instantly',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Current Balance
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color: Colors.blue[600],
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available Balance',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.blue[600],
                        ),
                      ),
                      Text(
                        formatter.format(_currentUser?.balance ?? 0),
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Service ID
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getServiceIdLabel(),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _serviceIdController,
                  decoration: InputDecoration(
                    hintText: _getServiceIdHint(),
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
                  ),
                  style: GoogleFonts.poppins(fontSize: 16),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Amount',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Enter amount to pay',
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
                    prefixText: '₹ ',
                    prefixStyle: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  style: GoogleFonts.poppins(fontSize: 16),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Pay Button
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _processPayment,
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
                        'Pay Now',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 24),

            // Disclaimer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.orange[600], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This is a simulation for demonstration purposes. No actual payment will be processed.',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.orange[700],
                      ),
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
}
