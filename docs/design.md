# Design Spec — 데이트 로그 앱

> 관리 주체: `design` 에이전트  
> 마지막 업데이트: 2026-04-25  
> 현재 UI 기반을 유지하면서 기능을 확장하는 방향으로 설계한다.

---

## 1. 앱 전체 컨셉

| 항목 | 내용 |
|------|------|
| 앱명 | **Dater** (가칭) |
| 슬로건 | 우리의 날들을 기록하다 |
| 타겟 | 데이트 기록을 감성적으로 남기고 싶은 커플 |
| 핵심 가치 | 둘이 함께 쓰는 공유 다이어리 + 지도 아카이브 |
| 무드 | 따뜻하고 감성적인 다이어리 느낌. 유치하지 않은 깔끔한 아카이브 |
| 컬러 기조 | 크림, 피치, 코랄, 핑크, 라벤더 |

---

## 2. 핵심 사용자 시나리오

### 시나리오 A — 데이트 후 기록하기
1. 앱 실행 → 카카오 로그인
2. 홈(캘린더) → 오늘 날짜 탭
3. `+` 버튼으로 기록 작성
4. 장소 선택(행정구역) → 사진 추가 → 메모 → 감성점수 선택
5. 저장 → 캘린더 날짜에 감성점수 색상 점 표시
6. 파트너도 같은 기록을 보고 코멘트 추가

### 시나리오 B — 지난 데이트 돌아보기
1. 지도 탭 → 전국에 찍힌 마커 확인
2. 마커 색상으로 감성점수 파악
3. 마커 탭 → 바텀시트로 미리보기
4. 상세보기 → 이미지/메모/태그 확인

### 시나리오 C — 파트너와 공유
1. 마이페이지 → 파트너 초대 코드 생성
2. 파트너가 코드 입력 → 커플 연결
3. 연결 후 두 사람이 동일한 기록 공간 접근
4. 각자 기록 작성 가능, 상대방 기록도 편집 가능

---

## 3. 화면 구조

```
앱 진입
└── 로그인 화면 (카카오 로그인)
    └── 홈 셸 (BottomNavigationBar 4탭)
        ├── [캘린더 탭]
        │   ├── 날짜 선택
        │   └── 기록 미리보기 카드
        ├── [지도 탭]
        │   ├── 전국 지도 + 마커
        │   └── 마커 탭 → 바텀시트 미리보기
        ├── [기록 탭] (기록 작성)
        │   ├── 제목 / 날짜 / 장소 선택
        │   ├── 이미지 업로드
        │   ├── 메모 / 태그
        │   └── 감성점수 선택
        └── [마이페이지 탭]
            ├── 카카오 프로필
            ├── 파트너 연결 상태
            └── 통계 요약

기록 카드 탭 → 기록 상세 화면
    ├── 이미지 슬라이더
    ├── 장소 / 날짜 / 감성
    ├── 메모 / 태그
    └── 편집 / 삭제 버튼
```

---

## 4. 탭 구조

| 탭 | 아이콘 | 역할 |
|----|--------|------|
| 캘린더 | `calendar_month` | 날짜별 기록 조회 (메인) |
| 지도 | `map` | 장소 기반 기록 조회 |
| 기록 | `add_circle` | 새 데이트 기록 작성 |
| 마이페이지 | `person` | 프로필 / 파트너 / 통계 |

---

## 5. 주요 화면별 UI 구성

### 5-1. 로그인 화면

```
┌─────────────────────────────┐
│                             │
│         [앱 로고]            │
│       Dater                 │
│   우리의 날들을 기록하다      │
│                             │
│                             │
│   ┌─────────────────────┐   │
│   │  🟡 카카오 로그인    │   │
│   └─────────────────────┘   │
│                             │
│   개인정보처리방침  이용약관  │
└─────────────────────────────┘
```

- 배경: 크림 화이트 (`#FFFDF9`)
- 로고: 감성적인 타이포 + 작은 하트 아이콘
- 카카오 버튼: 공식 컬러 `#FEE500`, 텍스트 `#3C1E1E`

---

### 5-2. 캘린더 홈 화면

```
┌─────────────────────────────┐
│ Dater              [필터] ⚙ │  ← 헤더
├─────────────────────────────┤
│       2026년 4월             │
│  일  월  화  수  목  금  토  │
│  ...  날짜 셀 ...            │
│  ● = 감성점수 색상 점        │  ← 기록 있는 날짜
├─────────────────────────────┤
│ 4월 25일 토요일      3건 ●  │  ← 선택 날짜 요약
├─────────────────────────────┤
│ ┌──────────────────────┐    │
│ │ [이미지]  제목         │    │  ← 미리보기 카드
│ │          📍 장소       │    │
│ │          ❤ 감성 ●●●●○ │    │
│ │          💬 메모 요약  │    │
│ └──────────────────────┘    │
│ ┌──────────────────────┐    │
│ │ ...                  │    │
│ └──────────────────────┘    │
└─────────────────────────────┘
```

