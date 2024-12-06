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
import 'package:fl_chart/fl_chart.dart';

class AverageGradeChart extends StatelessWidget {
  final Map<String, double> averageGrades;

  AverageGradeChart({required this.averageGrades});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: BarChart(
        BarChartData(
          titlesData: FlTitlesData(
            leftTitles: SideTitles(showTitles: true, getTitles: (value) {
              return value.toInt().toString();  // y축의 학점 (0부터 5까지)
            }),
            bottomTitles: SideTitles(showTitles: true, getTitles: (value) {
              // x축의 연도와 학기 표시
              String key = averageGrades.keys.toList()[value.toInt()];
              return key;
            }),
          ),
          borderData: FlBorderData(show: true),
          barGroups: averageGrades.entries.map((entry) {
            return BarChartGroupData(
              x: averageGrades.keys.toList().indexOf(entry.key),  // x축: 연도와 학기
              barRods: [
                BarChartRodData(
                  y: entry.value,  // y축: 학점
                  width: 16,
                  colors: [Colors.blue],
                  borderRadius: BorderRadius.zero,
                ),
              ],
              showingTooltipIndicators: [0],  // ToolTip 표시
            );
          }).toList(),
          gridData: FlGridData(show: true),  // 격자 표시
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, double>>(
      future: fetchAverageGrades(),  // API 호출하여 평균 학점 데이터 가져오기
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text('내 정보')),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text('내 정보')),
            body: Center(child: Text('오류 발생: ${snapshot.error}')),
          );
        }

        final averageGrades = snapshot.data ?? {};
        return Scaffold(
          appBar: AppBar(title: Text('내 정보')),
          body: Column(
            children: [
              ProfileCard(),
              Expanded(child: AverageGradeChart(averageGrades: averageGrades)),
            ],
          ),
        );
      },
    );
  }
}

Future<Map<String, double>> fetchAverageGrades() async {
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print('저장된 토큰: $token');
    return token;
  }

  final token = await getToken();
  if (token == null) return {};

  final Map<String, double> averageGrades = {};

  final semesters = [
    {'year': '2024', 'semester': '1학기'},
  ];

  for (var semester in semesters) {
    final url = Uri.parse('http://localhost:8080/api/lectures/average-grade');
    final response = await http.post(
      url,
      headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'year': semester['year'],
        'semester': semester['semester'],
        'page': 0,
        'size': 0,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data != null) {
        // Assuming the response body contains a plain string value
        final averageGrade = double.tryParse(data.toString()) ?? 0.0;
        averageGrades['${semester['year']} ${semester['semester']}'] = averageGrade;
      }
    } else {
      print('학점 계산에 실패했습니다. 상태 코드: ${response.statusCode}');
    }
  }

  return averageGrades;
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
            onTap: pickImage,
            child: CircleAvatar(
              radius: 40,
              backgroundImage: profileImageUrl.isNotEmpty
                  ? NetworkImage(profileImageUrl)
                  : null,
              child: profileImageUrl.isEmpty
                  ? Icon(
                Icons.person,
                size: 40,
                color: Colors.white,
              )
                  : null,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$m_name',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text('학과: $m_department'),
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
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileEditScreen()),
              );

              if (result == true) {
                setState(() {
                  isLoading = true;
                });
                fetchProfileData(); // Refresh data
                fetchProfileImage(); // Refresh image
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
