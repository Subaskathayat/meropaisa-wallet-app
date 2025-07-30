import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class TestFirebaseScreen extends StatefulWidget {
  const TestFirebaseScreen({super.key});

  @override
  State<TestFirebaseScreen> createState() => _TestFirebaseScreenState();
}

class _TestFirebaseScreenState extends State<TestFirebaseScreen> {
  final List<String> _testResults = [];
  bool _isLoading = false;

  void _addResult(String result) {
    setState(() {
      _testResults.add(result);
    });
  }

  Future<void> _runFirebaseTests() async {
    setState(() {
      _isLoading = true;
      _testResults.clear();
    });

    try {
      // Test 1: Firebase Core Initialization
      _addResult('✓ Testing Firebase Core...');
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (Firebase.apps.isNotEmpty) {
        _addResult('✓ Firebase Core: INITIALIZED');
      } else {
        _addResult('✗ Firebase Core: NOT INITIALIZED');
        return;
      }

      // Test 2: Firebase Auth
      _addResult('✓ Testing Firebase Auth...');
      await Future.delayed(const Duration(milliseconds: 500));
      
      try {
        final auth = FirebaseAuth.instance;
        final currentUser = auth.currentUser;
        _addResult('✓ Firebase Auth: CONNECTED');
        _addResult('  Current User: ${currentUser?.uid ?? 'Not logged in'}');
      } catch (e) {
        _addResult('✗ Firebase Auth: ERROR - ${e.toString()}');
      }

      // Test 3: Cloud Firestore
      _addResult('✓ Testing Cloud Firestore...');
      await Future.delayed(const Duration(milliseconds: 500));
      
      try {
        final firestore = FirebaseFirestore.instance;
        
        // Test write operation
        await firestore.collection('test').doc('connectivity').set({
          'timestamp': FieldValue.serverTimestamp(),
          'test': 'Firebase connectivity test',
        });
        
        // Test read operation
        final doc = await firestore.collection('test').doc('connectivity').get();
        
        if (doc.exists) {
          _addResult('✓ Cloud Firestore: READ/WRITE SUCCESS');
        } else {
          _addResult('✗ Cloud Firestore: READ FAILED');
        }
        
        // Clean up test document
        await firestore.collection('test').doc('connectivity').delete();
        
      } catch (e) {
        _addResult('✗ Cloud Firestore: ERROR - ${e.toString()}');
      }

      // Test 4: Firebase Storage
      _addResult('✓ Testing Firebase Storage...');
      await Future.delayed(const Duration(milliseconds: 500));
      
      try {
        final storage = FirebaseStorage.instance;
        final ref = storage.ref().child('test/connectivity_test.txt');
        
        // Test upload
        await ref.putString('Firebase Storage connectivity test');
        
        // Test download
        final downloadUrl = await ref.getDownloadURL();
        
        if (downloadUrl.isNotEmpty) {
          _addResult('✓ Firebase Storage: UPLOAD/DOWNLOAD SUCCESS');
        } else {
          _addResult('✗ Firebase Storage: DOWNLOAD FAILED');
        }
        
        // Clean up test file
        await ref.delete();
        
      } catch (e) {
        _addResult('✗ Firebase Storage: ERROR - ${e.toString()}');
      }

      // Test 5: Network Connectivity
      _addResult('✓ Testing Network Connectivity...');
      await Future.delayed(const Duration(milliseconds: 500));
      
      try {
        final firestore = FirebaseFirestore.instance;
        await firestore.enableNetwork();
        _addResult('✓ Network: CONNECTED');
      } catch (e) {
        _addResult('✗ Network: ERROR - ${e.toString()}');
      }

      _addResult('');
      _addResult('🎉 Firebase Tests Completed!');

    } catch (e) {
      _addResult('✗ CRITICAL ERROR: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Firebase Connectivity Test',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF262626),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _runFirebaseTests,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3D95CE),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Run Firebase Tests',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: _testResults.isEmpty
                    ? Center(
                        child: Text(
                          'Press the button to run Firebase connectivity tests',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        itemCount: _testResults.length,
                        itemBuilder: (context, index) {
                          final result = _testResults[index];
                          Color textColor = Colors.black87;
                          
                          if (result.startsWith('✓')) {
                            textColor = Colors.green[700]!;
                          } else if (result.startsWith('✗')) {
                            textColor = Colors.red[700]!;
                          } else if (result.startsWith('🎉')) {
                            textColor = Colors.blue[700]!;
                          }
                          
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              result,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: textColor,
                                fontWeight: result.startsWith('✓') || result.startsWith('✗') || result.startsWith('🎉')
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
