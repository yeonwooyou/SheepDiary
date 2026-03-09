#  Sheep Diary — Flutter + Django + DRF + MySQL 프로젝트

---

## 폴더 구조

```
sheep_diary/
├── frontend/         # Flutter 앱 (Flutter SDK 필수)
├── backend/          # Django + DRF 백엔드 서버
├── db/               # MySQL DB 초기 세팅
│   ├── schema/       # 테이블 생성 스크립트 (DDL)
│   └── seed/         # 더미 데이터 삽입 스크립트 (DML)
├── deploy/           # 배포
├── docs/             # 문서
├── .gitignore
└── README.md
```

.gitkeep 파일들은 폴더구조 유지를 위해 넣어놓았습니다. 깃 클론 후에는 삭제해도 됩니다.

## 개발 환경 설정 가이드

### 1. Python Conda 환경 준비

```bash
# conda 가상환경 생성 (Python 3.10 기준)
conda create -n sheepdiary_env python=3.10
conda activate sheepdiary_env

# 필수 패키지 설치
cd backend # 가상환경 확인하고, backend 폴더로 이동합니다.
pip install -r requirements.txt
```

-   추가로, 이메일 인증번호 보관에 사용할 캐시DB Redis를 설치합니다.
-   https://github.com/microsoftarchive/redis/releases
-   Assets 제일 위의 msi파일 다운로드 후 설치, PATH 추가

---

### 2. Django + DRF 백엔드 개발 서버 실행

```bash
# backend 폴더로 이동
cd backend/

# DB 마이그레이션 실행
python manage.py makemigrations
python manage.py migrate

# 개발 서버 실행
python manage.py runserver
```

-   실행에는 `.env` 파일이 필요합니다. 아래 `.env 예시` 항목을 참고해 직접 생성하세요.
-   (`.gitignore`에 포함되어 있으므로 Git에는 업로드되지 않습니다.)

---

### 4. API 테스트 방법

개발 중인 API를 로컬에서 테스트하려면 다음과 같은 절차를 따릅니다.

### 예시: API-U001 — 앱 초기 사용자 상태 확인 — GET /api/users/me/daily-status/

#### 1. 서버 실행

```bash
cd backend/
python manage.py runserver
```

#### 2. http로 API 호출 (Flutter Dart 예시)

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> fetchUserDailyStatus(String accessToken) async {
  const String baseUrl = 'http://127.0.0.1:8000'; // Android 에뮬레이터: 'http://10.0.2.2:8000'
  final String url = '$baseUrl/api/users/me/daily-status/';

  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken", // JWT 토큰
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      print("API 응답:");
      print(data);
    } else {
      print("오류 발생: 상태 코드 ${response.statusCode}");
      print(response.body);
    }
  } catch (e) {
    print("네트워크 오류: $e");
  }
}
```

#### 3. 예상 응답 예시

```bash
{
  "is_authenticated": true,
  "today_date": "2025-04-17",
  "emotion": "happy",
  "diary_exists": false
}
```

---

## 참고 사항

-   `frontend`와 `backend`는 각각 독립적으로 실행
-   Django REST Framework로 Flutter 앱에 API 제공
-   `.env` 파일을 활용해 비밀 키 및 DB 비밀번호 등 민감 정보 분리 추천
-   `config/settings.py`에서 `ALLOWED_HOSTS`, `CORS`, `STATIC`, `MEDIA` 경로 등도 설정 필요

---