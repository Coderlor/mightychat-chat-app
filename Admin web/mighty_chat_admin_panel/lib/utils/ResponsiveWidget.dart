import 'package:flutter/material.dart';

class ResponsiveWidget extends StatelessWidget {
  final Widget largeScreen;
  final Widget? mediumScreen;
  final Widget? smallScreen;

  const ResponsiveWidget({Key? key, required this.largeScreen, this.mediumScreen, this.smallScreen}) : super(key: key);

  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 800;
  }

  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width > 1200 && MediaQuery.of(context).size.height - kToolbarHeight > 500;
  }

  static bool isMediumScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 800 && MediaQuery.of(context).size.width <= 1200;
  }

  static bool isLessMediumScreen(BuildContext context) {
    return MediaQuery.of(context).size.width <= 1200;
  }

  static bool isExtraSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width <= 900;
  }

  static bool isExtraMediumScreen(BuildContext context) {
    return MediaQuery.of(context).size.width <= 800;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        print('${constraints.maxWidth}  ${constraints.maxHeight}');
        if (constraints.maxWidth > 1200) {
          return largeScreen;
        } else if (constraints.maxWidth <= 1200 && constraints.maxWidth >= 800) {
          return mediumScreen ?? largeScreen;
        } else {
          return smallScreen ?? largeScreen;
        }
      },
    );
  }
}
