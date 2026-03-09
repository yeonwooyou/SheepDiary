# Sheep Diary — AI 기반 자동 일기 생성 앱

## 기여 내용 (유연우)

- **DB 설계 및 관리**: 서비스 운영에 필요한 데이터 구조를 관리하고, 기능 구현에 필요한 데이터베이스 연동을 담당함.
- **LLM 기반 이미지 캡셔닝 및 LangChain 기반 일기 생성 기능 구현**: 이미지와 사용자 입력 데이터를 바탕으로 자동 일기 생성 흐름을 설계하고 구현함.

---

사용자가 하루 동안 기록한 **사진, 장소, 감정, 키워드**를 바탕으로 일기를 작성·관리하고, 이벤트 기반으로 **일기 초안(제안)** 을 생성하는 모바일 앱 프로젝트입니다.

> 이 레포는 포트폴리오 정리용으로, 서비스 전체 구현본인 `Program/`과 AI 생성 흐름 데모인 `Demo/`를 함께 포함하고 있습니다.

## 프로젝트 개요

- **프로젝트명**: Sheep Diary
- **진행 기간**: 2025년 3월 27일 ~ 2025년 5월 24일
- **프로젝트 형태**: AI 기반 자동 일기 생성 모바일 앱 서비스 개발
- **목표**: 사용자의 하루 기록 데이터를 기반으로 일기 작성 및 AI 기반 일기 초안 생성 기능 구현

## 핵심 기능

- **회원가입/로그인**
  - 이메일 인증 코드 발송 및 검증
  - JWT 기반 로그인 및 토큰 갱신

- **일기 작성/수정/조회**
  - 날짜별 일기 작성 및 수정
  - 특정 날짜 일기 조회
  - 월별 일기 작성 여부 조회

- **이벤트/타임라인 기반 일기 제안**
  - 하루 동안의 이벤트 데이터를 기반으로 일기 초안 생성
  - 사진, 장소, 감정, 키워드 정보를 활용한 생성 흐름 구현
  - 데모 환경에서는 목업 데이터 기반으로 동작

- **갤러리(이미지 업로드 연동)**
  - S3 Presigned URL 기반 이미지 업로드 흐름 포함
  - 업로드 완료 후 이미지 확정 처리 기능 포함

## 기술 스택

- **Frontend**: Flutter, Provider
- **Backend**: Django, Django REST Framework, SimpleJWT
- **Database / Cache**: MySQL, Redis
- **Infra / Docs**: AWS S3 (boto3), drf-spectacular (Swagger/OpenAPI)

## 폴더 구성

### `Program/` — 모바일 앱(Flutter) + 백엔드(Django/DRF) 통합
- **frontend/**: Flutter 앱
- **backend/**: Django + DRF API 서버
- **db/**: MySQL 스키마 및 시드 스크립트(해당 시)
- **docs/**, **deploy/**: 문서 및 배포 관련 자료

빠른 시작 및 상세 설정은 `Program/README.md`를 참고하세요.

### `Demo/` — AI 일기 생성 핵심 로직 데모(발췌본)
- `diary_generator.py`: 사진/이벤트 기반 일기 생성 흐름을 설명하는 데모 스크립트
- `README.md`: 데모 실행 가이드

> 참고: `Demo/`는 전체 서비스 구현본이 아니라, **LLM/LangChain 기반 일기 생성 아이디어와 처리 흐름을 이해할 수 있도록 발췌·재구성한 데모**입니다.

## 실행 가이드

### 1) 백엔드 실행 (Django/DRF)
`Program/README.md`를 참고하세요.  
실행을 위해 MySQL, Redis, `.env` 설정이 필요합니다.

일반적으로는 아래와 같은 순서로 실행합니다.

```bash
cd Program/backend
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver
```

### 2) 프론트엔드 실행 (Flutter)

Flutter SDK가 설치되어 있어야 합니다.

```bash
cd Program/frontend
flutter pub get
flutter run
```

- 에뮬레이터 또는 실제 기기(Android/iOS)에서 실행 가능합니다.
- 백엔드 서버가 먼저 실행 중인 상태여야 합니다.
- `lib/constants/` 내 API 주소를 환경에 맞게 확인하세요.
