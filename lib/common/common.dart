import 'package:flutter/material.dart';

class SymbolButton extends StatelessWidget {
  final String path;
  final double width;
  final double heigh;

  const SymbolButton({
    Key? key,
    required this.path,
    required this.width,
    required this.heigh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: heigh,
      width: width,
      decoration: BoxDecoration(
          color: Colors.transparent,
          image: DecorationImage(
            image: AssetImage(path),
            fit: BoxFit.contain,
          )),
    );
  }
}
