import 'package:flutter/material.dart';

class TimetableWidget extends StatelessWidget {
  final List<String> week = ['월', '화', '수', '목', '금'];
  final int kColumnLength = 13;
  final double kFirstColumnHeight = 20;
  final double kBoxSize = 40;
  final double kTimeColumnWidth = 30.0;

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

  final Map<String, Color> subjectColors = {};
  final List<Color> colorPalette = [
    Colors.blue.withAlpha((0.4 * 255).toInt()),
    Colors.green.withAlpha((0.4 * 255).toInt()),
    Colors.orange.withAlpha((0.4 * 255).toInt()),
    Colors.purple.withAlpha((0.4 * 255).toInt()),
    Colors.pink.withAlpha((0.4 * 255).toInt()),
    Colors.teal.withAlpha((0.4 * 255).toInt()),
  ];

  TimetableWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final availableWidth = screenWidth - (32 + kTimeColumnWidth);
    final dynamicBoxSize = availableWidth / 5;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getSemesterText(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // 과목 추가 버튼
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('과목 추가'),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Stack(
                  children: [
                    Table(
                      columnWidths: {
                        0: FixedColumnWidth(kTimeColumnWidth),
                        for (var i = 1; i <= 5; i++) i: const FlexColumnWidth(),
                      },
                      children: [
                        TableRow(
                          children: [
                            _buildTimeCell(""),
                            ...week.map((day) => _buildDayCell(day)),
                          ],
                        ),
                        ...List.generate(kColumnLength, (index) {
                          return TableRow(
                            children: [
                              _buildTimeCell("${index + 9}"),
                              ...week.map((day) => _buildEmptyCell(dynamicBoxSize)),
                            ],
                          );
                        }),
                      ],
                    ),
                    ...timetable.map((subject) => _buildClassContainer(subject, dynamicBoxSize)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getSemesterText() {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;
    final semester = (month >= 2 && month <= 7) ? 1 : 2;

    return '$year년 $semester학기 시간표';
  }

  Widget _buildTimeCell(String time) {
    return Container(
      height: 30,
      width: 50,
      alignment: Alignment.center,
      child: Text(
        time,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  Widget _buildDayCell(String day) {
    return Container(
      height: 30,
      alignment: Alignment.center,
      child: Text(
        day,
        style: const TextStyle(
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
    return subjectColors.putIfAbsent(
      subject,
          () => colorPalette[subjectColors.length % colorPalette.length],
    );
  }

  Widget _buildClassContainer(Map<String, dynamic> subject, double boxWidth) {
    final timeStr = subject['time'] as String;
    final day = timeStr.split(' ')[0];
    final timeParts = timeStr.split(' ')[1].split('-');
    final startHour = int.parse(timeParts[0]);
    final endHour = int.parse(timeParts[1]);
    final duration = endHour - startHour;

    // 요일에 따른 위치 계산
    final dayIndex = week.indexOf(day);
    final left = kTimeColumnWidth + (dayIndex * boxWidth);
    final top = 30.0 + ((startHour - 9) * kBoxSize);

    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: boxWidth,
        height: kBoxSize * duration,
        decoration: BoxDecoration(
          color: _getSubjectColor(subject['subject'] as String),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 0.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                subject['subject'] as String,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                subject['location'] as String,
                style: const TextStyle(fontSize: 10),
                textAlign: TextAlign.center,
              ),
              Text(
                subject['professor'] as String,
                style: const TextStyle(fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
