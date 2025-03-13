import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void customRoute(
  BuildContext context,
  Widget widget, {
  bool fullscreenDialog = false,
}) {
  if (Platform.isIOS) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => widget,
        fullscreenDialog: fullscreenDialog,
      ),
    );
  } else {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => widget,
        fullscreenDialog: fullscreenDialog,
      ),
    );
  }
}

void removeRoute(
  BuildContext context,
  Widget widget, {
  bool isAll = false,
}) {
  if (Platform.isIOS) {
    Navigator.of(context).pushAndRemoveUntil(
      CupertinoPageRoute(
        builder: (context) => widget,
      ),
      isAll ? (Route<dynamic> route) => false : ModalRoute.withName('/'),
    );
  } else {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => widget,
      ),
      isAll ? (Route<dynamic> route) => false : ModalRoute.withName('/'),
    );
  }
}
