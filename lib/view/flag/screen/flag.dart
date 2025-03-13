// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';


class FlagScreen extends StatefulWidget {
  final String currentPalce;
  Function onChoose;

  FlagScreen({super.key, required this.currentPalce, required this.onChoose});

  @override
  _FlagScreenState createState() => _FlagScreenState();
}

class _FlagScreenState extends State<FlagScreen> {
  final LoadingController loadingController = Get.put(LoadingController());
  FlagController flagController = Get.find();

  AddressController addressController = Get.find();
  bool _dialogShown = false;
  int add_index = 0;
  final TextEditingController _placeController = TextEditingController();
  int currentIndex = -1;
  int downIndex = 0;
  String userUnit = "M";

  @override
  void initState() {
    super.initState();


    if (!_dialogShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        //   flagNotiAlert(context);
            init();
        _dialogShown = true;
        // LoadingController.to.isLoading.value = true;
        // flagController.getGolfNear(addressController.currentlatitude.value, addressController.currentlongitude.value);
        // LoadingController.to.isLoading.value = false;
      });
    }
  }

  add() async {
    await flagController.insertFlag(46, 35, flagController.placeNames[add_index], "cm");
    await flagController.insertFlag(50, 35, flagController.placeNames[add_index], "cm");
    flagController.getFlags(flagController.placeNames[add_index]);

  }

  init() async {
    print("flag init");
    userUnit = await getUserUnit() ?? "M";
      addressController.getCurrentLocation();
      addressController.getCurrentOnlyLocation();
      LoadingController.to.isLoading.value = true;

      print("addressController.currentlatitude.value ======== ${addressController.currentlatitude.value}");
      flagController.getGolfNear(addressController.currentlatitude.value, addressController.currentlongitude.value);
      LoadingController.to.isLoading.value = false;
  }

  @override
  void dispose() {
    super.dispose();

    // flagController.downFlag[downIndex] = false;
    flagController.selectFlagH = -1;
    flagController.selectFlagV = -1;
    flagController.selectGolfPlace = -1;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFFF6F6F6),
        appBar: FlagAppBar(
          title: AppLocalizations.of(context)!.selectGolfCourse,
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: Obx(() {
            return GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Column(
                      children: [
                        Container(
                          color: Colors.white,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.all(20),
                                  child: TextFormField(
                                    controller: _placeController,
                                    onChanged: (value) {
                                      flagController.getGolfCourses(
                                          addressController.currentlatitude.value, addressController.currentlongitude.value, value);
                                      if (_placeController.text == "") {
                                        flagController.getGolfNear(addressController.currentlatitude.value, addressController.currentlongitude.value);
                                      }
                                    },
                                    decoration: InputDecoration(
                                      hintStyle: TextStyle(
                                        color: Color(0xFFD0D0D0),
                                        fontSize: 15,
                                        fontFamily: 'Pretendard',
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: -0.48,
                                      ),
                                      hintText: AppLocalizations.of(context)!.hint,
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0xFFD0D0D0),
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0xFFD0D0D0),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Container(
                                margin: EdgeInsets.only(right: 16),
                                width: 24,
                                height: 24,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(),
                                child: Stack(
                                  children: [
                                    Image.asset('assets/page-search-md.png'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 18,
                        ),
                        Expanded(
                          child: Container(
                            color: Color(0xFFF6F6F6),
                            margin: EdgeInsets.only(left: 16, right: 16),
                            child: SingleChildScrollView(
                              child: Container(
                                child: Center(
                                  child: Column(
                                    children: List.generate(
                                      flagController.placeNames.length,
                                      (index) => Column(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              widget.onChoose(flagController.placeNames[index]);
                                            },
                                            behavior: HitTestBehavior.opaque,
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
                                                    SizedBox(
                                                      width: customWidth(context) - 150,
                                                      child: Text(
                                                        // "placeName",
                                                        flagController.placeNames[index],
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 15,
                                                          fontFamily: 'Pretendard',
                                                          fontWeight: FontWeight.w400,
                                                          letterSpacing: -0.45,
                                                        ),
                                                        overflow: TextOverflow.clip,
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
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (loadingController.isLoading.value)
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
            );
          }),
        ),
      ),
    );
  }
}
