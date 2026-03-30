import 'package:flutter/material.dart';

class genre extends StatefulWidget {
  final String genreName;

  const genre(this.genreName, {super.key});

  @override
  State<genre> createState() => _genreState();
}

class _genreState extends State<genre> {
  bool selected = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selected = !selected;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(0),
          border: Border.all(
            color: selected ? const Color(0xffD0FF00) : const Color(0xff595959),
          ),
        ),
        child: Container(
          // width: selected ? ,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.01,
              vertical: MediaQuery.of(context).size.width * 0.005,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                selected
                    ? Icon(Icons.check, color: Color(0xffD0FF00))
                    : SizedBox(width: 0),
                selected
                    ? SizedBox(width: MediaQuery.of(context).size.width * 0.01)
                    : SizedBox(width: 0),
                Text(
                  widget.genreName,
                  style: TextStyle(
                    color: selected ? const Color(0xffD0FF00) : Colors.white,
                    fontSize: MediaQuery.of(context).size.height * 0.020,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
