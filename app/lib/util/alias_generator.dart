import 'dart:math';

import 'package:localsend_app/gen/strings.g.dart';

String generateRandomAlias() {
  final random = Random();
  final adj = t.aliasGenerator.adjectives;
  final fruits = t.aliasGenerator.fruits;

  // The combination of both is locale dependent too.
  return t.aliasGenerator.combination(
    adjective: adj[random.nextInt(adj.length)],
    fruit: fruits[random.nextInt(fruits.length)],
  );
}

/// lotus-share: whether [alias] is a random English name (e.g. "Strategic Tomato") while the app runs in
/// another language. Such names come from a first start before Vietnamese became the default, or from
/// settings that used to be shared with another app. Names the user typed never match, so they are kept.
bool isGeneratedAliasOfOtherLocale(String alias) {
  if (LocaleSettings.currentLocale == AppLocale.en) {
    return false;
  }
  return isGeneratedAlias(alias, AppLocale.en.buildSync());
}

/// Whether [alias] is exactly one combination of the random name lists of [translations].
bool isGeneratedAlias(String alias, Translations translations) {
  final generator = translations.aliasGenerator;
  for (final adjective in generator.adjectives) {
    for (final fruit in generator.fruits) {
      if (generator.combination(adjective: adjective, fruit: fruit) == alias) {
        return true;
      }
    }
  }
  return false;
}
