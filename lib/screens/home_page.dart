import 'package:flutter/material.dart';

import '../profile_page.dart';

// 위젯
import '../widgets/timetable_widget.dart';
import '../widgets/lecture_search_bottom_sheet.dart';

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
              child: Stack(
                children: [
                  Column(
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
                                          content: StatefulBuilder(
                                            builder: (BuildContext context, StateSetter setState) {
                                              return Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
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
                                                          setState(() {
                                                            semesterProvider.setYear(value);
                                                          });
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                  SizedBox(height: 16),
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
                                                          setState(() {
                                                            semesterProvider.setSemester(value);
                                                          });
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
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
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: IconButton(
                                icon: Icon(Icons.person),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => ProfileScreen()),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      TimetableWidget(dynamicBoxSize: dynamicBoxSize),
                    ],
                  ),
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: FloatingActionButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                          ),
                          builder: (BuildContext context) {
                            return FractionallySizedBox(
                              heightFactor: 0.8,
                              child: const LectureSearchBottomSheet(),
                            );
                          },
                        );
                      },
                      backgroundColor: Colors.black,
                      child: Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ],
              ),
            )
          : Container(),
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
