import 'package:flutter/material.dart';
import "package:google_fonts/google_fonts.dart";


class PoppinsTitleText extends StatelessWidget {
  
  const PoppinsTitleText(this.text, this.fontSize, this.color);

  final String text;
  final double fontSize;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(text,
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