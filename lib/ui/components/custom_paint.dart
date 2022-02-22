import 'package:flutter/material.dart';

class OpenPainter extends CustomPainter {
  double width;
  double height;
  double ofX;
  double ofY;
  OpenPainter(this.width, this.height, [this.ofX = 0, this.ofY = 0]);
  @override
  void paint(Canvas canvas, Size size) {
    var paint1 = Paint()
      ..color = Color(Colors.grey[200]!.value)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset(ofX, ofY) & Size(width, height), paint1);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
