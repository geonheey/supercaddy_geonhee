import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image/image.dart' as img;
import 'package:pytorch_lite/pytorch_lite.dart';


import '../../../widget/size.dart';
import '../../../widget/windiretionIcon.dart';
import '../../aiming/widget/object.dart';
import '../screen/finder.dart';

class FinserTest extends StatefulWidget {
  final String imagePath;
  final String distanceText;
  final String wind;
  final double windPosition;
  final String unit;
  final String club;
  final double zoomValue;
  final double angle;

  const FinserTest({
    super.key,
    required this.imagePath,
    required this.distanceText,
    required this.wind,
    required this.windPosition,
    required this.unit,
    required this.club,
    required this.zoomValue,
    required this.angle,
  });

  @override
  _FinserTestState createState() => _FinserTestState();
}

class _FinserTestState extends State<FinserTest> with WidgetsBindingObserver {
  late ModelObjectDetection _objectModel;
  ResultObjectDetection? maxObjDetect;
  List<ResultObjectDetection?> maxObjDetectList = [];
  final FlutterTts tts = FlutterTts();
  ObjectRecogniz objectRecogniz = ObjectRecogniz();
  ObjectRecognizFov objectRecogniztest = ObjectRecognizFov();
  bool isLoading = false; // Replaced LoadingController with local variable
  List<String> palcNm = [];
  List<String> flagH = [];
  List<String> flagV = [];
  List<String> unit = [];
  List<String> golfLa = [];
  var changedata = 0;
  var isInKoreaCheck = true;
  String? distanceText = "0.0";
  List<String> golfLo = [];
  String userUnit = "M";
  String nearestClubName = "SW";
  bool processing = false;
  Uint8List? regionBytes;
  String heightDistanceText = "0";
  int heightDistance = 0;
  bool sound = true;
  String testString = "";
  List<double> resultData = [0, 0];
  double typeData = 0;
  double test33 = 0;
  double test44 = 0;
  String recommendText = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      init();
    });
  }

  Future<void> initTts() async {
    await tts.setLanguage("ko-KR");
    await tts.setSpeechRate(0.3);
    await tts.setVolume(1.0);
    await tts.setPitch(1.0);
  }

  Future<void> init() async {
    // sound = (await getSoundCheck())!;
    setState(() => isLoading = true); // Replaced LoadingController
    palcNm = await getRecentGolf("golfPlaceKey");
    flagH = ["50"]; // await getRecentGolf("flagHKey");
    flagV = ["45"]; // await getRecentGolf("flagVKey");
    golfLa = await getRecentGolf("flagLaKey");
    golfLo = await getRecentGolf("flagLoKey");
    unit = await getRecentGolf("flagUnitKey");
    userUnit = await getUserUnit() ?? "M";
    changedata = await getChangeDistance() ?? 0;
    print("palcNm ========== $palcNm");
    print("flagH ========== $flagH");
    print("flagV ========== $flagV");
    print("golfLa ========== $golfLa");
    print("golfLo ========== $golfLo");
    print("unit ========== $unit");
    await initTts();
    setState(() {});

    await runObjectDetection(widget.imagePath);
    setState(() => isLoading = false); // Replaced LoadingController
  }

  Future<void> loadModel() async {
    String pathObjectDetectionModel = "assets/models/yolov8_flag_640.torchscript";
    try {
      _objectModel = await PytorchLite.loadObjectDetectionModel(
          pathObjectDetectionModel, 1, 640, 640,
          labelPath: "assets/labels/label_flag.txt",
          objectDetectionModelType: ObjectDetectionModelType.yolov8);
    } catch (e) {
      if (e is PlatformException) {
        print("only supported for android, Error is $e");
      } else {
        print("Error is $e");
      }
    }
  }

  double generateRandomPercentage() {
    final random = Random();
    return 50 + random.nextDouble() * 45; // 70부터 95까지의 값 생성
  }

  Future<double> getAverageBrightness(String imagePath) async {
    final imageFile = File(imagePath);
    final decodedImage = await img.decodeImageFile(imagePath);
    if (decodedImage == null) {
      throw Exception('Failed to decode image: $imagePath');
    }
    final grayscaleImage = img.grayscale(decodedImage);
    final byteData = grayscaleImage.toUint8List();
    final numBytes = byteData.lengthInBytes;
    var totalBrightness = 0.0;
    for (var i = 0; i < numBytes; i++) {
      totalBrightness += byteData[i];
    }
    final averageBrightness = totalBrightness / numBytes;
    return averageBrightness;
  }

  Future<void> runObjectDetection(String filePath) async {
    print("runObjectDetection");
    processing = true;
    File image1 = File(filePath);
    await loadModel().then((value) async {
      await image1.readAsBytes().then((Uint8List image) async {
        List<ResultObjectDetection?> objDetec1 =
        await _objectModel.getImagePredictionList(image,
            minimumScore: 0.05, iOUThreshold: 0.5);
        maxObjDetect = null;
        maxObjDetectList.clear();
        var decodedImage = await decodeImageFromList(image1.readAsBytesSync());

        print("${decodedImage.height}");
        print("${decodedImage.width}");

        test33 = generateRandomPercentage();
        test44 = await getAverageBrightness(filePath);

        setState(() {
          if (objDetec1.isNotEmpty) {
            maxObjDetect = objDetec1.first;
          }

          for (int i = 0; i < objDetec1.length; i++) {
            if (maxObjDetect!.score < objDetec1[i]!.score) {
              maxObjDetect = objDetec1[i];
            }
          }
          if (maxObjDetect != null) {
            maxObjDetectList.add(maxObjDetect);
          }
          if (maxObjDetect != null) {
            print(maxObjDetect!.rect.bottom);
            print(maxObjDetect!.rect.top);
            print(maxObjDetect!.rect.right);
            print(maxObjDetect!.rect.left);
            print(maxObjDetect!.rect.width);
            print(maxObjDetect!.rect.height);
            print("d. object 디텍팅 성공");
            var distance = 0.0;
            if (userUnit == "M") {
              resultData = objectRecogniztest.distance(
                  context,
                  image1,
                  maxObjDetect!,
                  widget.zoomValue,
                  int.parse(flagH.last),
                  int.parse(flagV.last),
                  decodedImage.height,
                  decodedImage.width,
                  MediaQuery.of(context).devicePixelRatio,
                  changedata);
              distance = resultData.first;
              typeData = resultData.last;

              if (typeData >= 0.9) {
                testString = "A tpye";
              } else if (typeData < 0.9 && typeData >= 0.7) {
                testString = "B tpye";
              } else if (typeData < 0.7 && typeData >= 0.5) {
                testString = "C tpye";
              } else if (typeData < 0.5) {
                testString = "D tpye";
              } else {
                testString = "알수없음";
              }
            } else {
              resultData = objectRecogniztest.distance(
                  context,
                  image1,
                  maxObjDetect!,
                  widget.zoomValue,
                  int.parse(flagH.last),
                  int.parse(flagV.last),
                  decodedImage.height,
                  decodedImage.width,
                  MediaQuery.of(context).devicePixelRatio,
                  changedata);
              distance = resultData.first * 1.09361;
              typeData = resultData.last;

              if (typeData >= 0.9) {
                testString = "A tpye";
              } else if (typeData < 0.9 && typeData >= 0.7) {
                testString = "B tpye";
              } else if (typeData < 0.7 && typeData >= 0.5) {
                testString = "C tpye";
              } else if (typeData < 0.5) {
                testString = "D tpye";
              } else {
                testString = "알수없음";
              }
            }

            int minDiff = 300;
            nearestClubName = "SW";
            for (var club in Club.clubs) {
              int diff = (club.distance - distance.toInt()).abs();
              print(diff);
              if (diff < minDiff) {
                minDiff = diff;
                nearestClubName = club.name;
              }
            }
            distanceText = distance.toStringAsFixed(0);
            img.Image? image = img.decodeImage(image1.readAsBytesSync());

            if (mounted) {
              setState(() {
                double intparse = double.parse(widget.angle.toStringAsFixed(2)) - 90;
                var underpi = 180 / intparse;
                var step2 = pi / underpi;
                heightDistanceText =
                    (double.parse(distanceText!) * step2).toStringAsFixed(0);

                print("heightDistance widget.angle = ${widget.angle}");
                print("heightDistance distanceText = $distanceText");
                print("heightDistance = $heightDistance");
                heightDistance = int.parse(heightDistanceText);

                recommendText = (heightDistance + distance).toStringAsFixed(0);
                processing = false;
              });
            }

            if (sound) {
              var heighvar = "오르막";
              if (heightDistanceText.contains("-")) {
                heighvar = "내리막";
              }
              var ttsHeight =
              heightDistanceText.replaceAll(RegExp('[^a-zA-Z0-9가-힣\\s]'), "");
              var unitTTs = userUnit == "M" ? "미터" : "야드";
              // tts.speak(
              //     "${distanceText} ${unitTTs} 보고 치시면 됩니다. $heighvar $ttsHeight 미터 입니다.");
            }
            if (int.parse(distanceText!) >= 0 && int.parse(distanceText!) <= 50) {
              // okCancleAlert(context, distance: distanceText!, userUnit: userUnit);
            }
            if (int.parse(distanceText!) >= 0 && int.parse(distanceText!) <= 20) {
              // okCancleAimingAlert(context, distance: distanceText!);
            }
            if (int.parse(distanceText!) > 170) {
              okCancleMaxAlert(context, distance: distanceText!);
            }
          } else {
            flagAlert(context,
                subTilte: AppLocalizations.of(context)!.flagNotfindMessage,
                buttonText: AppLocalizations.of(context)!.ok);
          }
        });
      });
    });
  }

  Widget boundingBoxes2(List<ResultObjectDetection?>? results) {
    if (results == null) {
      return Container();
    }
    return Stack(
      children: results.map((e) => BoxWidget(result: e!)).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.9,
      heightFactor: 0.8,
      child: Scaffold(
        body: SafeArea(
          child: Container(
            width: customWidth(context),
            height: customHeight(context),
            color: Colors.black,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(10))),
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
                              const SizedBox(height: 10),
                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          child: Text(
                                            recommendText,
                                            style: TextStyle(
                                              color: Color(0xFF30C58F),
                                              fontSize: 40,
                                              fontFamily: 'Roboto',
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: -1.20,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Container(
                                          margin: EdgeInsets.only(top: 15),
                                          child: Text(
                                            widget.unit,
                                            style: TextStyle(
                                              color: Color(0xFF30C58F),
                                              fontSize: 30,
                                              fontFamily: 'Roboto',
                                              fontWeight: FontWeight.w400,
                                              letterSpacing: -0.90,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        Stack(
                          children: [
                            Container(
                              width: customWidth(context),
                              height: customHeight(context) / 3.8,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: Image.file(
                                  File(widget.imagePath),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            regionBytes == null
                                ? Container()
                                : Positioned(
                              top: 10,
                              right: 5,
                              child: Container(
                                width: customWidth(context) / 4,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Color(0xFF30C58F),
                                    width: 2,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.memory(regionBytes!),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              child: Text(
                                !isKoreanSystemLocale() ? "Measured Distance" : "측정 거리",
                                style: TextStyle(
                                  color: Color(0xFF898989),
                                  fontSize: 15,
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: -0.45,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  '$distanceText $userUnit',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: -0.45,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              child: Text(
                                AppLocalizations.of(context)!.recommended,
                                style: TextStyle(
                                  color: Color(0xFF898989),
                                  fontSize: 15,
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: -0.45,
                                ),
                              ),
                            ),
                            Text(
                              nearestClubName,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w400,
                                letterSpacing: -0.45,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              child: Text(
                                AppLocalizations.of(context)!.altitude,
                                style: TextStyle(
                                  color: Color(0xFF898989),
                                  fontSize: 15,
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: -0.45,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  '${heightDistanceText}m',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: -0.45,
                                  ),
                                ),
                                SizedBox(width: 2),
                                heightDistance >= 0
                                    ? Image.asset('assets/up.png')
                                    : Image.asset('assets/down.png'),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              child: Text(
                                AppLocalizations.of(context)!.windSpeed,
                                style: TextStyle(
                                  color: Color(0xFF898989),
                                  fontSize: 15,
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: -0.45,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  '${widget.wind}m/s',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: -0.45,
                                  ),
                                ),
                                SizedBox(width: 5),
                                WindDirectionIcon(widget.windPosition),
                              ],
                            ),
                          ],
                        ),
                        Expanded(child: SizedBox()),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context); // Replaced Get.back()
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
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4)),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.filmingAgain,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
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
                // Positioned(
                //   top: 50,
                //   right: 30,
                //   child: GestureDetector(
                //     onTap: () {
                //       print(distanceText);
                //       if (isInKoreaCheck) {
                //         Navigator.push(
                //           context,
                //           MaterialPageRoute(
                //             builder: (context) => KAkaoMap2(distance: distanceText!),
                //           ),
                //         ); // Replaced Get.to()
                //       } else {
                //         Navigator.push(
                //           context,
                //           MaterialPageRoute(
                //             builder: (context) => HoleMap2(distance: distanceText!),
                //           ),
                //         ); // Replaced Get.to()
                //       }
                //     },
                //     child: Image.asset('assets/page-map-01.png'),
                //   ),
                // ),
                // Positioned(
                //   top: 80,
                //   right: 5,
                //   child: GestureDetector(
                //     onTap: () {
                //       if (isInKoreaCheck) {
                //         Navigator.push(
                //           context,
                //           MaterialPageRoute(
                //             builder: (context) => KAkaoMap2(distance: distanceText!),
                //           ),
                //         ); // Replaced Get.to()
                //       } else {
                //         Navigator.push(
                //           context,
                //           MaterialPageRoute(
                //             builder: (context) => HoleMap2(distance: distanceText!),
                //           ),
                //         ); // Replaced Get.to()
                //       }
                //     },
                //     child: !isKoreanSystemLocale()
                //         ? Image.asset('public/images/page-map-01-us.png')
                //         : Image.asset('assets/Group16295.png'),
                //   ),
                // ),
                if (isLoading) // Replaced loadingController.isLoading.value
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
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}