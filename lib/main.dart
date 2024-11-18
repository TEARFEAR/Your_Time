import 'package:flutter/material.dart';
import 'login_page.dart'; // 로그인 화면 파일 import
import 'home_page.dart'; // 홈 화면 파일 import
import 'signup_page.dart'; // 회원가입 화면 파일 import

void main() {

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // 상단 우측에 디버그 띠 없애기
      title: 'SchoolPlanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(), // 로그인 화면을 초기 화면으로 설정
      routes: {
        '/home': (context) => HomePage(), // 로그인 성공 시 이동할 홈 화면
        '/signup': (context) => SignupPage(), // 회원가입 화면 라우트 추가
      },
    );
  }
}