**캘린더 날짜 셀 규칙**
- 기록 없음: 기본 스타일
- 기록 있음: 날짜 아래 감성점수 색상 점(dot) 최대 3개 표시
- 오늘: `pinkLight` 원형 배경
- 선택됨: `pink` 원형 배경 + 흰 텍스트

**미리보기 카드 구성**
- 좌측: 대표 이미지 (없으면 감성점수 색상 블록)
- 우측 상단: 제목 (없으면 장소명)
- 우측 중간: 📍 장소명 · 감성점수 이모지
- 우측 하단: 메모 1줄 요약 (maxLines: 1)
- 카드 탭 → 상세 화면 이동

---

### 5-3. 지도 홈 화면

```
┌─────────────────────────────┐
│   [지도]       [내 위치] ⊕  │  ← 플로팅 헤더
│                             │
│    ┌──────────────────┐     │
│    │                  │     │
│    │   🗺 한반도 지도  │     │
│    │                  │     │
│    │   ● ●  ●        │     │  ← 감성점수 마커
│    │     ●           │     │
│    └──────────────────┘     │
│                             │
│ ┌───────────────────────┐   │  ← 마커 탭 시 바텀시트
│ │ ─────────             │   │
│ │ [이미지]  장소명       │   │
│ │          날짜 · 감성   │   │
│ │          메모 요약     │   │
│ │        [상세보기] →   │   │
│ └───────────────────────┘   │
└─────────────────────────────┘
```

**마커 디자인**
- 원형 컨테이너 (흰 배경 + 감성점수 색상 테두리)
- 내부: 감성점수 이모지
- 크기: 48×48

---

### 5-4. 기록 작성 화면

```
┌─────────────────────────────┐
│ ← 기록 작성                 │
├─────────────────────────────┤
│ [+ 사진 추가]  [사진1][사진2]│  ← 이미지 선택
├─────────────────────────────┤
│ 제목 (선택)                  │
│ ┌─────────────────────────┐ │
│ │ 어떤 데이트였나요?        │ │
│ └─────────────────────────┘ │
│                             │
│ 📍 장소                     │
│ ┌─────────────────────────┐ │
│ │ 시/도 선택 > 시/군/구 >  │ │  ← 행정구역 피커
│ └─────────────────────────┘ │
│                             │
│ 📅 날짜                     │
│ ┌─────────────────────────┐ │
│ │ 2026년 4월 25일          │ │
│ └─────────────────────────┘ │
│                             │
│ 💬 메모                     │
│ ┌─────────────────────────┐ │
│ │ 오늘 어떤 하루였나요?    │ │
│ └─────────────────────────┘ │
│                             │
│ 🏷 태그 (쉼표 구분)         │
│ ┌─────────────────────────┐ │
│ │ 카페, 영화, 드라이브     │ │
│ └─────────────────────────┘ │
│                             │
│ 오늘 감정은?                │
│  😢    😕    😊    🥰    💕  │  ← 이모지 감성 선택
│  아쉬움 잔잔함 보통  좋음  최고 │
│                             │
│ ┌─────────────────────────┐ │
│ │      기록 저장하기       │ │
│ └─────────────────────────┘ │
└─────────────────────────────┘
```

---

### 5-5. 기록 상세 화면

```
┌─────────────────────────────┐
│ ←  데이트 기록     [편집] ✎ │
├─────────────────────────────┤
│ ┌─────────────────────────┐ │
│ │   이미지 슬라이더        │ │  ← PageView
│ │   (스와이프로 여러 장)   │ │
│ └─────────────────────────┘ │
│ ● ○ ○  (인디케이터)        │
├─────────────────────────────┤
│ 제목                        │
│ 2026년 4월 25일 토요일      │
├─────────────────────────────┤
│ 📍 장소      서울 마포구     │
│ 💸 비용      48,000원        │
│ ❤ 감성       🥰 좋음         │
├─────────────────────────────┤
│ 💬 메모                     │
│ 오늘 데이트는 정말...        │
├─────────────────────────────┤
│ 🏷 태그                     │
│ [카페] [영화] [드라이브]    │
├─────────────────────────────┤
│ 📝 작성자    nickname        │  ← 파트너 공유 정보
└─────────────────────────────┘
```

---

### 5-6. 마이페이지

