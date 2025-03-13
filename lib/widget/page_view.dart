import 'package:flutter/material.dart';
import 'package:supercaddy_geonhee/widget/size.dart';

class CustomPageView extends StatefulWidget {
  final PageController? pageController;
  final List<Widget>? children;

  const CustomPageView({
    Key? key,
    @required this.pageController,
    @required this.children,
  }) : super(key: key);

  @override
  _CustomPageViewState createState() => _CustomPageViewState();
}

class _CustomPageViewState extends State<CustomPageView>
    with TickerProviderStateMixin {
  PageController? _pageController;
  List<double>? _heights;

  double get _currentHeight => _heights![
      _pageController!.hasClients ? _pageController!.page!.round() : 0];

  @override
  void initState() {
    _pageController = widget.pageController;

    _heights = widget.children!.map((e) => 0.0).toList();
    super.initState();
  }

  double _getHeight(double height) {
    if (height > customHeight(context) / 2) {
      return height;
    } else {
      return customHeight(context) / 2;
    }
  }

  List<Widget> get _sizeReportingChildren => widget.children!
      .asMap()
      .map(
        (index, child) => MapEntry(
          index,
          OverflowBox(
            minHeight: 0,
            maxHeight: double.infinity,
            alignment: Alignment.topCenter,
            child: SizeReportingWidget(
              onSizeChange: (size) =>
                  setState(() => _heights![index] = size.height),
              child: child,
            ),
          ),
        ),
      )
      .values
      .toList();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      curve: Curves.easeInOutCubic,
      duration: Duration(milliseconds: 100),
      tween: Tween<double>(
          begin: _getHeight(_heights![0]), end: _getHeight(_currentHeight)),
      builder: (context, value, child) => SizedBox(height: value, child: child),
      child: PageView(
        controller: _pageController,
        allowImplicitScrolling: true,
        children: _sizeReportingChildren,
      ),
    );
  }
}

class SizeReportingWidget extends StatefulWidget {
  final Widget child;
  final ValueChanged<Size> onSizeChange;

  const SizeReportingWidget({
    Key? key,
    required this.child,
    required this.onSizeChange,
  }) : super(key: key);

  @override
  _SizeReportingWidgetState createState() => _SizeReportingWidgetState();
}

class _SizeReportingWidgetState extends State<SizeReportingWidget> {
  late Size _oldSize;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _notifySize());
    return widget.child;
  }

  void _notifySize() {
    final size = context.size;
    if (_oldSize != size) {
      _oldSize = size!;
      widget.onSizeChange(size);
    }
  }
}
