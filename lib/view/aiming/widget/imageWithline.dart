import 'dart:io';

import 'package:flutter/material.dart';

import '../../../widget/size.dart';

class ImageWithAnimatedLine extends StatefulWidget {
  final String imagePath;

  const ImageWithAnimatedLine({super.key, 
    required this.imagePath,
  });

  @override
  _ImageWithAnimatedLineState createState() => _ImageWithAnimatedLineState();
}

class _ImageWithAnimatedLineState extends State<ImageWithAnimatedLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _baseScale = 1.0;
  double _currentScale = 1.0;
  Offset _baseOffset = Offset.zero;
  Offset _currentOffset = Offset.zero;
  Offset? _startPoint;
  Offset? _endPoint;
  double maskHeight = 0;
  double _touchX = 0.0;
  final double _touchY = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _touchX = MediaQuery.of(context).size.width / 2 -16;
      print(_touchX);
    });

    _controller.forward();
  }



  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
  
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
       setState(() {
            _touchX = details.localPosition.dx;
             print(_touchX);
          });
      },
      onTapDown: (details) {
        print("onTapDown");
        if (mounted) {
          setState(() {
            _touchX = details.localPosition.dx;
          });
        }
      },
      onScaleStart: (details) {
        print("onScaleStart");
        _baseScale = _currentScale;

        _baseOffset = details.focalPoint;
      },
      onScaleUpdate: (details) {
        print("onScaleUpdate");
        setState(() {
          _currentScale =
              (_baseScale * details.scale).clamp(1.0, double.infinity);

          // 이미지가 원래 크기와 같을 때만 이동하도록 설정
          if (_currentScale != 1.0) {
            _currentOffset = details.focalPoint - _baseOffset;
          }
        });
      },
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Transform.translate(
              offset: _currentOffset,
              child: Transform.scale(
                scale: _currentScale,
                child: Image.file(
                  File(widget.imagePath),
                  width: customWidth(context),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          CustomPaint(
            painter: AnimatedLinePainter(
              animation: _controller,
              touchX: _touchX,
              touchY: _touchY,
            ),
            size: Size(customWidth(context), customHeight(context)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class AnimatedLinePainter extends CustomPainter {
  final Animation<double> animation;
  final double touchX;
  final double touchY;

  AnimatedLinePainter({
    required this.animation,
    required this.touchX,
    required this.touchY,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paintRed = Paint()
      ..color = Colors.red
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..maskFilter = MaskFilter.blur(BlurStyle.inner, 2);

    final start = Offset(touchX, 0.0);
    final end = Offset(touchX, size.height);

    // 빨간색 선 그리기
    canvas.drawLine(start, end, paintRed);

    // 동그라미 그리기
    final paintCircle = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    const circleRadius = 8.0;
    final circleCenter = Offset(touchX, size.height);

    canvas.drawCircle(circleCenter, circleRadius, paintCircle);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