```
┌─────────────────────────────┐
│ 마이페이지                   │
├─────────────────────────────┤
│  [프로필 이미지]             │
│  닉네임                     │
│  카카오 연동 완료 ✓          │
├─────────────────────────────┤
│ 파트너                      │
│ ┌─────────────────────────┐ │
│ │ [상대 이미지]  닉네임    │ │  ← 연결됨
│ │ 함께한 날 : 120일        │ │
│ └─────────────────────────┘ │
│ 또는                        │
│ [파트너 초대 코드 생성]      │  ← 미연결
├─────────────────────────────┤
│ 우리의 통계                  │
│ 총 데이트     42회           │
│ 총 비용       1,240,000원    │
│ 평균 감성     🥰 좋음        │
│ 자주 간 곳   서울 마포구     │
├─────────────────────────────┤
│ [로그아웃]                  │
└─────────────────────────────┘
```

---

## 6. 데이터 모델 설계

### User
```dart
class User {
  final String id;           // UUID (내부 식별자)
  final String kakaoId;      // 카카오 유저 ID
  final String nickname;
  final String? profileImageUrl;
  final String? email;       // 선택 수집
  final String? coupleId;    // 커플 연결 시 채워짐
  final DateTime createdAt;
}
```

### Couple
```dart
class Couple {
  final String id;           // 커플 공간 ID
  final String userAId;      // 유저 A
  final String userBId;      // 유저 B
  final String inviteCode;   // 초대 코드 (6자리)
  final DateTime linkedAt;
}
```

### DateLog
```dart
class DateLog {
  final String id;           // UUID
  final String coupleId;     // 소속 커플 공간
  final String authorId;     // 작성자 유저 ID
  final String? title;
  final DateTime startedAt;
  final DateTime? endedAt;
  final DatePlace place;     // 하위 모델
  final String memo;
  final int moodScore;       // 1~5
  final double totalCost;
  final List<String> tags;
  final List<String> photoUrls;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### DatePlace
```dart
class DatePlace {
  final String sido;         // 시/도 (예: 서울특별시)
  final String sigungu;      // 시/군/구 (예: 마포구)
  final String? eupmyeondong; // 읍/면/동 (예: 연남동) — 선택
  final String displayName;  // "서울 마포구" 형태로 표시
  final double latitude;     // 대표 좌표
  final double longitude;
}
```

---

## 7. Flutter 폴더 구조

```
lib/
├── main.dart
└── src/
    ├── app.dart
    ├── models/
    │   ├── date_log.dart
    │   ├── date_place.dart
    │   ├── user.dart
    │   └── couple.dart
    ├── state/
    │   ├── date_log_state.dart      # DateLog CRUD Provider
    │   ├── auth_state.dart          # 로그인 상태
    │   ├── couple_state.dart        # 커플 연결 상태
    │   └── filter_state.dart        # 필터 상태
    ├── data/
    │   ├── date_log_repository.dart
    │   ├── auth_repository.dart
    │   ├── couple_repository.dart
    │   └── place_data.dart          # 행정구역 정적 데이터
    ├── features/
    │   ├── auth/
    │   │   └── login_screen.dart
    │   ├── calendar/
    │   │   └── calendar_screen.dart
    │   ├── map/
    │   │   └── map_screen.dart
    │   ├── add/
    │   │   ├── add_log_screen.dart
    │   │   └── widgets/
    │   │       ├── place_picker.dart      # 행정구역 선택
    │   │       ├── image_picker_row.dart
    │   │       └── mood_selector.dart
    │   ├── detail/
    │   │   └── detail_screen.dart
    │   └── mypage/
    │       ├── mypage_screen.dart
    │       └── widgets/
    │           └── partner_card.dart
    └── core/
        ├── constants/
        │   ├── app_constants.dart
        │   └── place_constants.dart   # 행정구역 데이터
        ├── theme/
        │   └── app_theme.dart
        └── utils/
            └── date_formatter.dart
```

---

## 8. 사용 패키지

| 기능 | 패키지 | 이유 |
|------|--------|------|
| 상태 관리 | `flutter_riverpod` | 현재 사용 중, Provider 패턴 |
| 캘린더 | `table_calendar` | 현재 사용 중 |
| 지도 | `flutter_map` + `latlong2` | 현재 사용 중, OSM 무료 |
| 카카오 로그인 | `kakao_flutter_sdk_user` | 카카오 공식 SDK |
| 이미지 선택 | `image_picker` | 갤러리/카메라 모두 지원 |
| 날짜 포맷 | `intl` | 현재 사용 중 |
| ID 생성 | `uuid` | 현재 사용 중 |
| 로컬 저장 (MVP) | `hive` + `hive_flutter` | 오프라인 우선, 빠름 |
| 원격 저장 (확장) | `supabase_flutter` | 커플 공유에 필요 |
| 이미지 표시 | `cached_network_image` | 네트워크 이미지 캐싱 |
| 로깅 | `logger` | 현재 사용 중 |

### pubspec.yaml 추가 항목
```yaml
dependencies:
  kakao_flutter_sdk_user: ^1.9.0
  image_picker: ^1.1.2
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  cached_network_image: ^3.4.1
  supabase_flutter: ^2.5.0   # 커플 공유 확장 시
