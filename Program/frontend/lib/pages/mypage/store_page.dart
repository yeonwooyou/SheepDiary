import 'package:flutter/material.dart';
import '../../theme/themed_scaffold.dart'; // ThemedScaffold 임포트

class StorePage extends StatelessWidget {
  const StorePage({super.key});

  // 이미지 경로와 이름을 리스트로 정의
  final List<Map<String, String>> items = const [
    {
      'image': 'assets/profile_sheep/whiteband.png',
      'name': '흰색 밴드',
    },
    {
      'image': 'assets/profile_sheep/brownband.png',
      'name': '갈색 밴드',
    },
    {
      'image': 'assets/profile_sheep/pinkband.png',
      'name': '핑크 밴드',
    },
    {
      'image': 'assets/profile_sheep/purpleband.png',
      'name': '보라 밴드',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      title: '슆스토어 🐑',
      currentIndex: null,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: items.length, // 4개로 변경
        itemBuilder: (context, index) {
          final item = items[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  item['image']!,
                  width: 60,
                  height: 70,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(item['name']!),
              subtitle: const Text('₩3,000'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${item['name']} 구매하시겠습니까?')),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
