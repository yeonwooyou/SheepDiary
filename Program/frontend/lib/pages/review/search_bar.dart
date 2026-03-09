import 'package:flutter/material.dart';
import '../../theme/themed_scaffold.dart';
import 'search_result_screen.dart';

class SearchBar extends StatelessWidget {
  const SearchBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController searchController = TextEditingController();

    void performSearch() {
      final searchQuery = searchController.text.trim();
      if (searchQuery.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchResultScreen(searchQuery: searchQuery),
          ),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // 왼쪽 버튼
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.search),
              onPressed: performSearch,
              tooltip: '검색',
            ),
          ),
          const SizedBox(width: 8),
          // 텍스트 필드
          Expanded(
            child: TextField(
              controller: searchController,
              keyboardType: TextInputType.text,
              enableSuggestions: false,
              autocorrect: false,
              decoration: InputDecoration(
                hintText: '일기 검색...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              onSubmitted: (_) => performSearch(),
            ),
          ),
        ],
      ),
    );
  }
}
