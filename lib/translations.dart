import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static final _t = Translations('en_us') +
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
        'en_us': 'Notes',
        'es': 'Notas',
        'ar': 'على',
      } +
      {
        'en_us': 'Study',
        'es': 'Estudiar',
        'ar': 'تواصل',
      } + {
        'en_us': 'You have pushed the button this many times:',
        'es': 'Has presionado el botón tantas veces:',
        'ar': ':لقد ضغطت على الزر عدة مرات',
      };

  String get i18n => localize(this, _t);
}
