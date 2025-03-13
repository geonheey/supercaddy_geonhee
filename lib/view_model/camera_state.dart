import 'package:camera/camera.dart';

class CameraState {
  final CameraController controller;
  final bool isDetecting;

  CameraState({required this.controller, required this.isDetecting});

  static Future<CameraState> initial() async {
    final cameras = await availableCameras(); // 사용 가능한 카메라 가져오기
    final firstCamera = cameras.first; // 첫 번째 카메라 선택

    final controller = CameraController(firstCamera, ResolutionPreset.high);
    await controller.initialize();

    return CameraState(controller: controller, isDetecting: false);
  }
}
