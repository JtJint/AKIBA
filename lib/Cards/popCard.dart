import 'package:akiba/color/HEXColor.dart';
import 'package:flutter/material.dart';

class popCard extends StatelessWidget {
  final dynamic image;

  final dynamic tag;

  final dynamic description;

  const popCard({
    super.key,
    required this.image,
    required this.tag,
    required this.description,
  });
  //이미지 받고 어떤 글과 태그 설명
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color(0xff1E1E1E),
      child: Column(
        children: [
          Stack(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.height * 0.4,
                decoration: BoxDecoration(
                  // 원하는 그라데이션 색상 설정
                  gradient: LinearGradient(
                    colors: [
                      HexColor("#D0FF00", opacity: 0.2),
                      HexColor("#D0FF00", opacity: 1),
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  // 테두리의 둥글기 (이미지 둥글기와 맞춰야 함)
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(3), // 테두리 두께
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    image,
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: MediaQuery.of(context).size.height * 0.4,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(top: 30, left: 20, child: tagWidget(tagName: tag)),
              Positioned(bottom: 30, left: 20, child: Text(description)),
            ],
          ),
        ],
      ),
    );
  }
}

class tagWidget extends StatelessWidget {
  final List<String> tagName;
  const tagWidget({super.key, required this.tagName});

  @override
  Widget build(BuildContext context) {
    Row tagRow = Row(
      children: tagName.map((tag) {
        return Container(
          // 1. 태그 사이의 간격 (기존 코드 유지)
          margin: EdgeInsets.only(
            right: MediaQuery.of(context).size.width * 0.01,
          ),

          // 2. [수정됨] 바깥쪽 데코레이션: 그라데이션 적용 (테두리 역할)
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xff8522D5),
                Color(0xffD0FF00),
              ], // 원하는 그라데이션 색상으로 변경
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(
              MediaQuery.of(context).size.width * 0.015,
            ),
          ),

          // 3. [추가됨] 테두리 두께 설정 (여기서 숫자를 조절하세요)
          padding: const EdgeInsets.all(1.5),

          // 4. [추가됨] 안쪽 컨테이너: 실제 배경색(검정)과 텍스트
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.015,
              vertical: MediaQuery.of(context).size.height * 0.003,
            ),
            decoration: BoxDecoration(
              color: const Color(0xff000000), // 안쪽 배경색 (검정)
              borderRadius: BorderRadius.circular(
                MediaQuery.of(context).size.width * 0.015,
              ),
            ),
            child: Text(
              '#' + tag,
              style: TextStyle(
                color: Colors.white,
                fontSize: MediaQuery.of(context).size.height * 0.012,
              ),
            ),
          ),
        );
      }).toList(),
    );
    return tagRow;
  }
}
