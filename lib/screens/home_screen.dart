import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/firebase_service.dart';
import '../services/image_service.dart';
import '../models/user_model.dart';
import 'transfer_money_screen.dart';
import 'load_money_screen.dart';
import 'dummy_payment_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserModel? _currentUser;
  bool _isLoading = true;

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
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _refreshData() {
    setState(() {
      _isLoading = true;
    });
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async => _refreshData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildHeader(),
                    _buildBalanceCard(),
                    _buildTransferButton(),
                    _buildUtilityPayments(),
                    _buildTravelTicketing(),
                    const SizedBox(height: 100), // Space for bottom nav
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello,',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  _currentUser?.name ?? 'User',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(25),
              ),
              child: ClipOval(child: _buildProfileImage()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    final String photoUrl = _currentUser?.profilePhotoUrl ?? '';
    final String defaultUrl = ImageService.getDefaultAvatarUrl(
      _currentUser?.name,
      _currentUser?.phoneNumber,
    );

    return Image.network(
      ImageService.isValidImageUrl(photoUrl) ? photoUrl : defaultUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.white.withValues(alpha: 0.2),
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.white.withValues(alpha: 0.2),
          child: const Icon(Icons.person, color: Colors.white, size: 24),
        );
      },
    );
  }

  Widget _buildBalanceCard() {
    final formatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Balance',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            formatter.format(_currentUser?.balance ?? 0),
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransferButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          // Load Money Button
          Expanded(
            child: Container(
              height: 56,
              margin: const EdgeInsets.only(right: 2),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoadMoneyScreen(),
                    ),
                  ).then((_) => _refreshData());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3D95CE), // Blue accent
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Load Money',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Send Money Button
          Expanded(
            child: Container(
              height: 56,
              margin: const EdgeInsets.only(left: 2),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TransferMoneyScreen(),
                    ),
                  ).then((_) => _refreshData());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3D95CE), // Blue accent
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Send Money',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUtilityPayments() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Utility Payments',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4, // 2x4 grid (4 columns)
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.85,
            children: [
              // First row
              _buildUtilityItem(
                'Mobile\nTop-up',
                Icons.phone_android,
                'mobile',
              ),
              _buildUtilityItem(
                'Electricity',
                Icons.electrical_services,
                'electricity',
              ),
              _buildUtilityItem('Water', Icons.water_drop, 'water'),
              _buildUtilityItem('Internet', Icons.wifi, 'internet'),
              // Second row
              _buildUtilityItem(
                'Traffic\nFine',
                Icons.local_police,
                'traffic_fine',
              ),
              _buildUtilityItem('Gas\nBill', Icons.local_gas_station, 'gas'),
              _buildUtilityItem('Cable\nTV', Icons.tv, 'cable_tv'),
              _buildUtilityItem('Insurance', Icons.security, 'insurance'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTravelTicketing() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Travel & Ticketing',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4, // 2x4 grid (4 columns)
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.85,
            children: [
              // First row
              _buildTravelItem('Airlines', Icons.flight, 'airline'),
              _buildTravelItem('Hotels', Icons.hotel, 'hotel'),
              _buildTravelItem(
                'Bus Tickets',
                Icons.directions_bus,
                'bus_ticket',
              ),
              _buildTravelItem('Movie Tickets', Icons.movie, 'movie_ticket'),
              // Second row
              _buildTravelItem('Train Tickets', Icons.train, 'train_ticket'),
              _buildTravelItem('Car Rental', Icons.car_rental, 'car_rental'),
              _buildTravelItem('Events', Icons.event, 'events'),
              _buildTravelItem('Tours', Icons.tour, 'tours'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUtilityItem(String title, IconData icon, String type) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DummyPaymentScreen(
              serviceType: type,
              serviceName: title.replaceAll('\n', ' '),
            ),
          ),
        ).then((_) => _refreshData());
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              flex: 2,
              child: Icon(
                icon,
                size: 24,
                color: const Color(0xFF3D95CE), // Blue accent
              ),
            ),
            const SizedBox(height: 6),
            Flexible(
              flex: 1,
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF262626), // Mine Shaft
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTravelItem(String title, IconData icon, String type) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DummyPaymentScreen(serviceType: type, serviceName: title),
          ),
        ).then((_) => _refreshData());
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              flex: 2,
              child: Icon(
                icon,
                size: 24,
                color: const Color(0xFF3D95CE), // Blue accent
              ),
            ),
            const SizedBox(height: 6),
            Flexible(
              flex: 1,
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF262626), // Mine Shaft
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
