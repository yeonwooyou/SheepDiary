import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/diary.dart';
import '../../data/diary_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '/pages/write/emoji.dart';
import '/helpers/auth_helper.dart';
import '../../theme/themed_scaffold.dart';

class DiaryEntry {
  final String date;
  final String text;
  final List<String> tags;
  final List<String> photos;
  final double latitude;
  final double longitude;
  final List<LatLng> timeline;
  final Set<Marker> markers;
  final LatLng cameraTarget;
  final String emotionEmoji;

  DiaryEntry({
    required this.date,
    required this.text,
    required this.tags,
    required this.photos,
    required this.latitude,
    required this.longitude,
    required this.timeline,
    required this.markers,
    required this.cameraTarget,
    required this.emotionEmoji,
  });
}

extension DiaryEntryExtension on DiaryEntry {
  Diary toDiary() {
    return Diary(
      id: UniqueKey().toString(),
      date: date,
      text: text,
      tags: tags,
      photos: photos,
      longitude: longitude,
      latitude: latitude,
      timeline: timeline.map((latLng) => {
        'lat': latLng.latitude,
        'lng': latLng.longitude,
      }).toList(),
      markers: markers.map((marker) => {
        'id': marker.markerId.value,
        'lat': marker.position.latitude,
        'lng': marker.position.longitude,
      }).toList(),
      cameraTarget: {
        'lat': cameraTarget.latitude,
        'lng': cameraTarget.longitude,
      },
      emotionEmoji: emotionEmoji,
    );
  }
}

class DiaryPage extends StatefulWidget {
  final DiaryEntry entry;
  final String emotionEmoji;
  final String date;

  const DiaryPage({
    super.key,
    required this.entry,
    required this.emotionEmoji,
    required this.date,
  });

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  final TextEditingController _textController = TextEditingController();
  final ValueNotifier<int> currentPageNotifier = ValueNotifier<int>(0);
  bool showMap = true;

  PageController? _pageController;
  int _currentPage = 0;

  void _saveCurrentPage() {
    if (!showMap) {
      // 사진 탭에서만 페이지 인덱스 저장
      _currentPage = _pageController?.page?.round() ?? 0;
    }
  }

