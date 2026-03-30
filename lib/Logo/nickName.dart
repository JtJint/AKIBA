import 'package:akiba/Logo/genre.dart';
import 'package:akiba/Logo/logo.dart';
import 'package:akiba/home.dart';
import 'package:flutter/material.dart';

class inputNickNamePage extends StatefulWidget {
  const inputNickNamePage({super.key});

  @override
  State<inputNickNamePage> createState() => _inputNickNamePage();
}

class _inputNickNamePage extends State<inputNickNamePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8, // ⭐ 핵심
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xffD0FF00),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('다음', style: TextStyle(color: Colors.black)),
          ),
        ),
      ),
      backgroundColor: const Color(0xff141414),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                Text(
                  '아키바에 접속할\n당신의 프로필을 입력해주세요',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: MediaQuery.of(context).size.height * 0.03,
                    fontWeight: FontWeight.w700,
                    // fontStyle: 'Pretendard-Light',
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                Text(
                  '닉네임',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: MediaQuery.of(context).size.height * 0.024,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xff000000),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 23, vertical: 12),
                    child: Stack(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.6,
                              child: TextField(
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize:
                                      MediaQuery.of(context).size.height *
                                      0.024,
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                            Spacer(),
                          ],
                        ),
                        Positioned(
                          top: 0,
                          bottom: 0,
                          right: 0,
                          child: TextButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                Color(0xff8522D5),
                              ),
                              foregroundColor: MaterialStateProperty.all(
                                Colors.white,
                              ),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0),
                                ),
                              ),
                            ),
                            onPressed: () {},
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              child: Text(
                                '중복 확인',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize:
                                      MediaQuery.of(context).size.height *
                                      0.018,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                Text(
                  '닉네임을 중복 확인해주세요',
                  style: TextStyle(
                    color: Color(0xffD0FF00),
                    fontSize: MediaQuery.of(context).size.height * 0.020,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                Text(
                  '관심 장르',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: MediaQuery.of(context).size.height * 0.022,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    genre('피규어'),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.014),
                    genre('한정판 굿즈'),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.014),
                    genre('애니 굿즈'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    genre('아크릴 스탠드'),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.014),
                    genre('빈티지'),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.014),
                    genre('특전 굿즈'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    genre('포토카드'),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.014),
                    genre('캔뱃지'),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.014),
                    genre('아트 도어'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
