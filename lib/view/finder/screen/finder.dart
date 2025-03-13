// ignore_for_file: prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pytorch_lite/pytorch_lite.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../view_model/load_provider.dart';
import '../../../widget/app_bar.dart';
import '../../../widget/size.dart';
import '../../aiming/widget/object.dart';
import '../../flag/screen/flag.dart';
import '../../utils/analytics_service.dart';
import '../widget/finder_test.dart';


// Providers
final cameraControllerProvider = StateProvider<CameraController?>((ref) => null);
final zoomValueProvider = StateProvider<double>((ref) => 1.0);
final ttsProvider = Provider<FlutterTts>((ref) => FlutterTts());
final camerasProvider = FutureProvider<List<CameraDescription>>((ref) async {
  return await availableCameras();
});


class AddressController extends StateNotifier<Map<String, dynamic>> {
  AddressController() : super({'currentWeatherWind': '', 'currentWeatherWindDgree': ''});
// Add methods if needed
}

final addressControllerProvider =
StateNotifierProvider<AddressController, Map<String, dynamic>>(
        (ref) => AddressController());

class UserInfoController extends StateNotifier<void> {
  UserInfoController() : super(null);
  void userHist(String useSe) {
    // Implement logic here
  }
}

final userInfoControllerProvider =
StateNotifierProvider<UserInfoController, void>((ref) => UserInfoController());

class NavigationController extends StateNotifier<int> {
  NavigationController() : super(0);
  void setBottomNavIndex(int index) => state = index;
}

final navigationControllerProvider =
StateNotifierProvider<NavigationController, int>((ref) => NavigationController());

class Finder extends ConsumerStatefulWidget {
  const Finder({Key? key}) : super(key: key);

  @override
  _FinderState createState() => _FinderState();
}

