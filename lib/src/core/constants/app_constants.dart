import 'package:flutter/material.dart';

class AppConstants {
  static const double defaultLatitude = 37.5665;
  static const double defaultLongitude = 126.9780;
  static const double defaultMapZoom = 11.0;

  static const int minMoodScore = 1;
  static const int maxMoodScore = 5;

  static const String osmTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String userAgentPackage = 'com.example.date_app';

  // ── Spacing ──────────────────────────────────────────────────────────────
  static const double spaceXS = 4.0;
  static const double spaceS  = 8.0;
  static const double spaceM  = 16.0;
  static const double spaceL  = 24.0;
  static const double spaceXL = 32.0;

  // ── Border radius ─────────────────────────────────────────────────────────
  static const double radiusS  = 8.0;
  static const double radiusM  = 12.0;
  static const double radiusL  = 16.0;
  static const double radiusXL = 24.0;

  // ── Colors (v2.0 — 웜톤 핑크 팔레트) ──────────────────────────────────────

  // 포인트
  static const Color pink       = Color(0xFFFF5A8A); // 로즈핑크 (기존 #FF4D8D 보정)
  static const Color pinkLight  = Color(0xFFFFEAF2); // 연핑크 배경 (기존 #FFE4EF 보정)
  static const Color pinkMid    = Color(0xFFFFCEDF); // 중간톤 (선택 상태, 파트너 카드 테두리)
  static const Color coral      = Color(0xFFFF7B6B); // 보조 포인트 (위치 아이콘 등)
  static const Color peach      = Color(0xFFFFB08A); // 웜 포인트 (비용 아이콘 등)

  // 배경 / 서피스
  static const Color surface      = Color(0xFFF8F5F2); // 크림베이지 (기존 #F6F6F9 웜톤으로)
  static const Color surfaceWarm  = Color(0xFFFFF8F5); // 더 따뜻한 화이트 (로그인, 기록 화면 배경)

  // 텍스트
  static const Color textPrimary   = Color(0xFF1E1A1D); // 따뜻한 블랙 (기존 #1A1A1A)
  static const Color textSecondary = Color(0xFF9A8E96); // 따뜻한 그레이 (기존 #8A8A9A)
  static const Color textHint      = Color(0xFFBFB5BB); // placeholder, 비활성 텍스트

  // 경계 / 구분
  static const Color border  = Color(0xFFEDEAEC); // 기존 #EEEEEF2 보정
  static const Color divider = Color(0xFFF2EEF0); // 더 옅은 구분선

  // ── Mood 색상 시스템 (v2.0 — 핑크 계열 통일) ─────────────────────────────

  /// 감정 배경색 (카드 블록, 바텀시트 썸네일 배경 등)
  static const List<Color> moodColors = [
    Colors.transparent, // 0 미사용
    Color(0xFFDCE8FB),  // 1 속상해 — 차분한 블루
    Color(0xFFEDE8F5),  // 2 그냥   — 연보라
    Color(0xFFFFF0D6),  // 3 좋아   — 따뜻한 옐로우
    Color(0xFFFFE0E0),  // 4 설레   — 코랄 핑크 (기존 #BBF7D0 그린 → 핑크 계열 통일)
    Color(0xFFFFEAF2),  // 5 최고야 — 핑크 로즈
  ];

  /// 감정 테두리/포인트색 (토끼 캐릭터 윤곽선, 마커 테두리, 선택 Border 등)
  static const List<Color> moodBorderColors = [
    Colors.transparent, // 0 미사용
    Color(0xFF8AAEE8),  // 1 속상해
    Color(0xFFA893D4),  // 2 그냥
    Color(0xFFF0B060),  // 3 좋아
    Color(0xFFF07878),  // 4 설레
    Color(0xFFFF5A8A),  // 5 최고야
  ];

  /// 감정 라벨 (v2.0 — 자연어 표현으로 교체)
  static const List<String> moodLabels = [
    '',
    '속상해', // 1
    '그냥',   // 2
    '좋아',   // 3
    '설레',   // 4
    '최고야', // 5
  ];

