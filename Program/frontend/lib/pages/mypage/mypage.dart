import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../theme/templates.dart';
import '../../theme/themed_scaffold.dart';
import '/pages/calendarscreen.dart';
import '/pages/write/timeline.dart';
import '/pages/starting/login.dart';
import 'editinfo.dart';
import 'diary_decoration_page.dart';
import 'purchase_history_page.dart';
import 'store_page.dart';
import 'terms_tabs_page.dart';
import 'package:test_sheep/pages/mypage/purchase_history_page.dart' as purchase;
import 'package:test_sheep/pages/mypage/store_page.dart' as store;
import '../../helpers/auth_helper.dart';

class UserProfile {
  final String user_name;
  final String email;

  UserProfile({required this.user_name, required this.email});

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      user_name: json['user_name'],
      email: json['email'],
    );
  }
}

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  _MyPageScreenState createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  UserProfile? _userProfile;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final headers = await getAuthHeaders();
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/users/me/profile/'),
        headers: headers
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _userProfile = UserProfile.fromJson(data);
          _loading = false;
        });
      } else if (response.statusCode == 401) {
        setState(() {
          _error = '인증 실패: 로그인 후 다시 시도하세요.';
          _loading = false;
        });
      } else {
        setState(() {
          _error = '오류 발생: 상태 코드 ${response.statusCode}';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = '네트워크 오류: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      title: "마이페이지",
      leading: null,
      currentIndex: 2,
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CalendarScreen()));
            break;
          case 1:
            Navigator.push(context, MaterialPageRoute(builder: (_) => WritePage(emotionEmoji: "😊", selectedDate: DateTime.now())));
            break;
          case 2:
          // 현재 페이지가 마이페이지이므로 아무 동작도 하지 않음
            break;
        }
      },
      navItems: const [
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: '리뷰'),
        BottomNavigationBarItem(icon: Icon(Icons.timeline), label: '타임라인'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이페이지'),
      ],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 프로필 영역
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      builder: (BuildContext context) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.photo_library),
                              title: const Text('갤러리에서 선택'),
                              onTap: () {
                                Navigator.pop(context);
                                print("갤러리 선택됨");
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.image),
                              title: const Text('기본 아이콘 선택'),
                              onTap: () {
                                Navigator.pop(context);
                                print("기본 아이콘 선택됨");
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/sheep.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userProfile?.user_name ?? '이름 없음',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _userProfile?.email ?? '이메일 없음',
                      style: const TextStyle(
                          fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 32),
            const Text('설정', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            _buildTextItem(
              context,
              '개인정보 수정',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const EditInfoPage()));
              },
            ),
            _buildTextItem(
              context,
              '이용약관, 개인정보동의서 및 AI처리방침',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsTabsPage()));
              },
            ),

            const SizedBox(height: 24),
            const Text('기타', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            _buildTextItem(
              context,
              '다이어리 꾸미기',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const DiaryDecorationPage()));
              },
            ),
            _buildTextItem(
              context,
              '스토어',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const store.StorePage()));
              },
            ),
            _buildTextItem(
              context,
              '구매 이력',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const purchase.PurchaseHistoryPage()));
              },
            ),

            const SizedBox(height: 24),
            const Text('계정', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            _buildTextItem(
              context,
              '로그아웃',
              textColor: Colors.red,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: const Text(
                        '정말 로그아웃 하시겠습니까?',
                        style: TextStyle(fontSize: 16),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.clear();
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => const LoginPage()),
                                  (route) => false,
                            );
                          },
                          child: const Text(
                            '예',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('아니요'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            _buildTextItem(
              context,
              '회원탈퇴',
              textColor: Colors.red,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: const Text(
                        '정말 회원탈퇴를 하시겠습니까?',
                        style: TextStyle(fontSize: 16),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.clear();
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => const LoginPage()),
                                  (route) => false,
                            );
                          },
                          child: const Text(
                            '예',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('아니요'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextItem(BuildContext context, String text, {VoidCallback? onTap, Color textColor = Colors.black}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text, style: TextStyle(fontSize: 16, color: textColor)),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
