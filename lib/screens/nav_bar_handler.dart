import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';
import 'statement_screen.dart';
import 'qr_scanner_screen.dart';
import 'support_screen.dart';
import 'more_screen.dart';

class NavBarHandler extends StatefulWidget {
  const NavBarHandler({super.key});

  @override
  State<NavBarHandler> createState() => _NavBarHandlerState();
}

class _NavBarHandlerState extends State<NavBarHandler> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const StatementScreen(),
    const HomeScreen(), // Placeholder for QR Scanner (will be handled differently)
    const SupportScreen(),
    const MoreScreen(),
  ];

  void _onTabTapped(int index) {
    if (index == 2) {
      // QR Scanner - Navigate to QR scanner screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const QRScannerScreen()),
      );
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  void _showWebQRMessage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'QR Scanner',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'QR code scanning is temporarily disabled due to build compatibility issues. Please use the phone number search in the transfer money screen instead.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1976D2),
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
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 8,
            color: Colors.white,
            child: SizedBox(
              height: 70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home,
                    label: 'Home',
                    index: 0,
                  ),
                  _buildNavItem(
                    icon: Icons.receipt_long_outlined,
                    activeIcon: Icons.receipt_long,
                    label: 'Statement',
                    index: 1,
                  ),
                  const SizedBox(width: 40), // Space for FAB
                  _buildNavItem(
                    icon: Icons.support_agent_outlined,
                    activeIcon: Icons.support_agent,
                    label: 'Support',
                    index: 3,
                  ),
                  _buildNavItem(
                    icon: Icons.more_horiz_outlined,
                    activeIcon: Icons.more_horiz,
                    label: 'More',
                    index: 4,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: Container(
        width: 65,
        height: 65,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(32.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1976D2).withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => _onTabTapped(2),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(
            Icons.qr_code_scanner,
            size: 28,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final bool isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Icon(
          isActive ? activeIcon : icon,
          color: isActive ? const Color(0xFF1976D2) : Colors.grey[600],
          size: 24,
        ),
      ),
    );
  }
}
