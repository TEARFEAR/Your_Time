import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1F3F6),
      appBar: AppBar(
        title: Text('내 정보'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          ProfileCard(), // ProfileCard 위젯 사용
          Expanded(
            child: GridView.count(
              padding: EdgeInsets.all(16),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                EvaluationButton(
                  icon: Icons.star,
                  label: '강의 평점 평가',
                  color: Colors.amber,
                ),
                EvaluationButton(
                  icon: Icons.show_chart,
                  label: '강의 난이도 평가',
                  color: Colors.redAccent,
                ),
                EvaluationButton(
                  icon: Icons.insert_drive_file,
                  label: '학습량 평가',
                  color: Colors.blueAccent,
                ),
                EvaluationButton(
                  icon: Icons.more_horiz,
                  label: '...',
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '내 정보',
          ),
        ],
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            // "홈" 버튼 클릭 시 이전 화면으로 돌아감
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}

class ProfileCard extends StatefulWidget {
  @override
  _ProfileCardState createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  String m_id = '';
  String m_pw = '';
  String m_name = '';
  String m_department = '';
  int m_tendency = 0;
  int m_difficulty = 0;
  int m_learningAmount = 0;
  bool isLoading = true;

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print('저장된 토큰: $token');
    return token;
  }

  Future<void> fetchProfileData() async {
    try {
      final token = await getToken();

      if (token == null) {
        return;
      }

      final url = Uri.parse('http://localhost:8080/api/members/info');
      print('요청 URL: $url');

      final response = await http.get(
        url,
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          m_id = data['id'] ?? '';
          m_pw = data['pw'] ?? '';
          m_name = data['name'] ?? '';
          m_department = data['department'] ?? '';
          m_tendency = data['tendency'] ?? 0;
          m_difficulty = data['difficulty'] ?? 0;
          m_learningAmount = data['learningAmount'] ?? 0;
          isLoading = false;
        });
      } else {
        print('회원정보를 불러오는데 실패했습니다. 상태 코드: ${response.statusCode}');
      }
    } catch (e) {
      print('회원정보를 불러오는데 실패했습니다. 에러: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: isLoading
          ? Center(child: CircularProgressIndicator())
          : Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(
                      'https://your-image-url.com'), // 여기에 이미지 URL을 넣으세요.
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${m_name}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('학과: ${m_department}'),
                      Text('학번: 2024000000'),
                      Row(
                        children: [
                          Text(
                            '성향: ${m_tendency}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // 정보 수정 버튼 기능
                  },
                  child: Text('회원 정보 수정'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFCBD5E0),
                  ),
                ),
              ],
            ),
    );
  }
}

class EvaluationButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  EvaluationButton({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // 버튼 기능 추가
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: color,
        backgroundColor: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 40),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
