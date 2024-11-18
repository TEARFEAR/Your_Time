import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final List<String> week = ['월', '화', '수', '목', '금'];
  final int kColumnLength = 13; // 9시부터 21시까지 
  final double kFirstColumnHeight = 20;
  final double kBoxSize = 60;

  final List<Map<String, dynamic>> timetable = [
    {
      'subject': '데이터베이스',
      'professor': '김교수',
      'location': '공학관 401',
      'time': '월 9-11'
    },
    {
      'subject': '알고리즘',
      'professor': '이교수', 
      'location': '과학관 202',
      'time': '화 13-15'
    },
    {
      'subject': '운영체제',
      'professor': '박교수',
      'location': '공학관 502',
      'time': '수 10-12'
    },
    {
      'subject': '컴퓨터네트워크',
      'professor': '최교수',
      'location': '과학관 401',
      'time': '목 15-17'
    },
    {
      'subject': '소프트웨어공학',
      'professor': '정교수',
      'location': '공학관 304',
      'time': '금 11-13'
    }
  ];

  // 과목별 색상을 저장하는 Map
  final Map<String, Color> subjectColors = {};
  final List<Color> colorPalette = [
    Colors.blue.withOpacity(0.2),
    Colors.green.withOpacity(0.2),
    Colors.orange.withOpacity(0.2),
    Colors.purple.withOpacity(0.2),
    Colors.pink.withOpacity(0.2),
    Colors.teal.withOpacity(0.2),
  ];

  @override
  Widget build(BuildContext context) {
    // 화면 크기에 따라 동적으로 박스 크기 계산
    final screenWidth = MediaQuery.of(context).size.width;
    final availableWidth = screenWidth - 82; // 패딩과 시간 열 너비 고려
    final dynamicBoxSize = availableWidth / 5; // 5일로 균등 분할

    return Scaffold(
      appBar: AppBar(
        title: Text('2023년 2학기 시간표'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // 과목 추가 기능 구현
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16.0),
              child: Stack(
                children: [
                  Table(
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
                      // 시간표 셀
                      ...List.generate(kColumnLength, (index) {
                        final hour = index + 9; // 9시부터 시작
                        return TableRow(
                          children: [
                            _buildTimeCell("$hour:00"),
                            ...week.map((day) => _buildEmptyCell(dynamicBoxSize)),
                          ],
                        );
                      }),
                    ],
                  ),
                  // 과목 컨테이너들을 Stack으로 쌓기
                  ...timetable.map((subject) => _buildClassContainer(subject, dynamicBoxSize)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeCell(String time) {
    return Container(
      height: 30,
      width: 50,
      alignment: Alignment.center,
      child: Text(
        time,
        style: TextStyle(fontSize: 12),
      ),
    );
  }

  Widget _buildDayCell(String day) {
    return Container(
      height: 30,
      alignment: Alignment.center,
      child: Text(
        day,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildEmptyCell(double width) {
    return Container(
      height: kBoxSize,
      width: width,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade300,
          width: 0.5,
        ),
      ),
    );
  }

  Color _getSubjectColor(String subject) {
    if (!subjectColors.containsKey(subject)) {
      final colorIndex = subjectColors.length % colorPalette.length;
      subjectColors[subject] = colorPalette[colorIndex];
    }
    return subjectColors[subject]!;
  }

  Widget _buildClassContainer(Map<String, dynamic> subject, double boxWidth) {
    final timeStr = subject['time'].toString();
    final day = timeStr.split(' ')[0];
    final timeParts = timeStr.split(' ')[1].split('-');
    final startHour = int.parse(timeParts[0]);
    final endHour = int.parse(timeParts[1]);
    final duration = endHour - startHour;

    // 요일에 따른 x 위치 계산 (패딩 고려)
    final dayIndex = week.indexOf(day);
    final left = 66.0 + (dayIndex * boxWidth); // 시간 열 너비(50) + 패딩(16)

    // 시작 시간에 따른 y 위치 계산 (패딩 고려)
    final top = 46.0 + ((startHour - 9) * kBoxSize); // 요일 행 높이(30) + 패딩(16)

    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: boxWidth,
        height: kBoxSize * duration,
        decoration: BoxDecoration(
          color: _getSubjectColor(subject['subject']),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 0.5,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(4.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                subject['subject'],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                subject['location'],
                style: TextStyle(fontSize: 10),
                textAlign: TextAlign.center,
              ),
              Text(
                subject['professor'],
                style: TextStyle(fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
