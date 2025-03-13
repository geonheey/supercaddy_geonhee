
import 'package:flutter/material.dart';

import 'inkwell.dart';

class CustomTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Function(int) onTap;
  final bool isActive;
  final List<Widget> tabs;

  CustomTabBarDelegate({
    required this.onTap,
    required this.isActive,
    required this.tabs,
  });

  @override
  double get minExtent => 51;
  @override
  double get maxExtent => 51;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Column(
      children: [
        Container(
          height: 50,
          color: Colors.white,
          child: CustomInkWell(
            onLongPress: () {},
            onTap: () {},
            child: TabBar(
              indicatorWeight: 2,
              indicatorColor: Color(0xff49D6BB),
              labelColor: Color(0xff222222),
              labelStyle: TextStyle(
                color: Color(0xff222222),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: TextStyle(
                color: Color(0xff666666),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              unselectedLabelColor: Color(0xff666666),
              tabs: tabs,
              onTap: onTap,
            ),
          ),
        ),
        isActive
            ? Container(
                height: 1,
                color: Color(0xffDDDDDD),
              )
            : Container(),
      ],
    );
  }

  @override
  bool shouldRebuild(CustomTabBarDelegate oldDelegate) {
    return true;
  }
}
