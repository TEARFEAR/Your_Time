import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/timetable_provider.dart';

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

    final timeDataList = parseTimeStr(subject['ScheduleInformation']);

    for (final timeData in timeDataList) {
      final day = timeData['day'];
      final startHour = timeData['startHour'];
      final endHour = timeData['endHour'];
      final location = timeData['location'];
      final duration = endHour - startHour;

      // 요일에 따른 위치 계산
      final dayIndex = week.indexOf(day);
      final left = kTimeColumnWidth + (dayIndex * boxWidth);
      final top = 30.0 + ((startHour - 9) * kBoxSize);

      containers.add(
        Positioned(
          left: left,
          top: top,
          child: GestureDetector(
            onTap: () => _showSubjectDetail(context, subject),
            child: Container(
              width: boxWidth,
              height: kBoxSize * duration,
              decoration: BoxDecoration(
                color: _getSubjectColor(subject['subjectName']),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 0.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject['subjectName'],
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      location,
                      style: const TextStyle(fontSize: 7),
                    ),
                    Text(
                      subject['professorInformation'],
                      style: const TextStyle(fontSize: 7),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
    return containers;
  }

  List<Map<String, dynamic>> parseTimeStr(String? timeStr) {
    if (timeStr == null || timeStr.trim().isEmpty) {
      print("No schedule information provided.");
      return []; // 빈 리스트 반환
    }

    final List<Map<String, dynamic>> parsedData = [];
    final timeSlots = timeStr.split(', ').map((slot) => slot.trim()).toList();

    for (String timeSlot in timeSlots) {
      try {
        if (!timeSlot.contains('~')) {
          print('Invalid timeSlot format: $timeSlot');
          continue; // 시간 범위(~)가 없는 경우 건너뜀
        }

        // 요일 추출
        final day = timeSlot.substring(0, 1);

        // 장소 여부 확인
        String location = "NULL";
        if (timeSlot.contains('(')) {
          location = timeSlot.split('(')[1].replaceAll(')', '').trim();
        }

        // 시간 범위 추출
        final timeRange = timeSlot.split('(')[0];
        final times = timeRange.substring(1).split('~');

        // times 배열 검증
        if (times.length != 2 || !times[0].contains(':') || !times[1].contains(':')) {
          print('Invalid time range: $timeRange');
          continue; // 잘못된 형식은 건너뜀
        }

        // 시작 시간과 끝 시간 추출
        final startHour = int.parse(times[0].split(':')[0]);
        final startMinute = int.parse(times[0].split(':')[1]);
        final endHour = int.parse(times[1].split(':')[0]);
        final endMinute = int.parse(times[1].split(':')[1]);

        // 데이터를 리스트에 추가
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

  void _showSubjectDetail(BuildContext context, Map<String, dynamic> subject) async {
    try {
      final url = Uri.parse('http://localhost:8080/api/lectures/getLectureInfo');
      final response = await http.post(
        url,
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'lectureId': subject['lecture_id'].toString(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rating = data['ratingTotal'] / (data['ratingCount'] == 0 ? 1 : data['ratingCount']);
        final difficulty = data['difficultyTotal'] / (data['difficultyCount'] == 0 ? 1 : data['difficultyCount']);
        final learningAmount = data['learningAmountTotal'] / (data['learningAmountCount'] == 0 ? 1 : data['learningAmountCount']);

        // 더미 데이터
        final List<Map<String, dynamic>> recommendedSubjects = [
          {
            'subject': '알고리즘',
            'professor': '공교수',
            'location': '공5410',
            'time': '월9:00-15:00, 수9:00-11:00',
          },
          {
            'subject': '기계학습',
            'professor': '이교수',
            'location': '공5413',
            'time': '월9:00-11:00, 금12:00-13:00',
          },
          {
            'subject': '컴퓨터일반',
            'professor': '박교수',
            'location': '공5409',
            'time': '금12:00-16:00',
          },
        ];

        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
          ),
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${subject['subject']} - ${subject['professor']}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFE74C3C),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          color: Colors.white,
                          onPressed: () {
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
                          },
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
                              (index) => Icon(Icons.star, size: 16)
                      ),
                      if (rating % 1 > 0)
                        Icon(Icons.star_half, size: 16),
                      Text(' (${rating.toStringAsFixed(1)}/5.0)', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '학업량 - ${_getLearningAmountText(learningAmount)}',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    '대체 과목',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  ...recommendedSubjects.map((rec) => Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${rec['subject']} / ${rec['location']} / ${rec['time']}',
                          style: TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  )).toList(),
                  SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      }
    } catch (e) {
      print('강의 평가를 불러오는데 실패했습니다. 에러: $e');
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

  void _deleteSubject(BuildContext context, Map<String, dynamic> subject) {
    // TimetableProvider에서 removeSubject 호출
    Provider.of<TimetableProvider>(context, listen: false).removeSubject(subject);
    Navigator.pop(context); // Bottom sheet 닫기
  }


}