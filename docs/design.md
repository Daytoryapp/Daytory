# Design Spec — 데이트 로그 앱

> 관리 주체: `design` 에이전트
> 마지막 업데이트: 2026-04-26
> **v2.0 전면 UI 고도화 — 토끼 캐릭터 감정 시스템 + 화면별 개선**

---

## 1. 앱 전체 컨셉

| 항목 | 내용 |
|------|------|
| 앱명 | **DayStory** |
| 슬로건 | 우리의 날들을 기록하다 |
| 타겟 | 데이트 기록을 감성적으로 남기고 싶은 커플 |
| 핵심 가치 | 둘이 함께 쓰는 공유 다이어리 + 지도 아카이브 |
| 무드 | 따뜻하고 감성적인 다이어리 느낌. 유치하지 않은 깔끔한 아카이브 |
| 컬러 기조 | 크림, 피치, 코랄, 핑크, 로즈 |

---

## 2. v2.0 컬러 팔레트 (개선됨)

### 기본 색상 토큰

```dart
// ── app_constants.dart 및 app_theme.dart 동기화 ──

// 배경
static const Color background   = Color(0xFFFFFFFF);
static const Color surface      = Color(0xFFF8F5F2);   // 크림빛 베이지 (기존 #F6F6F9 → 웜톤으로 변경)
static const Color surfaceWarm  = Color(0xFFFFF8F5);   // 로그인/히어로 섹션용

// 포인트
static const Color pink         = Color(0xFFFF5A8A);   // 기존 #FF4D8D보다 덜 형광, 더 로즈핑크
static const Color pinkLight    = Color(0xFFFFEBF1);   // 기존 #FFE4EF보다 밝고 부드럽게
static const Color pinkMid      = Color(0xFFFFCEDF);   // 중간톤 추가 (선택 상태 등)
static const Color coral        = Color(0xFFFF7B6B);   // 포인트 보조 (4번 감정 배경 등)
static const Color peach        = Color(0xFFFFB08A);   // 웜 포인트 (기념일, 배지 등)

// 텍스트
static const Color textPrimary  = Color(0xFF1E1A1D);   // 기존 #1A1A1A보다 따뜻한 블랙
static const Color textSecondary= Color(0xFF9A8E96);   // 기존 #8A8A9A보다 따뜻한 그레이
static const Color textHint     = Color(0xFFBFB5BB);   // placeholder, 비활성 텍스트

// 경계/구분선
static const Color border       = Color(0xFFEDEAEC);   // 기존 #EEEEEF2 보정
static const Color divider      = Color(0xFFF2EEF0);   // 더 옅은 구분선
```

### 감정 색상 시스템 (v2.0 — 토끼 캐릭터 연동)

| 점수 | 라벨 | 캐릭터 | 배경색 HEX | 테두리/포인트 HEX | 감성 |
|------|------|--------|-----------|-----------------|------|
| 1 | 속상해 | 슬픈 토끼 | `#DCE8FB` | `#8AAEE8` | 차분한 블루 |
| 2 | 그냥 | 무표정 토끼 | `#EDE8F5` | `#A893D4` | 연보라 |
| 3 | 좋아 | 미소 토끼 | `#FFF0D6` | `#F0B060` | 따뜻한 옐로우 |
| 4 | 설레 | 볼빨간 토끼 | `#FFE0E0` | `#F07878` | 코랄 핑크 |
| 5 | 최고야 | 하트눈 토끼 | `#FFEAF2` | `#FF5A8A` | 핑크 로즈 |

```dart
static const List<Color> moodColors = [
  Colors.transparent,   // 0 미사용
  Color(0xFFDCE8FB),    // 1 속상해
  Color(0xFFEDE8F5),    // 2 그냥
  Color(0xFFFFF0D6),    // 3 좋아
  Color(0xFFFFE0E0),    // 4 설레
  Color(0xFFFFEAF2),    // 5 최고야
];

static const List<Color> moodBorderColors = [
  Colors.transparent,
  Color(0xFF8AAEE8),    // 1
  Color(0xFFA893D4),    // 2
  Color(0xFFF0B060),    // 3
  Color(0xFFF07878),    // 4
  Color(0xFFFF5A8A),    // 5
];

// 텍스트 이모지 제거 → RabbitMoodWidget으로 대체
// moodEmojis 리스트는 하위 호환용으로만 유지 (필터 칩 텍스트 등)
static const List<String> moodLabels = ['', '속상해', '그냥', '좋아', '설레', '최고야'];
```

