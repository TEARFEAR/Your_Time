import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = '';
  String department = '';
  String studentId = '';
  String tendency = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProfileData(); // API 호출
  }

  Future<void> fetchProfileData() async {
    try {
      final url = Uri.parse('http://localhost:8080/api/members/info'); // API URL
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // 성공적으로 데이터를 가져왔을 경우
        final data = jsonDecode(response.body);
        setState(() {
          name = data['name'];
          department = data['department'];
          studentId = data['studentId'];
          tendency = data['tendency'];
          isLoading = false;
        });
      } else {
        // 실패 시 에러 처리
        print('Failed to load profile data: ${response.body}');
      }
    } catch (e) {
      print('Error fetching profile data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('내 정보'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // 로딩 상태 표시
          : Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(
                    'https://your-image-url.com'), // Replace with actual image URL
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: Text(
                name,
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('학과', style: TextStyle(fontSize: 16)),
                Text(department, style: TextStyle(fontSize: 16)),
                SizedBox(height: 10),
                Text('학번', style: TextStyle(fontSize: 16)),
                Text(studentId, style: TextStyle(fontSize: 16)),
                SizedBox(height: 10),
                Text('성향', style: TextStyle(fontSize: 16)),
                Text(tendency,
                    style: TextStyle(
                        fontSize: 16, color: Colors.red)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
