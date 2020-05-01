# Tecarta Bible

## Development Info

### Localization

For multi-language support we're using the [`i18n_extension`](https://pub.dev/packages/i18n_extension) library.

It's super simple:

  1. Import `translations.dart`.

  2. Add `.i18n` to the end of your string.

  3. And, at some point in the future, we'll need to add the string and its translations to the `translations.dart` file (could be easily automated by writing a command line utility that extracts all strings with the posfix `.i18n`).

### Model Classes

In general model classes should be defined as immutable, and kept as simple as possible.

For model classes that need to support equality comparison (`==`) and/or `copyWith`, the [`freezed`](https://pub.dev/packages/freezed) library can be used to reduce boilerplate. (The `freezed` library also provides access to some useful features that Dart doesn't currently support, such as union types (e.g. Kotlin & Swift) and lazily initialized variables.)

### Bloc

To keep our `bloc` classes consistent and reduce boilerplate, the [`bloc`](https://pub.dev/packages/bloc) library can be be used.