---

## 3. 토끼 캐릭터 감정 위젯 스펙 (RabbitMoodWidget)

### 파일 위치
```
lib/src/core/widgets/rabbit_mood_widget.dart
```

### 위젯 인터페이스
```dart
class RabbitMoodWidget extends StatelessWidget {
  const RabbitMoodWidget({
    super.key,
    required this.moodScore,   // 1~5
    this.size = 48.0,          // 전체 크기 (정방형)
    this.showLabel = false,    // 라벨 텍스트 표시 여부
    this.isSelected = false,   // 선택 상태 (테두리 강조)
  });

  final int moodScore;
  final double size;
  final bool showLabel;
  final bool isSelected;
}
```

### CustomPainter 구조 — RabbitPainter

```dart
class RabbitPainter extends CustomPainter {
  const RabbitPainter({required this.moodScore});
  final int moodScore;

  @override
  void paint(Canvas canvas, Size size) {
    // 그리는 순서: 귀 → 몸통 → 얼굴 → 눈 → 코 → 입 → 볼터치 → 장식

    final cx = size.width / 2;
    final cy = size.height / 2;
    final r  = size.width * 0.38;   // 얼굴 반지름 기준

    _drawEars(canvas, size, cx, cy, r);
    _drawFace(canvas, size, cx, cy, r);
    _drawEyes(canvas, size, cx, cy, r, moodScore);
    _drawNose(canvas, size, cx, cy, r);
    _drawMouth(canvas, size, cx, cy, r, moodScore);
    _drawCheeks(canvas, size, cx, cy, r, moodScore);
    if (moodScore == 5) _drawHearts(canvas, size, cx, cy, r);
    if (moodScore == 1) _drawTears(canvas, size, cx, cy, r);
  }
}
```

### 얼굴별 상세 드로잉 스펙

#### 공통 — 몸통 & 얼굴
```
몸통(타원):
  center: (cx, cy + r * 0.55)
  radiusX: r * 0.70
  radiusY: r * 0.55
  fillColor: white (또는 #FFF8F8 크림화이트)

얼굴(원):
  center: (cx, cy)
  radius: r
  fillColor: white
  strokeColor: 각 감정 moodBorderColors[score], width: r * 0.05
```

#### 귀 (공통)
```
왼쪽 귀 (타원):
  center: (cx - r * 0.45, cy - r * 0.90)
  radiusX: r * 0.22
  radiusY: r * 0.42
  fillColor: white
  strokeColor: moodBorderColors[score], width: r * 0.05

왼쪽 귀 안쪽 (타원):
  center: (cx - r * 0.45, cy - r * 0.90)
  radiusX: r * 0.12
  radiusY: r * 0.28
  fillColor: moodColors[score].withAlpha(180)

오른쪽 귀: 좌우 대칭 (cx + r * 0.45 로 x 반전)

감정별 귀 변형:
  mood=1: 귀가 살짝 앞으로 쳐짐 → 귀 타원을 5도 기울임 (rotate)
  mood=5: 귀 끝에 작은 하트 장식 (r * 0.08 크기 Path)
```

