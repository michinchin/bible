import 'package:i18n_extension/i18n_extension.dart';

// cspell: disable

extension Localization on String {
  static final _t = Translations('en_us') +

      // Study tabs
      {
        'en_us': 'About',
        'es': 'Acerca de',
      } +
      {
        'en_us': 'Intro',
        'es': 'Intro',
      } +
      {
        'en_us': 'Resources',
        'es': 'Recursos',
      } +
      {
        'en_us': 'Notes',
        'es': 'Notas',
        'ar': 'على',
      } +

      // ...
      {
        'en_us': 'Explore',
        'es': 'Explorar',
        'ar': 'عرض',
      } +
      {
        'en_us': 'Home',
        'es': 'Casa',
        'ar': 'ترجمة',
      } +
      {
        'en_us': 'Study',
        'es': 'Estudiar',
        'ar': 'تواصل',
      };

  String get i18n => localize(this, _t);
}
