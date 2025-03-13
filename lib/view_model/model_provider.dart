// import 'package:camera/camera.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:pytorch_lite/pytorch_lite.dart';
//
// // 사용 가능한 카메라 목록 제공
// final camerasProvider = FutureProvider<List<CameraDescription>>((ref) async {
//   return await availableCameras();
// });
//
// // 카메라 컨트롤러 제공
// final cameraControllerProvider = StateProvider<CameraController?>((ref) => null);
//
// // YOLOv8 모델 결과 제공
// final objectDetectionProvider = StateProvider<List<ResultObjectDetection>?>((ref) => null);
//
// // 깃발까지의 거리 제공
// final distanceProvider = StateProvider<double?>((ref) => null);