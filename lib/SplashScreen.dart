import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import ScreenUtil
import 'SnakeGameScreen.dart'; // Import your SnakeGameScreen widget

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.repeat(reverse: true);
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => SnakeGameScreen(), // Navigate to the game screen
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Initialize ScreenUtil instance
    ScreenUtil.init(context, designSize: Size(320, 534));

    return Scaffold(
      backgroundColor: Colors.green, // Background color of the splash screen
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _animation,
              child: Icon(
                Icons.gamepad, // Icon for your game
                size: ScreenUtil().setSp(100), // Set icon size based on screen resolution
                color: Colors.white,
              ),
            ),
            SizedBox(height: ScreenUtil().setHeight(20)), // Set height based on screen height
            Text(
              'Cobra Chase', // Your game name
              style: TextStyle(
                color: Colors.white,
                fontSize: ScreenUtil().setSp(30), // Set font size based on screen resolution
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: ScreenUtil().setHeight(10)), // Set height based on screen height
            Text(
              'Eat to Grow', // Tagline or additional information
              style: TextStyle(
                color: Colors.white,
                fontSize: ScreenUtil().setSp(20), // Set font size based on screen resolution
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}