  // 탭 전환 시 호출되는 메서드 수정
  void _toggleView(bool isMap) {
    if (isMap) {
      _saveCurrentPage();
    }
    setState(() {
      showMap = isMap;
      if (!isMap) {
        // 사진 탭 전환 시 PageController 초기화 또는 jumpToPage
        if (_pageController == null) {
          _pageController = PageController(
            viewportFraction: 0.8,
            initialPage: _currentPage,
          );
        } else {
          // 타이밍 문제 해결을 위해 프레임 이후 페이지 전환
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _pageController?.jumpToPage(_currentPage);
          });
        }
      }
    });
  }

  // dispose 메서드 추가
  @override
  void dispose() {
    _pageController?.dispose();
    _textController.dispose();
    currentPageNotifier.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _textController.text = widget.entry.text;
    _pageController = PageController(
      viewportFraction: 0.8,
      initialPage: _currentPage,
    );
  }

  void _saveDiary() {
    final updatedEntry = DiaryEntry(
      date: widget.entry.date,
      text: _textController.text,
      tags: widget.entry.tags,
      photos: widget.entry.photos,
      latitude: widget.entry.latitude,
      longitude: widget.entry.longitude,
      timeline: widget.entry.timeline,
      cameraTarget: widget.entry.cameraTarget,
      markers: widget.entry.markers,
      emotionEmoji: widget.entry.emotionEmoji,
    );

    final updatedDiary = updatedEntry.toDiary();
    Provider.of<DiaryProvider>(context, listen: false).addDiary(updatedDiary);

    // 서버 전송 생략하고 테스트하려면 여기를 주석처리
    _sendDiaryToServer(updatedEntry, _textController.text);

    Navigator.pop(context);
  }

  Future<void> _sendDiaryToServer(DiaryEntry entry, String finalText) async {
    final url = Uri.parse('http://10.0.2.2:8000/api/diaries/${widget.date}/');
    final body = jsonEncode({
      'final_text': _textController.text,
      'tags': widget.entry.tags,
      'emotion': convertEmojiToId(widget.entry.emotionEmoji),
      'timeline_sent': widget.entry.timeline
          .map((latLng) => {'lat': latLng.latitude, 'lng': latLng.longitude})
          .toList(),
      'markers': widget.entry.markers
          .map((marker) => {
        'id': marker.markerId.value,
        'lat': marker.position.latitude,
        'lng': marker.position.longitude,
      }).toList(),
      'cameraTarget': {
        'lat': widget.entry.cameraTarget.latitude,
        'lng': widget.entry.cameraTarget.longitude,
      },
    });

    final headers = await getAuthHeaders();

    try {
      final response = await http.put(url, body: body, headers: headers);  // PUT 요청으로 변경
      if (response.statusCode == 200) {
        print("✅ Diary successfully updated!");
      } else {
        print("❌ Server error: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Failed to connect to server: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      title: '일기 작성',
      actions: [
        IconButton(
          icon: const Icon(Icons.save),
          onPressed: _saveDiary,
        ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "🗓 ${widget.entry.date}",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (widget.entry.emotionEmoji.isNotEmpty) ...[
                  const Text("오늘의 기분 ", style: TextStyle(fontSize: 16)),
                  Text(widget.entry.emotionEmoji, style: const TextStyle(fontSize: 20)),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text("🗺 지도"),
                  selected: showMap,
                  onSelected: (_) => _toggleView(true),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text("📷 사진"),
                  selected: !showMap,
                  onSelected: (_) => _toggleView(false),
                ),
              ],
            ),
            const SizedBox(height: 16),
            showMap ? _buildMapTimeline() : _buildPhotoSlider(),
            const SizedBox(height: 24),
            const Text("📝 다이어리 내용", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _textController,
              maxLines: null,
              decoration: InputDecoration(
                hintText: '오늘의 기록을 입력하세요...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.all(12),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 24),
            if (widget.entry.tags.isNotEmpty) ...[
              const Text("🏷 태그", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: widget.entry.tags.map((tag) => Chip(label: Text(tag))).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }


  Widget _buildMapTimeline() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.hardEdge,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: widget.entry.cameraTarget,
          zoom: 12,
        ),
        markers: widget.entry.markers,
        polylines: {
          if (widget.entry.timeline.length > 1)
            Polyline(
              polylineId: const PolylineId("timelinePath"),
              color: Colors.blueAccent,
              width: 4,
              points: widget.entry.timeline,
            ),
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: false,
        onMapCreated: (controller) {},
      ),
    );
  }

  Widget _buildPhotoSlider() {

    final List<String> fixedPhotos = [
      'assets/images/demo01.jpg',
      'assets/images/demo02.jpg',
      'assets/images/demo03.jpg',
      'assets/images/demo04.jpg',
      'assets/images/demo05.jpg',
      'assets/images/demo06.jpg',
    ];

    return Column(
      children: [
        SizedBox(
          height: 250,
          child: PageView.builder(
            // itemCount: widget.entry.photos.length,
            controller: _pageController!,
            onPageChanged: (index) {
              currentPageNotifier.value = index;
              _currentPage = index;
              // currentPageNotifier.value = index;
            },
            itemCount: fixedPhotos.length,
            itemBuilder: (context, index) {
              final photoPath = fixedPhotos[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    photoPath,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        ValueListenableBuilder<int>(
          valueListenable: currentPageNotifier,
          builder: (context, _currentPage, _) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                fixedPhotos.length,
                    (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? Colors.blue
                        : Colors.grey.withOpacity(0.5),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}