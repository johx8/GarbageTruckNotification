import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:garbage_noti_app/pages/driverRole.dart';
import 'package:garbage_noti_app/pages/services.dart';
import 'package:garbage_noti_app/pages/userRole.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRegistrationScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Registration')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: streetController,
              decoration: InputDecoration(labelText: 'Street'),
            ),
            TextField(
              controller: areaController,
              decoration: InputDecoration(labelText: 'Area'),
            ),
            TextField(
              controller: pincodeController,
              decoration: InputDecoration(labelText: 'Pincode'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String? userId = await RegistrationService.registerUser(
                  role: 'user',
                  data: {
                    'name': nameController.text,
                    'phone': phoneController.text,
                    'street': streetController.text,
                    'area': areaController.text,
                    'pincode': pincodeController.text,
                    'lastUpdated': FieldValue.serverTimestamp(),
                  },
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('User registered successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UserProfileScreen(userId: userId!),
                  ),
                );
                // final prefs = await SharedPreferences.getInstance();
                // await prefs.setBool('isLoggedIn', true);
                // await prefs.setString('role', 'user'); // or 'driver'
                // await prefs.setString('userId', newUserId); // Replace with actual UID
                nameController.clear();
                phoneController.clear();
                streetController.clear();
                areaController.clear();
                pincodeController.clear();
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}

class DriverRegistrationScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController vehicleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Driver Registration')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Driver Name'),
            ),
            TextField(
              controller: vehicleController,
              decoration: InputDecoration(labelText: 'Vehicle Number'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String? driverId = await RegistrationService.registerUser(
                  role: 'driver',
                  data: {
                    'name': nameController.text,
                    'vehicleNo': vehicleController.text,
                    // 'lastUpdated': FieldValue.serverTimestamp(),
                  },
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Driver registered successfully')),
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DriverNotificationScreen()
                  ),
                );
                nameController.clear();
                vehicleController.clear();
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}

class RoleSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Role')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => UserRegistrationScreen()),
              ),
              child: Text('User Registration'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DriverRegistrationScreen()),
              ),
              child: Text('Driver Registration'),
            ),
          ],
        ),
      ),
    );
  }
}
