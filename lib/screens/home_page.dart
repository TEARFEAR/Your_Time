import 'package:flutter/material.dart';

import '../utils/utils.dart';
import '../profile_page.dart';

// 위젯
import '../widgets/timetable_widget.dart';
import '../widgets/lecture_search_bottom_sheet.dart';
import '../widgets/custom_bottom_navigation.dart';

// provider
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../providers/timetable_provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // ProfileProvider의 fetchProfileData 호출
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProfileProvider>(context, listen: false).fetchProfileData();
    });

    // TimetableProvider 초기화 (빈 타임테이블 설정)
    Provider.of<TimetableProvider>(context, listen: false).setInitialTimetable([]);
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      // "내 정보" 화면으로 전환
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfileScreen()),
      ).then((_) {
        // "내 정보" 화면에서 돌아오면 홈 화면 상태로 복원
        setState(() {
          _selectedIndex = 0;
        });
      });
    } else {
      // 홈 버튼 동작
      setState(() {
        _selectedIndex = index;
      });
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  final int kColumnLength = 13;
  final double kTimeColumnWidth = 20.0;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final availableWidth = screenWidth - (32 + kTimeColumnWidth);
    final dynamicBoxSize = availableWidth / 5;

    return Scaffold(
      body: _selectedIndex == 0
          ? SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    getSemesterText(),
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      // 과목 추가 버튼 클릭 시 바텀 시트를 띄움
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(15)),
                        ),
                        builder: (BuildContext context) {
                          return const LectureSearchBottomSheet(); // 검색 바텀 시트를 표시
                        },
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text(
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
            TimetableWidget(dynamicBoxSize: dynamicBoxSize),
          ],
        ),
      )
          : Container(),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  void addLectureToTimetable(Map<String, dynamic> lecture) {
    setState(() {
      // 예: 시간표 리스트에 강의를 추가
      //_timetable.add(lecture);
    });

    // 성공 메시지 출력 (선택 사항)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("'${lecture['subjectName']}' 강의가 시간표에 추가되었습니다."),
      ),
    );
  }

}