#### 눈 (감정별)
```
눈 기준 위치: left=(cx - r*0.28, cy - r*0.08), right=(cx + r*0.28, cy - r*0.08)
눈 크기 반지름: eyeR = r * 0.10

mood=1 (슬픈 토끼):
  눈 모양: 아래로 굽은 반원 (Path arc, 하강)
  눈동자: 없음, strokeColor: moodBorderColors[1], strokeWidth: r*0.04
  눈썹: 양쪽 모두 내측 끝이 올라간 슬픈 눈썹 (Path)

mood=2 (무표정 토끼):
  눈 모양: 가로 직선 (길이 eyeR*2, strokeWidth: r*0.05)
  눈썹: 일자 수평

mood=3 (미소 토끼):
  눈 모양: 위로 굽은 반원 (호), 위아래 선 없는 초승달 눈
  strokeColor: textPrimary, strokeWidth: r*0.05

mood=4 (볼빨간 토끼):
  눈 모양: mood=3과 동일하나 살짝 더 큰 반원
  눈 내부: 작은 하이라이트 흰 점 (radius: r*0.03)

mood=5 (하트눈 토끼):
  눈 모양: 하트 Path (크기 r*0.22×r*0.20)
  하트 fillColor: moodBorderColors[5] (#FF5A8A)
  하이라이트: 흰 점 (r*0.04)
```

#### 코
```
공통:
  위치: (cx, cy + r * 0.12)
  모양: 작은 타원
  radiusX: r * 0.07
  radiusY: r * 0.045
  fillColor: moodBorderColors[score].withAlpha(200)
```

#### 입 (감정별)
```
입 기준 위치 y: cy + r * 0.28
입 너비 반경: mouthW = r * 0.22

mood=1 (슬픔):
  U자 뒤집힌 곡선 (아래로 처진 입)
  Path: moveTo(cx - mouthW, cy + r*0.28)
        quadraticBezierTo(cx, cy + r*0.18, cx + mouthW, cy + r*0.28)
  strokeColor: moodBorderColors[1], strokeWidth: r*0.045

mood=2 (무표정):
  가로 직선
  Path: moveTo(cx - mouthW*0.7, cy + r*0.28)
        lineTo(cx + mouthW*0.7, cy + r*0.28)
  strokeWidth: r*0.04

mood=3 (미소):
  완만한 U자 곡선
  Path: moveTo(cx - mouthW, cy + r*0.26)
        quadraticBezierTo(cx, cy + r*0.38, cx + mouthW, cy + r*0.26)
  strokeWidth: r*0.045

mood=4 (설레):
  mood=3보다 더 넓고 깊은 U자
  Path: moveTo(cx - mouthW*1.1, cy + r*0.24)
        quadraticBezierTo(cx, cy + r*0.42, cx + mouthW*1.1, cy + r*0.24)
  strokeWidth: r*0.05

mood=5 (최고야):
  활짝 웃는 입 (치아 표시)
  외곽 U자 Path (mood=4와 동일한 크기)
  내부 흰 타원 (치아): center=(cx, cy+r*0.32), radiusX=mouthW*0.85, radiusY=r*0.09
  strokeColor: moodBorderColors[5], strokeWidth: r*0.05
```

#### 볼터치 (mood 3~5)
```
mood=3:
  양쪽 원형 볼 (opacity 0.35)
  위치: left=(cx - r*0.50, cy + r*0.18), right=(cx + r*0.50, cy + r*0.18)
  radius: r * 0.14
  fillColor: Color(0xFFFFCCAA) // 복숭아빛

mood=4:
  radius: r * 0.16 (더 크게)
  fillColor: Color(0xFFFFAAB0) // 핑크빛 볼

mood=5:
  radius: r * 0.18
  fillColor: Color(0xFFFF90A8) // 진핑크 볼
  + 볼 안에 작은 별 모양 장식 (흰색, Path star r*0.05)
```

#### 특수 장식

```
mood=1 눈물:
  위치: 왼쪽 눈 아래
  Path: moveTo(cx - r*0.28, cy + r*0.05)
        cubicTo(cx - r*0.34, cy + r*0.15, cx - r*0.22, cy + r*0.20, cx - r*0.28, cy + r*0.05)
  fillColor: Color(0xFF8AAEE8).withAlpha(180)

mood=5 하트 장식:
  2개의 작은 하트, 얼굴 양 사이드 상단
  위치: left=(cx - r*1.05, cy - r*0.55), right=(cx + r*1.05, cy - r*0.55)
  크기: r * 0.18
  fillColor: Color(0xFFFF5A8A).withAlpha(200)
```

### 감정 선택 UI (_MoodSelector 교체)

