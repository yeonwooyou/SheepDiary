// import 'dart:async';
// import 'package:flutter/material.dart';
// import '../../main_navigation.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'login.dart';
// import 'splashscreen.dart';
// import '../write/timeline.dart';
// import '/pages/starting/login.dart'; // LoginPage imp
//
// class LandingPage extends StatefulWidget {
//   const LandingPage({super.key});
//
//   @override
//   State<LandingPage> createState() => _LandingPageState();
// }
//
// class _LandingPageState extends State<LandingPage> {
//   @override
//   void initState() {
//     super.initState();
//     _handleStartupFlow();
//     _checkAutoLogin();
//   }
//
//
//   Future<void> _checkAutoLogin() async {
//     await Future.delayed(const Duration(seconds: 2)); // 2초 동안 스플래시 화면을 연출
//
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('jwt_token');
//     final autoLogin = prefs.getBool('auto_login') ?? false;
//
//     // 자동 로그인 상태 확인
//     if (token != null && autoLogin) {
//       // 자동 로그인된 경우, SplashScreen으로 이동
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const SplashScreen()), // SplashScreen으로 이동
//       );
//     } else {
//       // 자동 로그인이 되어 있지 않으면 LoginPage로 이동
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const LoginPage()), // LoginPage로 이동
//       );
//     }
//   }
//
//   Future<void> _handleStartupFlow() async {
//     await Future.delayed(const Duration(seconds: 2)); // Splash 연출
//
//     final prefs = await SharedPreferences.getInstance();
//     final isAgreed = prefs.getBool('is_agreed') ?? false;
//
//     if (!isAgreed) {
//       _showAgreementDialog(prefs);
//     } else {
//       _checkLoginStatus(prefs); // ⬅️ 여기에서 JWT + auto_login으로 판별
//     }
//   }
//
//   void _checkLoginStatus(SharedPreferences prefs) {
//     final token = prefs.getString('jwt_token');
//     final autoLogin = prefs.getBool('auto_login') ?? false;
//
//     if (token != null && autoLogin) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const SplashScreen()),
//       );
//     } else {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const LoginPage()),
//       );
//     }
//   }
//
//   void _showAgreementDialog(SharedPreferences prefs) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         title: const Text('이용약관 동의'),
//         content: const Text(
//           '앱을 사용하려면 이용약관 및 위치정보 수집에 동의하셔야 합니다.',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               prefs.setBool('is_agreed', true); // 동의 저장
//               Navigator.pop(context);
//               _checkLoginStatus(prefs);
//             },
//             child: const Text('동의'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop(); // 선택사항: 앱 종료 등
//             },
//             child: const Text('거부'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // 앱 커버 이미지
//             Image.asset(
//               'assets/images/app_cover.png',
//               width: MediaQuery.of(context).size.width * 0.8,
//               fit: BoxFit.contain,
//             ),
//             const SizedBox(height: 20),
//             // 로딩 중 텍스트
//             const Text(
//               '앱 로딩 중...',
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.grey,
//               ),
//             ),
//             const SizedBox(height: 20),
//             // 로딩 인디케이터
//             const CircularProgressIndicator(),
//           ],
//         ),
//       ),
//     );
//   }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import 'splashscreen.dart';
import '/pages/write/timeline.dart'; // WritePage 임포트

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

final double gap = 10; // 양과 보더콜리 사이 간격

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  bool _movedBorderCollie = false;
  bool _movedSheep = false;

  @override
  void initState() {
    super.initState();
    _handleStartupFlow();

    // 보더콜리는 먼저 출발
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _movedBorderCollie = true;
      });
    });

    // 양은 1초 뒤 출발
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        _movedSheep = true;
      });
    });
  }

  Future<void> _handleStartupFlow() async {
    await Future.delayed(const Duration(seconds: 3));

    final prefs = await SharedPreferences.getInstance();
    final isAgreed = prefs.getBool('is_agreed') ?? false;
    final token = prefs.getString('access_token');
    final autoLogin = prefs.getBool('auto_login') ?? false;

    if (!isAgreed) {
      _showAgreementDialog(prefs); // 이용약관 동의 다이얼로그
    } else {
      // 약관에 동의한 경우 자동 로그인 체크
      if (token != null && autoLogin) {
        // 자동 로그인된 경우 SplashScreen으로 이동
        print('✅ 자동 로그인 진행: 토큰 있음 + autoLogin true');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const SplashScreen()), // SplashScreen으로 이동
        );
      } else {
        // 자동 로그인이 안 된 경우 LoginPage로 이동
        print('🔒 로그인 필요: 토큰 없음 or autoLogin false');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const LoginPage()), // LoginPage로 이동
        );
      }
    }
  }

  void _showAgreementDialog(SharedPreferences prefs) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('이용약관 동의'),
        content: const Text(
          '앱을 사용하려면 이용약관 및 위치정보 수집에 동의하셔야 합니다.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              prefs.setBool('is_agreed', true); // 동의 저장
              Navigator.pop(context);
              _handleStartupFlow(); // 동의 후 로그인 체크
            },
            child: const Text('동의'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // 선택사항: 앱 종료 등
            },
            child: const Text('거부'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double animationWidth = MediaQuery.of(context).size.width * 0.8;

    return Scaffold(
      backgroundColor: const Color(0xFFFCF6F6),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 앱 커버 이미지
            Image.asset(
              'assets/images/app_cover.JPG',
              width: animationWidth,
              fit: BoxFit.contain,
            ),
            // const SizedBox(height: 20),
            // const Text(
            //   '앱 로딩 중...',
            //   style: TextStyle(fontSize: 16, color: Colors.grey),
            // ),
            // const SizedBox(height: 20),

            SizedBox(
              width: animationWidth,
              height: 100,
              child: Stack(
                children: [
                  // 모서리 둥근 사각형 (배경 역할)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFABF0B4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),

                  // // 양 이미지 (오른쪽 아래)
                  // Positioned(
                  //   right: 10,
                  //   bottom: 0,
                  //   child: Image.asset(
                  //     'assets/images/sheep2.png',
                  //     width: 113,
                  //   ),
                  // ),
                  //
                  // // 보더콜리 이미지 (애니메이션)
                  // AnimatedPositioned(
                  //   duration: const Duration(seconds: 3),
                  //   curve: Curves.easeInOut,
                  //   left: _moved ? (animationWidth - 90) : 0,
                  //   bottom: 0,
                  //   child: Image.asset(
                  //     'assets/images/border_collie.png',
                  //     width: 80,
                  // 양 (중간 → 보더콜리보다 약간 앞에서 멈춤)


                  AnimatedPositioned(
                    duration: const Duration(seconds: 2),
                    curve: Curves.easeInOut,
                    right: _movedSheep ? 0 : (animationWidth / 1.7 - 113 / 2), // 중앙에서 시작
                    bottom: 0,
                    child: Image.asset(
                      'assets/images/sheep2.png',
                      width: 113,
                    ),
                  ),

// 보더콜리 (오른쪽 끝 → 맨 오른쪽 끝)
                  AnimatedPositioned(
                    duration: const Duration(seconds: 3),
                    curve: Curves.easeInOut,
                    right: _movedBorderCollie ? 55 : (animationWidth - 90), // 왼쪽 끝에서 시작
                    bottom: 0,
                    child: Image.asset(
                      'assets/images/border_collie.png',
                      width: 80,
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}
