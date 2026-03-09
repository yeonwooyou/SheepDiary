import 'package:flutter/material.dart';

/// 템플릿 정의
class DiaryTemplate {
  final String name;
  final Color appBarColor;
  final Color backgroundColor;
  final String imagePath;  // 이미지 경로 추가

  const DiaryTemplate({
    required this.name,
    required this.appBarColor,
    required this.backgroundColor,
    required this.imagePath,  // 이미지 경로를 초기화
  });
}

const defaultTemplate = DiaryTemplate(
  name: '연두목장',
  appBarColor: Color(0xFFABF0B4),
  backgroundColor: Color(0xFFFFFFFF),
  imagePath: 'assets/profile_sheep/green.png',  // 이미지 경로 추가
);

const purpleTemplate = DiaryTemplate(
  name: '보라목장',
  appBarColor: Color(0xFFD4B5F9), // 라벤더톤 퍼플
  backgroundColor: Color(0xFFFFFFFF),
  imagePath: 'assets/profile_sheep/purple.png',  // 이미지 경로 추가
);

const brownTemplate = DiaryTemplate(
  name: '파란목장',
  appBarColor: Color(0xFFA9D7F5),
  backgroundColor: Color(0xFFFFFFFF),
  imagePath: 'assets/profile_sheep/blue.png',  // 이미지 경로 추가
);

const pinkTemplate = DiaryTemplate(
  name: '노란목장',
  appBarColor: Color(0xFFFFE5B0),
  backgroundColor: Color(0xFFFFFFFF),
  imagePath: 'assets/profile_sheep/yellow.png',  // 이미지 경로 추가
);

const whiteTemplate = DiaryTemplate(
  name: '하얀목장',
  appBarColor: Color(0xFFD3D3D3),
  backgroundColor: Color(0xFFFFFFFF),
  imagePath: 'assets/profile_sheep/white.png',  // 이미지 경로 추가
);

const List<DiaryTemplate> allTemplates = [
  defaultTemplate,
  brownTemplate,
  pinkTemplate,
  purpleTemplate,
  whiteTemplate,
];
/// Provider - 템플릿 전역 상태
class TemplateProvider with ChangeNotifier {
  DiaryTemplate _currentTemplate = defaultTemplate;

  DiaryTemplate get currentTemplate => _currentTemplate;

  void setTemplate(DiaryTemplate newTemplate) {
    _currentTemplate = newTemplate;
    notifyListeners();
  }
}
