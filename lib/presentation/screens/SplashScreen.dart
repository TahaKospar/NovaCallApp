import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:novacall/constants/icon/gif.dart';
import 'package:novacall/constants/strings/strings.dart';
import 'package:novacall/main.dart' show initZegoService;

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user != null && user.emailVerified) {
      await _initZegoForCurrentUser(user.uid);

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, home);
    } else {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, loginScreen);
    }
  }

  Future<void> _initZegoForCurrentUser(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      final userName = doc.data()?['name'] ?? 'User';

      await initZegoService(userID: userId, userName: userName);
    } catch (e) {
      debugPrint('Error initializing Zego: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        width: screenSize.width,
        height: screenSize.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 45, 95, 185),
              Color.fromARGB(255, 70, 117, 204),
              Color.fromARGB(255, 100, 145, 230),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Welcome to NovaCall",
                    style: TextStyle(
                      fontSize: screenSize.width * 0.07,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.9),
                          offset: const Offset(0, 9),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.05),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: screenSize.width * 0.35,
                      height: screenSize.width * 0.35,
                      child: gif(),
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.08),
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                    strokeWidth: 2.5,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
