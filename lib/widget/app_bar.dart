import 'package:flutter/material.dart';

import '../common/color.dart';
import '../view/finder/screen/finder_coach.dart';
import '../view_model/navigation_provider.dart';
import 'button.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Color? backgroundColor;
  final bool? fullscreenDialog;
  final Function? onTap;
  final List<Widget>? actions;
  final bool? isLeading;
  final Color? titleColor;

  const CustomAppBar({
    Key? key,
    @required this.title,
    this.backgroundColor,
    this.fullscreenDialog = false,
    this.onTap,
    this.actions,
    this.isLeading = true,
    this.titleColor,
  }) : super(key: key);

  @override
  Size get preferredSize => AppBar().preferredSize;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0,
      elevation: 0,
      centerTitle: isLeading,
      backgroundColor: backgroundColor ?? Colors.white,
      leading:
          isLeading!
              ? CustomCupertinoButton(
                margin: EdgeInsets.only(left: 10),
                onTap: () => Navigator.of(context).pop(),
                // child: fullscreenDialog!
                //     ? Image.asset(iconClose)
                //     : Image.asset(iconBack),
              )
              : null,
      title: Text('$title', style: TextStyle(color: appTitleColor, fontSize: 20, fontWeight: FontWeight.bold)),
      bottom: PreferredSize(preferredSize: Size.fromHeight(1), child: Container(color: Colors.grey[100], height: 1)),
      actions: actions ?? [],
    );
  }
}

class SettingAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Color? backgroundColor;
  final bool? fullscreenDialog;
  final Function? onTap;
  final List<Widget>? actions;
  final bool? isLeading;
  final Color? titleColor;

  const SettingAppBar({
    Key? key,
    this.backgroundColor,
    this.fullscreenDialog = false,
    this.onTap,
    this.actions,
    this.isLeading = true,
    this.titleColor,
  }) : super(key: key);

  @override
  Size get preferredSize => AppBar().preferredSize;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0,
      backgroundColor: backgroundColor ?? Colors.white,
      title: Image.asset('assets/home/supercaddie.png'),
      bottom: PreferredSize(preferredSize: Size.fromHeight(1), child: Container(color: Colors.grey[100], height: 1)),
    );
  }
}

class BlackAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Color? backgroundColor;
  final bool? fullscreenDialog;
  final Function? onTap;
  final List<Widget>? actions;
  final bool? isLeading;
  final Color? titleColor;

  const BlackAppBar({
    Key? key,
    this.backgroundColor,
    this.fullscreenDialog = false,
    this.onTap,
    this.actions,
    this.isLeading = true,
    this.titleColor,
    this.title,
  }) : super(key: key);

  @override
  Size get preferredSize => AppBar().preferredSize;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      //appBar 투명색
      leading:
          isLeading!
              ? CustomCupertinoButton(
                //margin: EdgeInsets.only(left: 10),
                onTap: () => Navigator.of(context).pop(),
                child: Image.asset('assets/blackback.png'),
              )
              : null,
      title: Text(
        '$title',
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.w500,
          height: 0.07,
          letterSpacing: -0.54,
        ),
      ),
      actions: actions ?? [],
    );
  }
}
class FunctionAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Color? backgroundColor;
  final bool? fullscreenDialog;
  final Function? onTap;
  final List<Widget>? actions;
  final bool? isLeading;
  final Color? titleColor;

  const FunctionAppBar({
    Key? key,
    this.backgroundColor,
    this.fullscreenDialog = false,
    this.onTap,
    this.actions,
    this.isLeading = true,
    this.titleColor,
    this.title,
  }) : super(key: key);

  @override
  Size get preferredSize => AppBar().preferredSize;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent, // AppBar transparent
      leading: isLeading!
          ? IconButton(
        icon: Image.asset('assets/back.png'),
        onPressed: () => Navigator.pop(context), // Return to previous screen
      )
          : null,
      title: Text(
        '$title',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.w500,
          height: 0.07,
          letterSpacing: -0.54,
        ),
      ),
      actions: actions ??
          [
            IconButton(
              visualDensity: VisualDensity(horizontal: -4.0, vertical: -4.0),
              padding: EdgeInsets.zero,
              icon: Image.asset('assets/coach.png', width: 24, height: 24),
              onPressed: () {
                // if (title == "로스트볼") {
                //   Navigator.push(
                //     context,
                //     MaterialPageRoute(builder: (context) => LostballCoachMark()),
                //   );
                // } else if (title == "에이밍") {
                //   Navigator.push(
                //     context,
                //     MaterialPageRoute(builder: (context) => AimingCoachMark()),
                //   );
                // } else if (title == "홀맵") {
                //   Navigator.push(
                //     context,
                //     MaterialPageRoute(builder: (context) => HoleCoachMark()),
                //   );
                // }
              },
            ),
          ],
    );
  }
}

class FlagAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Color? backgroundColor;
  final bool? fullscreenDialog;
  final Function? onTap;
  final List<Widget>? actions;
  final bool? isLeading;
  final Color? titleColor;

  const FlagAppBar({
    Key? key,
    this.backgroundColor,
    this.fullscreenDialog = false,
    this.onTap,
    this.actions,
    this.isLeading = true,
    this.titleColor,
    this.title,
  }) : super(key: key);

  @override
  Size get preferredSize => AppBar().preferredSize;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.white,
      //appBar 투명색
      leading:
          isLeading!
              ? CustomCupertinoButton(
                //margin: EdgeInsets.only(left: 10),
                onTap: () => Navigator.of(context).pop(),
                child: Image.asset('assets/blackback.png'),
              )
              : null,
      title: Text(
        '$title',
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.w500,
          height: 0.07,
          letterSpacing: -0.54,
        ),
      ),
      actions: actions ?? [],
    );
  }
}

class FinderAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Color? backgroundColor;
  final bool? fullscreenDialog;
  final Function? onTap;
  final List<Widget>? actions;
  final bool? isLeading;
  final Color? titleColor;

  const FinderAppBar({
    Key? key,
    this.backgroundColor,
    this.fullscreenDialog = false,
    this.onTap,
    this.actions,
    this.isLeading = true,
    this.titleColor,
    this.title,
  }) : super(key: key);

  @override
  Size get preferredSize => AppBar().preferredSize;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent, // AppBar 투명색
      leading: isLeading!
          ? IconButton(
        icon: Image.asset('assets/back.png'),
        onPressed: () => Navigator.of(context).pop(),
      )
          : null,
      title: Text(
        '$title',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.w500,
        ),
      ),
      actions: actions ??
          [
            IconButton(
              visualDensity: const VisualDensity(horizontal: -4.0, vertical: -4.0),
              icon: Image.asset('assets/coach.png', width: 24, height: 24),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => FinderCoachMark()),
                );
              },
            ),
          ],
    );
  }
}


