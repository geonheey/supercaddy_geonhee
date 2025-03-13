import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:superfinder/app/controller/flag_controller.dart';
import 'package:superfinder/l10n/gen_l10n/app_localizations.dart';
import 'package:superfinder/widget/alert.dart';
import 'package:superfinder/widget/size.dart';

import '../../../widget/size.dart';

class FlagCard extends StatefulWidget {
  const FlagCard({super.key});

  @override
  _FlagCardState createState() => _FlagCardState();
}

class _FlagCardState extends State<FlagCard> {
  FlagController flagController = Get.find();
  int currentIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        child: Center(
          child: Column(
            children: List.generate(
              flagController.placeNames.length,
              (index) => Column(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () async {
                      setState(() {
                        currentIndex = -1;
                      });
                      flagController.selectFlagH = -1;
                      flagController.selectFlagV = -1;
                      flagController.selectGolfPlace = -1;

                      print(index);
                      if (flagController.downFlag[index]) {
                        flagController.downFlag[index] = false;
                      } else {
                        flagController.downFlag[index] = true;
                      }

                      for (int i = 0; i < flagController.downFlag.length; i++) {
                        if (i != index) {
                          flagController.downFlag[i] = false;
                        }
                      }

                      await flagController.getFlags(flagController.placeNames[index]);
                      flagController.selectGolfPlace = index;
                    },
                    child: Container(
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      child: Container(
                        margin: EdgeInsets.only(left: 20, right: 20, top: 14, bottom: 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              child: Text(
                                flagController.placeNames[index],
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: -0.45,
                                ),
                              ),
                            ),
                            Container(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    '${flagController.placeDistance[index]}km',
                                    style: TextStyle(
                                      color: Color(0xFF666666),
                                      fontSize: 15,
                                      fontFamily: 'Pretendard',
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: -0.45,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                      width: 24,
                                      height: 24,
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(),
                                      child: flagController.downFlag[index]
                                          ? Image.asset('public/images/icon-chevron.png')
                                          : Image.asset('public/images/down.png')),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  flagController.downFlag[index]
                      ? Container(
                          margin: EdgeInsets.only(bottom: 10),
                          color: Colors.white,
                          child: Container(
                            margin: EdgeInsets.only(top: 10),
                            child: Column(
                              children: [
                                Column(
                                  // mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    flagController.flag.length,
                                    (index) => Column(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(left: 10, right: 10, bottom: 2),
                                          height: 51,
                                          decoration: ShapeDecoration(
                                            color: currentIndex == index ? Color(0xFFE9F7F2) : Colors.white,
                                            shape: RoundedRectangleBorder(
                                              side: BorderSide(width: 1, color: currentIndex == index ? Color(0xFF30C58F) : Color(0xFFF0F0F0)),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ),
                                          child: GestureDetector(
                                            behavior: HitTestBehavior.opaque,
                                            onTap: () {
                                              setState(() {
                                                currentIndex = index;
                                                flagController.selectFlagH = flagController.flag[index]!.hLNTH.toInt();
                                                flagController.selectFlagV = flagController.flag[index]!.vLNTH.toInt();
                                              });
                                            },
                                            child: Container(
                                              child: Padding(
                                                padding: const EdgeInsets.all(16.0),
                                                child: Row(
                                                  children: [
                                                    currentIndex == index ? Image.asset('public/images/flag-02.png') : Image.asset('public/images/flag-01.png'),
                                                    SizedBox(
                                                      width: 8,
                                                    ),
                                                    Text(
                                                      '${flagController.flag[index]!.hLNTH.toStringAsFixed(0)} x ${flagController.flag[index]!.vLNTH.toStringAsFixed(0)}',
                                                      style: TextStyle(
                                                        color: currentIndex == index ? Color(0xFF30C58F) : Color(0xFF666666),
                                                        fontSize: 15,
                                                        fontFamily: 'Pretendard',
                                                        fontWeight: FontWeight.w400,
                                                        letterSpacing: -0.45,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                      ],
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    flagAddAlert(context, flagController.placeNames[index]);
                                  },
                                  child: Container(
                                    width: customWidth(context),
                                    margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                                    decoration: ShapeDecoration(
                                      color: Color(0xFF30C58F),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 22, top: 14, bottom: 14),
                                      child: Row(
                                        children: [
                                          Container(
                                              width: 24,
                                              height: 24,
                                              clipBehavior: Clip.antiAlias,
                                              decoration: BoxDecoration(),
                                              child: Image.asset('public/images/icon-plus.png')),
                                          Text(
                                            AppLocalizations.of(context).registerFlag,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontFamily: 'Pretendard',
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: -0.45,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
