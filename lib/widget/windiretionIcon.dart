import 'package:flutter/material.dart';

class WindDirectionIcon extends StatelessWidget {
  final double degree;

  const WindDirectionIcon(this.degree, {super.key});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: degree * (3.14 / 180), // 각도를 라디안으로 변환
      child: Icon(Icons.navigation), // 또는 다른 아이콘을 사용할 수 있습니다.
    );
  }
}