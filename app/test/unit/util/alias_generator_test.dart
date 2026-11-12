import 'package:flutter_test/flutter_test.dart';
import 'package:localsend_app/gen/strings.g.dart';
import 'package:localsend_app/util/alias_generator.dart';

void main() {
  group('isGeneratedAliasOfOtherLocale', () {
    tearDown(() async => LocaleSettings.setLocale(AppLocale.en));

    test('English random name is replaced while running in Vietnamese', () async {
      await LocaleSettings.setLocale(AppLocale.vi);
      expect(isGeneratedAliasOfOtherLocale('Strategic Tomato'), isTrue);
    });

    test('Vietnamese random name and typed names are kept', () async {
      await LocaleSettings.setLocale(AppLocale.vi);
      expect(isGeneratedAliasOfOtherLocale(generateRandomAlias()), isFalse);
      expect(isGeneratedAliasOfOtherLocale('Laptop của Tú'), isFalse);
      expect(isGeneratedAliasOfOtherLocale('Strategic Tomato 2'), isFalse);
    });

    test('English names are kept when the app runs in English', () async {
      await LocaleSettings.setLocale(AppLocale.en);
      expect(isGeneratedAliasOfOtherLocale('Strategic Tomato'), isFalse);
    });
  });
}
