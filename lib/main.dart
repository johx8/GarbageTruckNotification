import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:garbage_noti_app/pages/driverRole.dart';
import 'package:garbage_noti_app/pages/userRole.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:garbage_noti_app/pages/userReg.dart';

// Initialize notification plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling background message: ${message.messageId}');
}

// Local Notification Setup
Future<void> setupFlutterNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Setup background messaging
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Setup local notifications
  await setupFlutterNotifications();

  // Load login state
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final role = prefs.getString('role');
  final userId = prefs.getString('userId');

  Widget _defaultHome = RoleSelectionScreen();

  if (isLoggedIn) {
    if (role == 'user' && userId != null) {
      _defaultHome = UserProfileScreen(userId: userId);
    } else {
      _defaultHome = DriverNotificationScreen();
    }
  } else {
    _defaultHome = RoleSelectionScreen();
  }

  runApp(MyApp(defaultHome: _defaultHome));
}

class MyApp extends StatelessWidget {
  final Widget defaultHome;

  const MyApp({required this.defaultHome, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Garbage Truck Notifier',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: defaultHome,
    );
  }
}
