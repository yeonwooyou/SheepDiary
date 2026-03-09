import 'package:flutter/material.dart';
import '../../theme/themed_scaffold.dart'; // ThemedScaffold 위젯 import

class SearchResultScreen extends StatelessWidget {
  final String searchQuery;

  const SearchResultScreen({Key? key, required this.searchQuery}) : super(key: key);

  // 하드코딩된 검색 결과 데이터
  final List<Map<String, dynamic>> searchResults = const [
    {
      'id': '1',
      'title': '김유정 레일바이크',
      'content': '야외활동을 즐겼다',
      'date': '25/05/21',
      'image': 'assets/images/demo01.jpg',
    },
    {
      'id': '2',
      'title': '산토리니',
      'content': '야외 포토존이 멋졌다',
      'date': '25/05/21',
      'image': 'assets/images/demo03.jpg',
    },
    {
      'id': '3',
      'title': '알파카월드',
      'content': '알파카월드 로고송이 인상에 남았다',
      'date': '25/05/21',
      'image': 'assets/images/demo05.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      title: "검색 결과",
      currentIndex: 0,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          final result = searchResults[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: InkWell(
              onTap: () {
                print('일기 선택: ${result['title']}');
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 제목 + 내용
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${result['title']} ',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              TextSpan(
                                text: result['content'],
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        // 작성 날짜 + 고정 문구 "나만보기"
                        Row(
                          children: [
                            Text(
                              '작성날짜: ${result['date']}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(Icons.lock, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            const Text(
                              '공유하기',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // 이미지 표시
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      result['image'],
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
