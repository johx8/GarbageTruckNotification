


//*****************************DEMO TO SHOW DATABASE CAN BE UPDATED**********************************************


// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'notificationHistory.dart';
//
// // 🌟 Import the notification plugin from main.dart
// import '../main.dart'; // Make sure flutterLocalNotificationsPlugin is accessible
//
// class UserProfileScreen extends StatefulWidget {
//   final String userId;
//
//   UserProfileScreen({required this.userId});
//
//   @override
//   State<UserProfileScreen> createState() => _UserProfileScreenState();
// }
//
// class _UserProfileScreenState extends State<UserProfileScreen> {
//   Map<String, dynamic>? userData;
//   bool isEditing = false;
//
//   final nameController = TextEditingController();
//   final phoneController = TextEditingController();
//   final streetController = TextEditingController();
//   final areaController = TextEditingController();
//   final pincodeController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     fetchUserData();
//     setupFirebaseMessagingListener(); // 🌟 Listen for incoming notifications
//   }
//
//   Future<void> fetchUserData() async {
//     final doc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
//
//     if (doc.exists) {
//       userData = doc.data()!;
//       setState(() {
//         nameController.text = userData!['name'];
//         phoneController.text = userData!['phone'];
//         streetController.text = userData!['street'];
//         areaController.text = userData!['area'];
//         pincodeController.text = userData!['pincode'];
//       });
//     }
//   }
//
//   Future<void> updateUserData() async {
//     final updatedData = {
//       'name': nameController.text,
//       'phone': phoneController.text,
//       'street': streetController.text,
//       'area': areaController.text,
//       'pincode': pincodeController.text,
//       'lastUpdated': DateTime.now(),
//     };
//
//     await FirebaseFirestore.instance
//         .collection('users')
//         .doc(widget.userId)
//         .set(updatedData, SetOptions(merge: false));
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Profile updated successfully!")),
//     );
//
//     setState(() {
//       isEditing = false;
//     });
//     fetchUserData(); // Refresh data
//   }
//
//   void setupFirebaseMessagingListener() {
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       RemoteNotification? notification = message.notification;
//       AndroidNotification? android = message.notification?.android;
//
//       if (notification != null && android != null) {
//         flutterLocalNotificationsPlugin.show(
//           notification.hashCode,
//           notification.title,
//           notification.body,
//           NotificationDetails(
//             android: AndroidNotificationDetails(
//               'garbage_alerts_channel', // custom channel id
//               'Garbage Alerts',
//               channelDescription: 'This channel is used for garbage truck alerts.',
//               importance: Importance.high,
//               priority: Priority.high,
//               ticker: 'ticker',
//             ),
//           ),
//         );
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (userData == null) {
//       return Scaffold(
//         appBar: AppBar(title: Text('Profile')),
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Your Profile'),
//         actions: [
//           IconButton(
//             icon: Icon(isEditing ? Icons.cancel : Icons.edit),
//             onPressed: () {
//               setState(() {
//                 isEditing = !isEditing;
//               });
//             },
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: ListView(
//           children: [
//             ...(isEditing ? buildEditableForm() : buildReadOnlyView()),
//
//             SizedBox(height: 20),
//
//             ElevatedButton.icon(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => NotificationsScreen(userId: widget.userId),
//                   ),
//                 );
//               },
//               icon: Icon(Icons.notifications),
//               label: Text('View Notifications'),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: isEditing
//           ? FloatingActionButton(
//         onPressed: updateUserData,
//         child: Icon(Icons.save),
//         tooltip: 'Save Changes',
//       )
//           : null,
//     );
//   }
//
//   List<Widget> buildReadOnlyView() {
//     return [
//       buildInfoTile('Name', nameController.text),
//       buildInfoTile('Phone Number', phoneController.text),
//       buildInfoTile('Street', streetController.text),
//       buildInfoTile('Area', areaController.text),
//       buildInfoTile('Pincode', pincodeController.text),
//     ];
//   }
//
//   List<Widget> buildEditableForm() {
//     return [
//       buildTextField('Name', nameController),
//       buildTextField('Phone Number', phoneController, keyboard: TextInputType.phone),
//       buildTextField('Street', streetController),
//       buildTextField('Area', areaController),
//       buildTextField('Pincode', pincodeController, keyboard: TextInputType.number),
//     ];
//   }
//
//   Widget buildTextField(String label, TextEditingController controller, {TextInputType? keyboard}) {
//     return TextField(
//       controller: controller,
//       decoration: InputDecoration(labelText: label),
//       keyboardType: keyboard,
//     );
//   }
//
//   Widget buildInfoTile(String title, String value) {
//     return ListTile(
//       title: Text(title),
//       subtitle: Text(value),
//     );
//   }
// }
//


//********************ACTUAL WORKING OF APP WHERE IT ALLOWS TO MAKE CHANGES AFTER 15 DAYS***************************************

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../main.dart'; // import flutterLocalNotificationsPlugin if declared there
import 'notificationHistory.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;

  UserProfileScreen({required this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  Map<String, dynamic>? userData;
  bool isEditing = false;
  bool canEdit = false;
  int daysRemaining = 0;

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final streetController = TextEditingController();
  final areaController = TextEditingController();
  final pincodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserData();
    setupFirebaseMessagingListener(); // 🌟 Listen for notifications
    requestNotificationPermission();
  }

  Future<void> fetchUserData() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();

    if (doc.exists) {
      final data = doc.data()!;
      final lastUpdated = (data['lastUpdated'] as Timestamp?)?.toDate();
      final now = DateTime.now();

      bool allowEdit = false;
      int remaining = 0;

      if (lastUpdated == null) {
        allowEdit = true;
      } else {
        final diff = now.difference(lastUpdated).inDays;
        allowEdit = diff >= 15;
        remaining = 15 - diff;
      }

      setState(() {
        userData = data;
        nameController.text = data['name'];
        phoneController.text = data['phone'];
        streetController.text = data['street'];
        areaController.text = data['area'];
        pincodeController.text = data['pincode'];
        canEdit = allowEdit;
        daysRemaining = remaining > 0 ? remaining : 0;
      });
    }
  }

  Future<void> updateUserData() async {
    final updatedData = {
      'name': nameController.text,
      'phone': phoneController.text,
      'street': streetController.text,
      'area': areaController.text,
      'pincode': pincodeController.text,
      'lastUpdated': DateTime.now(),
    };

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .set(updatedData, SetOptions(merge: false));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Profile updated successfully!")),
    );

    setState(() {
      isEditing = false;
    });

    fetchUserData(); // Refresh data
  }

  void setupFirebaseMessagingListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'garbage_alerts_channel', // Channel ID
              'Garbage Alerts',
              channelDescription: 'This channel is used for garbage truck alerts.',
              importance: Importance.high,
              priority: Priority.high,
              ticker: 'ticker',
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (userData == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Profile')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Profile'),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.cancel : Icons.edit),
            onPressed: canEdit
                ? () {
              setState(() {
                isEditing = !isEditing;
              });
            }
                : null,
            tooltip: canEdit
                ? (isEditing ? 'Cancel Editing' : 'Edit Profile')
                : 'Editing allowed after 15 days',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ...(isEditing ? buildEditableForm() : buildReadOnlyView()),

            SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationsScreen(userId: widget.userId),
                  ),
                );
              },
              icon: Icon(Icons.notifications),
              label: Text('View Notifications'),
            ),
          ],
        ),
      ),
      floatingActionButton: isEditing
          ? FloatingActionButton(
        onPressed: updateUserData,
        child: Icon(Icons.save),
        tooltip: 'Save Changes',
      )
          : null,
    );
  }

  List<Widget> buildReadOnlyView() {
    return [
      buildInfoTile('Name', nameController.text),
      buildInfoTile('Phone Number', phoneController.text),
      buildInfoTile('Street', streetController.text),
      buildInfoTile('Area', areaController.text),
      buildInfoTile('Pincode', pincodeController.text),
    ];
  }

  List<Widget> buildEditableForm() {
    return [
      buildTextField('Name', nameController),
      buildTextField('Phone Number', phoneController, keyboard: TextInputType.phone),
      buildTextField('Street', streetController),
      buildTextField('Area', areaController),
      buildTextField('Pincode', pincodeController, keyboard: TextInputType.number),
    ];
  }

  Widget buildTextField(String label, TextEditingController controller, {TextInputType? keyboard}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: keyboard,
    );
  }

  Widget buildInfoTile(String title, String value) {
    return ListTile(
      title: Text(title),
      subtitle: Text(value),
    );
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
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

}

