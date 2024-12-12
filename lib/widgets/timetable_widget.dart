import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/timetable_provider.dart';
import '../providers/semester_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimetableWidget extends StatelessWidget {
  final double dynamicBoxSize;

  TimetableWidget({Key? key, required this.dynamicBoxSize}) : super(key: key);

  final List<String> week = ['월', '화', '수', '목', '금'];
  final int kColumnLength = 13;
  final double kFirstColumnHeight = 20;
  final double kBoxSize = 43;
  final double kTimeColumnWidth = 35.0;

  @override
  Widget build(BuildContext context) {
    // TimetableProvider에서 시간표 데이터를 가져옴
    final timetable = Provider.of<TimetableProvider>(context).timetable;

    return Expanded(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Stack(
            children: [
              Table(
                columnWidths: {
                  0: FixedColumnWidth(kTimeColumnWidth),
                  1: FlexColumnWidth(),
                  2: FlexColumnWidth(),
                  3: FlexColumnWidth(),
                  4: FlexColumnWidth(),
                  5: FlexColumnWidth(),
                },
                border: TableBorder.all(
                  color: Colors.grey.shade300,
                  width: 0.5,
                ),
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  // 요일 헤더
                  TableRow(
                    children: [
                      _buildTimeCell(""),
                      ...week.map((day) => _buildDayCell(day)),
                    ],
                  ),
                  // 시간대별 행 생성
                  ...List.generate(kColumnLength, (index) {
                    final hour = index + 9;
                    return TableRow(
                      children: [
                        _buildTimeCell("$hour"),
                        ...week.map((day) => _buildEmptyCell(dynamicBoxSize)),
                      ]
                    );
                  }),
                ],
              ),
              // 시간표에 과목들 표시
              ...[
                ...timetable.map((subject) =>
                    _buildClassContainers(context, subject, dynamicBoxSize))
              ].expand((x) => x),
            ],
          ),
        ),
      ),
    );
  }

  // 요일 셀
  Widget _buildDayCell(String day) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(child: Text(day)),
      ),
    );
  }

  // 시간 셀
  Widget _buildTimeCell(String time) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(child: Text(time)),
      ),
    );
  }

  // 빈 셀 (과목이 없는 시간대)
  Widget _buildEmptyCell(double boxWidth) {
    return TableCell(
      child: Container(
        width: boxWidth,
        height: kBoxSize,
        color: Colors.transparent,
      ),
    );
  }

  List<Widget> _buildClassContainers(BuildContext context, Map<String, dynamic> subject, double boxWidth) {
    final List<Widget> containers = [];
    
    if (subject['ScheduleInformation'] == null) {
      print('Warning: ScheduleInformation is null for subject: ${subject['subject']}');
      return containers;
    }

    final timeDataList = parseTimeStr(subject['ScheduleInformation']);
    if (timeDataList.isEmpty) {
      print('Warning: No valid time data for subject: ${subject['subject']}');
      return containers;
    }

    for (final timeData in timeDataList) {
      final day = timeData['day'];
      final startHour = timeData['startHour'];
      final endHour = timeData['endHour'];
      final location = timeData['location'];
      final duration = endHour - startHour;

      // 요일에 따른 위치 계산
      final dayIndex = week.indexOf(day);
      final left = kTimeColumnWidth + (dayIndex * (boxWidth - 3.0));
      
      // 시작 시간에 따른 top 위치 계산
      final startMinutes = timeData['startMinute'] ?? 0;
      final endMinutes = timeData['endMinute'] ?? 0;
      
      // 시간을 30분 단위로 계산
      final halfHourBlocks = ((startHour - 9) * 2) + (startMinutes / 30);
      final top = 35.0 + (halfHourBlocks * (kBoxSize / 2));
      
      // 강의 시간 길이 계산 (30분 단위)
      final durationHalfHours = ((endHour - startHour) * 2) + ((endMinutes - startMinutes) / 30);
      final height = durationHalfHours * (kBoxSize / 2);

      containers.add(
        Positioned(
          left: left,
          top: top,
          child: GestureDetector(
            onTap: () => _showSubjectDetail(
              context,
              {
                'subject': subject['subject'] ?? '과목명 없음',
                'professor': subject['professor'] ?? '교수명 없음',
                'location': location ?? '강의실 정보 없음',
                'time': subject['ScheduleInformation'] ?? '시간 정보 없음',
                'lecture_id': subject['lecture_id']
              },
            ),
            child: Container(
              width: boxWidth - 2,  // 양쪽 1픽셀 여백
              height: height,
              decoration: BoxDecoration(
                color: _getSubjectColor(subject['subject'] ?? '').withOpacity(0.25),
                borderRadius: BorderRadius.circular(2),
                border: Border.all(color: _getSubjectColor(subject['subject'] ?? '')),
              ),
              padding: const EdgeInsets.all(4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject['subject'] ?? '과목명 없음',
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (location != null && location != "NULL")
                    Text(
                      location,
                      style: const TextStyle(fontSize: 10),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    
    return containers;
  }

  List<Map<String, dynamic>> parseTimeStr(String? timeStr) {
    if (timeStr == null || timeStr.trim().isEmpty || timeStr == "null") {
      print("No schedule information provided or null value received.");
      return [];
    }

    final List<Map<String, dynamic>> parsedData = [];
    final timeSlots = timeStr.split(',').map((slot) => slot.trim()).toList();

    Map<String, String> dayMap = {
      '월': '월', '화': '화', '수': '수', '목': '목', '금': '금',
    };

    for (String timeSlot in timeSlots) {
      try {
        if (timeSlot.isEmpty) continue;

        // 요일 추출
        String? day;
        for (var key in dayMap.keys) {
          if (timeSlot.contains(key)) {
            day = key;
            break;
          }
        }

        if (day == null) {
          print('Invalid day format in timeSlot: $timeSlot');
          continue;
        }

        // 시간과 장소 분리
        final timeAndLocation = timeSlot.substring(timeSlot.indexOf(day) + 1);
        if (!timeAndLocation.contains('~')) {
          print('Invalid time format: $timeAndLocation');
          continue;
        }

        final timeAndLocationParts = timeAndLocation.split('(');
        
        // 시간 범위 추출
        final timeRange = timeAndLocationParts[0].trim();
        final times = timeRange.split('~');

        // 장소 추출
        String location = "NULL";
        if (timeAndLocationParts.length > 1) {
          location = timeAndLocationParts[1].replaceAll(')', '').trim();
        }

        if (times.length != 2) {
          print('Invalid time range format: $timeRange');
          continue;
        }

        // 시작 시간과 끝 시간 추출
        final startTimeParts = times[0].split(':');
        final endTimeParts = times[1].split(':');

        if (startTimeParts.length != 2 || endTimeParts.length != 2) {
          print('Invalid time format: $timeRange');
          continue;
        }

        final startHour = int.parse(startTimeParts[0].trim());
        final startMinute = int.parse(startTimeParts[1].trim());
        final endHour = int.parse(endTimeParts[0].trim());
        final endMinute = int.parse(endTimeParts[1].trim());

        parsedData.add({
          'day': day,
          'startHour': startHour,
          'startMinute': startMinute,
          'endHour': endHour,
          'endMinute': endMinute,
          'location': location,
        });
      } catch (e) {
        print('Error parsing timeSlot: $timeSlot. Error: $e');
        print('Original timeStr: $timeStr');
      }
    }

    return parsedData;
  }


  final Map<String, Color> subjectColors = {};
  final List<Color> colorPalette = [
    const Color.fromARGB(255, 80, 140, 189).withOpacity(0.7),
    const Color.fromARGB(255, 114, 205, 117).withOpacity(0.7),
    const Color.fromARGB(255, 246, 180, 82).withOpacity(0.7),
    const Color.fromARGB(255, 162, 88, 175).withOpacity(0.7),
    const Color.fromARGB(255, 231, 64, 120).withOpacity(0.7),
    const Color.fromARGB(255, 58, 205, 190).withOpacity(0.7),
    const Color.fromARGB(255, 250, 236, 109).withOpacity(0.7),
    const Color.fromARGB(255, 62, 192, 209).withOpacity(0.7),
  ];

  Color _getSubjectColor(String subject) {
    if (!subjectColors.containsKey(subject)) {
      final colorIndex = subjectColors.length % colorPalette.length;
      subjectColors[subject] = colorPalette[colorIndex];
    }
    return subjectColors[subject]!;
  }

  Future<void> _showSubjectDetail(BuildContext context, Map<String, dynamic> subject) async {
    try {
      print('Subject details: $subject');
      
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception("토큰이 없습니다. 로그인이 필요합니다.");
      }

      // 시간표 데이터에서 enrollment_id 가져오기
      final timetableProvider = Provider.of<TimetableProvider>(context, listen: false);
      final enrollmentData = timetableProvider.timetable.firstWhere(
        (item) => item['lecture_id'] == subject['lecture_id'],
        orElse: () => throw Exception("수강 신청 정보를 찾을 수 없습니다."),
      );

      final enrollmentId = enrollmentData['enrollment_id'];

      // 과목 상세 정보 가져오기
      final detailResponse = await http.post(
        Uri.parse('http://localhost:8080/api/lectures/getLectureInfo'),
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'lectureId': subject['lecture_id'],
        }),
      );

      // 추천 과목 목록 가져오기
      final recommendResponse = await http.post(
        Uri.parse('http://localhost:8080/api/lectures/recommendOtherLectures'),
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'lectureId': subject['lecture_id'],
        }),
      );

      if (detailResponse.statusCode == 200 && recommendResponse.statusCode == 200) {
        final data = jsonDecode(utf8.decode(detailResponse.bodyBytes));
        final recommendedLectures = jsonDecode(utf8.decode(recommendResponse.bodyBytes)) as List;
        final rating = data['ratingTotal'] / (data['ratingCount'] == 0 ? 1 : data['ratingCount']);
        final difficulty = data['difficultyTotal'] / (data['difficultyCount'] == 0 ? 1 : data['difficultyCount']);
        final learningAmount = data['learningAmountTotal'] / (data['learningAmountCount'] == 0 ? 1 : data['learningAmountCount']);

        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (BuildContext context) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${data['subjectName']} - ${data['professorInformation']}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFE74C3C),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            color: Colors.white,
                            onPressed: () => _showDeleteDialog(context, subject),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '과목 난이도 - ${_getDifficultyText(difficulty)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('평점 - ', style: TextStyle(fontSize: 16)),
                        ...List.generate(
                          rating.floor(),
                          (index) => const Icon(Icons.star, color: Colors.amber, size: 16)
                        ),
                        if (rating % 1 > 0)
                          const Icon(Icons.star_half, color: Colors.amber, size: 16),
                        Text(' (${rating.toStringAsFixed(1)}/5.0)', 
                          style: const TextStyle(fontSize: 16)
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '학업량 - ${_getLearningAmountText(learningAmount)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '추천 대체 과목',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // 추천 과목 목록 (스크롤 가능한 부분)
                    Expanded(
                      child: ListView.builder(
                        itemCount: recommendedLectures.length,
                        itemBuilder: (context, index) {
                          final lecture = recommendedLectures[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${lecture['subjectName']} / ${lecture['professorInformation']} / ${lecture['scheduleInformation']}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () => _switchEnrollment(
                                    context,
                                    enrollmentId.toString(),
                                    lecture['id'],
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                  ),
                                  child: const Text('변경', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
    } catch (e) {
      print('강의 정보를 불러오는데 실패했습니다. 에러: $e');
    }
  }

  String _getDifficultyText(double difficulty) {
    if (difficulty >= 3.75) return '상';
    if (difficulty >= 2.25) return '중';
    return '하';
  }

  String _getLearningAmountText(double amount) {
    if (amount >= 3.75) return '많음';
    if (amount >= 2.25) return '보통';
    return '적음';
  }

  Future<void> _deleteSubject(BuildContext context, Map<String, dynamic> subject) async {
    try {
      // 시간표 데이터에서 enrollment_id 가져오기
      final timetableProvider = Provider.of<TimetableProvider>(context, listen: false);
      final enrollmentData = timetableProvider.timetable.firstWhere(
        (item) => item['lecture_id'] == subject['lecture_id'],
        orElse: () => throw Exception("수강 신청 정보를 찾을 수 없습니다."),
      );

      final enrollmentId = enrollmentData['enrollment_id'];
      
      if (enrollmentId == null) {
        throw Exception("수강 신청 ID가 없습니다.");
      }

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception("토큰이 없습니다. 로그인이 필요합니다.");
      }

      // 과목 수강 취소 API 호출
      final deleteResponse = await http.delete(
        Uri.parse('http://localhost:8080/api/lectures/deleteEnrollment'),
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'enrollmentId': int.parse(enrollmentId.toString()),
        }),
      );

      if (deleteResponse.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('과목이 성공적으로 삭제되었습니다.')),
        );
        Navigator.pop(context); // Bottom sheet 닫기
        
        // 시간표 새로고침
        final semesterProvider = Provider.of<SemesterProvider>(context, listen: false);
        await semesterProvider.fetchEnrollments();
      } else {
        throw Exception('과목 삭제 실패');
      }
    } catch (e) {
      print('과목 삭제 중 오류 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('과목 삭제 중 오류가 발생했습니다.')),
      );
    }
  }

  void _showDeleteDialog(BuildContext context, Map<String, dynamic> subject) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('과목 삭제'),
          content: const Text('이 과목을 시간표에서 삭제하시겠습니까?'),
          actions: [
            TextButton(
              child: const Text('취소'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('삭제', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.pop(context);
                _deleteSubject(context, subject);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _switchEnrollment(BuildContext context, String? enrollmentId, String newLectureId) async {
    try {
      if (enrollmentId == null) {
        throw Exception("수강 신청 ID가 없습니다.");
      }

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception("토큰이 없습니다. 로그인이 필요합니다.");
      }

      // 현재 과목 수강 취소
      final deleteResponse = await http.delete(
        Uri.parse('http://localhost:8080/api/lectures/deleteEnrollment'),
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'enrollmentId': int.parse(enrollmentId),
        }),
      );

      if (deleteResponse.statusCode == 200) {
        // 새로운 과목 수강 신청
        final enrollResponse = await http.post(
          Uri.parse('http://localhost:8080/api/lectures/enrollment'),
          headers: {
            'accept': '*/*',
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'lectureId': newLectureId,
          }),
        );

        if (enrollResponse.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('과목이 성공적으로 변경되었습니다.')),
          );
          Navigator.pop(context); // 상세 창 닫기
          
          // 시간표 새로고침
          final semesterProvider = Provider.of<SemesterProvider>(context, listen: false);
          await semesterProvider.fetchEnrollments();
        } else {
          throw Exception('새로운 과목 수강신청 실패');
        }
      } else {
        throw Exception('현재 과목 수강취소 실패');
      }
    } catch (e) {
      print('과목 변경 중 오류 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('과목 변경 중 오류가 발생했습니다.')),
      );
    }
  }

}