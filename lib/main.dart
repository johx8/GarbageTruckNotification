import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:udp/udp.dart';

void main() {
  runApp(const MyApp());
}

final FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Garbage Notification',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const RegistrationScreen(),
    );
  }
}

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeNotification();
    _checkStoredUser();
  }

  Future<void> _initializeNotification() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await notificationsPlugin.initialize(initSettings);
  }

  Future<void> _checkStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final storedName = prefs.getString('userName');
    final storedStreet = prefs.getString('streetNumber');
    if (storedName != null && storedStreet != null) {
      _startListening(int.parse(storedStreet));
    }
  }

  Future<void> _saveUserAndListen() async {
    final name = _nameController.text.trim();
    final street = _streetController.text.trim();

    if (name.isEmpty || street.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields.")),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);
    await prefs.setString('streetNumber', street);

    _startListening(int.parse(street));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Registered and listening for truck alerts."),
      ),
    );
  }

  Future<void> _startListening(int userStreet) async {
    final receiver = await UDP.bind(Endpoint.any(port: Port(65000)));

    receiver.asStream().listen((datagram) {
      if (datagram == null) return;
      final message = String.fromCharCodes(datagram.data);
      debugPrint("Received UDP Message: $message");

      if (message.contains("I am here:")) {
        final parts = message.split(':');
        if (parts.length > 1) {
          final street = int.tryParse(parts[1].trim());
          if (street != null && street == userStreet) {
            _showLocalNotification();
          }
        }
      }
    });
  }

  Future<void> _showLocalNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'area_alerts',
          'Garbage Truck Alerts',
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails notifDetails = NotificationDetails(
      android: androidDetails,
    );

    await notificationsPlugin.show(
      0,
      'Garbage Truck is Here!',
      'The truck has arrived at your street.',
      notifDetails,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Registration')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _streetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Street Number'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveUserAndListen,
              child: const Text('Register & Start Listening'),
            ),
          ],
        ),
      ),
    );
  }
}
