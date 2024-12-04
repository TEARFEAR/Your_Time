// 강의 필터링 함수
List<Map<String, dynamic>> filterLectures({
  required List<dynamic> lectureList,
  required String scheduleInformation,
  required List<String> selectedCategories,
}) {
  return lectureList.where((lecture) {
    if (lecture is! Map<String, dynamic>) return false;

    final matchesSchedule = scheduleInformation.isEmpty ||
        (lecture['scheduleInformation']?.contains(scheduleInformation) ?? false);

    final matchesCategory = selectedCategories.isEmpty ||
        selectedCategories.contains(lecture['issueDivision'] ?? '');

    return matchesSchedule && matchesCategory;
  }).cast<Map<String, dynamic>>().toList();
}

String getSemesterText() {
  final now = DateTime.now();
  final year = now.year;
  final month = now.month;
  final semester = (month >= 2 && month <= 7) ? 1 : 2;

  return '$year년 $semester학기\n시간표';
}
