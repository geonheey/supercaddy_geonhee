  import 'package:flutter/material.dart';
import 'package:pytorch_lite/pigeon.dart';

import '../../app/ui/box_widget.dart';

Widget boundingBoxes2(List<ResultObjectDetection?>? results) {

    if (results == null) {
      return Container();
    }

    return Stack(
      
      children: results.map((e) => BoxWidget(result: e!)).toList(),
    );
  }



  Widget boundingBoxes3(ResultObjectDetection results) {

    return Stack(
      
      children: [BoxWidget2(result: results,)],
    );
  }