import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
      Uri.parse("http://localhost:8080/api/lectures/getLectureInfoByNameContaining"),
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
