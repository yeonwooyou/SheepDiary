// 구매이력 페이지 (동일한 사진 박스 구조)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/themed_scaffold.dart';

/// 4. 구매이력 페이지
class PurchaseHistoryPage extends StatelessWidget {
  const PurchaseHistoryPage({super.key});

  // 구매한 이미지 목록
  final List<String> purchasedImagePaths = const [
    'assets/profile_sheep/green.png',
    'assets/profile_sheep/purple.png',
    'assets/profile_sheep/blue.png',
    'assets/profile_sheep/yellow.png',
    'assets/profile_sheep/white.png',
  ];

  final List<String> imageNames = const [
    '초록 목장',
    '보라 목장',
    '파란 목장',
    '노란 목장',
    '하얀 목장',
  ];

  final List<String> imageMessages = const [
    '보유 중인 초록 목장을 선택했어요!',
    '보유 중인 보라 목장을 선택했어요!',
    '보유 중인 파란 목장을 선택했어요!',
    '보유 중인 노란 목장을 선택했어요!',
    '보유 중인 하얀 목장을 선택했어요!',
  ];

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      title: '나의 구매내역',
      currentIndex: null, // 하단 내비게이션 없음
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: purchasedImagePaths.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemBuilder: (context, index) {
            final imagePath = purchasedImagePaths[index];
            return GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(imageMessages[index]),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: AssetImage(imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}