import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'camera_state.dart';

final cameraStateProvider = StateNotifierProvider<CameraStateNotifier, CameraState?>((ref) {
  return CameraStateNotifier();
});

class CameraStateNotifier extends StateNotifier<CameraState?> {
  CameraStateNotifier() : super(null) {
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      final firstCamera = cameras.first;
      final controller = CameraController(firstCamera, ResolutionPreset.high);
      await controller.initialize();
      state = CameraState(controller: controller, isDetecting: false);
    }
  }

  void startDetection() {
    if (state != null) {
      state = CameraState(controller: state!.controller, isDetecting: true);
    }
  }

  void stopDetection() {
    if (state != null) {
      state = CameraState(controller: state!.controller, isDetecting: false);
    }
  }
}
