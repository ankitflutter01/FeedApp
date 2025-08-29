import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:practical_task/untils/app_color.dart';
import '../../untils/app_string.dart';
import '../../untils/common_widget.dart';
import '../home/home_screen.dart';
import '../sign_up/sign_up_view.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 3));
    User? user = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => user != null ? HomeScreen() : SignUpPage(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColorOne,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.rss_feed,
                color: Colors.white,
                size: 100,
              ),
              const SizedBox(height: 20),
              CommonAppText(
                text: AppStrings.appName,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
                maxLine: 1,
                textAlignment: TextAlign.center,
              ),
              const SizedBox(height: 10),
              CommonAppText(
                text: AppStrings.nameSubTitle,
                fontSize: 16,
                color: Colors.white70,
                maxLine: 1,
                textAlignment: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
