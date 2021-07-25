import 'package:flutter/material.dart';


class PoppinsTitleText extends StatelessWidget {
  
  const PoppinsTitleText(this.text, this.fontSize, this.color, this.textAlign);

  final String text;
  final double fontSize;
  final Color color;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(text,
      textAlign: textAlign,
      style: TextStyle(
        fontFamily: 'Poppins',
        color: color,
        fontWeight: FontWeight.w700,
        fontSize: fontSize,
      ),
    );
  }
}