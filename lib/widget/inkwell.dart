import 'package:flutter/material.dart';

class CustomInkWell extends StatelessWidget {
  final EdgeInsetsGeometry? padding;
  final Function() onTap;
  final Function() onLongPress;
  final BorderRadiusGeometry? borderRadius;
  final Widget? child;
  final Color? color;

  const CustomInkWell({
    Key? key,
    this.padding,
    required this.onTap,
    required this.onLongPress,
    this.borderRadius,
    @required this.child,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? Colors.transparent,
      borderRadius: borderRadius ?? BorderRadius.circular(0),
      child: InkWell(
        onLongPress: onLongPress,
        onTap: onTap,
        borderRadius: BorderRadius.circular(0),
        child: Container(
          padding: padding ?? EdgeInsets.all(0),
          child: child,
        ),
      ),
    );
  }
}
