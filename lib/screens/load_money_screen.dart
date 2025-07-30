import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/firebase_service.dart';
import '../services/transaction_auth_service.dart';
import '../models/user_model.dart';

class LoadMoneyScreen extends StatefulWidget {
  const LoadMoneyScreen({super.key});

  @override
  State<LoadMoneyScreen> createState() => _LoadMoneyScreenState();
}

class _LoadMoneyScreenState extends State<LoadMoneyScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  bool _isLoading = false;
  UserModel? _currentUser;
  String _selectedMethod = 'card'; // card, bank, mobile

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  void _loadCurrentUser() async {
    try {
      if (FirebaseService.currentUserId != null) {
        UserModel? user = await FirebaseService.getUser(
          FirebaseService.currentUserId!,
        );
        setState(() {
          _currentUser = user;
        });
      }
    } catch (e) {
      _showSnackBar('Error loading user data: ${e.toString()}');
    }
  }

  void _loadMoney() async {
    String amountText = _amountController.text.trim();

    if (amountText.isEmpty) {
      _showSnackBar('Please enter amount');
      return;
    }

    double? amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      _showSnackBar('Please enter a valid amount');
      return;
    }

    if (amount < 10) {
      _showSnackBar('Minimum load amount is ₹10');
      return;
    }

    if (amount > 50000) {
      _showSnackBar('Maximum load amount is ₹50,000');
      return;
    }

    // Validate payment method fields
    if (_selectedMethod == 'card') {
      if (_cardNumberController.text.trim().length < 16) {
        _showSnackBar('Please enter a valid card number');
        return;
      }
      if (_expiryController.text.trim().length < 5) {
        _showSnackBar('Please enter valid expiry date (MM/YY)');
        return;
      }
      if (_cvvController.text.trim().length < 3) {
        _showSnackBar('Please enter valid CVV');
        return;
      }
    }

    // Authenticate transaction before proceeding
    final isAuthenticated =
        await TransactionAuthService.authenticateTransaction(
          context: context,
          transactionType: 'load',
          amount: amount,
        );

    if (!isAuthenticated) {
      return; // User cancelled or authentication failed
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate load money transaction
      bool success = await FirebaseService.loadMoney(
        userId: FirebaseService.currentUserId!,
        amount: amount,
        method: _selectedMethod,
      );

      setState(() {
        _isLoading = false;
      });

      if (success) {
        _showSuccessDialog(amount);
      } else {
        _showSnackBar('Load money failed. Please try again.');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Error: ${e.toString()}');
    }
  }

  void _showSuccessDialog(double amount) {
    final formatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
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
              child: const Icon(Icons.check, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              'Money Loaded Successfully!',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF262626),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              '${formatter.format(amount)} added to your wallet',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
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
                color: const Color(0xFF3D95CE),
              ),
            ),
          ),
        ],
      ),
    );
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Load Money',
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
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current Balance Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3D95CE), Color(0xFF2E7BB8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Balance',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _currentUser != null
                              ? formatter.format(_currentUser!.balance)
                              : '₹0.00',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Amount Input
                  Text(
                    'Enter Amount',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF262626),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.poppins(fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Enter amount (₹10 - ₹50,000)',
                      prefixIcon: const Icon(
                        Icons.currency_rupee,
                        color: Color(0xFF3D95CE),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF3D95CE),
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Payment Method Selection
                  Text(
                    'Payment Method',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF262626),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Payment method tabs
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedMethod = 'card'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _selectedMethod == 'card'
                                    ? const Color(0xFF3D95CE)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Debit/Credit Card',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: _selectedMethod == 'card'
                                      ? Colors.white
                                      : const Color(0xFF262626),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Card Details (only show if card is selected)
                  if (_selectedMethod == 'card') ...[
                    Text(
                      'Card Details',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF262626),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Card Number
                    TextField(
                      controller: _cardNumberController,
                      keyboardType: TextInputType.number,
                      maxLength: 16,
                      style: GoogleFonts.poppins(fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'Card Number',
                        prefixIcon: const Icon(
                          Icons.credit_card,
                          color: Color(0xFF3D95CE),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF3D95CE),
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        counterText: '',
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        // Expiry Date
                        Expanded(
                          child: TextField(
                            controller: _expiryController,
                            keyboardType: TextInputType.number,
                            maxLength: 5,
                            style: GoogleFonts.poppins(fontSize: 16),
                            decoration: InputDecoration(
                              hintText: 'MM/YY',
                              prefixIcon: const Icon(
                                Icons.calendar_today,
                                color: Color(0xFF3D95CE),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF3D95CE),
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              counterText: '',
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        // CVV
                        Expanded(
                          child: TextField(
                            controller: _cvvController,
                            keyboardType: TextInputType.number,
                            maxLength: 3,
                            obscureText: true,
                            style: GoogleFonts.poppins(fontSize: 16),
                            decoration: InputDecoration(
                              hintText: 'CVV',
                              prefixIcon: const Icon(
                                Icons.lock,
                                color: Color(0xFF3D95CE),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF3D95CE),
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              counterText: '',
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                  ],

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
                        Icon(
                          Icons.info_outline,
                          color: Colors.orange[600],
                          size: 20,
                        ),
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

                  const SizedBox(height: 32),

                  // Load Money Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _loadMoney,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3D95CE),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Load Money',
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
