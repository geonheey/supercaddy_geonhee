// // import 'package:flutter_pytorch/flutter_pytorch.dart';
// import 'package:flutter/services.dart';
// import 'dart:typed_data';
//
// import 'package:pytorch_lite/enums/model_type.dart';
//
// class YoloModel {
//   late ModelObjectDetection _model;
//
//   Future loadModel() async {
//     String pathObjectDetectionModel =
//         "assets/models/yolov8_flag_640.torchscript";
//     try {
//       _objectModel = await PytorchLite.loadObjectDetectionModel(
//           pathObjectDetectionModel, 1, 640, 640,
//           objectDetectionModelType: ObjectDetectionModelType.yolov8,
//           labelPath: "assets/labels/label_flag.txt");
//     } catch (e) {
//       if (e is PlatformException) {
//       } else {}
//     }
//   }
//
//   Future<void> runModel(Uint8List imageBytes) async {
//     try {
//       final List<dynamic> results = await _model.getImagePrediction(
//         imageBytes,
//         minimumScore: 0.5,
//         IOUThershold: 0.5,
//       );
//
//       print("모델 예측 결과: $results");
//
//       if (results.isNotEmpty) {
//         final detectedFlag = results[0];
//         final double flagWidthInPixels = detectedFlag['rect']['width'];
//         const double flagRealWidth = 2.0; // 깃발 실제 크기 (미터)
//
//         double distance = calculateDistance(flagWidthInPixels, flagRealWidth);
//         print("깃발까지의 거리: $distance 미터");
//       }
//     } catch (e) {
//       print("YOLO 추론 오류: $e");
//     }
//   }
// }
