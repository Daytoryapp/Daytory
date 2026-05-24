// ⚠️  이 파일은 flutterfire configure 실행 후 자동으로 교체됩니다.
//
// 설정 순서:
//   1. Firebase Console(https://console.firebase.google.com)에서 프로젝트 생성
//   2. Android/iOS 앱 등록 (패키지명: com.example.date_app)
//   3. 터미널에서 실행:
//        dart pub global activate flutterfire_cli
//        flutterfire configure
//   4. 생성된 firebase_options.dart, google-services.json, GoogleService-Info.plist 확인
//
// 아래 플레이스홀더는 빌드 에러를 방지하기 위한 임시 코드입니다.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    throw UnsupportedError(
      'flutterfire configure를 먼저 실행하세요. '
      'lib/firebase_options.dart가 자동 생성됩니다.',
    );
  }
}
