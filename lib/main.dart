import 'package:flutter/material.dart';
import 'package:flutter/services.dart';  // SystemChrome을 위해 추가
import 'login_page.dart'; // 로그인 화면 파일 import
import 'home_page.dart'; // 홈 화면 파일 import
import 'signup_page.dart'; // 회원가입 화면 파일 import

void main() {
  WidgetsFlutterBinding.ensureInitialized();  // 바인딩 초기화
  
  // 상태바 스타일 설정
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,  // 상태바 배경색
      statusBarIconBrightness: Brightness.dark,  // 상태바 아이콘 색상
      statusBarBrightness: Brightness.light,  // iOS 상태바 스타일
    ),
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle.dark,  // 상태바 아이콘 색상
        ),
      ),
      home: LoginPage(),
      routes: {
        '/home': (context) => HomePage(), // 로그인 성공 시 이동할 홈 화면
        '/signup': (context) => SignupPage(), // 회원가입 화면 라우트 추가
      },
    );
  }
}
