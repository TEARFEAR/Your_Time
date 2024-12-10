import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'timetable_provider.dart';

class SemesterProvider with ChangeNotifier {
  int _selectedYear = DateTime.now().year;
  int _selectedSemester = (DateTime.now().month >= 2 && DateTime.now().month <= 7) ? 1 : 2;

  int get selectedYear => _selectedYear;
  int get selectedSemester => _selectedSemester;

  void setYear(int year) {
    _selectedYear = year;
    notifyListeners();
    fetchEnrollments();
  }

  void setSemester(int semester) {
    _selectedSemester = semester;
    notifyListeners();
    fetchEnrollments();
  }

  Future<void> fetchEnrollments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception("토큰이 없습니다. 로그인이 필요합니다.");
      }

      final response = await http.post(
        Uri.parse('http://localhost:8080/api/lectures/findEnrollments'),
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'year': _selectedYear.toString(),
          'semester': (_selectedSemester.toString()+'학기'),
          'page': 0,
          'size': 100  // 충분히 큰 숫자로 설정
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> enrollments = jsonDecode(utf8.decode(response.bodyBytes));
        print('Enrollments from API: $enrollments');
        final List<Map<String, dynamic>> timetableData = enrollments.map((enrollment) {
          return {
            'lecture_id': enrollment['lectureId'],
            'enrollment_id': enrollment['enrollmentId'],
            'subject': enrollment['lectureName'],
            'ScheduleInformation': enrollment['scheduleInformation'],
          };
        }).toList();

        // TimetableProvider 업데이트
        timetableProvider?.setInitialTimetable(timetableData);
      } else {
        timetableProvider?.setInitialTimetable([]);
        throw Exception('Failed to load enrollments');
      }
    } catch (e) {
      print('Error fetching enrollments: $e');
    }
  }

  // TimetableProvider 참조를 위한 변수
  TimetableProvider? timetableProvider;

  // TimetableProvider 설정
  void setTimetableProvider(TimetableProvider provider) {
    timetableProvider = provider;
  }

  List<Map<String, dynamic>> parseTimeStr(String? timeStr) {
    if (timeStr == null || timeStr.trim().isEmpty) {
      print("No schedule information provided.");
      return [];
    }

    final List<Map<String, dynamic>> parsedData = [];
    final timeSlots = timeStr.split(', ').map((slot) => slot.trim()).toList();

    for (String timeSlot in timeSlots) {
      try {
        if (!timeSlot.contains('~')) {
          print('Invalid timeSlot format: $timeSlot');
          continue;
        }

        // 요일 추출
        final day = timeSlot.substring(0, 1);
        
        // 시간과 장소 분리
        final timeAndLocation = timeSlot.substring(1).split('(');
        final time = timeAndLocation[0];
        final location = timeAndLocation[1].replaceAll(')', '');

        // 시작 시간과 종료 시간 분리
        final times = time.split('~');
        final startTime = times[0];
        final endTime = times[1];

        // 시작 시간과 종료 시간을 시간과 분으로 분리
        final startHourMin = startTime.split(':');
        final endHourMin = endTime.split(':');

        parsedData.add({
          'day': day,
          'startHour': int.parse(startHourMin[0]),
          'startMinute': int.parse(startHourMin[1]),
          'endHour': int.parse(endHourMin[0]),
          'endMinute': int.parse(endHourMin[1]),
          'location': location,
        });
      } catch (e) {
        print('Error parsing timeSlot: $timeSlot, Error: $e');
        continue;
      }
    }

    return parsedData;
  }
}