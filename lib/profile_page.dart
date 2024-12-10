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

  const AverageGradeChart({Key? key, required this.averageGrades}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 300,
      child: averageGrades.isEmpty
          ? const Center(child: Text('학기별 평점 데이터가 없습니다.'))
          : Column(
              children: [
                const Text(
                  '학기별 평점',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 4.5,
                      minY: 0,
                      groupsSpace: 12,
                      barGroups: _createBarGroups(),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                averageGrades.keys.elementAt(value.toInt()),
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            reservedSize: 30,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  List<BarChartGroupData> _createBarGroups() {
    return averageGrades.entries.map((entry) {
      return BarChartGroupData(
        x: averageGrades.keys.toList().indexOf(entry.key),
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: Colors.blue,
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();
  }
}

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, double>>(
      future: fetchAverageGrades(),
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
  String profileImageUrl = '';

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
        final decodedResponse = utf8.decode(response.bodyBytes);
        final data = jsonDecode(decodedResponse);
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
        fetchProfileImage();
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
    fetchProfileImage();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: pickImage,
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: Color(0xFFE2E8F0),
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
                    SizedBox(width: 40),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m_name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 10),
                          Container(
                            padding: EdgeInsets.all(10),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '학과',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 10,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        m_department,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        '성향',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 10,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        getTendencyText(m_tendency),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfileEditScreen()),
                      );

                      if (result == true) {
                        setState(() {
                          isLoading = true;
                        });
                        fetchProfileData();
                        fetchProfileImage();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      '회원 정보 수정',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