```

---

## 9. 감성점수 색상 시스템

| 점수 | 라벨 | 이모지 | 색상 (HEX) | 용도 |
|------|------|--------|-----------|------|
| 1 | 아쉬움 | 😢 | `#BFDBFE` (차분한 블루) | 차갑고 잔잔한 느낌 |
| 2 | 잔잔함 | 😕 | `#E9D5FF` (연보라) | 무난하고 조용한 느낌 |
| 3 | 보통 | 😊 | `#FEF08A` (옐로우) | 밝고 따뜻한 중간 |
| 4 | 좋음 | 🥰 | `#FCA5A5` (코랄) | 설레고 행복한 느낌 |
| 5 | 최고 | 💕 | `#FF4D8D` (핑크) | 최고의 순간 |

```dart
// app_constants.dart에 정의
static const List<Color> moodColors = [
  Colors.transparent,           // 0 (미사용)
  Color(0xFFBFDBFE),            // 1 아쉬움
  Color(0xFFE9D5FF),            // 2 잔잔함
  Color(0xFFFEF08A),            // 3 보통
  Color(0xFFFCA5A5),            // 4 좋음
  Color(0xFFFF4D8D),            // 5 최고
];

static const List<String> moodEmojis = ['', '😢', '😕', '😊', '🥰', '💕'];
static const List<String> moodLabels = ['', '아쉬움', '잔잔함', '보통', '좋음', '최고'];
```

**적용 위치**
- 캘린더 날짜 아래 점(dot)
- 기록 카드 좌측 이모지 배경
- 지도 마커 테두리 색상
- 상세 화면 히어로 섹션 배경

---

## 10. MVP 범위 vs 확장 기능

### MVP (Phase 1~3) — 지금 바로 구현
| 기능 | 상태 |
|------|------|
| 캘린더 기반 기록 조회 | ✅ 구현됨 |
| 지도 기반 기록 조회 | ✅ 구현됨 |
| 기록 작성 (위도/경도 입력) | ✅ 구현됨 |
| 감성점수 이모지 선택 UI | ✅ 구현됨 |
| 기록 상세 화면 | ✅ 구현됨 |
| 통계 화면 | ✅ 구현됨 |
| 행정구역 장소 피커 | 🔜 Phase 2 |
| 이미지 첨부 (image_picker) | 🔜 Phase 2 |
| 카카오 로그인 | 🔜 Phase 2 |
| Hive 로컬 영속 저장 | 🔜 Phase 2 |
| 마이페이지 기본 | 🔜 Phase 2 |

### 확장 기능 (Phase 4+)
| 기능 | 설명 |
|------|------|
| 커플 연결 & 공유 | Supabase 기반 실시간 동기화, 초대 코드 |
| 파트너 기록 편집 | coupleId 기반 공유 공간, 권한 구조 |
| Reverse Geocoding | 지도 탭에서 직접 위치 선택 + 주소 자동 변환 |
| 이미지 클라우드 저장 | Supabase Storage 연동 |
| 기념일 알림 | 특별한 날짜 push 알림 |
| 기록 내보내기 | PDF/이미지로 추억 앨범 생성 |

---

## 11. UI/UX 디자인 가이드

### 색상 토큰
```dart
// 배경
background:    #FFFFFF
surface:       #F6F6F9
surfaceWarm:   #FFFDF9   // 로그인/따뜻한 화면

// 텍스트
textPrimary:   #1A1A1A
textSecondary: #8A8A9A

// 포인트
pink:          #FF4D8D
pinkLight:     #FFE4EF
border:        #EEEEEF2
```

### 타이포그래피
| 용도 | 크기 | 굵기 |
|------|------|------|
| 화면 대제목 | 24px | w800 |
| 카드 제목 | 16px | w600 |
| 섹션 헤더 | 15px | w700 |
| 본문 | 14px | w400 |
| 보조 텍스트 | 12px | w400 |
| 태그/뱃지 | 11px | w500 |

