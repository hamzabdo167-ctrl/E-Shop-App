import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/authCheck');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // الحصول على أبعاد الشاشة
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    // حساب أحجام متجاوبة بناءً على عرض/ارتفاع الشاشة
    final double iconSize = screenWidth * 0.18; // 18% من عرض الشاشة
    final double titleFontSize = screenWidth * 0.08; // 8% من عرض الشاشة
    final double subtitleFontSize = screenWidth * 0.035; // 3.5% من عرض الشاشة
    final double progressSize = screenWidth * 0.1; // 10% من عرض الشاشة

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7EE),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),

                    // حاوية الأيقونة المتجاوبة
                    Container(
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4A017).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.shopping_bag_outlined,
                        size: iconSize.clamp(
                          40.0,
                          120.0,
                        ), // تحديد حد أدنى وأقصى لحجم الأيقونة
                        color: const Color(0xFFD4A017),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.02),

                    // النص الرئيسي
                    Text(
                      'E-SHOP',
                      style: TextStyle(
                        fontSize: titleFontSize.clamp(20.0, 48.0),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                        color: const Color(0xFF2C2C2C),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.04),

                    // مؤشر التحميل
                    SizedBox(
                      width: progressSize.clamp(24.0, 60.0),
                      height: progressSize.clamp(24.0, 60.0),
                      child: const CircularProgressIndicator(
                        color: Color(0xFFD4A017),
                        strokeWidth: 3,
                      ),
                    ),

                    const Spacer(),

                    // النص السفلي
                    Text(
                      'Welcome to E-SHOP',
                      style: TextStyle(
                        fontSize: subtitleFontSize.clamp(12.0, 20.0),
                        color: Colors.grey,
                        letterSpacing: 1,
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.03),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