```dart
// 기존 _MoodSelector → RabbitMoodSelector 로 교체

class RabbitMoodSelector extends StatelessWidget {
  const RabbitMoodSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(5, (i) {
        final mood = i + 1;
        final isSelected = selected == mood;
        final bgColor = AppConstants.moodColors[mood];
        final borderColor = AppConstants.moodBorderColors[mood];

        return GestureDetector(
          onTap: () => onChanged(mood),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            width: isSelected ? 64 : 58,
            height: isSelected ? 80 : 72,
            decoration: BoxDecoration(
              color: isSelected ? bgColor : AppConstants.surface,
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              border: Border.all(
                color: isSelected ? borderColor : Colors.transparent,
                width: 1.8,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RabbitMoodWidget(
                  moodScore: mood,
                  size: isSelected ? 44 : 36,
                  isSelected: isSelected,
                ),
                const SizedBox(height: 5),
                Text(
                  AppConstants.moodLabels[mood],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                    color: isSelected ? borderColor : AppConstants.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
```

---

## 4. 화면별 UI 개선 스펙 (v2.0)

### 4-1. 로그인 화면

**현재 문제점**
- 로고가 단순 컬러 원 + 이모지 조합
- 하단 여백 구성이 단조로움
- `DayStory` 타이포가 충분히 브랜딩되지 않음

**개선안**
```dart
// 전체 배경: surfaceWarm(#FFF8F5) — 크림 화이트
// 상단 60% 영역 (로고 섹션)

// 1. 로고 컨테이너 교체
Container(
  width: 108,
  height: 108,
  decoration: BoxDecoration(
    color: AppConstants.pinkLight,          // #FFEAF2
    shape: BoxShape.circle,
    border: Border.all(color: AppConstants.pinkMid, width: 3),
  ),
  child: Center(
    child: RabbitMoodWidget(               // mood=5 하트눈 토끼
      moodScore: 5,
      size: 64,
    ),
  ),
),
SizedBox(height: 20),

// 2. 앱명 타이포
Text(
  'DayStory',
  style: TextStyle(
    fontSize: 38,
    fontWeight: FontWeight.w800,
    color: AppConstants.textPrimary,
    letterSpacing: -1.5,
    height: 1.0,
  ),
),
SizedBox(height: 6),

// 3. 슬로건 — 하트 아이콘 인라인 포함
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Icon(Icons.favorite_rounded, size: 13, color: AppConstants.pink),
    SizedBox(width: 5),
    Text(
      '우리만의 데이트 기록장',
      style: TextStyle(fontSize: 15, color: AppConstants.textSecondary, fontWeight: FontWeight.w400),
    ),
    SizedBox(width: 5),
    Icon(Icons.favorite_rounded, size: 13, color: AppConstants.pink),
  ],
),

// 하단 40% 영역 (로그인 버튼)
// 버튼 상단에 미세 안내 텍스트 추가
Padding(
  padding: EdgeInsets.only(bottom: 10),
  child: Text(
    '3초 만에 시작하세요',
    style: TextStyle(fontSize: 12, color: AppConstants.textHint),
  ),
),
// 카카오 버튼 — 기존 유지, 하단 법적 안내 추가
SizedBox(height: 16),
Text(
  '개인정보처리방침  ·  이용약관',
  style: TextStyle(fontSize: 11, color: AppConstants.textHint),
)
```

---

### 4-2. 캘린더 화면

**현재 문제점**
- 헤더 타이틀이 과하게 큰 w800 텍스트, 전체 무게 불균형
- 캘린더 감정 dot이 단색, RabbitMoodWidget으로 교체 검토
- 로그 카드 좌측 이모지 썸네일이 텍스트 이모지라 크기 제어 불가

