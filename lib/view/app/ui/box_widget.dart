import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pytorch_lite/pigeon.dart';

import '../../../widget/size.dart';

/// Individual bounding box
class BoxWidget extends StatelessWidget {
  ResultObjectDetection result;
  Color? boxesColor;
  bool showPercentage;
  BoxWidget(
      {Key? key,
        required this.result,
        this.boxesColor,
        this.showPercentage = true})
      : super(key: key);

  // Emoji Unicodes
  // 😁 : 1F801 | 🥳 : 1F973 | 😎 : 1F80E
  // ❤ : 2764 | 🤍 : 1F90D | 💯 : 1F4AF
  // 👇 : 1F447 | 👍 : 1F44D | 👀 : 1F440
  // 🏌	 : 1F300 | ⛳ : 28F3 | ✨ : 2728
  // 🍔 : 1F354 | 🍜 : 1F350 | 🍣 : 1F363
  // List emojilist = [
  //   '1F801', '1F973', '1F80E', '2764',
  //   '1F90D', '1F4AF', '1F447', '1F44D',
  //   '1F440', '1F300', '28F3', '2728',
  //   '1F354', '1F350', '1F363'
  // ];
  List emojilist = [
    '😁',
    '🥳',
    '😎',
    '❤',
    '🤍',
    '💯',
    '👇',
    '👍',
    '👀',
    '🏌',
    '⛳',
    '✨',
    '🍔',
    '🍜',
    '🍣'
  ];
  int randomNum = Random().nextInt(15);

  // late String emoji = 'u{' + emojilist[randomNum] + '}';
  late String emoji = emojilist[randomNum];

  @override
  Widget build(BuildContext context) {
    // Color for bounding box
    //print(MediaQuery.of(context).size);
    Color? usedColor;
    //Size screenSize = CameraViewSingleton.inputImageSize;
    //   Size screenSize = CameraViewSingleton.actualPreviewSizeH;
    Size screenSize = MediaQuery.of(context).size;

    //print(screenSize);
    double factorX = screenSize.width;
    double factorY = screenSize.height;
    if (boxesColor == null) {
      //change colors for each label
      usedColor = Colors.primaries[
      ((result.className ?? result.classIndex.toString()).length +
          (result.className ?? result.classIndex.toString())
              .codeUnitAt(0) +
          result.classIndex) %
          Colors.primaries.length];
    } else {
      usedColor = boxesColor;
    }
    return Positioned(
      left: result.rect.left * factorX,
      top: (result.rect.top * factorY)-20,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: result.rect.width.toDouble() * factorX,
            height: result.rect.height.toDouble() * factorY,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.20000000298023224),

              // borderRadius: BorderRadius.circular(100)
            ),
            child: Image.asset(
              'public/images/group-16314.png',
              fit: BoxFit.fill,
            ),
          ),
        ],
      ),
    );
  }
}



/// Individual bounding box
class BoxWidget2 extends StatelessWidget {
  ResultObjectDetection result;
  Color? boxesColor;
  bool showPercentage;
  BoxWidget2(
      {Key? key,
        required this.result,
        this.boxesColor,
        this.showPercentage = true})
      : super(key: key);

  // Emoji Unicodes
  // 😁 : 1F801 | 🥳 : 1F973 | 😎 : 1F80E
  // ❤ : 2764 | 🤍 : 1F90D | 💯 : 1F4AF
  // 👇 : 1F447 | 👍 : 1F44D | 👀 : 1F440
  // 🏌	 : 1F300 | ⛳ : 28F3 | ✨ : 2728
  // 🍔 : 1F354 | 🍜 : 1F350 | 🍣 : 1F363
  // List emojilist = [
  //   '1F801', '1F973', '1F80E', '2764',
  //   '1F90D', '1F4AF', '1F447', '1F44D',
  //   '1F440', '1F300', '28F3', '2728',
  //   '1F354', '1F350', '1F363'
  // ];
  List emojilist = [
    '😁',
    '🥳',
    '😎',
    '❤',
    '🤍',
    '💯',
    '👇',
    '👍',
    '👀',
    '🏌',
    '⛳',
    '✨',
    '🍔',
    '🍜',
    '🍣'
  ];
  int randomNum = Random().nextInt(15);

  // late String emoji = 'u{' + emojilist[randomNum] + '}';
  late String emoji = emojilist[randomNum];

  @override
  Widget build(BuildContext context) {
    // Color for bounding box
    //print(MediaQuery.of(context).size);
    Color? usedColor;
    //Size screenSize = CameraViewSingleton.inputImageSize;
    //   Size screenSize = CameraViewSingleton.actualPreviewSizeH;
    Size screenSize = MediaQuery.of(context).size;

    //print(screenSize);
    double factorX = customWidth(context)*0.9;
    double factorY = (customHeight(context))*0.8-70;
    if (boxesColor == null) {
      //change colors for each label
      usedColor = Colors.primaries[
      ((result.className ?? result.classIndex.toString()).length +
          (result.className ?? result.classIndex.toString())
              .codeUnitAt(0) +
          result.classIndex) %
          Colors.primaries.length];
    } else {
      usedColor = boxesColor;
    }
    return Positioned(
      left: result.rect.left * factorX,
      top: (result.rect.top * factorY),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: result.rect.width.toDouble() * factorX,
            height: result.rect.height.toDouble() * factorY,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.20000000298023224),

              // borderRadius: BorderRadius.circular(100)
            ),
            child: Image.asset(
              'public/images/group-16314.png',
              fit: BoxFit.fill,
            ),
          ),
        ],
      ),
    );
  }
}
