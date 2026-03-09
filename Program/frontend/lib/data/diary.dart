import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '/pages/write/emoji.dart';

class Diary {

  final String id;
  final String date; // "yyyy-MM-dd" 형식
  final String text;
  final List<String> tags;
  final List<String> photos;
  final double latitude;  // 위도
  final double longitude; // 경도
  final List<Map<String, double>> timeline;
  final Map<String, double> cameraTarget;
  final List<Map<String, dynamic>> markers;
  final String emotionEmoji; // 새로운 필드 추가
  // final DateTime diary_date;

  static LatLng mapToLatLng(Map<String, double> map) {
    return LatLng(map['lat']!, map['lng']!);
  }

  List<LatLng> get timelineLatLng =>
      timeline.map((e) => mapToLatLng(e)).toList();

  LatLng get cameraLatLng => mapToLatLng(cameraTarget);


  Diary({
    required this.id,
    required this.date,
    required this.text,
    required this.tags,
    required this.photos,
    required this.latitude,
    required this.longitude,
    required this.timeline,
    required this.markers,
    required this.cameraTarget,
    required this.emotionEmoji, // selectedEmoji를 생성자에 추가
    // required this.diary_date,  // 생성자에 diary_date 추가
  });


  factory Diary.fromJson(Map<String, dynamic> json) {
    return Diary(
      id: json['diary_id'].toString(),
      date: json['date'], // yyyy-MM-dd 문자열
      text: '',           // API에 없으므로 빈 문자열 처리
      tags: List<String>.from(json['keywords'] ?? []),
      photos: [],         // API에 없음, 빈 리스트 처리
      latitude: 0.0,      // API에 없음, 기본값 0.0
      longitude: 0.0,     // API에 없음, 기본값 0.0
      timeline: [],       // API에 없음, 빈 리스트 처리
      cameraTarget: {'lat': 0.0, 'lng': 0.0}, // 기본값
      markers: [],        // API에 없음, 빈 리스트 처리
      emotionEmoji: convertIdToEmoji(json['emotion_id']),
    );
  }


  String mapEmotionIdToEmoji(int? emotionId) {
    switch (emotionId) {
      case 1: return '😊';
      case 2: return '😢';
      case 3: return '😠';
      case 4: return '😲';
      case 5: return '😴';
      default: return '🙂';
    }
  }

  factory Diary.empty() {
    return Diary(
      id: UniqueKey().toString(), // 임시로 UniqueKey로 고유 id 생성
      date: DateTime.now().toIso8601String().split('T').first, // yyyy-MM-dd 형태로 변환
      text: '',
      tags: [],
      photos: [],
      latitude: 0.0,
      longitude: 0.0,
      timeline: [], // ✅ 빈 리스트로 초기화
      cameraTarget: {'lat': 0.0, 'lng': 0.0}, // ✅ 기본 좌표값
      markers: [], // ✅ 마커도 빈 리스트로 초기화
      emotionEmoji: '', // 기본적으로 빈 문자열로 초기화
      // diary_date: DateTime.now(), // 날짜는 현재 DateTime으로 초기화
    );
  }
}