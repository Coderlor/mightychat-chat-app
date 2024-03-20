import 'package:flutter/material.dart';
import '../utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

class NoDataComponent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(appImages.emptyData, height: 250, width: 250),
          16.height,
          Text('No Inactive user', style: boldTextStyle()),
        ],
      ),
    );
  }
}
