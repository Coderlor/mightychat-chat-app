import 'package:chat/utils/AppImages.dart';
import 'package:flutter/material.dart';

class Language {
  int id;
  String name;
  String languageCode;
  String fullLanguageCode;
  String flag;
  String groupName;

  Language(this.id, this.name, this.languageCode, this.flag, this.fullLanguageCode, this.groupName);

  static List<Language> getLanguages() {
    return <Language>[
      Language(0, 'English (Default Language)', 'en', ic_us, 'en-EN', 'langGroup'),
      Language(1, 'ગુજરાતી', 'gu', ic_india, 'gu-IN', 'langGroup'),
      Language(2, 'हिन्दी', 'hi', ic_india, 'hi-IN', 'langGroup'),
      Language(3, 'عربي', 'ar', ic_ar, 'ar-AR', 'langGroup'),
      Language(4, 'français', 'fr', ic_french, 'fr-FR', 'langGroup'),
    ];
  }

  static List<String> languages() {
    List<String> list = [];

    getLanguages().forEach((element) {
      list.add(element.languageCode);
    });

    return list;
  }

  static List<Locale> languagesLocale() {
    List<Locale> list = [];

    getLanguages().forEach((element) {
      list.add(Locale(element.languageCode, ''));
    });

    return list;
  }
}
