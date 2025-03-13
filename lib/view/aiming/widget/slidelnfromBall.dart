import 'package:flutter/material.dart';

class SlideInFromBall extends StatefulWidget {
  final Widget child;

  const SlideInFromBall({Key? key, required this.child}) : super(key: key);

  @override
  _SlideInFromBallState createState() => _SlideInFromBallState();
}

class _SlideInFromBallState extends State<SlideInFromBall> with SingleTickerProviderStateMixin {
   late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 10), // 애니메이션 지속 시간 조정
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(2.0, 0.0), // 시작 위치를 오른쪽으로 넓혀서 튕기는 느낌을 줌
      end: Offset.zero, // 원래 위치로 이동
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut, // 통통 튀는 애니메이션 적용
      ),
    );
    // 애니메이션 시작
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            _slideAnimation.value.dx,
            // 위아래로 통통 튀는 느낌을 주기 위해 사인 함수 적용
            50.0 * (-1.0 * _slideAnimation.value.dx * _slideAnimation.value.dx + 1.0),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}