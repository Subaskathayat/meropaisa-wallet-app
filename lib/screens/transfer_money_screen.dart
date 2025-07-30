import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/firebase_service.dart';
import '../services/transaction_auth_service.dart';
import '../models/user_model.dart';

class TransferMoneyScreen extends StatefulWidget {
  final String? recipientId;
  final String? recipientName;

  const TransferMoneyScreen({super.key, this.recipientId, this.recipientName});

  @override
  State<TransferMoneyScreen> createState() => _TransferMoneyScreenState();
}

class _TransferMoneyScreenState extends State<TransferMoneyScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  UserModel? _currentUser;
  UserModel? _recipient;
  bool _isLoading = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    if (widget.recipientId != null) {
      _loadRecipient();
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    _noteController.dispose();
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

  void _loadRecipient() async {
    try {
      if (widget.recipientId != null) {
        UserModel? user = await FirebaseService.getUser(widget.recipientId!);
        setState(() {
          _recipient = user;
          _phoneController.text =
              user?.phoneNumber.replaceFirst('+91', '') ?? '';
        });
      }
    } catch (e) {
      _showSnackBar('Error loading recipient data');
    }
  }

  void _searchRecipient() async {
    String phoneNumber = _phoneController.text.trim();

    if (phoneNumber.isEmpty) {
      _showSnackBar('Please enter phone number');
      return;
    }

    if (phoneNumber.length != 10) {
      _showSnackBar('Please enter a valid 10-digit phone number');
      return;
    }

    // Check if it's the same as current user's phone
    if (_currentUser?.phoneNumber == '+91$phoneNumber') {
      _showSnackBar('You cannot send money to yourself');
      return;
    }

    setState(() {
      _isSearching = true;
      _recipient = null;
    });

    try {
      UserModel? user = await FirebaseService.getUserByPhoneNumber(
        '+91$phoneNumber',
      );
      setState(() {
        _recipient = user;
        _isSearching = false;
      });

      if (user == null) {
        _showSnackBar('User not found with this phone number');
      }
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      _showSnackBar('Error searching for user');
    }
  }

  void _transferMoney() async {
    if (_recipient == null) {
      _showSnackBar('Please search and select a recipient first');
      return;
    }

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

    if (amount > (_currentUser?.balance ?? 0)) {
      _showSnackBar('Insufficient balance');
      return;
    }

    // Authenticate transaction before proceeding
    final isAuthenticated =
        await TransactionAuthService.authenticateTransaction(
          context: context,
          transactionType: 'transfer',
          amount: amount,
          recipientName: _recipient!.name,
        );

    if (!isAuthenticated) {
      return; // User cancelled or authentication failed
    }

    setState(() {
      _isLoading = true;
    });

    try {
      bool success = await FirebaseService.transferMoney(
        senderId: FirebaseService.currentUserId!,
        receiverId: _recipient!.uid,
        amount: amount,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      );

      setState(() {
        _isLoading = false;
      });

      if (success) {
        _showSuccessDialog(amount);
      } else {
        _showSnackBar('Transfer failed. Please try again.');
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
              'Transfer Successful!',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${formatter.format(amount)} sent to ${_recipient!.name}',
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
                color: const Color(0xFF1976D2),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Transfer Money',
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

            // Recipient Phone Number
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recipient\'s Phone Number',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        decoration: InputDecoration(
                          hintText: 'Enter 10-digit phone number',
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.grey[500],
                          ),
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
                          prefixText: '+91 ',
                          prefixStyle: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          counterText: '',
                        ),
                        style: GoogleFonts.poppins(fontSize: 16),
                        onChanged: (value) {
                          if (_recipient != null) {
                            setState(() {
                              _recipient = null;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isSearching ? null : _searchRecipient,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1976D2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSearching
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(Icons.search, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Recipient Info
            if (_recipient != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Icon(
                        Icons.person,
                        color: Colors.green[600],
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _recipient!.name,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.green[700],
                            ),
                          ),
                          Text(
                            _recipient!.phoneNumber,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.green[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.check_circle,
                      color: Colors.green[600],
                      size: 24,
                    ),
                  ],
                ),
              ),
            ],

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
                    hintText: 'Enter amount',
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

            const SizedBox(height: 24),

            // Note (Optional)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Note (Optional)',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _noteController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Add a note for this transfer',
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
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  style: GoogleFonts.poppins(fontSize: 16),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Send Button
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _transferMoney,
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
                        'Send Money',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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
