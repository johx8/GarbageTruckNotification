import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegistrationService {
  static Future<String?> registerUser({
    required String role, // 'user' or 'driver'
    required Map<String, dynamic> data,
  }) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection(role == 'driver' ? 'drivers' : 'users')
          .doc(); // Generate new doc with auto ID

      await docRef.set({
        ...data,
        'role': role,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      final newUserId = docRef.id; // ✅ This is your generated Firestore doc ID

      // Save to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('role', role);
      await prefs.setString('userId', newUserId);

      // print("Registration complete for $role with ID: ${docRef.id}");
      // return docRef.id; // Return the generated document ID
      print("Registered and saved user ID: $newUserId");
      return newUserId;
    } catch (e) {
      print("Error during registration: $e");
      return null;
    }
  }
}
