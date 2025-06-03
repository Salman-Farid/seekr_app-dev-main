import 'package:flutter/material.dart';

class L10n {
  static final all = [
    const Locale('en', 'US'),
    const Locale.fromSubtags(languageCode: 'zh'),
    const Locale.fromSubtags(
      languageCode: 'zh',
      scriptCode: 'Hans',
      countryCode: 'CN',
    ),
    const Locale.fromSubtags(
      languageCode: 'zh',
      scriptCode: 'Hant',
      countryCode: 'HK',
    ),
    const Locale('es', 'ES'), // Spanish
    const Locale('ja', 'JP'), // Japanese
  ];

  static String? getLang(String? code) {
    switch (code) {
      case 'US':
        return 'English';
      case 'HK':
        return '繁體';
      case 'CN':
        return '简体';
      case 'ES':
        return 'Español';
      case 'JP':
        return '日本語';
    }
    return 'English';
  }
}
