import 'package:flutter/material.dart';

class MyThumbShape extends SliderComponentShape {
  final double thumbWidth;
  final int max;
  final int current;
  // final double thumbRadius;
  // final double min, max;

  MyThumbShape({this.thumbWidth = 15, this.max, this.current});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size(thumbWidth, thumbWidth);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    Animation<double> activationAnimation,
    Animation<double> enableAnimation,
    bool isDiscrete,
    TextPainter labelPainter,
    RenderBox parentBox,
    SliderThemeData sliderTheme,
    TextDirection textDirection,
    double value,
    double textScaleFactor,
    Size sizeWithOverflow,
  }) {
    context.canvas.drawCircle(
        center, thumbWidth, Paint()..color = sliderTheme.disabledThumbColor);

    TextSpan span = new TextSpan(
      style: new TextStyle(
        fontSize: thumbWidth * .8,
        fontWeight: FontWeight.w100,
        color: Colors.black,
      ),
      text: current.toString(),
    );

    TextPainter tp = new TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr);
    tp.layout();
    Offset textCenter =
        Offset(center.dx - (tp.width / 2), center.dy - (tp.height / 2));

    tp.paint(context.canvas, textCenter);
  }
}
