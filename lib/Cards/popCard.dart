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
              SizedBox(child: Image.network(image, fit: BoxFit.cover)),
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
    // List<Widget> tags = [];
    Row tagRow = Row(
      children: tagName.map((tag) {
        return Container(
          margin: EdgeInsets.only(
            right: MediaQuery.of(context).size.width * 0.01,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.015,
            vertical: MediaQuery.of(context).size.height * 0.003,
          ),
          decoration: BoxDecoration(
            color: Color(0xff000000),
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
        );
      }).toList(),
    );
    return tagRow;
  }
}
