import 'package:flutter/material.dart';

double customWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

double customHeight(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

double customBottom(BuildContext context) {
  if (MediaQuery.of(context).viewPadding.bottom == 0) {
    return 20;
  } else {
    return 35;
  }
}