**개선안**
```dart
// 헤더: 앱명 → 달력 아이콘 + 현재 월로 교체
Row(
  children: [
    // 로고 작은 버전 (20px 토끼) + 앱명
    RabbitMoodWidget(moodScore: 5, size: 20),
    SizedBox(width: 8),
    Text('DayStory', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppConstants.textPrimary)),
    Spacer(),
    // 통계 아이콘 추가 (stats 페이지 이동용)
    IconButton(icon: Icon(Icons.bar_chart_rounded), ...),
    Stack(children: [ IconButton(icon: Icon(Icons.tune_rounded)), ... ]),
  ],
),

// 캘린더 감정 마커: 기존 dot → 미니 RabbitMoodWidget
// markerBuilder에서 CustomPainter로 미니 토끼 그리기
// 단, 성능을 위해 16px 이하는 dot 유지 (zoom 상태와 무관, 항상 8px dot)
// → dot 컬러만 moodBorderColors로 교체

// 로그 카드 (_LogCard) 감정 블록 교체
// 사진 없을 때: moodColor 배경 + RabbitMoodWidget(size: 32)
Container(
  width: 60,
  height: 60,
  color: moodColor,
  child: Center(
    child: RabbitMoodWidget(moodScore: log.moodScore, size: 34),
  ),
),

// 카드 radius 변경: radiusL(16) → radiusXL(24) — 더 부드럽게
// 카드 border 제거, 대신 surfaceWarm 배경에서 흰 카드로 미세 대비

// EmptyState 토끼 추가
Column(
  children: [
    RabbitMoodWidget(moodScore: 3, size: 56),
    SizedBox(height: 12),
    Text('이 날의 기록이 없어요', style: ...),
    SizedBox(height: 4),
    Text('기록 탭에서 추가해보세요', style: ...),
  ],
),

// 필터 바텀시트 감정 필터 칩: 이모지 텍스트 → 미니 토끼
// _FilterChip label에서 moodEmojis 제거,
// leading: RabbitMoodWidget(moodScore: m, size: 18) 추가
```

---

### 4-3. 기록 작성 화면

**현재 문제점**
- `_SectionLabel` 스타일이 textSecondary 단색, 섹션 구분이 약함
- `_MoodSelector`가 텍스트 이모지 기반
- 저장 버튼 영역이 화면 하단에 밀려있어 스크롤 UX 불편
- 전체 배경이 white, 필드와 구분이 잘 안됨

**개선안**
```dart
// 화면 배경: surfaceWarm (#FFF8F5) 로 변경
// 각 폼 그룹을 흰 카드 컨테이너로 묶기

// SectionLabel 개선
class _SectionLabel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(width: 3, height: 14, decoration: BoxDecoration(color: AppConstants.pink, borderRadius: BorderRadius.circular(2))),
          SizedBox(width: 7),
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppConstants.textPrimary)),
        ],
      ),
    );
  }
}

// 폼 카드 그루핑: 관련 필드들을 Container로 묶기
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(AppConstants.radiusL),
    border: Border.all(color: AppConstants.border),
  ),
  child: Column(children: [
    // 제목 필드
    // 구분선
    Divider(height: 1, color: AppConstants.divider),
    // 장소 필드
  ]),
),

// 감정 선택 → RabbitMoodSelector 교체 (섹션 3 참조)

// 저장 버튼: 최하단 고정 + 위 그라디언트 처리
// Scaffold body를 Stack으로 변경
Stack(
  children: [
    SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 100),  // 하단 여백 100
      child: Form(...),
    ),
    Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x00FFF8F5), AppConstants.surfaceWarm],
            stops: [0.0, 0.35],
          ),
        ),
        padding: EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: FilledButton(onPressed: _submit, child: Text('기록 저장하기')),
      ),
    ),
  ],
),
```

---

### 4-4. 지도 화면

**현재 문제점**
- 마커 내부 이모지가 OS별 렌더링 불일치
- 지도 헤더 overlay가 너무 단순
- 마커 말풍선 꼬리(TailPainter)가 직선 삼각형이라 날카로움
- 바텀시트 감정 이모지 표시

