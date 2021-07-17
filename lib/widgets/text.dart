import 'package:flutter/material.dart';
import "package:google_fonts/google_fonts.dart";


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
      style: GoogleFonts.poppins(
        textStyle: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        ),
      ),
    );
  }
}