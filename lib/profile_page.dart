import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1F3F6),
      appBar: AppBar(
        title: Text('내 정보'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          ProfileCard(), // ProfileCard 위젯 사용
          Expanded(
            child: GridView.count(
              padding: EdgeInsets.all(16),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                EvaluationButton(
                  icon: Icons.star,
                  label: '강의 평점 평가',
                  color: Colors.amber,
                ),
                EvaluationButton(
                  icon: Icons.show_chart,
                  label: '강의 난이도 평가',
                  color: Colors.redAccent,
                ),
                EvaluationButton(
                  icon: Icons.insert_drive_file,
                  label: '학습량 평가',
                  color: Colors.blueAccent,
                ),
                EvaluationButton(
                  icon: Icons.more_horiz,
                  label: '...',
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '내 정보',
          ),
        ],
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            // "홈" 버튼 클릭 시 이전 화면으로 돌아감
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}

class ProfileCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(
                'https://your-image-url.com'), // 여기에 이미지 URL을 넣으세요.
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '민재와 윤진',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text('학과: 컴퓨터융합학부'),
                Text('학번: 2024000000'),
                Row(
                  children: [
                    Text(
                      '성향: ',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      '도전형🔥',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // 정보 수정 버튼 기능
            },
            child: Text('회원 정보 수정'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFCBD5E0),
            ),
          ),
        ],
      ),
    );
  }
}

class EvaluationButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  EvaluationButton({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // 버튼 기능 추가
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: color,
        backgroundColor: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 40),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
