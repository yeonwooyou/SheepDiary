import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../data/diary.dart';
import '../../data/diary_provider.dart';
import '/pages/review/review_page.dart';
import '/pages/review/search_result_screen.dart';
import '/pages/write/timeline.dart';
import '/pages/write/diary_page.dart';
import '/pages/write/emoji.dart';
import '/pages/mypage/mypage.dart';
import '/theme/themed_scaffold.dart';
import '/theme/templates.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '/helpers/auth_helper.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

extension DiaryModelExtension on Diary {
  DiaryEntry toDiaryEntry() {
    return DiaryEntry(
      text: text,
      tags: tags,
      date: date,
      photos: photos,
      latitude: latitude,
      longitude: longitude,
      timeline: timeline.map((e) => LatLng(e['lat'] ?? 0.0, e['lng'] ?? 0.0)).toList(),
      cameraTarget: LatLng(cameraTarget['lat'] ?? 0.0, cameraTarget['lng'] ?? 0.0),
      markers: markers.map((marker) {
        return Marker(
          markerId: MarkerId(marker['id'] ?? UniqueKey().toString()),
          position: LatLng(marker['lat'] ?? 0.0, marker['lng'] ?? 0.0),
        );
      }).toSet(),
      emotionEmoji: emotionEmoji,
    );
  }
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Set<String> _diaryDates = {}; // 'YYYY-MM-DD' 형식으로 저장
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchDiaryDatesByMonth(_focusedDay);
    });
  }

  Future<void> fetchDiaryDatesByMonth(DateTime date) async {
    final month = DateFormat('yyyy-MM').format(date);
    final headers = await getAuthHeaders();
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/diaries/dates/?month=$month'),
      headers: headers
    );

    if (response.statusCode == 200) {
      final List<dynamic> diariesJson = json.decode(response.body)['diaries'];

      // Provider 접근
      final diaryProvider = Provider.of<DiaryProvider>(context, listen: false);

      // diaries 리스트로 변환
      final diariesList = diariesJson.map<Diary>((json) => Diary.fromJson(json)).toList();

      // 날짜 문자열만 추출해 Set으로 만듦
      final datesSet = diariesList.map((d) => d.date).toSet();

      setState(() {
        diaryProvider.diaries = diariesList;
        _diaryDates = datesSet;
      });
    } else {
      debugPrint('다이어리 날짜 목록을 불러오는 데 실패함: ${response.statusCode}');
    }
  }

  Future<void> _showYearMonthPicker(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _focusedDay,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: '연도/월 선택',
      locale: const Locale('ko'),
      fieldLabelText: '날짜를 선택하세요',
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    if (picked != null) {
      setState(() => _focusedDay = picked);
      fetchDiaryDatesByMonth(picked); // 달 변경 시 API 호출
    }
  }

  void _onDateSelected(BuildContext context, DateTime selectedDay) {
    final dateKey = DateFormat('yyyy-MM-dd').format(selectedDay);
    final diaryProvider = Provider.of<DiaryProvider>(context, listen: false);

    Diary? diary = diaryProvider.getDiaryByDate(dateKey);

    // Diary.empty() 반환을 null 처럼 사용하기 위해 아래 조건 확인 가능
    if (diary != null && diary.id.isNotEmpty) {
      DiaryEntry entry = diary.toDiaryEntry();

      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => ReviewPage(
            entry: entry,
            date: dateKey,
            emotionEmoji: entry.emotionEmoji,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("알림"),
          content: const Text("해당 날짜의 다이어리가 없습니다."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("확인"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      title: "달력",
      currentIndex: 0,
      leading: null,
      onTap: (index) {
        switch (index) {
          case 0:
            break;
          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WritePage(
                  emotionEmoji: "😊",
                  selectedDate: DateTime.now(),
                ),
              ),
            );
            break;
          case 2:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyPageScreen()),
            );
            break;
        }
      },
      navItems: const [
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: '리뷰'),
        BottomNavigationBarItem(icon: Icon(Icons.timeline), label: '타임라인'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이페이지'),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  hintText: '일기 검색...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  // 오른쪽 돋보기 아이콘 버튼 삭제
                ),
                onSubmitted: (value) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SearchResultScreen(searchQuery: value),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('yyyy년 MM월').format(_focusedDay),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.calendar_month),
                            onPressed: () => _showYearMonthPicker(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 1.5),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  _onDateSelected(context, selectedDay);
                },
                headerVisible: false,
                availableCalendarFormats: const {
                  CalendarFormat.month: 'Month',
                },
                calendarFormat: CalendarFormat.month,
                eventLoader: (day) {
                  final dateKey = DateFormat('yyyy-MM-dd').format(day);
                  final diaryProvider = Provider.of<DiaryProvider>(context, listen: false);
                  final hasDiary = diaryProvider.diaries.any((d) => d.date == dateKey);
                  return hasDiary ? [dateKey] : [];
                },
                calendarStyle: const CalendarStyle(
                  selectedDecoration: BoxDecoration(),
                  todayDecoration: BoxDecoration(),
                  outsideTextStyle: TextStyle(color: Colors.grey),
                  weekendTextStyle: TextStyle(color: Colors.red),
                  defaultTextStyle: TextStyle(color: Colors.black87),
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, events) {
                    if (events.isNotEmpty) {
                      return Positioned(
                        bottom: 5,
                        child: Image.asset(
                          'assets/icons/app_icon.png',
                          width: 40,
                          height: 40,
                        ),
                      );
                    }
                    return null;
                  },
                  selectedBuilder: (context, day, focusedDay) {
                    final now = DateTime.now();
                    final isToday = day.year == now.year &&
                        day.month == now.month &&
                        day.day == now.day;

                    if (isToday) {
                      final currentTemplate = context.watch<TemplateProvider>().currentTemplate;
                      return Transform.translate(
                        offset: const Offset(0, -10),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: currentTemplate.appBarColor,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${day.day}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    }

                    return Center(
                      child: Text("🐑", style: const TextStyle(fontSize: 24)),
                    );
                  },
                    todayBuilder: (context, day, focusedDay) {
                      final currentTemplate = context.watch<TemplateProvider>().currentTemplate;
                      return Transform.translate(
                        offset: const Offset(0, -10),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: currentTemplate.appBarColor,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${day.day}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}