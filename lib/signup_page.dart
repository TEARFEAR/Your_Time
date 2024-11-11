import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _pwController = TextEditingController();
  String? selectedPreference; // 성향 선택 변수 (아직 api 구성 x)

  final Map<String, int> preferenceMap = {
    '안정형': 1,
    '밸런스형': 2,
    '도전형': 3,
  };

  Future<void> _signup() async {
    final id = _idController.text;
    final name = _nameController.text;
    final pw = _pwController.text;
    final tendency = preferenceMap[selectedPreference];

    final url = Uri.parse('http://localhost:8080/api/auth/signup');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': id, 'name': name, 'pw': pw, 'tendency': tendency}),
      );

      if (response.statusCode == 200) {
        print("회원가입 성공");
        Navigator.pop(context); // 회원가입 후 로그인 화면으로 돌아감
      } else if (response.statusCode == 401) {
        print("회원가입 실패: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('회원가입에 실패했습니다. 다시 시도해주세요.')),
        );
      } else {
        print("알 수 없는 오류 발생: ${response.statusCode}");
      }
    } catch (e) {
      print("회원가입 중 오류 발생: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('네트워크 오류가 발생했습니다. 다시 시도해주세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Form( // 여기에 Form 위젯 추가
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 30),
              Center(
                child: Text(
                  '회원가입',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 40),
              // 이름 입력 필드
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: '이름',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이름을 입력해주세요.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              // 아이디 입력 필드
              TextFormField(
                controller: _idController,
                decoration: InputDecoration(
                  hintText: '아이디',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '아이디를 입력해주세요.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              // 비밀번호 입력 필드
              TextFormField(
                controller: _pwController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: '비밀번호',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: Icon(Icons.visibility_off),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호를 입력해주세요.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              // 성향 선택 Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                hint: Text('본인의 성향을 선택해 주세요'),
                value: selectedPreference,
                items: ['안정형', '밸런스형', '도전형'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedPreference = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return '성향을 선택해 주세요';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              // 회원가입 버튼
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _signup();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, // 검은색 배경
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  '회원가입',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}