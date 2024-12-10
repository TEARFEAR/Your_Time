import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/lecture_service.dart'; // API 함수들
import '../utils/utils.dart';

// Widget
import 'issue_division_selector.dart'; // 과목 분류 바텀 시트 위젯
import 'package:http/http.dart' as http;

// provider
import '../providers/semester_provider.dart';

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
  void addLectureToTimetable(Map<String, dynamic> lecture) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception("토큰이 없습니다. 로그인이 필요합니다.");
      }

      // 수강 신청 API 호출
      final response = await http.post(
        Uri.parse("http://localhost:8080/api/lectures/enrollment"),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({"lectureId": lecture["id"]}),
      );

      if (response.statusCode == 200) {
        // 강의 추가 성공 시 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("'${lecture['subjectName']}' 강의가 성공적으로 수강 신청되었습니다."),
          ),
        );
        Navigator.pop(context); // 검색 창 닫기
        
        // 시간표 새로고침
        final semesterProvider = Provider.of<SemesterProvider>(context, listen: false);
        await semesterProvider.fetchEnrollments();
      } else {
        // 강의 추가 실패 시 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("강의 수강 신청 실패: ${response.statusCode}"),
          ),
        );
      }
    } catch (error) {
      print("강의 수강 신청 중 오류 발생: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("강의 수강 신청 중 오류가 발생했습니다."),
        ),
      );
    }
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

  void showFilterOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '필터',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                onChanged: (value) {
                  setState(() {
                    scheduleInformation = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: "시간대",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  showCategorySelector();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  side: BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text("과목 구분 선택"),
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close),
              ),
              Text(
                '과목 검색',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 40),
            ],
          ),
          SizedBox(height: 20),
          TextField(
            onChanged: (value) {
              setState(() {
                subjectName = value;
              });
            },
            decoration: InputDecoration(
              hintText: "과목명",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: showFilterOptions,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    side: BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text("필터"),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: searchButtonPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text("검색"),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: filteredLectures.isEmpty
                ? Center(
                    child: Text(
                      '검색 결과가 없습니다.',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredLectures.length,
                    itemBuilder: (context, index) {
                      final lecture = filteredLectures[index];
                      return ListTile(
                        title: Text(lecture['subjectName'] ?? '정보 없음'),
                        subtitle: Text(
                          '${lecture['professorInformation'] ?? '교수 정보 없음'} / ${lecture['scheduleInformation'] ?? '시간 정보 없음'}',
                        ),
                        onTap: () => showAddLectureDialog(lecture),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
