import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// 강의 정보 DB에 저장하는 함수
Future<void> fetchLectures() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception("토큰이 없습니다. 로그인이 필요합니다.");
    }

    // 연도와 학기를 계산
    final yearAndSemester = _getYearAndSemester();
    final year = yearAndSemester['year'];
    final semester = yearAndSemester['semester'];

    // API 호출
    final responseFetch = await http.post(
      Uri.parse("http://10.0.2.2:8080/api/lectures/fetch?year=$year&semester=$semester"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // 헤더에 토큰 추가
      },
    );

    if (responseFetch.statusCode == 200) {
      print("강의 정보 업데이트 성공: ${responseFetch.body}");
    } else {
      throw Exception("강의 정보 업데이트 실패: ${responseFetch.statusCode}");
    }
  } catch (error) {
    print("강의 데이터를 불러오는 데 실패했습니다: $error");
  }
}

// 과목명 기준으로 강의 검색 함수
Future<List<dynamic>> searchLecturesByName(String lectureName) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception("토큰이 없습니다. 로그인이 필요합니다.");
    }

    // API 호출 본문 구성
    final requestBody = {
      "lectureName": lectureName,
    };

    // API 호출
    final response = await http.post(
      Uri.parse("http://10.0.2.2:8080/api/lectures/getLectureInfoByNameContaining"),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token', // 헤더에 토큰 추가
      },
      body: utf8.encode(jsonEncode(requestBody)),
    );

    if (response.statusCode == 200) {
      final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
      print("검색이 성공적으로 완료되었습니다.");
      return decodedResponse;  // 검색 결과 반환
    } else if (response.statusCode == 404) {
      print("검색 결과가 없습니다.");
      return [];  // 검색 결과가 없으면 빈 리스트 반환
    } else {
      throw Exception("강의 검색 실패: ${response.statusCode}");
    }
  } catch (error) {
    print("강의 검색 중 오류가 발생했습니다: $error");
    return [];  // 오류 발생 시 빈 리스트 반환
  }
}

// 연도와 학기를 계산하는 함수
Map<String, int> _getYearAndSemester() {
  final now = DateTime.now();
  final year = now.year;
  final semester = (now.month >= 2 && now.month <= 7) ? 1 : 2; // 1학기: 2~7월, 2학기: 그 외
  return {'year': year, 'semester': semester};
}
