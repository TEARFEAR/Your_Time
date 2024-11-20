import 'package:flutter/material.dart';
import 'profile_page.dart';

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

    if (index == 1) {
      _showProfileScreen();
    }
  }

  void _showProfileScreen() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (BuildContext context) {
        return ProfileScreen(); // ProfileScreen을 모달로 표시
      },
    );
  }

  final List<String> week = ['월', '화', '수', '목', '금'];
  final int kColumnLength = 13;
  final double kFirstColumnHeight = 20;
  final double kBoxSize = 43;
  final double kTimeColumnWidth = 20.0;

  List<Map<String, dynamic>> _timetable = [
    {
      'subject': '데이터베이스',
      'professor': '김교수',
      'time': '월12:00~14:00(공2114), 화17:00~19:00(공2114)'
    },
    {
      'subject': '알고리즘',
      'professor': '이교수',
      'time': '화13:00~15:00(공2114), 목13:00~15:00(공2114)'
    },
    {
      'subject': '운영체제',
      'professor': '박교수',
      'time': '수10:00~12:00(공2114), 목10:00~12:00(공2114)'
    },
    {
      'subject': '컴퓨터네트워크',
      'professor': '최교수',
      'time': '목15:00~17:00(공2114)'
    },
    {
      'subject': '소프트웨어공학',
      'professor': '정교수',
      'time': '금11:00~13:00(공2114)'
    }
  ];

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

  String _getSemesterText() {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;
    final semester = (month >= 2 && month <= 7) ? 1 : 2;

    return '$year년 $semester학기\n시간표';
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
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      // 추후 구현
                    },
                    icon: Icon(Icons.add),
                    label: Text(
                      '과목 추가',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
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
                      ...[..._timetable.map((subject) => _buildClassContainers(subject, dynamicBoxSize))].expand((x) => x),
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
        style: TextStyle(fontSize: 10),
      ),
    );
  }

  Widget _buildDayCell(String day) {
    return Container(
      height: 20,
      alignment: Alignment.center,
      child: Text(
        day,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 10,
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

  List<Widget> _buildClassContainers(Map<String, dynamic> subject, double boxWidth) {
    final List<Widget> containers = [];
    final timeStr = subject['time'].toString();
    final timeSlots = timeStr.split(', ');

    for (String timeSlot in timeSlots) {
      final day = timeSlot.substring(0, 1);
      final timeRange = timeSlot.split('(')[0];
      final times = timeRange.substring(1).split('~');
      final startHour = int.parse(times[0].split(':')[0]);
      final endHour = int.parse(times[1].split(':')[0]);
      final duration = endHour - startHour;
      final location = timeSlot.split('(')[1].replaceAll(')', '');

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
                color: _getSubjectColor(subject['subject']),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 0.5,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(3.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject['subject'],
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      location,
                      style: TextStyle(fontSize: 7),
                    ),
                    Text(
                      subject['professor'],
                      style: TextStyle(fontSize: 7),
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

  void _showSubjectDetail(BuildContext context, Map<String, dynamic> subject) { // 과목 상세 페이지
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.delete_outline),
                      color: Colors.white,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('과목 삭제'),
                              content: Text('이 과목을 시간표에서 삭제하시겠습니까?'),
                              actions: [
                                TextButton(
                                  child: Text('취소'),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                TextButton(
                                  child: Text(
                                    '삭제',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _deleteSubject(subject);
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
              SizedBox(height: 16),
              Text(
                '과목 난이도 - 상',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Text('평점 - '),
                  ...List.generate(4, (index) => Icon(Icons.star, size: 16)),
                  Icon(Icons.star_half, size: 16),
                  Text(' (4.0/5.0)'),
                ],
              ),
              SizedBox(height: 8),
              Text('학업량 - 많음'),
              SizedBox(height: 16),
              Divider(),
              SizedBox(height: 16),
              Text(
                '대체 과목',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              Text('알고리즘 / 공5410 / 월9:00-15:00, 수9:00-11:00'),
              SizedBox(height: 8),
              Text('기계학습 / 공5413 / 월9:00-11:00, 금12:00-13:00'),
              SizedBox(height: 8),
              Text('컴퓨터일반 / 공5409 / 금12:00-16:00'),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _deleteSubject(Map<String, dynamic> subject) {
    setState(() {
      _timetable.removeWhere((item) =>
        item['subject'] == subject['subject'] &&
        item['professor'] == subject['professor']
      );
    });
    Navigator.pop(context); // 팝업 닫기
  }
}
