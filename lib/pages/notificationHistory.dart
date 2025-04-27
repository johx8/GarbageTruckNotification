import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../main.dart'; // ✨ Import this for permissions

class NotificationsScreen extends StatefulWidget {
  final String userId; // Pass the user ID when opening this screen

  NotificationsScreen({required this.userId});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    requestNotificationPermission(); // ✨ Ask permission when screen opens
    listenToNewNotifications();
  }

  void requestNotificationPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('⚡ User granted provisional permission');
    } else {
      print('❌ User declined or has not accepted permission');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: widget.userId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No notifications yet.'));
          }

          final notifications = snapshot.data!.docs;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final message = notification['message'] ?? '';
              final timestamp = notification['timestamp'] as Timestamp;

              return ListTile(
                leading: Icon(Icons.notifications),
                title: Text(message),
                subtitle: Text(
                  '${timestamp.toDate()}',
                  style: TextStyle(fontSize: 12),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void listenToNewNotifications() {
    FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: widget.userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      for (var docChange in snapshot.docChanges) {
        if (docChange.type == DocumentChangeType.added) {
          final message = docChange.doc['message'] ?? 'New Notification';

          flutterLocalNotificationsPlugin.show(
            message.hashCode, // unique id
            'New Alert', // title
            message, // body
            NotificationDetails(
              android: AndroidNotificationDetails(
                'garbage_alerts_channel',
                'Garbage Alerts',
                channelDescription: 'This channel is used for garbage truck alerts.',
                importance: Importance.high,
                priority: Priority.high,
              ),
            ),
          );
        }
      }
    });
  }
}
