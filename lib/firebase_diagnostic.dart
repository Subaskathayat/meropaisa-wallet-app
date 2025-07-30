import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'services/firebase_service.dart';

class FirebaseDiagnosticScreen extends StatefulWidget {
  const FirebaseDiagnosticScreen({super.key});

  @override
  State<FirebaseDiagnosticScreen> createState() => _FirebaseDiagnosticScreenState();
}

class _FirebaseDiagnosticScreenState extends State<FirebaseDiagnosticScreen> {
  final List<DiagnosticResult> _results = [];
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _runDiagnostics();
  }

  Future<void> _runDiagnostics() async {
    setState(() {
      _isRunning = true;
      _results.clear();
    });

    // Test 1: Firebase Core
    await _testFirebaseCore();
    
    // Test 2: Firebase Auth
    await _testFirebaseAuth();
    
    // Test 3: Firestore
    await _testFirestore();
    
    // Test 4: User Authentication Flow
    await _testUserAuthFlow();

    setState(() {
      _isRunning = false;
    });
  }

  Future<void> _testFirebaseCore() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        _addResult('Firebase Core', 'PASS', 'Firebase is properly initialized');
      } else {
        _addResult('Firebase Core', 'FAIL', 'Firebase not initialized');
      }
    } catch (e) {
      _addResult('Firebase Core', 'ERROR', e.toString());
    }
  }

  Future<void> _testFirebaseAuth() async {
    try {
      final auth = FirebaseAuth.instance;
      final currentUser = auth.currentUser;
      
      if (currentUser != null) {
        _addResult('Firebase Auth', 'PASS', 'User logged in: ${currentUser.uid}');
      } else {
        _addResult('Firebase Auth', 'INFO', 'No user currently logged in');
      }
      
      // Test auth state changes
      auth.authStateChanges().listen((user) {
        // Auth state listener is working
      });
      
      _addResult('Firebase Auth Service', 'PASS', 'Auth service accessible');
    } catch (e) {
      _addResult('Firebase Auth', 'ERROR', e.toString());
    }
  }

  Future<void> _testFirestore() async {
    try {
      final firestore = FirebaseFirestore.instance;
      
      // Test basic connectivity
      await firestore.enableNetwork();
      _addResult('Firestore Network', 'PASS', 'Network enabled successfully');
      
      // Test read operation
      try {
        final testDoc = await firestore.collection('test').doc('diagnostic').get();
        _addResult('Firestore Read', 'PASS', 'Read operation successful');
      } catch (e) {
        _addResult('Firestore Read', 'WARN', 'Read failed (may be permissions): ${e.toString()}');
      }
      
      // Test write operation
      try {
        await firestore.collection('test').doc('diagnostic').set({
          'timestamp': FieldValue.serverTimestamp(),
          'test': 'diagnostic',
        });
        _addResult('Firestore Write', 'PASS', 'Write operation successful');
        
        // Clean up
        await firestore.collection('test').doc('diagnostic').delete();
      } catch (e) {
        _addResult('Firestore Write', 'WARN', 'Write failed (may be permissions): ${e.toString()}');
      }
      
    } catch (e) {
      _addResult('Firestore', 'ERROR', e.toString());
    }
  }

  Future<void> _testUserAuthFlow() async {
    try {
      // Test if FirebaseService methods are accessible
      final currentUserId = FirebaseService.currentUserId;
      _addResult('FirebaseService', 'PASS', 'Service accessible, current user: ${currentUserId ?? 'None'}');
      
      // Test if we can access user data
      if (currentUserId != null) {
        try {
          final user = await FirebaseService.getUser(currentUserId);
          if (user != null) {
            _addResult('User Data', 'PASS', 'User data retrieved: ${user.name}');
          } else {
            _addResult('User Data', 'WARN', 'User document not found in Firestore');
          }
        } catch (e) {
          _addResult('User Data', 'ERROR', 'Failed to retrieve user data: ${e.toString()}');
        }
      }
      
    } catch (e) {
      _addResult('User Auth Flow', 'ERROR', e.toString());
    }
  }

  void _addResult(String test, String status, String message) {
    setState(() {
      _results.add(DiagnosticResult(test, status, message));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Firebase Diagnostics',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF262626),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _isRunning ? null : _runDiagnostics,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isRunning
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF3D95CE)),
                  SizedBox(height: 16),
                  Text('Running Firebase diagnostics...'),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final result = _results[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: _getStatusIcon(result.status),
                    title: Text(
                      result.test,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      result.message,
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(result.status),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        result.status,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _getStatusIcon(String status) {
    switch (status) {
      case 'PASS':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'FAIL':
        return const Icon(Icons.error, color: Colors.red);
      case 'ERROR':
        return const Icon(Icons.error_outline, color: Colors.red);
      case 'WARN':
        return const Icon(Icons.warning, color: Colors.orange);
      case 'INFO':
        return const Icon(Icons.info, color: Colors.blue);
      default:
        return const Icon(Icons.help, color: Colors.grey);
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PASS':
        return Colors.green;
      case 'FAIL':
        return Colors.red;
      case 'ERROR':
        return Colors.red;
      case 'WARN':
        return Colors.orange;
      case 'INFO':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

class DiagnosticResult {
  final String test;
  final String status;
  final String message;

  DiagnosticResult(this.test, this.status, this.message);
}
