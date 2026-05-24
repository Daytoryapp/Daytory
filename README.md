<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:FF6B9D,50:C44569,100:6C5CE7&height=240&section=header&text=Daytory&fontSize=80&fontColor=ffffff&fontAlignY=38&desc=캘린더와%20지도로%20기록하는%20우리의%20데이트%20💕&descSize=18&descAlignY=62" />

<br/>

<p>
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
  <img src="https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white" />
  <img src="https://img.shields.io/badge/Status-Phase%203%20In%20Progress-FF6B9D?style=for-the-badge" />
</p>

<p>
  <img src="https://img.shields.io/github/stars/Daytoryapp/Daytory?style=flat-square&color=FF6B9D" />
  <img src="https://img.shields.io/github/last-commit/Daytoryapp/Daytory?style=flat-square&color=6C5CE7" />
  <img src="https://img.shields.io/github/languages/top/Daytoryapp/Daytory?style=flat-square&color=02569B" />
</p>

</div>

<br/>

## 💝 About Daytory

**Daytory**는 *Date* + *History* 의 합성어로,  
**캘린더(시간 축)** 와 **지도(장소 축)** 를 동등한 홈 탭으로 제공하는 데이트 로그 앱입니다.

> 언제, 어디서, 무엇을 했는지 — 우리만의 기록을 한 곳에 ✨

<br/>

## 🎯 Core Features

| 기능 | 설명 |
| :--- | :--- |
| 🔐 **인증** | 카카오 소셜 로그인 + Supabase Auth |
| 💑 **커플 연동** | 커플 코드 생성 및 파트너 연결 |
| 📝 **기록 CRUD** | 제목, 장소, 좌표, 메모, 태그, 비용, 감정 점수, 사진 저장/수정/삭제 |
| 📅 **캘린더 탐색** | 기록 날짜 인디케이터 + 선택 날짜 리스트 |
| 🗺️ **지도 탐색** | 마커 클러스터링 + 바텀시트 미리보기 + 상세 이동 |
| 🔍 **필터링** | 태그 / 감정 기준으로 기록 필터 |
| 📊 **통계** | 총 횟수, 총 비용, 평균 감정, 월별 횟수 분석 |
| 👤 **마이페이지** | 프로필 관리 및 설정 |

<br/>

## 🛠️ Tech Stack

#### Framework & Language
<p>
  <img src="https://img.shields.io/badge/Flutter-02569B?style=flat-square&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=flat-square&logo=dart&logoColor=white" />
</p>

#### Backend & Auth
<p>
  <img src="https://img.shields.io/badge/Supabase-3ECF8E?style=flat-square&logo=supabase&logoColor=white" />
  <img src="https://img.shields.io/badge/Kakao_SDK-FFCD00?style=flat-square&logo=kakao&logoColor=black" />
</p>

#### Core Packages
<p>
  <img src="https://img.shields.io/badge/flutter__riverpod-State%20Mgmt-02569B?style=flat-square&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/hive-Local%20DB-FF6B9D?style=flat-square" />
  <img src="https://img.shields.io/badge/table__calendar-Calendar%20UI-FF6B9D?style=flat-square" />
  <img src="https://img.shields.io/badge/flutter__map-Map%20UI-7CB342?style=flat-square" />
  <img src="https://img.shields.io/badge/image__picker-사진-FF9800?style=flat-square" />
  <img src="https://img.shields.io/badge/geolocator-위치-009688?style=flat-square" />
  <img src="https://img.shields.io/badge/intl-Format-009688?style=flat-square" />
  <img src="https://img.shields.io/badge/uuid-ID-FF9800?style=flat-square" />
</p>

#### Platforms
<p>
  <img src="https://img.shields.io/badge/iOS-000000?style=flat-square&logo=apple&logoColor=white" />
  <img src="https://img.shields.io/badge/Android-3DDC84?style=flat-square&logo=android&logoColor=white" />
</p>

> 지도 타일은 **OpenStreetMap**을 사용합니다.

<br/>

## 📁 Folder Structure

```
lib/src/
├── 📦 models/         # 도메인 모델 (Entry, Tag, Emotion 등)
├── 💾 data/           # 리포지토리 (CRUD)
├── 🔄 state/          # 전역 상태 + 필터 상태 (Riverpod)
└── 🎨 features/       # 화면 단위 기능
    ├── auth/         # 로그인 / 인증
    ├── couple/       # 커플 연동
    ├── calendar/     # 캘린더 탭
    ├── map/          # 지도 탭
    ├── add/          # 기록 추가
    ├── detail/       # 기록 상세
    ├── stats/        # 통계
    └── mypage/       # 마이페이지
```

<br/>

## 🚀 Getting Started

#### 1. Repository 클론
```bash
git clone https://github.com/Daytoryapp/Daytory.git
cd Daytory
```

#### 2. 환경 변수 설정
```bash
cp .env.example .env
# .env 파일을 편집하여 Supabase URL, Kakao API 키 등 입력
```

#### 3. 의존성 설치
```bash
flutter pub get
```

#### 4. 앱 실행
```bash
flutter run
```

<br/>

## ✅ Roadmap

#### Phase 1 — MVP `완료`
- [x] 데이터 모델 / 저장소 / CRUD 기본 흐름 구성
- [x] 기록 작성 / 상세 화면 구현
- [x] 캘린더 탭 구현
- [x] 지도 탭 구현
- [x] 필터 / 통계 화면 구현

#### Phase 2 — 인프라 & 소셜 `완료`
- [x] PR 자동 생성 워크플로우
- [x] Supabase 백엔드 연동
- [x] 카카오 소셜 로그인
- [x] 커플 연동 (코드 기반 파트너 연결)
- [x] Hive 로컬 DB 연동
- [x] 사진 선택 (`image_picker`) 및 저장
- [x] 지도 마커 클러스터링

#### Phase 3 — 확장 `진행 중`
- [ ] 지도에서 카테고리별 마커 표시 (DB 스키마 수정 필요)
- [ ] DB 설계 고도화
- [ ] 솔로 / 커플 / 가족 단위로 사용 모드 확장

#### Future — 추가 확장 아이디어
- [ ] 동선 기록 (복수 장소) 모델 확장
- [ ] 지도 검색 강화
- [ ] 푸시 알림 (기념일, 리마인더)

<br/>

## 🤝 Contributing

기여는 언제나 환영합니다! 다음 절차를 따라주세요.

```bash
1. Fork the repository
2. Create your feature branch (git checkout -b feature/AmazingFeature)
3. Commit your changes (git commit -m 'Add some AmazingFeature')
4. Push to the branch (git push origin feature/AmazingFeature)
5. Open a Pull Request
```

<br/>

## 📄 License

<div>개발자: 정재민</div>
<div>contact 🏹: wjdwoals000619@gmail.com</div>

<br/>

<div align="center">

---

<sub>Made with 💕 by **Daytory Team** · 우리의 모든 순간을 기록하다.</sub>

<br/>

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:6C5CE7,50:C44569,100:FF6B9D&height=100&section=footer" />

</div>
