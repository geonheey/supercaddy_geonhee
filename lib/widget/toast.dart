
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void customToast(
  BuildContext context, {
  required String title,
}) {
  Fluttertoast.showToast(
      msg: title,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0);
}
// void customToast2(
//   BuildContext context, {
//   required String title,
// }) {
//   showFlash(
//     context: context,
//     duration: Duration(milliseconds: 2500),
//     builder: (context, controller) {
//       return Flash(

//     controller: controller,


//         child:  FlashBar(
//                             controller: controller,
//                             indicatorColor: Colors.red,
//                             icon: Icon(Icons.tips_and_updates_outlined),
//                             title: Text(''),
//                             content: Text('This is basic flash.'),

//                           ),
//       );
//     },
//   );
// }