**개선안**
```dart
// 마커 내부 감정 표현: 이모지 → RabbitMoodWidget
// _EmojiContent 교체
class _RabbitContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppConstants.moodColors[mood.clamp(1,5)].withAlpha(80),
      child: Center(
        child: RabbitMoodWidget(moodScore: mood, size: 34),
      ),
    );
  }
}

// 말풍선 꼬리: 직삼각형 → 둥근 꼬리로 교체
class _TailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(size.width * 0.2, 0)
      ..quadraticBezierTo(size.width * 0.5, size.height, size.width * 0.5, size.height)
      ..quadraticBezierTo(size.width * 0.5, size.height, size.width * 0.8, 0)
      ..close();
    canvas.drawPath(path, paint);
  }
}

// 헤더 overlay 개선: 지도 타이틀 필 + 기록 수 배지
Container(
  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(AppConstants.radiusXL),
    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 2))],
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.map_rounded, size: 16, color: AppConstants.pink),
      SizedBox(width: 6),
      Text('지도', style: ...),
      if (logs.isNotEmpty) ...[
        SizedBox(width: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(color: AppConstants.pinkLight, borderRadius: BorderRadius.circular(10)),
          child: Text('${logs.length}', style: TextStyle(fontSize: 11, color: AppConstants.pink, fontWeight: FontWeight.w700)),
        ),
      ],
    ],
  ),
),

// 바텀시트 감정 표시: 이모지 → RabbitMoodWidget(size: 36)
// 상단 핸들 바 색상: border → pinkMid (#FFCEDF) 로 부드럽게
```

---

### 4-5. 통계 화면

**현재 문제점**
- `_HeroCard`의 이모지가 텍스트 이모지
- 감정 분포 그래프가 단순 LinearProgressIndicator
- 통계 섹션 구분이 명확하지 않음
- 월별 그래프 bar 색상이 pinkLight 단색

**개선안**
```dart
// _HeroCard 이모지 교체
// emoji: String → 아이콘 or RabbitMoodWidget
// 평균 감정 카드: emoji 파라미터 대신 moodScore 파라미터 추가
class _HeroCard extends StatelessWidget {
  const _HeroCard({
    this.iconData,       // 일반 통계 아이콘
    this.moodScore,      // 감정 카드 전용
    required this.label,
    required this.value,
    this.wide = false,
    this.accentColor,    // 카드 좌측 포인트 컬러
  });
}

// 총 데이트 카드: Icons.calendar_heart_outline → 핑크 아이콘
// 총 비용 카드: Icons.payments_outlined → 피치 아이콘

// 감정 분포: LinearProgressIndicator → 커스텀 바
// 왼쪽: RabbitMoodWidget(size: 22) + 라벨
// 바: ClipRRect + AnimatedContainer(width: ratio * maxWidth)
// 바 색상: moodBorderColors[mood] 그라디언트
Row(
  children: [
    RabbitMoodWidget(moodScore: mood, size: 22),
    SizedBox(width: 6),
    SizedBox(
      width: 28,
      child: Text(moodLabels[mood], style: TextStyle(fontSize: 10, color: textSecondary)),
    ),
    SizedBox(width: 6),
    Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              height: 10,
              color: moodBorderColors[mood].withAlpha(200),
              // 전체 배경은 surface
            ),
          );
        },
      ),
    ),
    SizedBox(width: 8),
    SizedBox(width: 24, child: Text('$count', textAlign: TextAlign.right, style: ...)),
  ],
),

// 월별 그래프 바 색상: pinkLight → 그라디언트 (pinkLight → pink)
// 바 height: 8 → 10 으로 약간 두껍게
// 섹션 헤더에 구분선 포인트 추가 (SectionLabel과 동일한 스타일)

// EmptyStats 교체
Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    RabbitMoodWidget(moodScore: 3, size: 64),
    SizedBox(height: 12),
    Text('아직 기록이 없어요', ...),
    SizedBox(height: 4),
    Text('데이트를 기록하면 통계가 나타나요', ...),
  ],
),
```

---

### 4-6. 마이페이지

**현재 문제점**
- 프로필 아바타 fallback이 `💕` 텍스트 이모지
- `_StatBox` 이모지가 텍스트 이모지
- 파트너 섹션 카드가 단순 border 박스

