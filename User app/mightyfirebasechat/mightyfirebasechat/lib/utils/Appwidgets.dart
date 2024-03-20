import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

AppBar appBar(context, String text, {Color backgroundColor = Colors.white, double textSize = 16, Color textColor = Colors.black, showBack = true, List<Widget>? actions}) {
  return AppBar(
    title: Text(text, style: TextStyle(color: textColor, fontSize: textSize)),
    backgroundColor: backgroundColor,
    leading: showBack ? IconButton(icon: Icon(Icons.arrow_back, color: textColor), onPressed: () => finish(context)) : null,
    actions: actions,
    automaticallyImplyLeading: true,
  );
}

Widget cachedImage(String? url, {double? height, double? width, BoxFit? fit, AlignmentGeometry? alignment, bool usePlaceholderIfUrlEmpty = true, double? radius}) {
  if (url.validate().isEmpty) {
    return placeHolderWidget(height: height, width: width, fit: fit, alignment: alignment, radius: radius);
  } else if (url.validate().startsWith('http')) {
    return Image.network(
      url!,
      height: height,
      width: width,
      fit: fit,
      errorBuilder: (BuildContext? context, Object? exception, StackTrace? stackTrace) {
        return Image.asset('assets/placeholder.jpg', height: height, width: width, fit: fit, alignment: alignment ?? Alignment.center).cornerRadiusWithClipRRect(radius ?? defaultRadius);
      },
      alignment: alignment as Alignment? ?? Alignment.center,
    );
  } else {
    return Image.asset('assets/placeholder.jpg', height: height, width: width, fit: fit, alignment: alignment ?? Alignment.center).cornerRadiusWithClipRRect(radius ?? defaultRadius);
  }
}

Widget placeHolderWidget({double? height, double? width, BoxFit? fit, AlignmentGeometry? alignment, double? radius}) {
  return Image.asset('assets/placeholder.jpg', height: height, width: width, fit: fit ?? BoxFit.cover, alignment: alignment ?? Alignment.center).cornerRadiusWithClipRRect(radius ?? defaultRadius);
}

Widget iconsBackgroundWidget(BuildContext context, {String? name, String? image, Color? color}) {
  return Container(
    width: context.width() / 3 - 32,
    color: context.scaffoldBackgroundColor,
    child: Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(child: SizedBox(height: 28, width: 28), backgroundColor: color, radius: 28),
            Positioned(
              top: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(56),
                      ),
                      color: Colors.black.withOpacity(0.2),
                    ),
                    width: 28,
                    height: 28,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(56),
                      ),
                      color: Colors.black.withOpacity(0.2),
                    ),
                    width: 28,
                    height: 28,
                  ),
                ],
              ),
            ),
            Image.asset(image.validate(), height: 28,width: 28, color: Colors.white),
          ],
        ),
        8.height,
        Text(name.validate(), style: secondaryTextStyle(color: textSecondaryColor)),
      ],
    ),
  );
}

Widget noDataFound({String text='No Chat'}){
  return  Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Image.asset("assets/no_messages.png", height: 120),
      22.height,
      Text(text, style: secondaryTextStyle()).center(),
    ],
  );
}
