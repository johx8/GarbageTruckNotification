import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DriverNotificationScreen extends StatefulWidget {
  @override
  _DriverNotificationScreenState createState() => _DriverNotificationScreenState();
}

class _DriverNotificationScreenState extends State<DriverNotificationScreen> {
  String? selectedStreet;
  String? selectedArea;
  String? selectedPincode;

  List<String> streets = [];
  List<String> areas = [];
  List<String> pincodes = [];

  bool isLoading = true; // 🔥 Added loading indicator

  @override
  void initState() {
    super.initState();
    fetchLocationOptions();
  }

  Future<void> fetchLocationOptions() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('users').get();

      Set<String> streetSet = {};
      Set<String> areaSet = {};
      Set<String> pincodeSet = {};

      for (var doc in snapshot.docs) {
        var data = doc.data();
        if (data.containsKey('street') && data.containsKey('area') && data.containsKey('pincode')) {
          streetSet.add(data['street']);
          areaSet.add(data['area']);
          pincodeSet.add(data['pincode']);
        }
      }

      setState(() {
        streets = streetSet.toList();
        areas = areaSet.toList();
        pincodes = pincodeSet.toList();
        isLoading = false; // 🔥 Done loading
      });
    } catch (e) {
      print('Error fetching location options: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> sendNotification() async {
    if (selectedStreet == null || selectedArea == null || selectedPincode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select Street, Area, and Pincode')),
      );
      return;
    }

    final usersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('street', isEqualTo: selectedStreet)
        .where('area', isEqualTo: selectedArea)
        .where('pincode', isEqualTo: selectedPincode)
        .get();

    if (usersSnapshot.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No users found for the selected location')),
      );
      return;
    }

    for (var userDoc in usersSnapshot.docs) {
      String userId = userDoc.id;
      print('Send notification to User ID: $userId');

      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': userId,
        'message': 'Garbage truck has arrived in your area!',
        'timestamp': DateTime.now(),
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Notification sent to users!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) { // 🔥 Show loader while fetching
      return Scaffold(
        appBar: AppBar(title: Text('Driver Notification')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Notification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Select Street'),
              items: streets.map((street) {
                return DropdownMenuItem(
                  value: street,
                  child: Text(street),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedStreet = value;
                });
              },
              value: selectedStreet,
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Select Area'),
              items: areas.map((area) {
                return DropdownMenuItem(
                  value: area,
                  child: Text(area),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedArea = value;
                });
              },
              value: selectedArea,
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Select Pincode'),
              items: pincodes.map((pincode) {
                return DropdownMenuItem(
                  value: pincode,
                  child: Text(pincode),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedPincode = value;
                });
              },
              value: selectedPincode,
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: sendNotification,
              child: Text('Send Notification'),
            ),
          ],
        ),
      ),
    );
  }
}