**개선안**
```dart
// 프로필 아바타 fallback: 이모지 → RabbitMoodWidget(moodScore: 5, size: 36)
class _ProfileAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,  // 60 → 64 크기업
      height: 64,
      decoration: BoxDecoration(
        color: AppConstants.pinkLight,
        shape: BoxShape.circle,
        border: Border.all(color: AppConstants.pink, width: 2.5),
      ),
      child: ClipOval(
        child: imageUrl != null
            ? CachedNetworkImage(imageUrl: imageUrl!, fit: BoxFit.cover, ...)
            : Center(child: RabbitMoodWidget(moodScore: 5, size: 40)),
      ),
    );
  }
}

// StatBox 이모지 교체
// 총 데이트: emoji '📅' → Icon(Icons.event_rounded, color: pink)
// 총 비용: emoji '💸' → Icon(Icons.account_balance_wallet_outlined, color: peach)
// 평균 감정: 평균 moodScore 기준 RabbitMoodWidget
// 자주 간 곳: Icon(Icons.location_on_rounded, color: coral)

// 파트너 섹션 카드 디자인 강화
Container(
  padding: EdgeInsets.all(18),
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AppConstants.pinkLight, Colors.white],
    ),
    borderRadius: BorderRadius.circular(AppConstants.radiusL),
    border: Border.all(color: AppConstants.pinkMid),
  ),
  child: ...,
),

// 프로필 카드 배경: surface → 핑크 그라디언트 카드
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AppConstants.surfaceWarm, AppConstants.pinkLight],
    ),
    borderRadius: BorderRadius.circular(AppConstants.radiusXL),
  ),
),

// D+일수 표시 개선: 'D+120일째' → '함께한 지 120일'
// 글자에 heart 아이콘 인라인 추가
Row(
  children: [
    Icon(Icons.favorite_rounded, size: 12, color: AppConstants.pink),
    SizedBox(width: 3),
    Text('함께한 지 ${days}일', style: TextStyle(fontSize: 12, color: AppConstants.pink, fontWeight: FontWeight.w600)),
  ],
),
```

---

### 4-7. 기록 상세 화면 (DetailScreen)

**현재 문제점**
- 히어로 섹션에 이모지 48px 텍스트
- `_InfoSection` border 스타일이 무겁게 느껴짐

**개선안**
```dart
// 히어로 섹션 감정 표현
Row(
  children: [
    Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(180),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: RabbitMoodWidget(moodScore: log.moodScore, size: 52),
    ),
    SizedBox(width: 16),
    Expanded(child: Column(...)),
  ],
),

// _InfoSection: border 제거 → 배경 surface + 더 큰 radius
Container(
  decoration: BoxDecoration(
    color: AppConstants.surface,
    borderRadius: BorderRadius.circular(AppConstants.radiusL),
  ),
),

// 태그 칩: pinkLight 배경 유지, 폰트 크기 12 → 13
// 상단 이미지 슬라이더 height: 220 → 240 (더 여유있게)
// 페이지 인디케이터 추가 (dots_indicator 패키지 or 직접 구현)
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: List.generate(log.photos.length, (i) => Container(
    margin: EdgeInsets.symmetric(horizontal: 3),
    width: currentPage == i ? 16 : 6,
    height: 6,
    decoration: BoxDecoration(
      color: currentPage == i ? AppConstants.pink : AppConstants.pinkLight,
      borderRadius: BorderRadius.circular(3),
    ),
  )),
),
```

---

## 5. 디자인 토큰 변경 요약 (v1.0 → v2.0)

