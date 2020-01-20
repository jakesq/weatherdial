import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import 'face.dart';

class ClockFace extends StatefulWidget {

  @override
  _ClockFaceState createState() => _ClockFaceState();
}

class _ClockFaceState extends State<ClockFace> {

  @override
  Widget build(BuildContext context) {

    double height = MediaQuery.of(context).size.height;
    
    return Container(
      height: height,
      width: height,
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(25),
        shape: BoxShape.circle
      ),
      padding: EdgeInsets.all(5),
      child: CustomPaint(
        painter: ClockDialPainter(),
      )
    );
  }
}
