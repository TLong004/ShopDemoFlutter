import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  static Future<void> init() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String token = await _firebaseMessaging.getToken() ?? '';
      print("Token: $token");
    } else {
      print("User declined or has not accepted permission");
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Nhận tin nhắn đã mở");
    });
  }
}