| 토큰 | v1.0 | v2.0 | 이유 |
|------|------|------|------|
| `pink` | `#FF4D8D` | `#FF5A8A` | 형광 줄이기, 로즈핑크로 조정 |
| `pinkLight` | `#FFE4EF` | `#FFEAF2` | 더 밝고 투명하게 |
| `pinkMid` | 없음 | `#FFCEDF` | 선택 상태 중간 톤 추가 |
| `surface` | `#F6F6F9` | `#F8F5F2` | 쿨그레이→크림베이지 웜톤으로 |
| `surfaceWarm` | 없음 | `#FFF8F5` | 로그인·히어로용 따뜻한 배경 |
| `textPrimary` | `#1A1A1A` | `#1E1A1D` | 따뜻한 블랙 |
| `textSecondary` | `#8A8A9A` | `#9A8E96` | 따뜻한 그레이 |
| `textHint` | 없음 | `#BFB5BB` | placeholder 전용 추가 |
| `coral` | 없음 | `#FF7B6B` | 보조 포인트 추가 |
| `peach` | 없음 | `#FFB08A` | 웜 포인트 추가 |
| `moodColors[4]` | `#BBF7D0` (그린) | `#FFE0E0` (코랄핑크) | 전체 핑크 계열 통일 |
| `moodBorderColors` | 없음 | 5종 추가 | 토끼 캐릭터 테두리·포인트용 |
| `moodEmojis` | 텍스트 이모지 | `RabbitMoodWidget` 교체 | OS 의존성 제거, 브랜드 아이덴티티 |

---

## 6. 적용 우선순위 (claude-code-writer 구현 순서)

### Phase A — 핵심 (즉시 구현)
1. `lib/src/core/widgets/rabbit_mood_widget.dart` 신규 생성
   - `RabbitPainter` CustomPainter (5단계 표정)
   - `RabbitMoodWidget` StatelessWidget 래퍼
2. `lib/src/core/constants/app_constants.dart` 토큰 업데이트
   - 신규 색상 추가 (`pinkMid`, `surfaceWarm`, `textHint`, `coral`, `peach`)
   - `moodColors` 배열 교체
   - `moodBorderColors` 배열 추가
   - `moodLabels` 텍스트 교체
3. `lib/src/core/theme/app_theme.dart` 컬러 교체
   - `_pink`, `_surface` 등 내부 상수 v2.0으로 갱신

### Phase B — 화면 적용 (Phase A 완료 후)
4. `lib/src/features/add/add_log_screen.dart`
   - `_MoodSelector` → `RabbitMoodSelector`로 교체
   - 배경색, 섹션 라벨, 폼 카드 그루핑, 저장 버튼 고정
5. `lib/src/features/calendar/calendar_screen.dart`
   - `_LogCard` 감정 블록 교체
   - `_EmptyState` 토끼 삽입
   - 헤더 개선
6. `lib/src/features/map/map_screen.dart`
   - `_EmojiContent` → `_RabbitContent` 교체
   - `_TailPainter` 개선
   - 헤더 overlay 개선
7. `lib/src/features/stats/stats_screen.dart`
   - `_HeroCard` 아이콘/토끼 교체
   - `_MoodDistribution` 바 교체
   - EmptyStats 토끼 교체
8. `lib/src/features/mypage/mypage_screen.dart`
   - `_ProfileAvatar` fallback 교체
   - `_StatBox` 아이콘 교체
   - 파트너 카드 그라디언트
9. `lib/src/features/auth/login_screen.dart`
   - 로고 컨테이너 교체 (토끼 삽입)
   - 배경색, 슬로건 레이아웃 개선
10. `lib/src/features/detail/detail_screen.dart`
    - 히어로 감정 표현 교체
    - `_InfoSection` 스타일 개선
    - 이미지 인디케이터 추가

---

## 7. 기존 스펙 유지 항목

- Material 3 기반, `useMaterial3: true`
- `ColorScheme.fromSeed(seedColor: pink)`
- spacing 상수 (XS/S/M/L/XL)
- radius 상수 (S/M/L/XL)
- `InputDecorationTheme` 기본 구조 (filled, borderRadius, focusBorder)
- `FilledButton`, `NavigationBarTheme`, `CardTheme` 기본 구조
- 화면 구조 (탭 4개, DateLog/DatePlace 모델)
- 카카오 로그인 플로우
- `table_calendar` 기반 캘린더
- `flutter_map` OSM 기반 지도

---

## 8. 에이전트 협업 참고

| 에이전트 | 담당 |
|----------|------|
| `design` | 이 문서 유지, 색상/컴포넌트 스펙 변경 시 업데이트 |
| `claude-code-writer` | Phase A → B 순서대로 구현 (섹션 6 참조) |
| `evaluator` | RabbitPainter 5단계 렌더링 검증, 색상 대비율 확인 |
