import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../utils/ResponsiveWidget.dart';

class DashboardCardComponent extends StatefulWidget {
  final Future<int>? future;
  final String? title;

  DashboardCardComponent({this.future, this.title});

  @override
  _DashboardCardComponentState createState() => _DashboardCardComponentState();
}

class _DashboardCardComponentState extends State<DashboardCardComponent> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
        future: widget.future,
        builder: (context, snap) {
          if (snap.hasData)
            return Container(
              width: 200,
              padding: EdgeInsets.all(16),
              decoration: boxDecorationRoundedWithShadow(8, backgroundColor: context.cardColor),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (!ResponsiveWidget.isSmallScreen(context)) Icon(Icons.person_outline_sharp, size: 34),
                  8.width,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(snap.data.validate().toString(), style: boldTextStyle()),
                      Text(widget.title.validate(), style: secondaryTextStyle(size: 14), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, maxLines: 2),
                    ],
                  ).expand(),
                ],
              ),
            );
          return snapWidgetHelper(snap, loadingWidget: SizedBox());
        });
  }
}
