import 'package:flutter/material.dart';
import 'screens/login_page.dart'; // 로그인 화면 파일 import
import 'screens/home_page.dart'; // 홈 화면 파일 import
import 'screens/signup_page.dart'; // 회원가입 화면 파일 import
import 'profile_page.dart';

// provider
import 'package:provider/provider.dart';
import 'providers/profile_provider.dart';
import 'providers/timetable_provider.dart';
import 'providers/semester_provider.dart';

void main() {
  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ChangeNotifierProvider(create: (_) => TimetableProvider()),
      ChangeNotifierProvider(create: (_) => SemesterProvider()),
    ], child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'your time',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'NotoSansKR',
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
        '/signup': (context) => SignupPage(),
        '/profile': (context) => ProfileScreen(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Text(
              'your  time',
              style: const TextStyle(
                fontFamily: 'LeagueSpartan',
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: -3,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 40,
            child: Center(
              child: Text(
                '민재와 윤진이',
                style: const TextStyle(
                  fontFamily: 'Gugi',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
