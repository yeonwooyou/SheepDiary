import 'package:flutter/material.dart';
import '../write/timeline.dart';
import '/pages/starting/login.dart'; // LoginPage import
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String userName = '익명';

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _startSplashTimer();
  }

  // 닉네임 불러오기
  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name');

    setState(() {
      userName = name ?? '익명';
    });
  }

  // 3초 후 페이지 이동
  void _startSplashTimer() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WritePage()),
      );
    });
  }

  Future<void> _checkAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');
    final autoLogin = prefs.getBool('auto_login') ?? false; // 기본값 설정

    // autoLogin 값이 true이고 access_token이 존재하면 Timeline으로 이동
    if (autoLogin == true && accessToken != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WritePage(selectedDate: DateTime.now())),
      );
    } else {
      // 그렇지 않으면 LoginPage로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 배경 이미지
          Center(
            child: Image.asset(
              'assets/images/sheep2.png',
              fit: BoxFit.contain,
              width: double.infinity,
            ),
          ),

          // 텍스트 오버레이
          Positioned(
            top: 200,
            left: 0,
            right: 0,
            child: Center(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '쉽\n',
                      style: const TextStyle(
                        fontFamily: 'melong',
                        color: Colors.blue,
                        // fontWeight: FontWeight.bold,
                        fontSize: 58,
                      ),
                    ),
                    const TextSpan(
                      text: '다이어리',
                      style: TextStyle(
                        fontFamily: 'melong',
                        color: Color(0xFF353232),
                        // fontWeight: FontWeight.bold,
                        fontSize: 58,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.left,
                style: const TextStyle(height: 1.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}