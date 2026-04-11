import 'package:akiba/utils/responsive.dart';
import 'package:flutter/material.dart';
import '../colors.dart';

class popCard extends StatelessWidget {
  final dynamic image;
  final dynamic tag;
  final dynamic name;
  final dynamic description;
  final dynamic darkness;

  const popCard({
    super.key,
    required this.darkness,
    required this.image,
    required this.tag,
    required this.description,
    required this.name,
  });
  //이미지 받고 어떤 글과 태그 설명
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: const Color(0xff1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: AKIBAGradient,
              borderRadius: BorderRadius.circular(0),
            ),
            padding: const EdgeInsets.all(3),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(0),
              child: Image.network(image, fit: BoxFit.cover),
            ),
          ),

          Positioned(
            top: Responsive.ref(context) * 0.02,
            left: MediaQuery.of(context).size.width * 0.026,
            child: tagWidget(tagName: tag),
          ),
          Positioned(
            bottom: Responsive.ref(context) * 0.07,
            left: MediaQuery.of(context).size.width * 0.026,
            child: Text(
              name,
              style: TextStyle(
                color: Colors.white,
                fontSize: Responsive.ref(context) * 0.02,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Positioned(
            bottom: Responsive.ref(context) * 0.02,
            left: MediaQuery.of(context).size.width * 0.026,
            child: Text(
              description,
              style: TextStyle(
                color: Colors.white,
                fontSize: Responsive.ref(context) * 0.015,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(darkness)),
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
          margin: EdgeInsets.only(right: Responsive.ref(context) * 0.01),

          // 2. [수정됨] 바깥쪽 데코레이션: 그라데이션 적용 (테두리 역할)
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xff8522D5),
                Color(0xffD0FF00),
              ], // 원하는 그라데이션 색상으로 변경
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            ),
            borderRadius: BorderRadius.circular(
              Responsive.ref(context) * 0.015,
            ),
          ),

          // 3. [추가됨] 테두리 두께 설정 (여기서 숫자를 조절하세요)
          padding: const EdgeInsets.all(1.5),

          // 4. [추가됨] 안쪽 컨테이너: 실제 배경색(검정)과 텍스트
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.ref(context) * 0.015,
              vertical: Responsive.ref(context) * 0.003,
            ),
            decoration: BoxDecoration(
              color: const Color(0xff000000), // 안쪽 배경색 (검정)
              borderRadius: BorderRadius.circular(
                Responsive.ref(context) * 0.015,
              ),
            ),
            child: Text(
              '#' + tag,
              style: TextStyle(
                color: Colors.white,
                fontSize: Responsive.ref(context) * 0.015,
              ),
            ),
          ),
        );
      }).toList(),
    );
    return tagRow;
  }
}
