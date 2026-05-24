import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FcmService {
  static final _messaging = FirebaseMessaging.instance;
  static final _localNotifications = FlutterLocalNotificationsPlugin();
  static StreamSubscription<String>? _tokenRefreshSub;

  static const _channelId = 'daytory_channel';
  static const _channelName = 'Daytory 알림';

  static Future<void> initialize() async {
    // 권한 요청 — 거부 시 이후 모든 FCM 처리 중단
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    // Android 포그라운드 알림 채널 생성
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      importance: Importance.high,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    // flutter_local_notifications 초기화 (포그라운드 알림 표시용)
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    await _localNotifications.initialize(
      const InitializationSettings(
          android: androidSettings, iOS: iosSettings),
    );

    // 포그라운드 메시지 수신 시 로컬 알림으로 표시
    FirebaseMessaging.onMessage.listen(_showLocalNotification);

    // iOS 포그라운드에서도 알림 배너 표시
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// 로그인 후 FCM 토큰을 Supabase users 테이블에 저장.
  static Future<void> saveToken(String kakaoId) async {
    try {
      final token = await _messaging.getToken();
      if (token == null) return;
      await _updateTokenInSupabase(kakaoId, token);

      // 이전 리스너 해제 후 재등록 (로그인 반복 시 누적 방지)
      await _tokenRefreshSub?.cancel();
      _tokenRefreshSub = _messaging.onTokenRefresh.listen((newToken) {
        _updateTokenInSupabase(kakaoId, newToken);
      });
    } catch (e) {
      debugPrint('[FCM] saveToken error: $e');
    }
  }

  static Future<void> _updateTokenInSupabase(
      String kakaoId, String token) async {
    try {
      await Supabase.instance.client
          .from('users')
          .update({'fcm_token': token}).eq('kakao_id', kakaoId);
    } catch (e) {
      debugPrint('[FCM] updateToken error: $e');
    }
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }
}
