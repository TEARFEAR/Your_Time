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
import '../providers/semester_provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ProfileProvider 초기화
      Provider.of<ProfileProvider>(context, listen: false).fetchProfileData();
      
      // TimetableProvider와 SemesterProvider 연결
      final timetableProvider = Provider.of<TimetableProvider>(context, listen: false);
      final semesterProvider = Provider.of<SemesterProvider>(context, listen: false);
      
      // SemesterProvider에 TimetableProvider 참조 설정
      semesterProvider.setTimetableProvider(timetableProvider);
      
      // 초기 시간표 데이터 로드
      semesterProvider.fetchEnrollments();
    });
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
                  Consumer<SemesterProvider>(
                    builder: (context, semesterProvider, child) {
                      return GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('학기 선택'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // 연도 선택
                                    Container(
                                      width: double.infinity,
                                      child: DropdownButton<int>(
                                        isExpanded: true,
                                        value: semesterProvider.selectedYear,
                                        items: List.generate(5, (index) {
                                          final year = DateTime.now().year - 2 + index;
                                          return DropdownMenuItem(
                                            value: year,
                                            child: Text('$year년'),
                                          );
                                        }),
                                        onChanged: (value) {
                                          if (value != null) {
                                            semesterProvider.setYear(value);
                                          }
                                        },
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    // 학기 선택
                                    Container(
                                      width: double.infinity,
                                      child: DropdownButton<int>(
                                        isExpanded: true,
                                        value: semesterProvider.selectedSemester,
                                        items: [
                                          DropdownMenuItem(value: 1, child: Text('1학기')),
                                          DropdownMenuItem(value: 2, child: Text('2학기')),
                                        ],
                                        onChanged: (value) {
                                          if (value != null) {
                                            semesterProvider.setSemester(value);
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('확인'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Text(
                          '${semesterProvider.selectedYear}년 ${semesterProvider.selectedSemester}학기\n시간표',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      // 과목 추가 버튼 클릭 시 바텀 시트를 띄움
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                        ),
                        builder: (BuildContext context) {
                          return FractionallySizedBox(
                            heightFactor: 0.8,  // 화면 높이의 90%
                            child: const LectureSearchBottomSheet(),
                          );
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