  // 하위 호환: moodEmojis는 필터 칩 텍스트 등 이모지가 꼭 필요한 곳에만 유지
  // 실제 감정 표현 UI는 RabbitMoodWidget으로 교체
  static const List<String> moodEmojis = ['', ':(', ':|', ':)', ':D', 'X)'];

  // ── 카테고리 (태그 기반) ─────────────────────────────────────────────────────
  static const List<String> categoryList = [
    '카페', '맛집', '산책', '영화', '드라이브',
    '쇼핑', '공원', '야외', '전시', '운동',
    '여행', '홈데이트', '야경', '스포츠', '뮤지컬',
  ];

  static const Map<String, String> categoryEmojis = {
    '카페': '☕',
    '맛집': '🍜',
    '산책': '🚶',
    '영화': '🎬',
    '드라이브': '🚗',
    '쇼핑': '🛍️',
    '공원': '🌳',
    '야외': '🌿',
    '전시': '🎨',
    '운동': '🏃',
    '여행': '✈️',
    '홈데이트': '🏠',
    '야경': '🌃',
    '스포츠': '⚽',
    '뮤지컬': '🎭',
  };

  // ── 지도 마커 색상 (카테고리별) ────────────────────────────────────────────
  // 각 항목: [bgColor(파스텔), borderColor(채도 높음)]

  /// 카테고리별 마커 bg/border 색상 쌍
  static const Map<String, List<Color>> categoryMarkerColors = {
    // 핑크/로즈 계열
    '카페':     [Color(0xFFFFE0EC), Color(0xFFFF5A8A)], // 앱 pink 포인트
    '뮤지컬':   [Color(0xFFFFD6E7), Color(0xFFE8387A)], // 딥로즈
    '홈데이트': [Color(0xFFFFE8F2), Color(0xFFFF7DAE)], // 라이트로즈

    // 코랄/레드 계열
    '맛집':     [Color(0xFFFFDDD8), Color(0xFFFF7B6B)], // 앱 coral 토큰
    '영화':     [Color(0xFFFFCFC8), Color(0xFFEE5A4A)], // 딥코랄

    // 피치/오렌지 계열
    '드라이브': [Color(0xFFFFE5CC), Color(0xFFFFB08A)], // 앱 peach 토큰
    '야경':     [Color(0xFFFFD8B0), Color(0xFFEE9055)], // 딥오렌지

    // 옐로우/골드 계열
    '공원':     [Color(0xFFFFF2CC), Color(0xFFE8B830)], // 골드옐로우
    '산책':     [Color(0xFFFFF8DC), Color(0xFFD4A820)], // 라이트골드

    // 그린/민트 계열
    '야외':     [Color(0xFFD6F0E0), Color(0xFF4EBB7A)], // 민트그린
    '운동':     [Color(0xFFCCEBDA), Color(0xFF38A862)], // 딥그린

    // 블루/스카이 계열
    '여행':     [Color(0xFFD6E8FB), Color(0xFF5090DC)], // 스카이블루
    '스포츠':   [Color(0xFFCCDFF8), Color(0xFF3570C8)], // 딥블루

    // 라벤더/퍼플 계열
    '쇼핑':     [Color(0xFFEDE0F8), Color(0xFFAA72DC)], // 라벤더
    '전시':     [Color(0xFFE4D5F5), Color(0xFF9258CC)], // 딥퍼플
  };

  // ── 클러스터 마커 상수 ──────────────────────────────────────────────────────

  /// 클러스터 버블 배경 (앱 포인트 컬러 — 군집 즉시 인식)
  static const Color clusterBg         = Color(0xFFFF5A8A);

  /// 클러스터 테두리 (지도 배경과 분리)
  static const Color clusterBorder     = Color(0xFFFFFFFF);

  /// 클러스터 기본 크기 (count ≤ 10)
  static const double clusterSize      = 48.0;

  /// 클러스터 확장 크기 (count > 10, 세 자리 숫자 대응)
  static const double clusterSizeLarge = 56.0;

  /// 클러스터 테두리 두께
  static const double clusterBorderWidth = 2.5;

  /// 클러스터 숫자 폰트 크기
  static const double clusterFontSize  = 15.0;
  // boxShadow: Color(0x33FF5A8A), blurRadius 8, offset Offset(0, 2)
}
