// ignore_for_file: non_constant_identifier_names, unused_field

import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pytorch_lite/pytorch_lite.dart';


import '../../../common/color.dart';
import '../../../widget/app_bar.dart';
import '../../../widget/size.dart';
import '../../../widget/toast.dart';
import '../widget/imageWithline.dart';

// LoadingController Provider 정의
final loadingControllerProvider = Provider<LoadingController>((ref) {
  return LoadingController(ref);
});

final loadingProvider = StateProvider<bool>((ref) => false);

class LoadingController {
  final Ref ref;
  LoadingController(this.ref);
  bool get isLoading => ref.watch(loadingProvider);
  set isLoading(bool value) => ref.read(loadingProvider.notifier).state = value;
}

class AimingResult extends ConsumerStatefulWidget {
  final String imagePath;
  final String distanceText;

  const AimingResult({
    Key? key,
    required this.imagePath,
    required this.distanceText,
  }) : super(key: key);

  @override
  ConsumerState<AimingResult> createState() => AimingResultState();
}

class AimingResultState extends ConsumerState<AimingResult>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  ModelObjectDetection? _objectModel;
  CameraController? cameraController;
  late List<CameraDescription> cameras;
  List<ResultObjectDetection?>? objDetect1;
  var globalKey = GlobalKey();
  List<ResultObjectDetection?>? results;
  bool isBall = false;
  bool isFlag = false;
  bool isPole = false;
  int active = 1;
  bool yard = true;
  ResultObjectDetection? maxObjDetect;
  List<ResultObjectDetection?> maxObjDetectList = [];

  List<dynamic> accelerometer = <dynamic>[];
  List<dynamic> gyroscope = <dynamic>[];
  double x = 0.0;
  double y = 0.0;
  double z = 0.0;
  Offset? _start;
  Offset? _end;
  double gyroscopeX = 0.0;
  double gyroscopeY = 0.0;
  double gyroscopeZ = 0.0;
  double angleXZ = 0.0;
  double angleYZ = 0.0;
  int zoomValue = 1;
  bool pnctestflug = false;
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];
  String distanceText = "";
  double ballSizeW = 0.0;
  double ballSizeH = 0.0;
  double maskHeight = 300;
  Animation<double>? _animation;
  AnimationController? _controller;
  AnimationController? _tapController;
  Animation<double>? _tapAnimation;
  double? _impactPositionY;

  @override
  void dispose() {
    Platform.isAndroid ? cameraController?.dispose().then((value) => print("didChangeAppLifecycleState dispose done")) : () {};
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _tapController?.dispose();
    print('debug didChangeAppLifecycleState disposed');
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _impactPositionY = details.localPosition.dy;
      _tapController!.forward(from: 0.0);
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    Tween<double> _tween = Tween<double>(begin: 0.0, end: 6);

    _animation = _tween.animate(_controller!)
      ..addListener(() {
        if (mounted) {
          setState(() {});
        }
      });

    _controller!.forward();
    _tapController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _tapAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_tapController!)
      ..addListener(() {
        if (mounted) {
          setState(() {});
        }
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _tapController!.reverse();
        } else if (status == AnimationStatus.dismissed) {
          if (mounted) {
            setState(() {
              _impactPositionY = null;
            });
          }
        }
      });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      customToast(context, title: "여기가 뭐야");
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        appBar: BlackAppBar(
          title: "Aiming",
        ),
        backgroundColor: Colors.white,
        extendBodyBehindAppBar: true,
        body: SafeArea(
          child: GestureDetector(
            onTapDown: (details) {
              if (mounted) {
                setState(() {
                  _handleTapDown(details);
                  maskHeight = (height - 70) - details.localPosition.dy;
                });
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Container(
                margin: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 116,
                            child: Text(
                              "Distance to the hole",
                              style: TextStyle(
                                color: Color(0xFF898989),
                                fontSize: 15,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w400,
                                letterSpacing: -0.45,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    widget.distanceText !=  "Try capturing the flag in the photo."
                                        ? Container(
                                      child: Text(
                                        '${widget.distanceText}m',
                                        style: TextStyle(
                                          color: Color(0xFF30C58F),
                                          fontSize: 60,
                                          fontFamily: 'Roboto',
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -1.20,
                                        ),
                                      ),
                                    )
                                        : Container(
                                      child: Text(
                                        widget.distanceText,
                                        style: TextStyle(
                                          color: Color(0xFF30C58F),
                                          fontSize: 20,
                                          fontFamily: 'Roboto',
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -1.20,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTapDown: (details) {
                        setState(() {
                          _start = details.localPosition;
                          _end = null;
                        });
                      },
                      child: Container(
                        width: customWidth(context),
                        height: customHeight(context) / 1.8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Stack(
                          children: [
                            ImageWithAnimatedLine(
                              imagePath: widget.imagePath,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(child: SizedBox()),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop(); // Get.back() 대신 사용
                      },
                      child: Container(
                        width: customWidth(context),
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 39, vertical: 16),
                        clipBehavior: Clip.antiAlias,
                        decoration: ShapeDecoration(
                          gradient: LinearGradient(
                            begin: Alignment(1.00, -0.04),
                            end: Alignment(-1, 0.04),
                            colors: const [Color(0xFF86E5B7), Color(0xFF4CBBC2)],
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        child: Text(
                          "Filming again",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w400,
                            letterSpacing: -0.45,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget customButton({required String text, required bool selected, required int zoomIndicator, required Size size}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          cameraController!.setZoomLevel(zoomIndicator.toDouble());
          active = zoomIndicator;
          zoomValue = zoomIndicator;
        });
      },
      child: Container(
        margin: EdgeInsets.all(selected ? 0 : 2),
        child: GestureDetector(
          onTap: () {
            setState(() {
              print("zoom test ${zoomIndicator.toDouble()}");
              active = zoomIndicator;
              zoomValue = zoomIndicator;
              cameraController!.setZoomLevel(zoomIndicator.toDouble());
            });
          },
          child: CircleAvatar(
            radius: selected ? size.width / 20 : size.width / 30,
            backgroundColor: selected ? colorR : Color.fromRGBO(255, 255, 255, 0.8),
            child: Text(
              text,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                fontSize: selected ? 15 : 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CircleWithLinesPainter extends CustomPainter {
  final double touchX;
  final double touchY;

  CircleWithLinesPainter(this.touchX, this.touchY);

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = touchX;
    final centerY = touchY;

    final paintRed = Paint()
      ..color = Colors.red
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 1);

    const startY = 0.0;
    final endY = size.height;

    final start = Offset(centerX, startY);
    final end = Offset(centerX, endY);

    canvas.drawLine(start, end, paintRed);

    final paintCircle = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    const circleRadius = 8.0;
    final circleCenter = Offset(centerX, endY);

    canvas.drawCircle(circleCenter, circleRadius, paintCircle);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}