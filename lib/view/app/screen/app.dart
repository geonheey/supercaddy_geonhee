// // ignore_for_file: non_constant_identifier_names, unused_field
// import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'package:get/get.dart';
// import 'package:superfinder/app/common/checkLocation.dart';
// import 'package:superfinder/app/common/color.dart';
// import 'package:superfinder/app/controller/coupon_controller.dart';
// import 'package:superfinder/app/controller/navigation_controller.dart';
// import 'package:superfinder/app/controller/notialarm.cotroller.dart';
// import 'package:superfinder/app/controller/notification_controller.dart';
// import 'package:superfinder/app/controller/point_page_controller.dart';
// import 'package:superfinder/app/controller/user_info_controller.dart';
// import 'package:superfinder/app/data/repository/point_repository.dart';
// import 'package:superfinder/app/ui/aiming/screen/aiming.dart';
// import 'package:superfinder/app/ui/finder/screen/finder.dart';
// import 'package:superfinder/app/ui/holemap/screen/holemap.dart';
// import 'package:superfinder/app/ui/holemap/screen/kakao_holemap.dart';
// import 'package:superfinder/app/ui/home/screen/home.dart';
// import 'package:superfinder/app/ui/lostball/screen/lostball.dart';
// import 'package:superfinder/app/ui/payment/screen/payment.dart';
// import 'package:superfinder/app/ui/setting/screen/notiAlarm2.dart';
// import 'package:superfinder/app/ui/setting/screen/setting.dart';
// import 'package:superfinder/app/ui/swing/screen/new_swing.dart';
// import 'package:superfinder/main.dart';
// import 'package:superfinder/widget/toast.dart';
//
// bool menuAction = false;
//
// class AppScreen extends StatefulWidget {
//   const AppScreen({
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   _AppScreenState createState() => _AppScreenState();
// }
//
// class _AppScreenState extends State<AppScreen> {
//   var bottomBarHeight = 80;
//   var tempIndex = 0;
//   var buttonAction = 0;
//   final NavigationController navigationController = Get.find();
//   var isInKoreaCheck = true;
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       init();
//       // setState(
//       //   () {
//       //     buttonAction = 1;
//       //   },
//       // );
//
//       //  menuAction = true;
//       // showHomeButtonMenu(
//       //   context,
//       //   bottomBarHeight,
//       //   onCallback1: () {
//       //     setState(() {
//       //       buttonAction = 0;
//       //     });
//       //     debugPrint("거리측정 클릭");
//       //     navigationController.setBottomNavIndex(
//       //         2); // NavigationController를 통해 bottomNavIndex 변경
//       //     Get.back();
//       //   },
//       //   onCallback2: () {
//       //     setState(() {
//       //       buttonAction = 0;
//       //     });
//       //     debugPrint("홀맵");
//       //     navigationController.setBottomNavIndex(4);
//       //     Get.back();
//       //   },
//       //   onCallback3: () {
//       //     setState(() {
//       //       buttonAction = 0;
//       //     });
//       //     debugPrint("에이밍");
//       //     navigationController.setBottomNavIndex(3);
//       //     Get.back();
//       //   },
//       //   onCallback4: () {
//       //     setState(() {
//       //       buttonAction = 0;
//       //     });
//       //     debugPrint("로스트볼");
//       //     navigationController.setBottomNavIndex(5);
//       //     Get.back();
//       //   },
//       //   onCallback5: () {
//       //     setState(() {
//       //       buttonAction = 0;
//       //     });
//       //     debugPrint("슈퍼스윙");
//       //     navigationController.setBottomNavIndex(6);
//       //     Get.back();
//       //   },
//       // );
//     });
//   }
//
//   init() async {
//           isInKoreaCheck = await isInKorea();
//     RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
//     if (initialMessage != null) {
//       print("initialMessageinitialMessageinitialMessageinitialMessageinitialMessageinitialMessag22e = ${initialMessage.notification!.title}");
//       _handleMessage(initialMessage);
//     }
//
//     final PendingDynamicLinkData? initialLink = await FirebaseDynamicLinks.instance.getInitialLink();
//     if (initialLink != null) {
//       final Uri deepLink = initialLink.link;
//       print('YYYY: $deepLink');
//       if (deepLink.toString().contains("crew")) {
//         await configInit();
//         Get.to(PaymentScreen(), transition: Transition.leftToRight);
//       }
//       // Navigator.pushNamed(context, deepLink.path);
//     }
//   }
//
//   Future<void> _handleMessage(RemoteMessage message) async {
//     print('message = ${message.notification!.title}');
//     NotificationsController notificationsController = Get.find();
//     notificationsController.insertNotification(message.notification!.title!, message.notification!.body!);
//     if (message.notification!.title!.contains("출석")) {
//       print("출석체크 페이지로 이동하라는 명령");
//     } else if (message.notification!.title!.contains("크루")) {
//       NotiAlarmController notiAlarmController = Get.find();
//
//       var data = await notiAlarmController.getNewNotiAlarmsDetail("3");
//       Get.to(
//           NotiAlarm2Setting(
//             boardId: 2,
//             title: data.boardTitle,
//             content: data.boardContent,
//             time: data.regDt,
//           ),
//           transition: Transition.leftToRight);
//     } else if (message.notification!.title!.contains("성공")) {
//       final UserInfoController userInfoController = Get.find();
//       PointPageController pointPageController = Get.find();
//       CouponController couponController = Get.find();
//
//       if (userInfoController.couponMode == 1) {
//         await couponController.useCoupon();
//       } else {
//         print("성공 후 포인트 차감");
//
//         final pointRepository = PointRepository();
//         await pointRepository.updatePoint(
//           pointDesc: '영상 분석',
//           pointValue: -1000,
//           userId: userInfoController.user!.email!,
//           pointType: 'REWARD',
//         );
//         await pointPageController.getPointList(userInfoController.user!.email!);
//       }
//     } else if (message.notification!.title!.contains("슈퍼스윙")) {
//       NotiAlarmController notiAlarmController = Get.find();
//
//       var data = await notiAlarmController.getNewNotiAlarmsDetail("1");
//       Get.to(
//           NotiAlarm2Setting(
//             boardId: 2,
//             title: data.boardTitle,
//             content: data.boardContent,
//             time: data.regDt,
//           ),
//           transition: Transition.leftToRight);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     DateTime? currentBackPressTime;
//     Future<bool> onWillPop() {
//       DateTime now = DateTime.now();
//
//       if (currentBackPressTime == null || now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
//         currentBackPressTime = now;
//         customToast(context, title: AppLocalizations.of(Get.context!)!.exitSupportMessage);
//         return Future.value(false);
//       }
//
//       return Future.value(true);
//     }
//
// //Scaffold(body: Aiming());
// // Scaffold(body: KAkaoMap());
// //Scaffold(body: Lostball());
// //Scaffold(body: SwingScreen());
//     Widget _navigationPage(int index) {
//       switch (index) {
//         case 0:
//           return Scaffold(body: HomeScreen());
//         case 1:
//           return Scaffold(body: Setting());
//         case 2:
//           return Scaffold(body: Finder());
//         case 3:
//           if (isInKoreaCheck) {
//             return Scaffold(
//               body: KakaoMap(),
//             );
//           } else {
//             return Scaffold(body: HoleMap());
//           }
//
//         //  return Scaffold(body: HoleMap());
//         case 4:
//           return Scaffold(body: Aiming());
//         case 5:
//           return Scaffold(body: Lostball());
//         case 6:
//           return Scaffold(body: SuperSwing());
//         default:
//           return Container(
//             color: Colors.purple,
//             child: Text("1"),
//           );
//       }
//     }
//
//     return SafeArea(
//       child: WillPopScope(
//         onWillPop: onWillPop,
//         child: Scaffold(
//           body: Obx(() => _navigationPage(navigationController.bottomNavIndex)), // Obx를 사용하여 bottomNavIndex를 관찰
//           floatingActionButton: FloatingActionButton(
//             backgroundColor: Colors.transparent,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
//             child: Container(
//               width: 62,
//               height: 62,
//               padding: const EdgeInsets.only(
//                 top: 18.60,
//                 left: 18.10,
//                 right: 19.10,
//                 bottom: 18.60,
//               ),
//               clipBehavior: Clip.antiAlias,
//               decoration: ShapeDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment(-0.72, 0.69),
//                   end: Alignment(0.72, -0.69),
//                   colors: const [Color(0xFF4196C7), Color(0xFF2CFF82)],
//                 ),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(104.28),
//                 ),
//               ),
//               child: Container(
//                 width: 30,
//                 height: 30,
//                 clipBehavior: Clip.antiAlias,
//                 decoration: BoxDecoration(),
//                 child: buttonAction == 0
//                     ? Image.asset(
//                         'public/images/button.png',
//                         fit: BoxFit.fill,
//                       )
//                     : Image.asset(
//                         'public/images/button2.png',
//                         fit: BoxFit.fill,
//                       ),
//               ),
//             ),
//             onPressed: () {
//               setState(
//                 () {
//                   buttonAction = 1;
//                 },
//               );
//
//               menuAction = true;
//               showHomeButtonMenu(
//                 context,
//                 bottomBarHeight,
//                 onCallback1: () {
//                   setState(() {
//                     buttonAction = 0;
//                   });
//                   debugPrint("거리측정 클릭");
//                   navigationController.setBottomNavIndex(2); // NavigationController를 통해 bottomNavIndex 변경
//                   Get.back();
//                 },
//                 onCallback2: () {
//                   setState(() {
//                     buttonAction = 0;
//                   });
//                   debugPrint("홀맵 클릭");
//                   navigationController.setBottomNavIndex(3);
//                   Get.back();
//                 },
//                 onCallback3: () {
//                   setState(() {
//                     buttonAction = 0;
//                   });
//                   debugPrint("에이밍 클릭");
//                   navigationController.setBottomNavIndex(4);
//                   Get.back();
//                 },
//                 onCallback4: () {
//                   setState(() {
//                     buttonAction = 0;
//                   });
//                   debugPrint("로스트볼 클릭");
//                   navigationController.setBottomNavIndex(5);
//                   Get.back();
//                 },
//                 onCallback5: () {
//                   setState(() {
//                     buttonAction = 0;
//                   });
//                   debugPrint("슈퍼스윙 클릭");
//                   navigationController.setBottomNavIndex(6);
//                   Get.back();
//                 },
//               );
//             },
//           ),
//           floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//           bottomNavigationBar: BottomNavigationBar(
//             currentIndex: tempIndex,
//             unselectedLabelStyle: TextStyle(fontSize: 10.48, fontFamily: 'Pretendard', fontWeight: FontWeight.w500, color: notActiveNavigationLabelColor),
//             selectedLabelStyle: TextStyle(fontSize: 10.48, fontFamily: 'Pretendard', fontWeight: FontWeight.w500, color: notActiveNavigationLabelColor),
//             selectedItemColor: notActiveNavigationLabelColor,
//             unselectedItemColor: notActiveNavigationLabelColor,
//             backgroundColor: buttonAction == 0 ? Colors.black : Colors.white,
//             items: [
//               BottomNavigationBarItem(
//                 icon: Obx(() => navigationController.bottomNavIndex == 0
//                     ? Image.asset('assets/gnb/homeOn.png', width: 23.30, height: 19.46)
//                     : Image.asset('assets/gnb/homeOff.png', width: 23.30, height: 19.46)),
//                 label: Get.context == null ? "" : AppLocalizations.of(Get.context!)!.home,
//               ),
//               BottomNavigationBarItem(
//                 icon: Obx(() => navigationController.bottomNavIndex == 1
//                     ? Image.asset('assets/gnb/settingOn.png', width: 23.30, height: 19.46)
//                     : Image.asset('assets/gnb/settingOff.png', width: 23.30, height: 19.46)),
//                 label: Get.context == null ? "" : AppLocalizations.of(Get.context!)!.settings,
//               ),
//             ],
//             onTap: (index) {
//               navigationController.setBottomNavIndex(index); // NavigationController를 통해 bottomNavIndex 변경
//
//               setState(() {
//                 buttonAction = 0;
//                 tempIndex = index;
//               });
//             },
//           ),
//         ),
//       ),
//     );
//   }
//
//   void showHomeButtonMenu(
//     BuildContext context,
//     int bottomBarHeight, {
//     required void Function() onCallback1,
//     required void Function() onCallback2,
//     required void Function() onCallback3,
//     required void Function() onCallback4,
//     required void Function() onCallback5,
//   }) {
//     showDialog(
//       // barrierDismissible: false,
//       context: context,
//       barrierColor: Colors.black.withOpacity(0.5),
//       builder: (BuildContext context) {
//         return DefaultTextStyle(
//           style: TextStyle(
//             color: Color(0xFF898989),
//             fontSize: 12,
//             fontFamily: 'Noto Sans KR',
//             fontWeight: FontWeight.w500,
//             //height: 0,
//             letterSpacing: -0.24,
//           ), //Flutter 옐로 밑 줄 때문에 사용
//           child: Padding(
//             padding: EdgeInsets.only(bottom: 100),
//             child: Align(
//               alignment: Alignment.bottomCenter,
//               child: Container(
//                 margin: EdgeInsets.only(
//                   left: 20,
//                   right: 20,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(100),
//                 ),
//                 width: MediaQuery.of(context).size.width,
//                 height: 77,
//                 child: Container(
//                   margin: EdgeInsets.only(left: 16, right: 16),
//                   child: Center(
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceAround,
//                       children: [
//                         GestureDetector(
//                           onTap: () {
//                             onCallback1();
//                           },
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Image.asset(
//                                 'public/images/icon-mesurement.png',
//                               ),
//                               Text(
//                                 AppLocalizations.of(Get.context!)!.distance,
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                   color: Color(0xFF898989),
//                                   fontSize: 12,
//                                   fontFamily: 'Noto Sans KR',
//                                   fontWeight: FontWeight.w500,
//                                   //height: 0,
//                                   letterSpacing: -0.24,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         GestureDetector(
//                           onTap: () {
//                             onCallback2();
//                           },
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Image.asset(
//                                 'public/images/icon-holemap.png',
//                               ),
//                               Text(
//                                 AppLocalizations.of(Get.context!)!.holemap,
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                   color: Color(0xFF898989),
//                                   fontSize: 12,
//                                   fontFamily: 'Noto Sans KR',
//                                   fontWeight: FontWeight.w500,
//                                   //height: 0,
//                                   letterSpacing: -0.24,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         GestureDetector(
//                           onTap: () {
//                             onCallback3();
//                           },
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Image.asset(
//                                 'public/images/icon-aiming.png',
//                               ),
//                               Text(
//                                 AppLocalizations.of(Get.context!)!.aiming,
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                   color: Color(0xFF898989),
//                                   fontSize: 12,
//                                   fontFamily: 'Noto Sans KR',
//                                   fontWeight: FontWeight.w500,
//                                   // height: 0,
//                                   letterSpacing: -0.24,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         GestureDetector(
//                           onTap: () {
//                             onCallback4();
//                           },
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Image.asset(
//                                 'public/images/icon-lostboll.png',
//                               ),
//                               Text(
//                                 AppLocalizations.of(Get.context!)!.lostball,
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                   color: Color(0xFF898989),
//                                   fontSize: 12,
//                                   fontFamily: 'Noto Sans KR',
//                                   fontWeight: FontWeight.w500,
//                                   // height: 0,
//                                   letterSpacing: -0.24,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         GestureDetector(
//                           onTap: () {
//                             onCallback5();
//                           },
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Image.asset(
//                                 'public/images/icon-superswing.png',
//                               ),
//                               Text(
//                                 AppLocalizations.of(Get.context!)!.superswing,
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                   color: Color(0xFF898989),
//                                   fontSize: 12,
//                                   fontFamily: 'Noto Sans KR',
//                                   fontWeight: FontWeight.w500,
//                                   //  height: 0,
//                                   letterSpacing: -0.24,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     ).then((value) {
//       setState(() {
//         buttonAction = 0;
//       });
//     });
//   }
// }
