import 'package:flutter/material.dart';
import 'dart:math';

class HoneycombLayoutDelegate extends MultiChildLayoutDelegate {
  double radius;
  double maxWidth;

  HoneycombLayoutDelegate(radius, maxWidth, {double scaleFactor = 1.0}) {
    this.radius = radius * scaleFactor;
    this.maxWidth = maxWidth * scaleFactor;
  }

  @override
  Size getSize(BoxConstraints constraints) {
    final s = radius * 2 + maxWidth;
    final sz = Size(s, s);
    final szz = constraints.constrain(sz);
    return szz;
  }

  @override
  void performLayout(Size size) {
    print(size);
    final hcc = size.center(Offset.zero);
    final hc = Size(maxWidth, maxWidth).center(Offset.zero);
    final center = hcc - hc;
    final rcos30 = radius * cos(30 / 360 * 2 * pi);
    final rsin30 = radius * sin(30 / 360 * 2 * pi);

    var boxConstraints =
        BoxConstraints(maxWidth: maxWidth, maxHeight: maxWidth);
    layoutChild(-1, boxConstraints);
    layoutChild(0, boxConstraints);
    layoutChild(1, boxConstraints);
    layoutChild(2, boxConstraints);
    layoutChild(3, boxConstraints);
    layoutChild(4, boxConstraints);
    layoutChild(5, boxConstraints);

    positionChild(-1, center);
    positionChild(0, center + Offset(0, -radius));
    positionChild(1, center + Offset(rcos30, -rsin30));
    positionChild(2, center + Offset(rcos30, rsin30));
    positionChild(3, center + Offset(0, radius));
    positionChild(4, center + Offset(-rcos30, rsin30));
    positionChild(5, center + Offset(-rcos30, -rsin30));
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return false;
  }
}

class Hexagon extends StatelessWidget {
  final Widget child;
  final Color color;
  final String text;
  final TextEditingController controller;

  Hexagon({
    this.child,
    this.text,
    this.color = Colors.black12,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: HexagonClipper(),
      child: GestureDetector(
        onTap: () {
          controller.text += text;
          controller.selection = TextSelection.fromPosition(
              TextPosition(offset: controller.text.length));
        },
        child: Container(
          color: color,
          alignment: Alignment.center,
          child: text != null
              ? Text(text, style: TextStyle(fontWeight: FontWeight.bold))
              : child,
        ),
      ),
    );
  }
}

class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final a = size.width / 2;
    final Point center = Point(a, a);
    const sqrt3half = 1.73205080757 / 2;
    final acos60 = a / 2;
    final asin60 = a * sqrt3half;

    final path = Path();
    // A B C D E F
    path.moveTo(a, 0);
    path.lineTo(acos60, asin60);
    path.lineTo(-acos60, asin60);
    path.lineTo(-a, 0);
    path.lineTo(-acos60, -asin60);
    path.lineTo(acos60, -asin60);
    path.lineTo(a, 0);

    path.close();
    return path.shift(Offset(center.x, center.y));
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
