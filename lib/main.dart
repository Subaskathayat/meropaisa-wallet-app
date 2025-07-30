import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'screens/auth_screen.dart';
import 'screens/nav_bar_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Firebase App Check for security
  await FirebaseAppCheck.instance.activate(
    // Use debug provider for development
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );

  runApp(const MeroPaisaApp());
}

class MeroPaisaApp extends StatelessWidget {
  const MeroPaisaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mero Paisa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFFFFFF), // White background
        primaryColor: const Color(0xFF3D95CE), // Blue accent
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3D95CE),
          primary: const Color(0xFF3D95CE),
          secondary: const Color(0xFF262626), // Mine Shaft
          surface: const Color(0xFFFFFFFF),
          onPrimary: const Color(0xFFFFFFFF), // Text on primary (blue)
          onSecondary: const Color(0xFFFFFFFF), // Text on Mine Shaft
          onSurface: const Color(0xFF262626), // Text on white/surface
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.poppinsTextTheme().apply(
          bodyColor: const Color(0xFF262626),
          displayColor: const Color(0xFF262626),
        ),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF262626), // Dark header
          foregroundColor: const Color(0xFFFFFFFF), // White text
          elevation: 0,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFFFFFFF),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3D95CE), // Blue accent
            foregroundColor: const Color(0xFFFFFFFF), // White text
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If user is logged in, show main app
        if (snapshot.hasData && snapshot.data != null) {
          return const NavBarHandler();
        }

        // If user is not logged in, show auth screen
        return const AuthScreen();
      },
    );
  }
}
