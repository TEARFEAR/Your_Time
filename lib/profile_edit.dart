import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ProfileEditScreen(),
    );
  }
}

class ProfileEditScreen extends StatefulWidget {
  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();
  String selectedTendency = '안전형';

  // Map for Tendency Conversion
  final Map<String, int> tendencyMap = {
    '안전형': 1,
    '밸런스형': 2,
    '도전형': 3,
  };

  // Method to get token from SharedPreferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token'); // Assumes token is saved with the key 'token'
  }

  // Method to send updated data to the server
  Future<void> updateProfile() async {
    final String url = 'http://10.0.2.2:8080/api/members/update';

    try {
      // Fetch the token
      final token = await getToken();
      if (token == null) {
        print('No token found. User might not be logged in.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인이 필요합니다.')),
        );
        return;
      }

      // Send the API request
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Include the token here
        },
        body: jsonEncode({
          'name': nameController.text,
          'password': passwordController.text,
          'department': departmentController.text,
          'tendency': tendencyMap[selectedTendency], // Convert to int
        }),
      );

      if (response.statusCode == 200) {
        print('Profile updated successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully!')),
        );
        // Navigate back to the ProfileScreen and refresh the data
        Navigator.pop(context, true); // Pass true to indicate success
      } else {
        print('Failed to update profile: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile!')),
        );
      }
    } catch (e) {
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          '내 정보',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: '이름 변경',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: '비밀번호 재설정',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              decoration: InputDecoration(
                labelText: '비밀번호 확인',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 16),
            TextField(
              controller: departmentController,
              decoration: InputDecoration(
                labelText: '학과',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: '본인의 성향을 선택해주세요.',
                border: OutlineInputBorder(),
              ),
              value: selectedTendency,
              items: [
                DropdownMenuItem(
                  child: Text('안전형'),
                  value: '안전형',
                ),
                DropdownMenuItem(
                  child: Text('밸런스형'),
                  value: '밸런스형',
                ),
                DropdownMenuItem(
                  child: Text('도전형'),
                  value: '도전형',
                ),
              ],
              onChanged: (value) {
                setState(() {
                  selectedTendency = value!;
                });
              },
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                if (passwordController.text != confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Passwords do not match!')),
                  );
                  return;
                }
                updateProfile(); // Call the update profile function
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                '저장',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
