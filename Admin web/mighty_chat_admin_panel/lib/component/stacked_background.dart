import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../main.dart';
import '../utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

class StackedBackground extends StatelessWidget {
  final Widget child;
  final bool showBackButton;

  StackedBackground({required this.child, this.showBackButton = true});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: context.height(),
          width: context.width(),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: Image.asset(appImages.singingBackground).image,
              fit: BoxFit.cover,
              colorFilter: appStore.isDarkMode ? ColorFilter.mode(Colors.black54, BlendMode.luminosity) : null,
            ),
          ),
        ),
        child.center(),
        if (showBackButton)
          Positioned(
            top: 16,
            left: 16,
            child: BackButton(
              onPressed: () {
                finish(context);
              },
            ),
          ),
        Observer(builder: (context) => Loader().visible(appStore.isLoading)),
      ],
    );
  }
}
