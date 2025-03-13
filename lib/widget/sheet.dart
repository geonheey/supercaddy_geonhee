import 'package:flutter/material.dart';

void customShowModalBottomSheet(
  BuildContext context, {
  double? height,
  @required Widget? child,
}) {
  showModalBottomSheet(
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
    ),
    context: context,
    builder: (context) {
      return SizedBox(
        height: height,
        child: SingleChildScrollView(
          child: child,
        ),
      );
    },
  );
}
