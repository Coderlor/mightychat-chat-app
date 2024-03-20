import 'package:flutter/material.dart';
import 'package:mighty_chat_admin_panel/main.dart';
import 'package:nb_utils/nb_utils.dart';

InputDecoration inputDecoration({String? labelText, Icon? icon}) {
  return InputDecoration(
    hintText: labelText,
    hintStyle: secondaryTextStyle(),
    prefixIcon: icon,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(defaultRadius), borderSide: BorderSide(color: Colors.transparent)),
    focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(defaultRadius), borderSide: BorderSide(color: Colors.transparent)),
    disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(defaultRadius), borderSide: BorderSide(color: Colors.transparent)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(defaultRadius), borderSide: BorderSide(color: Colors.transparent)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(defaultRadius), borderSide: BorderSide(color: Colors.transparent)),
    alignLabelWithHint: true,
    filled: true,
    fillColor: appStore.isDarkMode ? dividerDarkColor : Colors.grey.withOpacity(0.3),
    isDense: true,
  );
}
