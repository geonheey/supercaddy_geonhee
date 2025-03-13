// ignore_for_file: non_constant_identifier_names, unused_field

import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pytorch_lite/pytorch_lite.dart';


import '../../../widget/app_bar.dart';
import '../../../widget/camera.dart';
import '../../../widget/size.dart';
import '../../../widget/toast.dart';
import '../widget/object.dart';
import '../widget/slideInfromRigthAnimaion.dart';
import '../widget/slidelnfromBall.dart';
import 'aiming_result.dart';

// Providers
final cameraControllerProvider = StateProvider<CameraController?>((ref) => null);
final isLoadingProvider = StateProvider<bool>((ref) => false);
final zoomValueProvider = StateProvider<double>((ref) => 1.0);
final ttsProvider = Provider<FlutterTts>((ref) => FlutterTts());
final camerasProvider = FutureProvider<List<CameraDescription>>((ref) async {
  return await availableCameras();
});

// Aiming Widget
class Aiming extends ConsumerStatefulWidget {
  const Aiming({Key? key}) : super(key: key);

  @override
  AimingState createState() => AimingState();
}

class AimingState extends ConsumerState<Aiming>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  ModelObjectDetection? _objectModel;
  late bool predicting;
  List<ResultObjectDetection?>? objDetect1;
  ObjectRecogniz objectRecogniz = ObjectRecogniz();

  final globalKey = GlobalKey();
  List<ResultObjectDetection?>? results;
  double active = 1.0;
  bool yard = true;
  ResultObjectDetection? maxObjDetect;
  List<ResultObjectDetection?> maxObjDetectList = [];
  int value = 1;
  bool pnctestflug = false;
  bool isFinish = true;
  String distanceText = "";

  double maskHeight = 300;
  Animation<double>? _animation;
  AnimationController? _controller;
  AnimationController? _tapController;
  Animation<double>? _tapAnimation;
  double? _impactPositionY;
  double opacityValue = 0.0;

  @override
  void dispose() {
    if (Platform.isAndroid) {
      ref.read(cameraControllerProvider)?.dispose().then((_) {
        print("didChangeAppLifecycleState dispose done");
      });
    }
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _tapController?.dispose();
    print('debug didChangeAppLifecycleState disposed');
    super.dispose();
  }

  Future<void> initTts() async {
    final tts = ref.read(ttsProvider);
    await tts.setLanguage("ko-KR");
    await tts.setSpeechRate(0.3);
    await tts.setVolume(1.0);
    await tts.setPitch(1.0);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    final tween = Tween<double>(begin: 0.0, end: 5.7);
    _animation = tween.animate(_controller!)
      ..addListener(() {
        if (mounted) setState(() {});
      });
    _controller!.forward();

    _tapController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _tapAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_tapController!)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _tapController!.reverse();
        } else if (status == AnimationStatus.dismissed) {
          setState(() {
            _impactPositionY = null;
          });
        }
      });

    initTts();
    initStateAsync();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _impactPositionY = details.localPosition.dy;
      _tapController!.forward(from: 0.0);
    });
  }

  Future<void> loadModel() async {
    const pathObjectDetectionModel = "assets/models/yolov8_flag_640.torchscript";
    try {
      _objectModel = await PytorchLite.loadObjectDetectionModel(
        pathObjectDetectionModel,
        1,
        640,
        640,
        objectDetectionModelType: ObjectDetectionModelType.yolov8,
        labelPath: "assets/labels/label_flag.txt",
      );
    } catch (e) {
      if (e is PlatformException) {
        // Handle platform-specific errors
      }
    }
  }

  void initStateAsync() async {
    Future.delayed(const Duration(seconds: 1), () {
      initializeCamera();
    });
    predicting = false;
  }

  Future<void> initializeCamera() async {
    final cameras = await ref.read(camerasProvider.future);
    final cameraController = CameraController(
      cameras[0], // Rear camera
      ResolutionPreset.veryHigh,
      enableAudio: false,
      imageFormatGroup:
      Platform.isAndroid ? null : ImageFormatGroup.bgra8888,
    );

    ref.read(cameraControllerProvider.notifier).state = cameraController;

    await cameraController.initialize().then((_) async {
      Size? previewSize = cameraController.value.previewSize;
      CameraViewSingleton.inputImageSize = previewSize!;
      final screenSize = MediaQuery.of(context).size;
      CameraViewSingleton.screenSize = screenSize;
      CameraViewSingleton.ratio = screenSize.width / previewSize.height;

      await cameraController.setFlashMode(FlashMode.off);

      await cameraController.getMaxZoomLevel().then((value) {
        print("zoomMax is $value");
        if (mounted) setState(() {});
      });

      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) setState(() => opacityValue = 1);
      });
      Future.delayed(const Duration(milliseconds: 4000), () {
        if (mounted) setState(() => opacityValue = 0);
      });
    });
  }

  Future<void> runObjectDetection(String filePath) async {
    print("runObjectDetection");
    final image = File(filePath);
    await loadModel().then((_) async {
      final imageBytes = await image.readAsBytes();
      final objDetec1 = await _objectModel!.getImagePredictionList(
        imageBytes,
        minimumScore: 0.05,
        iOUThreshold: 0.5,
      );
      maxObjDetect = null;

      if (objDetec1.isNotEmpty) {
        maxObjDetect = objDetec1.first;
      }

      for (var i = 0; i < objDetec1.length; i++) {
        if (maxObjDetect!.score < objDetec1[i]!.score) {
          maxObjDetect = objDetec1[i];
        }
      }
      if (maxObjDetect != null) {
        maxObjDetectList.add(maxObjDetect);
      }

      if (maxObjDetect != null) {
        print("d. object 디텍팅 성공");
        final distance = objectRecogniz.distance(
          maxObjDetect!,
          1,
          53,
          38,
          1920,
          1080,
          MediaQuery.of(context).devicePixelRatio,
        );
        distanceText = distance.toStringAsFixed(0);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AimingResult(
              imagePath: filePath,
              distanceText: distanceText,
            ),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AimingResult(
              imagePath: filePath,
              distanceText: "Try capturing the flag in the photo.",
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final cameraController = ref.watch(cameraControllerProvider);
        final isLoading = ref.watch(isLoadingProvider);
        final zoomValue = ref.watch(zoomValueProvider);

        final width = MediaQuery.of(context).size.width;
        final height = MediaQuery.of(context).size.height;

        Future<bool> onWillPop() {
          // Replace navigation logic if needed
          return Future.value(false);
        }

        if (cameraController == null || !cameraController.value.isInitialized) {
          return SizedBox(
            height: height,
            child: Opacity(
              opacity: 0.5,
              child: Container(
                color: Colors.grey,
                child: Center(
                  child: Image.asset(
                    'assets/spinner.gif',
                    width: 50,
                    height: 50,
                  ),
                ),
              ),
            ),
          );
        }

        return WillPopScope(
          onWillPop: onWillPop,
          child: SafeArea(
            child: Scaffold(
              appBar: FunctionAppBar(
                title: "aiming",
              ),
              backgroundColor: Colors.white,
              extendBodyBehindAppBar: true,
              body: Stack(
                children: <Widget>[
                  SizedBox(
                    width: width,
                    height: height,
                    child: CameraPreview(cameraController),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onHorizontalDragEnd: (details) {
                      if (details.primaryVelocity! < 0) {
                        // Swipe left
                        setState(() {
                          value = (value == 8) ? 1 : value + 1;
                          cameraController.setZoomLevel(value.toDouble());
                          active = value.toDouble();
                          ref.read(zoomValueProvider.notifier).state =
                              value.toDouble();
                        });
                      } else {
                        // Swipe right
                        setState(() {
                          value = (value == 1) ? 8 : value - 1;
                          cameraController.setZoomLevel(value.toDouble());
                          active = value.toDouble();
                          ref.read(zoomValueProvider.notifier).state =
                              value.toDouble();
                        });
                      }
                    },
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 50),
                        width: customWidth(context),
                        height: 47,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(7, (index) {
                            final number = (value - 4 + index) % 8 + 1;
                            return number == value
                                ? Container(
                              width: 47,
                              height: 47,
                              decoration: const ShapeDecoration(
                                color: Colors.white,
                                shape: OvalBorder(),
                              ),
                              child: Center(
                                child: Text(
                                  'x$number',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: number == value
                                        ? Colors.black
                                        : Colors.white,
                                    fontSize:
                                    number == value ? 21.94 : 13.71,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            )
                                : GestureDetector(
                              onTap: () {
                                setState(() {
                                  value = number;
                                  cameraController
                                      .setZoomLevel(value.toDouble());
                                  active = value.toDouble();
                                  ref
                                      .read(zoomValueProvider.notifier)
                                      .state = value.toDouble();
                                });
                              },
                              child: Container(
                                width: 34.03,
                                height: 34.03,
                                decoration: ShapeDecoration(
                                  shape: CircleBorder(
                                    side: BorderSide(
                                      width: 0.69,
                                      color: Color(0xFF666666),
                                    ),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'x$number',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: number == value
                                          ? Colors.black
                                          : Colors.white,
                                      fontSize: number == value
                                          ? 21.94
                                          : 13.71,
                                      fontFamily: 'Pretendard',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 50),
                      width: 60,
                      height: 60,
                      child: CustomPaint(
                        painter: CircleWithLinesPainter(maskHeight, _animation!),
                      ),
                    ),
                  ),
                  SlideInFromRightAnimation(
                    milliseconds: 1000,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: GestureDetector(
                        onTapDown: _handleTapDown,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 180 + 37),
                          child: SizedBox(
                            width: customWidth(context),
                            height: customHeight(context) / 2.5,
                            child: Image.asset(
                              'assets/mask.png',
                              fit: BoxFit.fill,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 130,
                    right: 0,
                    left: 0,
                    child: AnimatedOpacity(
                      opacity: opacityValue,
                      duration: const Duration(seconds: 2),
                      child: Container(
                        margin: const EdgeInsets.only(left: 15),
                        width: 100,
                        height: 100,
                        child: Image.asset(
                          'assets/img_flg.png',
                          width: 100,
                          height: 100,
                        ),
                      ),
                    ),
                  ),
                  SlideInFromRightAnimation(
                    milliseconds: 1000,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 130),
                        child: Text(
                          "Please place the ball in the center and click.",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w400,
                            height: 0.11,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SlideInFromBall(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: GestureDetector(
                        onTap: () async {
                          if (!isFinish) {
                            customToast(context, title: "분석 중 입니다.");
                            return;
                          }
                          setState(() {
                            ref.read(isLoadingProvider.notifier).state = true;
                            isFinish = false;
                          });
                          await cameraController.setFocusMode(FocusMode.locked);
                          await cameraController
                              .setExposureMode(ExposureMode.locked);

                          final image = await cameraController.takePicture();
                          print('사진이 저장되었습니다: ${image!.path}');

                          await runObjectDetection(image.path);
                          setState(() {
                            isFinish = true;
                            ref.read(isLoadingProvider.notifier).state = false;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.4),
                                spreadRadius: 2,
                                blurRadius: 7,
                                offset: const Offset(0, 3),
                              ),
                            ],
                            border: Border.all(
                                color: Colors.white.withOpacity(0.7)),
                          ),
                          margin: const EdgeInsets.only(bottom: 200),
                          child: SizedBox(
                            child: Image.asset(
                              'assets/group16313.png',
                              fit: BoxFit.contain,
                              opacity: const AlwaysStoppedAnimation(.5),
                              width: 70,
                              height: 70,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (isLoading)
                    Positioned.fill(
                      child: IgnorePointer(
                        ignoring: true,
                        child: Opacity(
                          opacity: 0.5,
                          child: Container(
                            color: Colors.grey,
                            child: Center(
                              child: Image.asset(
                                'assets/spinner.gif',
                                width: 50,
                                height: 50,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    final cameraController = ref.read(cameraControllerProvider);
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }
    try {
      switch (state) {
        case AppLifecycleState.paused:
          print('debug didChangeAppLifecycleState paused');
          if (cameraController.value.isStreamingImages) {
            cameraController.stopImageStream();
            print("debug stopStream");
          }
          break;
        case AppLifecycleState.inactive:
          print('debug didChangeAppLifecycleState inactive');
          break;
        case AppLifecycleState.detached:
          print('debug didChangeAppLifecycleState detached');
          break;
        case AppLifecycleState.resumed:
          print('debug didChangeAppLifecycleState resumed');
          break;
        default:
      }
    } on CameraException catch (e) {
      print("CameraException: ${e.code}");
    }
  }
}

class CircleWithLinesPainter extends CustomPainter {
  final double touchX;
  final Animation<double> animation;

  CircleWithLinesPainter(this.touchX, this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    final paintRed = Paint()
      ..color = Colors.red
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);

    const startY = -70.0;
    final endY = centerY - touchX + 137;
    final currentY = lerpDouble(startY, endY, animation.value)!;

    final start = Offset(centerX, startY);
    final end = Offset(centerX, currentY);

    if (touchX == 300) {
      if (currentY == endY) {
        canvas.drawLine(
            start, Offset(centerX, lerpDouble(endY, startY, animation.value)!), paintRed);
      } else {
        canvas.drawLine(start, end, paintRed);
      }
    } else {
      final leftEnd2 = Offset(centerX, -touchX + 110);
      canvas.drawLine(start, leftEnd2, paintRed);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}