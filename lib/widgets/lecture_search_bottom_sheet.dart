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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchRecommendedLectures();
    });
  }

  // 추천 강의를 가져오는 함수
  Future<void> fetchRecommendedLectures() async {
    try {
      print("API 호출 시작");
      List<
          dynamic> recommendedLectures = await getRecommendedLectures(); // 비동기 호출

      if (recommendedLectures.isEmpty) {
        print("추천 강의가 없습니다.");
      } else {
        print("추천 강의가 있습니다.");
      }

      setState(() {
        lectureList = recommendedLectures; // 화면에 반영
        filteredLectures = recommendedLectures;
      });
    } catch (error) {
      print("추천 강의 로드 실패: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("추천 강의를 가져오는 데 실패했습니다."),
        ),
      );
    }
  }


  // 추천 강의 API 호출 (Mock 또는 실제 API 연결)
  Future<List<dynamic>> getRecommendedLectures() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception("토큰이 없습니다. 로그인이 필요합니다.");
      }

      final response = await http.post(
        Uri.parse("http://localhost:8080/api/lectures/recommendLecture"),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "year": 2024,
          "semester": "2학기",
          "page": 0,
          "size": 10, // 최대 10개의 추천 강의 표시
        }),
      );

      if (response.statusCode == 200) {
        // 응답 본문을 UTF-8로 디코딩
        final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));

        if (decodedResponse is Map) {
          // Map 안에 "lectures"라는 키가 있을 경우 해당 리스트를 반환
          return decodedResponse['lectures'] ?? [];
        } else {
          throw Exception("응답 형식이 예상과 다릅니다.");
        }
      } else {
        throw Exception("추천 강의 조회 실패: ${response.statusCode}");
      }
    } catch (error) {
      print("추천 강의 조회 중 오류 발생: $error");
      return [];
    }
  }

  bool isSearching = false;  // 검색 상태를 나타내는 변수
  // 검색 버튼을 눌렀을 때 호출되는 함수
  void searchButtonPressed() async {
    // 강의 검색 후 결과 받아오기
    isSearching = true;
    List<dynamic> lectures = await searchLecturesByName(subjectName);

    // 검색된 강의 목록을 화면에 표시
    setState(() {
      lectureList = lectures; // lectureList를 업데이트하여 화면에 표시
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
      isScrollControlled: true,
      // Bottom Sheet가 화면의 중앙에 나타나도록 설정
      backgroundColor: Colors.transparent,
      // 배경을 투명하게 설정
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
        throw Exception("로그인이 필요합니다. 다시 로그인해주세요.");
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
        // 강의 추가 성공
        _showSuccessDialog(lecture['subjectName']);

        // 시간표 새로고침
        final semesterProvider = Provider.of<SemesterProvider>(context, listen: false);
        await semesterProvider.fetchEnrollments();
      } else {
        // 응답 상태 코드에 따라 메시지 처리
        final errorMessage = _getErrorMessage(response.statusCode);
        _showErrorDialog(errorMessage);
      }
    } catch (error) {
      print("강의 수강 신청 중 오류 발생: $error");
      _showErrorDialog("강의 수강 신청 중 알 수 없는 오류가 발생했습니다.");
    }
  }

// 성공 다이얼로그 표시
  void _showSuccessDialog(String subjectName) {
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("수강 신청 성공"),
            content: Text("'${subjectName}' 강의가 성공적으로 수강 신청되었습니다."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                  Navigator.pop(context); // 검색 창 닫기
                },
                child: const Text("확인"),
              ),
            ],
          );
        },
      );
    }
  }

// 에러 다이얼로그 표시
  void _showErrorDialog(String message) {
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("수강 신청 실패"),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("확인"),
              ),
            ],
          );
        },
      );
    }
  }

// 상태 코드에 따른 에러 메시지 반환
  String _getErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return "수강 신청에 실패했습니다: 이미 신청한 강의입니다.";
      case 403:
        return "수강 신청 권한이 없습니다. 다시 로그인해주세요.";
      case 409:
        return "수강 신청 실패: 강의 시간이 중복됩니다.";
      default:
        return "수강 신청 실패: 서버 오류 ($statusCode).";
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
          // 필터링된 강의 목록 표시
          Expanded(
            child: filteredLectures.isEmpty
                ? Center(
              child: Text(
                '추천 강의가 없습니다.',
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
                  subtitle: Row(
                    children: [
                      Text(
                        '${lecture['professorInformation'] ?? '교수 정보 없음'}',
                      ),
                      SizedBox(width: 8),
                      Text(
                        '${lecture['scheduleInformation'] ?? '시간 정보 없음'}',
                      ),
                      // 강의 옆에 "추천 강의" 표시
                      SizedBox(width: 8),
                      if (!isSearching)
                        Text(
                          '추천 강의',  // 여기서 강의 옆에 "추천 강의" 표시
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
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