class _FinderState extends ConsumerState<Finder> with WidgetsBindingObserver {
  CameraController? _controller;
  late ModelObjectDetection _objectModel;
  ResultObjectDetection? maxObjDetect;
  List<ResultObjectDetection?> maxObjDetectList = [];
  ObjectRecogniz objectRecogniz = ObjectRecogniz();
  double active = 1.0;
  double? zoomMaxValue = 1;
  double zoomValue = 1.0;
  String? distanceText = "0.0";
  List<String> palcNm = [];
  List<String> flagH = [];
  List<String> flagV = [];
  List<String> unit = [];
  List<String> golfLa = [];
  var cameraLoding = false;
  List<String> golfLo = [];
  List<dynamic> accelerometer = <dynamic>[];
  double x = 0.0;
  double y = 0.0;
  double z = 0.0;
  double gyroscopeX = 0.0;
  double gyroscopeY = 0.0;
  double gyroscopeZ = 0.0;
  double angleXZ = 0.0;
  double angleYZ = 0.0;
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];
  String userUnit = "M";
  double opacityValue = 0.0;
  String appBarTitle = "";
  final FlutterTts tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      init();
      if (!cameraLoding) {
        _initializeCamera();
      }
      showDailyToast();
    });
    ref.read(userInfoControllerProvider.notifier).userHist("STAT0010");
    _streamSubscriptions.add(accelerometerEvents.listen(
          (AccelerometerEvent e) {
        if (!mounted) return;
        setState(() {
          accelerometer = <double>[e.x, e.y, e.z];
          x = accelerometer[0];
          y = accelerometer[1];
          z = accelerometer[2];
          angleXZ = atan2(x, z) * 180 / pi;
          angleYZ = atan2(y, z) * 180 / pi;
        });
      },
    ));
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !cameraLoding) {
      _initializeCamera();
    }
  }

  Future<void> showDailyToast() async {
    final prefs = await SharedPreferences.getInstance();
    DateTime today = DateTime.now();
    String todayString = '${today.year}-${today.month}-${today.day}';
    String? lastDateString = prefs.getString('last_toast_date');
    if (lastDateString == null || lastDateString != todayString) {
      await prefs.setString('last_toast_date', todayString);
    }
  }

  Future<void> init() async {
    palcNm = await getRecentGolf("golfPlaceKey");
    flagH = await getRecentGolf("flagHKey");
    flagV = await getRecentGolf("flagVKey");
    golfLa = await getRecentGolf("flagLaKey");
    golfLo = await getRecentGolf("flagLoKey");
    unit = await getRecentGolf("flagUnitKey");
    userUnit = await getUserUnit() ?? "M";
    await initTts();
    if (mounted) setState(() {});
  }

  Future<void> initTts() async {
    await tts.setLanguage("ko-KR");
    await tts.setSpeechRate(0.3);
    await tts.setVolume(1.0);
    await tts.setPitch(1.0);
  }

  Future<void> _initializeCamera() async {
    cameraLoding = true;
    ref.read(loadingProvider.notifier).setLoading(true);
    final cameras = await ref.read(camerasProvider.future);
    _controller = CameraController(cameras.first, ResolutionPreset.max);
    await _controller?.initialize().then((_) async {
      debugPrint("카메라 초기화 완료");
      zoomMaxValue = await _controller!.getMaxZoomLevel().then((value) => value > 8 ? 8 : value);
      Future.delayed(Duration(milliseconds: 1000), () {
        if (mounted) setState(() => opacityValue = 1);
      });
      Future.delayed(Duration(milliseconds: 3000), () {
        if (mounted) setState(() => opacityValue = 0);
      });
      _controller!.setZoomLevel(zoomValue);
      ref.read(loadingProvider.notifier).setLoading(false);
      cameraLoding = false;
    });
    ref.read(cameraControllerProvider.notifier).state = _controller;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    _controller?.dispose();
    super.dispose();
  }

  Widget customButton({
    required String text,
    required bool selected,
    required double zoomIndicator,
    required Size size,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _controller!.setZoomLevel(zoomIndicator);
          active = zoomIndicator;
          zoomValue = zoomIndicator;
          ref.read(zoomValueProvider.notifier).state = zoomIndicator;
        });
      },
      child: CircleAvatar(
        radius: selected ? size.width / 20 : size.width / 30,
        backgroundColor: !selected ? Colors.black : Colors.white,
        child: Text(
          text,
          style: TextStyle(
            color: !selected ? Colors.white : Colors.black,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            fontSize: selected ? 15 : 12,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final analyticsService = AnalyticsService();
    analyticsService.analytics.logScreenView(screenName: 'finder-page');

    Future<bool> onWillPop() {
      ref.read(navigationControllerProvider.notifier).setBottomNavIndex(0);
      return Future.value(false);
    }

    var size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: onWillPop,
      child: SafeArea(
        child: Scaffold(
          appBar: FinderAppBar(
            title: palcNm.isNotEmpty
                ? palcNm.last == "cm"
                ? "choose a golf course"
                : palcNm.last
                : "choose a golf course",
          ),
          backgroundColor: Colors.white,
          extendBodyBehindAppBar: true,
          body: RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: Consumer(
              builder: (context, ref, child) {
                final isLoading = ref.watch(loadingProvider);
                return Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    if (_controller != null && _controller!.value.isInitialized)
                      SizedBox(
                        width: customWidth(context),
                        height: customHeight(context),
                        child: CameraPreview(_controller!),
                      )
                    else
                      Container(),
                    Positioned(
                      top: 0,
                      bottom: 240,
                      right: 0,
                      left: 0,
                      child: Center(
                        child: Text(
                          "Place the flag in the square",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      bottom: 0,
                      right: 0,
                      left: 0,
                      child: Image.asset('assets/subtract.png'),
                    ),
                    Positioned(
                      top: 0,
                      bottom: 0,
                      right: 0,
                      left: 0,
                      child: AnimatedOpacity(
                        opacity: opacityValue,
                        duration: Duration(seconds: 2),
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: Image.asset('assets/img_flg.png', width: 50, height: 50),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 50,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Column(
                          children: [
                            SizedBox(height: 22),
                            Container(
                              width: 100,
                              height: 43,
                              decoration: ShapeDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  customButton(
                                    text: "x1",
                                    selected: active == 1,
                                    zoomIndicator: 1,
                                    size: size,
                                  ),
                                  customButton(
                                    text: "x${zoomMaxValue!.toInt()}",
                                    selected: active == zoomMaxValue!,
                                    zoomIndicator: zoomMaxValue!,
                                    size: size,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 22),
                            GestureDetector(
                              onTap: () async {
                                try {
                                  ref.read(loadingProvider.notifier).setLoading(true);
                                  ref.read(userInfoControllerProvider.notifier).userHist("STAT0011");
                                  if (Platform.isAndroid) {
                                    await _controller?.setFocusMode(FocusMode.locked);
                                    await _controller?.setExposureMode(ExposureMode.locked);
                                  }
                                  final image = await _controller?.takePicture();
                                  ref.read(loadingProvider.notifier).setLoading(false);

                                  showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (BuildContext context) {
                                      return FinserTest(
                                        imagePath: image!.path,
                                        distanceText: distanceText!,
                                        wind: ref.read(addressControllerProvider)['currentWeatherWind'],
                                        windPosition: ref.read(addressControllerProvider)['currentWeatherWindDgree'],
                                        unit: userUnit,
                                        club: "nearestClubName",
                                        zoomValue: zoomValue,
                                        angle: angleYZ,
                                      );
                                    },
                                  ).then((value) async {
                                    await _initializeCamera();
                                    init();
                                  });
                                } catch (e) {
                                  print('사진 촬영 중 오류 발생: $e');
                                }
                              },
                              child: Image.asset('assets/shot1.png'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 60,
                      left: 20,
                      right: 20,
                      child: palcNm.isEmpty
                          ? GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FlagScreen(
                                currentPalce: '',
                                onChoose: (String clubName) {
                                  Navigator.pop(context);
                                  appBarTitle = clubName;
                                  setState(() {
                                    palcNm.add(clubName);
                                    setRecentGolf(
                                      golfPlace: clubName,
                                      selectFlagH: "53",
                                      selectFlagV: "45",
                                      la: '',
                                      lo: '',
                                      unit: unit.last,
                                    );
                                  });
                                },
                              ),
                            ),
                          ).then((value) => init());
                        },
                        child: Container(
                          padding: const EdgeInsets.only(top: 14, left: 20, right: 20, bottom: 14),
                          decoration: ShapeDecoration(
                            color: Colors.white.withOpacity(0.8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Image.asset('public/images/page-flag-01.png', width: 15, height: 14),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Flag Information",
                                    style: TextStyle(
                                      color: Color(0xFF5A5A5A),
                                      fontSize: 13,
                                      fontFamily: 'Pretendard',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                "Click to select a flag",
                                style: TextStyle(
                                  color: Color(0xFF5A5A5A),
                                  fontSize: 13,
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                          : GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FlagScreen(
                                currentPalce: '',
                                onChoose: (String clubName) {
                                  Navigator.pop(context);
                                  appBarTitle = clubName;
                                  setState(() {
                                    palcNm.add(clubName);
                                    setRecentGolf(
                                      golfPlace: clubName,
                                      selectFlagH: "53",
                                      selectFlagV: "45",
                                      la: '',
                                      lo: '',
                                      unit: unit.last,
                                    );
                                  });
                                },
                              ),
                            ),
                          ).then((value) => init());
                        },
                        child: Container(
                          padding: const EdgeInsets.only(top: 14, left: 20, right: 20, bottom: 14),
                          decoration: ShapeDecoration(
                            color: Colors.white.withOpacity(0.8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Image.asset('public/images/page-flag-01.png', width: 15, height: 14),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Flag Information",
                                    style: TextStyle(
                                      color: Color(0xFF5A5A5A),
                                      fontSize: 13,
                                      fontFamily: 'Pretendard',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                userUnit == "M"
                                    ? unit.last == "cm"
                                    ? '${53}${unit.last} x ${48}${unit.last}'
                                    : '${(int.parse("53") * 0.999996984).toStringAsFixed(0)}cm x ${(int.parse("48") * 0.999996984).toStringAsFixed(0)}cm'
                                    : unit.last == "in"
                                    ? '${53}${unit.last} x ${"48"}${unit.last}'
                                    : '${(int.parse("53") * 1.09361).toStringAsFixed(0)}in x ${(int.parse("48") * 1.09361).toStringAsFixed(0)}in',
                                style: TextStyle(
                                  color: Color(0xFF5A5A5A),
                                  fontSize: 13,
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
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
                                child: Image.asset('assets/spinner.gif', width: 50, height: 50),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// Placeholder functions (implement as needed)
Future<List<String>> getRecentGolf(String key) async => [];
Future<String?> getUserUnit() async => "M";
void setRecentGolf({
  required String golfPlace,
  required String selectFlagH,
  required String selectFlagV,
  required String la,
  required String lo,
  required String unit,
}) {}