### 간격
```
XS: 4   S: 8   M: 16   L: 24   XL: 32
페이지 수평 패딩: 20px
```

### 컴포넌트 규칙
- **카드**: 흰 배경 + `border: #EEEEEF2` + `radius: 16`
- **버튼**: `radius: 14`, `height: 52`, 그림자 없음
- **입력 필드**: `filled: true`, `fillColor: #F6F6F9`, 보더 없음, 포커스 시 핑크 보더
- **바텀시트**: 상단 `radius: 24`, 핸들 바 포함
- **마커**: 흰 원 + 감성점수 색상 테두리 2px + 내부 이모지

### 이미지 카드
- 좌측 이미지: 가로 80px × 세로 80px, `radius: 12`, `BoxFit.cover`
- 이미지 없을 때: 감성점수 색상 블록으로 대체
- 이미지 있을 때: `cached_network_image` + 로딩 shimmer

---

## 12. 구현 우선순위 (claude-code-writer 참고용)

### Phase 2 — 지금 바로 시작 (이번 스프린트)

#### P1: 행정구역 장소 피커
```
파일: lib/src/core/constants/place_constants.dart
      lib/src/features/add/widgets/place_picker.dart

구현:
- 시/도 목록 정적 데이터 (17개)
- 시/도 선택 → 시/군/구 목록 필터
- BottomSheet 내 2단 Picker 또는 ListTile 선택
- 선택값 → DatePlace 모델로 변환
- 대표 좌표 매핑 테이블 (각 구별 중심 좌표)

완료 조건: 장소 선택 후 기록 저장 → 지도에 올바른 위치 마커 표시
```

#### P2: 이미지 첨부
```
파일: lib/src/features/add/widgets/image_picker_row.dart

구현:
- image_picker로 갤러리/카메라 선택
- 선택 이미지 수평 스크롤 미리보기
- 최대 5장 제한
- 첫 번째 이미지 → 카드 대표 이미지
- MVP: 로컬 파일 경로 저장 (Base64 or 파일 경로)

완료 조건: 이미지 첨부 후 캘린더 카드에 대표 이미지 표시
```

#### P3: Hive 로컬 영속 저장
```
파일: lib/src/data/date_log_repository.dart (수정)

구현:
- HiveBox<DateLog> 연동
- 앱 재시작 후에도 기록 유지
- TypeAdapter 자동 생성 (build_runner)

완료 조건: 앱 종료 후 재시작 시 기록 유지
```

#### P4: 카카오 로그인
```
파일: lib/src/features/auth/login_screen.dart
      lib/src/state/auth_state.dart
      lib/src/data/auth_repository.dart

구현:
- kakao_flutter_sdk_user 연동
- 카카오 앱 키 설정 (AndroidManifest, Info.plist)
- 로그인 → User 모델 저장
- 앱 진입 시 로그인 상태 확인 → 자동 로그인

완료 조건: 카카오 로그인 → 프로필 이미지/닉네임 마이페이지 표시
```

#### P5: 마이페이지 기본
```
파일: lib/src/features/mypage/mypage_screen.dart

구현:
- 카카오 프로필 (이미지 + 닉네임)
- 기본 통계 (횟수, 비용, 평균 감성)
- 로그아웃

완료 조건: 마이페이지에서 프로필 확인 + 로그아웃 동작
```

---

### Phase 3 — 커플 공유 (다음 스프린트)

#### P6: Supabase 연동 + 커플 연결
```
테이블:
  users (id, kakao_id, nickname, profile_image_url, couple_id)
  couples (id, user_a_id, user_b_id, invite_code, linked_at)
  date_logs (id, couple_id, author_id, ...모든 필드)
  photos (id, date_log_id, url, order)

구현:
- Supabase 프로젝트 생성 + Row Level Security 설정
- 초대 코드 생성 (6자리 랜덤)
- 파트너가 코드 입력 → couple 연결
- coupleId 기반 데이터 필터링
- 실시간 구독 (RealtimeChannel)으로 파트너 기록 즉시 반영

RLS 정책:
  date_logs: couple_id = auth.jwt() → couple_id 일치 시만 SELECT/INSERT/UPDATE
  
완료 조건: 두 기기에서 같은 기록 공간 접근, 파트너 기록 실시간 반영
```

---

## 에이전트 협업 참고

| 에이전트 | 담당 |
|----------|------|
| `design` | 이 문서 유지, 색상/컴포넌트 스펙 변경 시 업데이트 |
| `claude-code-writer` | Phase 2~3 순서대로 구현, 위 완료 조건 충족 후 다음 단계 |
| `evaluator` | 각 Phase 완료 시 테스트 작성 + 버그 리포트 |
