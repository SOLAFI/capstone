import 'package:flutter/material.dart';

class FloatingBackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: ()=> Navigator.of(context).pop(),
      child: Icon(
        Icons.arrow_back,
        color: Colors.grey[500],
      ),
      backgroundColor: Colors.grey[200],
    );
  }
}



