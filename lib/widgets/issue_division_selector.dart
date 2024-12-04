import 'package:flutter/material.dart';

class CategorySelector extends StatefulWidget {
  final List<String> selectedCategories;
  final Function(List<String>) onCategoriesChanged;

  const CategorySelector({
    Key? key,
    required this.selectedCategories,
    required this.onCategoriesChanged,
  }) : super(key: key);

  @override
  _CategorySelectorState createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Align(
        alignment: Alignment.center,
        child: Container(
          height: 600, // 고정된 높이값 설정
          margin: const EdgeInsets.only(left: 20, right: 20, bottom: 50),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "과목 구분 선택",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // 과목 분류 목록
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    '일반선택',
                    '교직',
                    '교양(일반)',
                    '교양(공통기초)',
                    '전공(기초)',
                    '전공(핵심)',
                    '전공(심화)',
                  ].map((category) {
                    return CheckboxListTile(
                      title: Text(category),
                      value: widget.selectedCategories.contains(category),
                      onChanged: (selected) {
                        setState(() {
                          if (selected == true) {
                            widget.selectedCategories.add(category);
                          } else {
                            widget.selectedCategories.remove(category);
                          }
                          widget.onCategoriesChanged(widget.selectedCategories); // 선택된 카테고리를 상위로 전달
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 10),
              // 확인 버튼
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Bottom Sheet 닫기
                  },
                  child: const Text("확인"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
