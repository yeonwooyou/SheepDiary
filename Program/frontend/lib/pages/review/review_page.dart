import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/themed_scaffold.dart';
import '../write/diary_page.dart';
import 'package:provider/provider.dart';
import '../../data/diary_provider.dart';
import '../../data/diary.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '/helpers/auth_helper.dart';
import '../../theme/templates.dart';
import '../write/emoji.dart';

class ReviewPage extends StatefulWidget {
  final DiaryEntry entry;
  final String date;
  final String emotionEmoji;

  const ReviewPage({
    super.key,
    required this.entry,
    required this.date,
    required this.emotionEmoji,
  });

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  bool showMap = true;
  int _selectedIndex = 1; // BottomNavigation 현재 탭 인덱스
  Map<String, dynamic>? diaryEntry;
  LatLng cameraTarget = const LatLng(37.7946, 127.8711); // 기본값
  List<LatLng> timelinePolyline = [];
  Set<Marker> markers = {};
  String emotionEmoji = '😊';
  final List<String> tags = ["김유정 레일바이크", "산토리니 카페", "알파카월드"]; // 태그 추가

  PageController? _pageController;
  final ValueNotifier<int> currentPageNotifier = ValueNotifier<int>(0);
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
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    emotionEmoji = widget.emotionEmoji;
    fetchDiaryData();
    _pageController = PageController(
      viewportFraction: 0.8,
      initialPage: _currentPage,
    );
  }

  Future<void> fetchDiaryData() async {
    final formattedDate = widget.date;
    final url = Uri.parse('http://10.0.2.2:8000/api/diaries/$formattedDate/');
    final headers = await getAuthHeaders();

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        print(data);

        final target = data['camera_target'] != null
            ? LatLng(
          data['camera_target']['lat'] ?? 37.7946,
          data['camera_target']['lng'] ?? 127.8711,
        )
            : const LatLng(37.7946, 127.8711);

        final timeline = (data['timeline_sent'] as List?)?.map<LatLng>((point) {
          return LatLng(point['lat'] ?? 37.7946, point['lng'] ?? 127.8711);
        }).toList() ?? [];

        final markerSet = (data['markers'] as List?)?.map<Marker>((marker) {
          return Marker(
            markerId: MarkerId(marker['id'] ?? ''),
            position: LatLng(marker['lat'] ?? 37.7946, marker['lng'] ?? 127.8711),
          );
        }).toSet() ?? {};

        setState(() {
          diaryEntry = data;
          cameraTarget = target;
          timelinePolyline = timeline;
          markers = markerSet;
        });
      } else {
        setState(() {
          diaryEntry = null;
        });
      }
    } catch (e) {
      setState(() {
        diaryEntry = null;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/calendar');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      title: "📖 내 일기 보기",
      currentIndex: null,
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          tooltip: 'Edit Diary',
          onPressed: () {
            if (diaryEntry != null) {
              DiaryEntry parsedDiary = DiaryEntry(
                date: diaryEntry!['date'] ?? '',
                text: diaryEntry!['final_text'] ?? '',
                tags: List<String>.from(diaryEntry!['keywords'] ?? []),
                photos: List<String>.from(diaryEntry!['photos'] ?? []), // 없으면 []
                latitude: (diaryEntry!['latitude'] ?? 37.7946).toDouble(),
                longitude: (diaryEntry!['longitude'] ?? 127.8711).toDouble(),
                timeline: (diaryEntry!['timeline_sent'] as List<dynamic>? ?? []).map((e) {
                  return LatLng(e['lat'] ?? 37.7946, e['lng'] ?? 127.8711);
                }).toList(),
                markers: (diaryEntry!['markers'] as List<dynamic>? ?? []).map<Marker>((marker) {
                  return Marker(
                    markerId: MarkerId(marker['id'].toString()),
                    position: LatLng(marker['lat'] ?? 37.7946, marker['lng'] ?? 127.8711),
                  );
                }).toSet(),
                cameraTarget: diaryEntry!['camera_target'] != null
                    ? LatLng(
                  diaryEntry!['camera_target']['lat'] ?? 37.7946,
                  diaryEntry!['camera_target']['lng'] ?? 127.8711,
                )
                    : const LatLng(37.7946, 127.8711),
                emotionEmoji: convertIdToEmoji(diaryEntry!['emotion_id'] ?? 1),
              );

              final initialText = diaryEntry?['text'] ?? '';
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) {
                  final diaryEntryObj = DiaryEntry(
                    date: widget.date,
                    text: initialText,
                    tags: [],
                    photos: [],
                    latitude: (diaryEntry!['latitude'] ?? 37.7946).toDouble(),
                    longitude: (diaryEntry!['longitude'] ?? 127.8711).toDouble(),
                    timeline: [],
                    markers: {},
                    cameraTarget: const LatLng(37.7946, 127.8711),
                    emotionEmoji: diaryEntry?['emotion_id'] ?? '',
                  );
                  return DiaryPage(
                    entry: diaryEntryObj,
                    emotionEmoji: diaryEntry?['emotion_id'] ?? '',
                    date: widget.date,
                  );
                },
                ),
              );
            }
          },
        ),
      ],
      child:
          diaryEntry == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "🗓 ${DateFormat('yyyy-MM-dd').format(DateTime.parse(widget.date))}",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "오늘의 기분: ${convertIdToEmoji(diaryEntry!['emotion_id'] ?? 1)}",
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("📝 다이어리 내용", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    diaryEntry?['final_text']?.replaceAll('  ', '\n') ?? 'No content available',
                    style: const TextStyle(fontSize: 15, height: 1.5),
                  ),
                ),
                const SizedBox(height: 24),
                const Text("🏷 태그", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: tags.map<Widget>((tag) => Chip(label: Text(tag))).toList(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 지도 표시용 위젯
  Widget _buildMapTimeline() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.hardEdge,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(target: cameraTarget, zoom: 13),
        markers: markers,
        polylines: {
          Polyline(
            polylineId: const PolylineId("timeline"),
            points: timelinePolyline,
            color: Colors.blue,
            width: 5,
          ),
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: false,
        onMapCreated: (GoogleMapController controller) {},
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
            },
            itemCount: fixedPhotos.length,
            itemBuilder: (context, index) {
              // final photoPath = widget.entry.photos[index];
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
