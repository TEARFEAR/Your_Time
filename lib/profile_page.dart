import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_edit.dart';

// provider
import 'package:provider/provider.dart';
import 'providers/profile_provider.dart';

//widget
import 'widgets/custom_bottom_navigation.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ProfileProvider에서 fetchProfileData 호출
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProfileProvider>(context, listen: false).fetchProfileData();
    });

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
              // children: [
              //   EvaluationButton(
              //     icon: Icons.star,
              //     label: '강의 평점 평가',
              //     color: Colors.amber,
              //   ),
              //   EvaluationButton(
              //     icon: Icons.show_chart,
              //     label: '강의 난이도 평가',
              //     color: Colors.redAccent,
              //   ),
              //   EvaluationButton(
              //     icon: Icons.insert_drive_file,
              //     label: '학습량 평가',
              //     color: Colors.blueAccent,
              //   ),
              //   EvaluationButton(
              //     icon: Icons.more_horiz,
              //     label: '...',
              //     color: Colors.grey,
              //   ),
              // ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 1, // '내 정보' 페이지이므로 1로 설정
        onItemTapped: (index) {
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
String profileImageUrl = ''; // To store the image URL

// Add ImagePicker instance
final ImagePicker _picker = ImagePicker();

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
        m_tendency = (data['tendency'] as num).toInt();
        m_difficulty = (data['difficulty'] as num).toInt();
        m_learningAmount = (data['learningAmount'] as num).toInt();
        isLoading = false;
      });
    } else {
      print('회원정보를 불러오는데 실패했습니다. 상태 코드: ${response.statusCode}');
    }
  } catch (e) {
    print('회원정보를 불러오는데 실패했습니다. 에러: $e');
  }
}

// Fetch the profile image
// Profile image fetch method
  Future<void> fetchProfileImage() async {
    try {
      final token = await getToken();
      if (token == null) return;

      final url = Uri.parse('http://localhost:8080/api/members/profileImage');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          profileImageUrl = 'data:image/jpeg;base64,' + base64Encode(response.bodyBytes);
        });
      } else {
        print('프로필 이미지를 불러오는데 실패했습니다. 상태 코드: ${response.statusCode}');
      }
    } catch (e) {
      print('프로필 이미지를 불러오는데 실패했습니다. 에러: $e');
    }
  }

// Upload profile image method
  Future<void> uploadProfileImage(XFile image) async {
    try {
      final token = await getToken();
      if (token == null) return;

      final url = Uri.parse('http://localhost:8080/api/members/uploadProfileImage');
      var request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('file', image.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        print('이미지 업로드 성공');
        fetchProfileImage(); // Reload image after upload
      } else {
        print('이미지 업로드 실패. 상태 코드: ${response.statusCode}');
      }
    } catch (e) {
      print('이미지 업로드 실패. 에러: $e');
    }
  }

// Image picker method
  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      await uploadProfileImage(image);
    }
  }

  String getTendencyText(int tendency) {
    switch (tendency) {
      case 1:
        return '안전형';
      case 2:
        return '밸런스형';
      case 3:
        return '도전형';
      default:
        return '알 수 없음';
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProfileData();
    fetchProfileImage(); // Fetch profile image when widget is loaded
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
          GestureDetector(
            onTap: pickImage, // Trigger image picker when tapped
            child: CircleAvatar(
              radius: 40,
              backgroundImage: profileImageUrl.isNotEmpty
                  ? NetworkImage(profileImageUrl)
                  : null, // Use default icon if no image URL
              child: profileImageUrl.isEmpty
                  ? Icon(
                Icons.person, // Default icon when no profile image is available
                size: 40,
                color: Colors.white, // Icon color (white in this case)
              )
                  : null, // Do not show the icon if there's an image
            ),
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
                      '성향: ${getTendencyText(m_tendency)}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              // Navigate to ProfileEditScreen and wait for the result
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileEditScreen()),
              );

              // Refresh the profile data if changes were made
              if (result == true) {
                setState(() {
                  isLoading = true; // Show loading while refreshing
                });
                fetchProfileData(); // Refresh the data
              }
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
