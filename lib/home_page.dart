import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // 하단 메뉴바 구현 (아직 안함)
  }

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
    Colors.blue.withOpacity(0.4),
    Colors.green.withOpacity(0.4),
    Colors.orange.withOpacity(0.4),
    Colors.purple.withOpacity(0.4),
    Colors.pink.withOpacity(0.4),
    Colors.teal.withOpacity(0.4),
  ];

  String _getSemesterText() {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;
    final semester = (month >= 2 && month <= 7) ? 1 : 2;

    return '$year년 $semester학기 시간표';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final availableWidth = screenWidth - (32 + kTimeColumnWidth);
    final dynamicBoxSize = availableWidth / 5;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getSemesterText(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      // 추후 구현
                    },
                    icon: Icon(Icons.add),
                    label: Text('과목 추가'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
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
                          // 시간표 셀
                          ...List.generate(kColumnLength, (index) {
                            final hour = index + 9;
                            return TableRow(
                              children: [
                                _buildTimeCell("$hour"),
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
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '내 정보',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
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

    // 요일에 따른 위치 계산
    final dayIndex = week.indexOf(day); // 시간 열을 고려하지 않음
    final left = kTimeColumnWidth + (dayIndex * boxWidth); // 50은 시간 열의 너비
    final top = 30.0 + ((startHour - 9) * kBoxSize); // 30은 요일 행의 높이

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
