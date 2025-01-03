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
  final Map<String, Map<String, double>> semesterData;

  const AverageGradeChart({Key? key, required this.semesterData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final highestGradeSemester = semesterData.entries.reduce((a, b) => a.value['평점']! > b.value['평점']! ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      height: 450,
      child: semesterData.isEmpty
          ? const Center(child: Text('학기별 데이터가 없습니다.'))
          : Column(
        children: [
          Text(
            '가장 높은 학기: ${highestGradeSemester.key}, 평점: ${highestGradeSemester.value['평점']!.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          const Text(
            '학기별 데이터',
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
                maxY: 5.0,
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
                          semesterData.keys.elementAt(value.toInt()),
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
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('평점', Colors.blue),
              const SizedBox(width: 16),
              _buildLegendItem('학습유용도', Colors.green),
              const SizedBox(width: 16),
              _buildLegendItem('난이도', Colors.red),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '추천성향: 도전형',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ],

      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  List<BarChartGroupData> _createBarGroups() {
    return semesterData.entries.map((entry) {
      final index = semesterData.keys.toList().indexOf(entry.key);
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: entry.value['평점']!,
            color: Colors.blue,
            width: 8,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
          BarChartRodData(
            toY: entry.value['학습유용도']!,
            color: Colors.green,
            width: 8,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
          BarChartRodData(
            toY: entry.value['난이도']!,
            color: Colors.red,
            width: 8,
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
    return FutureBuilder<Map<String, Map<String, double>>>(
      future: fetchSemesterData(),
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

        final semesterData = snapshot.data ?? {};
        return Scaffold(
          appBar: AppBar(title: Text('내 정보')),
          body: Column(
            children: [
              ProfileCard(),
              Expanded(child: AverageGradeChart(semesterData: semesterData)),
            ],
          ),
        );
      },
    );
  }
}

Future<Map<String, Map<String, double>>> fetchSemesterData() async {
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token;
  }

  final token = await getToken();
  if (token == null) return {};

  // 기본 더미 데이터
  final Map<String, Map<String, double>> semesterData = {
    '2021 1학기': {'평점': 3.2, '학습유용도': 4.0, '난이도': 3.5},
    '2021 2학기': {'평점': 2.8, '학습유용도': 3.5, '난이도': 3.0},
    '2022 1학기': {'평점': 3.7, '학습유용도': 4.2, '난이도': 3.8},
    '2022 2학기': {'평점': 3.9, '학습유용도': 4.5, '난이도': 4.0},
    '2023 1학기': {'평점': 4.0, '학습유용도': 4.8, '난이도': 4.2},
    '2023 2학기': {'평점': 3.6, '학습유용도': 4.0, '난이도': 3.7},
    '2024 1학기': {'평점': 3.8, '학습유용도': 4.1, '난이도': 3.9},
  };

  // API 호출
  final List<String> metrics = ['평점', '학습유용도', '난이도'];
  for (final metric in metrics) {
    final url = Uri.parse('http://localhost:8080/api/lectures/average-$metric');
    final response = await http.post(
      url,
      headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'year': '2024',
        'semester': '2학기',
        'page': 0,
        'size': 0,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data != null) {
        semesterData['2024 2학기'] ??= {};
        semesterData['2024 2학기']?[metric] = double.tryParse(data.toString()) ?? 0.0;
      }
    } else {
      print('2024년 2학기 $metric 계산에 실패했습니다. 상태 코드: ${response.statusCode}');
    }
  }

  return semesterData;
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
