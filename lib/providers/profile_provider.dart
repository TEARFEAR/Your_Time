import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileProvider with ChangeNotifier {
  String m_id = '';
  String m_pw = '';
  String m_name = '';
  String m_department = '';
  int m_tendency = 0;
  int m_difficulty = 0;
  int m_learningAmount = 0;
  bool isLoading = true;

  Future<void> fetchProfileData() async {
    try {
      final token = await getToken();

      if (token == null) {
        return;
      }

      final url = Uri.parse('http://10.0.2.2:8080/api/members/info');
      print('요청 URL: $url');

      final response = await http.get(
        url,
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        m_id = data['id'] ?? '';
        m_pw = data['pw'] ?? '';
        m_name = data['name'] ?? '';
        m_department = data['department'] ?? '';
        m_tendency = (data['tendency'] as num).toInt(); // double -> int 변환
        m_difficulty = (data['difficulty'] as num).toInt(); // double -> int 변환
        m_learningAmount = (data['learningAmount'] as num).toInt(); // double -> int 변환
        isLoading = false;
        notifyListeners();
      } else {
        print('회원정보를 불러오는데 실패했습니다. 상태 코드: ${response.statusCode}');
      }
    } catch (e) {
      print('회원정보를 불러오는데 실패했습니다. 에러: $e');
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print('저장된 토큰: $token');
    return token;
  }
}
