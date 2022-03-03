import 'package:flutter/material.dart';
import 'dart:math';

class MessageBubbleReceived extends StatelessWidget {
  MessageBubbleReceived(this.message, {this.isImage = false, Key? key})
      : super(key: key);
  String message;
  bool isImage;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(pi),
              child: CustomPaint(
                painter: CustomShape(const Color(0xFFE0E0E0)),
              ),
            ),
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                  ),
                ),
                child: isImage
                    ? GestureDetector(
                        onTap: () => showDialog(
                            context: context,
                            builder: (context) => Dialog(
                                backgroundColor: Colors.transparent,
                                child: InteractiveViewer(
                                    panEnabled: true,
                                    minScale: 0.5,
                                    maxScale: 4,
                                    clipBehavior: Clip.none,
                                    child: Image.network(message)))),
                        child: Image.network(
                          message,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }
                            return Center(
                                child: Container(
                              color: Colors.grey,
                              width: 300,
                              height: 200,
                            ));
                          },
                        ))
                    : Text(
                        message,
                        style:
                            const TextStyle(color: Colors.black, fontSize: 14),
                      ),
              ),
            ),
          ]),
    );
  }
}

class MessageBubbleSent extends StatelessWidget {
  MessageBubbleSent(this.message, {this.isImage = false, Key? key})
      : super(key: key);
  String message;
  bool isImage;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.cyan[900],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
              ),
              child: isImage
                  ? GestureDetector(
                      onTap: () => showDialog(
                          context: context,
                          builder: (context) => Dialog(
                              backgroundColor: Colors.transparent,
                              child: InteractiveViewer(
                                  panEnabled: true,
                                  minScale: 0.5,
                                  maxScale: 4,
                                  clipBehavior: Clip.none,
                                  child: Image.network(message)))),
                      child: Image.network(
                        message,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }
                          return Center(
                              child: Container(
                            color: Colors.grey,
                            width: 300,
                            height: 200,
                          ));
                        },
                      ))
                  : Text(
                      message,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
            ),
          ),
          CustomPaint(painter: CustomShape(const Color(0xFF006064))),
        ],
      ),
    );
  }
}

class CustomShape extends CustomPainter {
  final Color bgColor;

  CustomShape(this.bgColor);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = bgColor;

    var path = Path();
    path.lineTo(-5, 0);
    path.lineTo(0, 10);
    path.lineTo(5, 0);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
