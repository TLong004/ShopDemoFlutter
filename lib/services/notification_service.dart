import 'dart:io'; // Thêm import này
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  static Future<void> init() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      try {
        if (Platform.isIOS) {
          String? apnsToken = await _firebaseMessaging.getAPNSToken();
          
          if (apnsToken == null) {
            print("Lưu ý: APNS Token chưa sẵn sàng (Thường xảy ra trên Simulator)");
            if (Platform.isIOS && !Platform.isMacOS) { 
            }
          }
        }

        String? token = await _firebaseMessaging.getToken();
        print("FCM Token: $token");
        
      } catch (e) {
        print("Lỗi lấy Token: $e");
      }
    } else {
      print("User declined or has not accepted permission");
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {});
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Nhận tin nhắn đã mở");
    });
  }
}