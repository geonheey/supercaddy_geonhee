import 'package:flutter/material.dart';

class SlideInFromRightAnimation extends StatefulWidget {
  final int milliseconds;
  final Widget child;

  const SlideInFromRightAnimation({Key? key, required this.child, required this.milliseconds}) : super(key: key);

  @override
  _SlideInFromRightAnimationState createState() => _SlideInFromRightAnimationState();
}

class _SlideInFromRightAnimationState extends State<SlideInFromRightAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.milliseconds), // 애니메이션 지속 시간 조정
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(1.0, 0.0), // 오른쪽에서 시작
      end: Offset.zero, // 원래 위치로 이동
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
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
    return SlideTransition(
      position: _slideAnimation,
      child: widget.child,
    );
  }
}


