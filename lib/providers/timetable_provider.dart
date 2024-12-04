import 'package:flutter/material.dart';

class TimetableProvider with ChangeNotifier {
  List<Map<String, dynamic>> _timetable = [];

  List<Map<String, dynamic>> get timetable => _timetable;

  void setInitialTimetable(List<Map<String, dynamic>> initialTimetable) {
    _timetable = initialTimetable;
    notifyListeners();
  }

  void addSubject(Map<String, dynamic> newSubject) {
    _timetable.add(newSubject);
    notifyListeners();
  }

  void removeSubject(Map<String, dynamic> subjectToRemove) {
    _timetable.remove(subjectToRemove);
    notifyListeners();
  }
}
