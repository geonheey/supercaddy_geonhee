// import 'package:flutter/material.dart';
// import 'package:flutter_pytorch/pigeon.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:camera/camera.dart';
// import 'package:pytorch_lite/pigeon.dart';
// import '../providers/camera_provider.dart';
// import '../models/yolo_model.dart';
// import '../view_model/camera_provider.dart';
// import 'result_screen.dart';
// import 'dart:typed_data';
//
// class CameraScreen extends ConsumerStatefulWidget {
//   @override
//   _CameraScreenState createState() => _CameraScreenState();
// }
//
// class _CameraScreenState extends ConsumerState<CameraScreen> {
//   final YoloModel _yoloModel = YoloModel();
//   bool isModelLoaded = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadModel();
//   }
//
//   Future<void> _loadModel() async {
//     await _yoloModel.loadModel();
//     setState(() {
//       isModelLoaded = true;
//     });
//   }
//
//   Future<void> _detectFlag() async {
//     final cameraState = ref.read(cameraStateProvider);
//     if (cameraState == null || !cameraState.controller.value.isInitialized) return;
//
//     try {
//       final XFile image = await cameraState.controller.takePicture();
//       final Uint8List imageBytes = await image.readAsBytes();
//
//       List<ResultObjectDetection> results = await _yoloModel.runModel(imageBytes);
//
//       if (results.isNotEmpty) {
//         final detectedFlag = results.first;
//         final double flagWidthInPixels = detectedFlag.rect.width;
//         const double flagRealWidth = 2.0; // 깃발 실제 크기 (미터)
//
//         double distance = calculateDistance(flagWidthInPixels, flagRealWidth);
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => ResultScreen(distance: distance)),
//         );
//       }
//     } catch (e) {
//       print("깃발 감지 오류: $e");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final cameraState = ref.watch(cameraStateProvider);
//
//     return Scaffold(
//       appBar: AppBar(title: Text("Flag Detection")),
//       body: cameraState == null
//           ? Center(child: CircularProgressIndicator())
//           : Column(
//         children: [
//           if (cameraState.controller.value.isInitialized)
//             CameraPreview(cameraState.controller),
//           SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: isModelLoaded ? _detectFlag : null,
//             child: Text(isModelLoaded ? 'Detect Flag' : 'Loading Model...'),
//           ),
//         ],
//       ),
//     );
//   }
// }
