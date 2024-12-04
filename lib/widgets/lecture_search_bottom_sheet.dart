import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/lecture_service.dart'; // API 함수들
import '../utils/utils.dart';

// Widget
import 'issue_division_selector.dart'; // 과목 분류 바텀 시트 위젯

// provider
import '../providers/timetable_provider.dart';

class LectureSearchBottomSheet extends StatefulWidget {
  const LectureSearchBottomSheet({Key? key}) : super(key: key);

  @override
  _LectureSearchBottomSheetState createState() =>
      _LectureSearchBottomSheetState();
}

class _LectureSearchBottomSheetState extends State<LectureSearchBottomSheet> {
  List<dynamic> lectureList = []; // 강의 목록
  List<dynamic> filteredLectures = []; // 필터링된 강의 목록
  List<String> selectedCategories = []; // 카테고리 목록

  String subjectName = ''; // 과목명 검색어
  String scheduleInformation = ''; // 시간대 검색어

  // 검색 버튼을 눌렀을 때 호출되는 함수
  void searchButtonPressed() async {

    // 강의 검색 후 결과 받아오기
    List<dynamic> lectures = await searchLecturesByName(subjectName);

    // 검색된 강의 목록을 화면에 표시
    setState(() {
      lectureList = lectures;  // lectureList를 업데이트하여 화면에 표시
      filteredLectures = filterLectures(
        lectureList: lectureList,
        scheduleInformation: scheduleInformation,
        selectedCategories: selectedCategories,
      );
    });
  }

  // 카테고리 선택을 위한 Bottom Sheet 열기
  void showCategorySelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Bottom Sheet가 화면의 중앙에 나타나도록 설정
      backgroundColor: Colors.transparent, // 배경을 투명하게 설정
      isDismissible: true,
      builder: (context) {
        return CategorySelector(
          selectedCategories: selectedCategories,
          onCategoriesChanged: (updatedCategories) {
            setState(() {
              selectedCategories = updatedCategories; // 선택된 카테고리 업데이트
            });
          },
        );
      },
    );
  }

  // 강의를 시간표에 추가하는 함수
  void addLectureToTimetable(Map<String, dynamic> lecture) {
    // TimetableProvider 사용
    Provider.of<TimetableProvider>(context, listen: false).addSubject(lecture);

    // 강의 추가 후 메시지 표시
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("'${lecture['subjectName']}' 강의가 시간표에 추가되었습니다."),
      ),
    );
  }

  void showAddLectureDialog(Map<String, dynamic> lecture) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("강의 추가"),
          content: Text(
            "시간표에 '${lecture['subjectName'] ?? '강의'}' 강의를 추가하시겠습니까?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: const Text("취소"),
            ),
            TextButton(
              onPressed: () {
                addLectureToTimetable(lecture); // 강의 추가 함수 호출
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: const Text("추가"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        height: MediaQuery.of(context).size.height * 0.9,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.close),
                ),
                const Text(
                  '과목 검색',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 48), // 닫기 버튼과 대칭 맞춤
              ],
            ),
            const SizedBox(height: 16.0),
            // 검색 필터 UI
            TextField(
              onChanged: (value) {
                setState(() {
                  subjectName = value;
                });
              },
              decoration: const InputDecoration(
                labelText: "과목명",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8.0),
            TextField(
              onChanged: (value) {
                setState(() {
                  scheduleInformation = value;
                });
              },
              decoration: const InputDecoration(
                labelText: "시간대",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: showCategorySelector,
              child: const Text("과목 구분 선택"),
            ),
            const SizedBox(height: 16.0),
            // 검색 버튼
            ElevatedButton(
              onPressed: searchButtonPressed,  // 검색 버튼을 눌렀을 때 호출되는 함수
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text(
                "검색",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 16.0),
            // 검색 결과 표시
            Expanded(
              child: filteredLectures.isEmpty
                  ? const Center(
                child: Text("검색 결과가 없습니다."),
              )
                  : ListView.builder(
                itemCount: filteredLectures.length,
                itemBuilder: (context, index) {
                  final lecture = filteredLectures[index];
                  return ListTile(
                    title: Text(lecture['subjectName'] ?? '정보 없음'),
                    subtitle: Text(lecture['scheduleInformation'] ?? '시간 정보 없음'),
                    onTap: () => showAddLectureDialog(lecture),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
