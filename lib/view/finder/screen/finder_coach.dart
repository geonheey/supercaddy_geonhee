import 'package:flutter/material.dart';


import '../../../widget/size.dart';

class FinderCoachMark extends StatelessWidget {
  
  const FinderCoachMark({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(children: [
        SizedBox(
          width: customWidth(context),
          height: customHeight(context),
        
          child: Container(
              child: Image.asset(
            'assets/finder-as.png',
            fit: BoxFit.contain,
          )),
        ),
        Positioned(
            top: 0,
            left: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                Navigator.pop(context); //여기여기
              },
              child: SizedBox(
                //  color: Colors.red,
                width: 100,
                height: 100,
              ),
            )),
      ]),
    );
  }
}
