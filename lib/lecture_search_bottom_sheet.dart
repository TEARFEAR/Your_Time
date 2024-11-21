import 'package:flutter/material.dart';
import 'styles.dart';  // 스타일 파일을 가져옴

class LectureSearchBottomSheet extends StatefulWidget {
  const LectureSearchBottomSheet({Key? key}) : super(key: key);

  @override
  _LectureSearchBottomSheetState createState() => _LectureSearchBottomSheetState();
}

class _LectureSearchBottomSheetState extends State<LectureSearchBottomSheet> {
  String? selectedPreference;
  String? searchResult;

  final List<String> subjectCategories = ["교양(일반)", "교양(공통기초)", "전공(기초)", "전공(핵심)", "전공(심화)", "일반선택", "교직"];

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
                    Navigator.of(context).pop(); // 닫기 버튼 동작
                  },
                  icon: const Icon(Icons.close),
                ),
                const Text(
                  '과목 검색',
                  style: AppStyles.titleText,
                ),
                const SizedBox(width: 48), // 닫기 버튼과 대칭을 맞추기 위해 공백 추가
              ],
            ),
            const SizedBox(height: 16.0),
            TextField(
              decoration: AppStyles.inputDecoration('과목명 검색'),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: AppStyles.inputDecoration('과목 분류'),
                    items: subjectCategories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {},
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: AppStyles.inputDecoration('시간대 선택'),
                    items: const [
                      DropdownMenuItem(value: "9:00-12:00", child: Text("9:00-12:00")),
                      DropdownMenuItem(value: "12:00-15:00", child: Text("12:00-15:00")),
                      DropdownMenuItem(value: "15:00-18:00", child: Text("15:00-18:00")),
                    ],
                    onChanged: (value) {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Padding(
              padding: AppStyles.buttonPadding,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    // 예시: 검색 버튼 눌렀을 때 가짜 결과 생성
                    searchResult = "검색 결과가 여기 표시됩니다.";
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text("검색"),
              ),
            ),
            // 검색 결과 영역
            Expanded(
              child: Container(
                padding: AppStyles.resultAreaPadding,
                decoration: AppStyles.resultAreaDecoration,
                width: MediaQuery.of(context).size.width - 32, // 양옆 패딩을 제외하고 꽉 차도록
                child: searchResult == null
                    ? const Center(child: Text("검색 결과가 없습니다."))
                    : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      searchResult!,
                      style: AppStyles.subtitleText,
                    ),
                    // 추가적인 검색 결과 내용이 있다면 여기에 추가
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
