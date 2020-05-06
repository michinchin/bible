# Tecarta Bible

## Development Info

### **Localization**

For multi-language support we're using Marcelo Glasberg's `i18n_extension` library (<https://pub.dev/packages/i18n_extension>).

It is super easy to use:

  1. Import `translations.dart`.

  2. Add `.i18n` to the end of your string.

  3. And, at some point in the future, we'll need to add the string and its translations to the `translations.dart` file (which, could be easily automated by writing a command line utility that extracts all strings with the postfix `.i18n`).

### **Model Classes**

In general, model classes should be defined as immutable, and kept as simple as possible.

For model classes that need to support equality comparison (`==`) and/or `copyWith`, Remi Rousselet's `freezed` library(<https://pub.dev/packages/freezed>) library should be used to keep our model classes consistent, and reduce boilerplate. The `freezed` library also provides access to some useful features such as union types, lazily initialized variables, and JSON serialization/deserialization.

Note, if you edit a model class that uses the freezed library, the associated auto-generated dart file(s) need to be updated by running:

> `flutter pub run build_runner build --delete-conflicting-outputs`

Or, to start a persistent process that watches for changes, you can run:

> `flutter pub run build_runner watch --delete-conflicting-outputs`

### **BLoC Classes**

To keep our `bloc` classes consistent and to reduce boilerplate we're using Felix Angelov's `bloc` library (<https://pub.dev/packages/bloc>). Its excellent documentation and example code can be found here: (<https://bloclibrary.dev>).
