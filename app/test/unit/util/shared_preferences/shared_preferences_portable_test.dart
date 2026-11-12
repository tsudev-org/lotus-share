import 'package:localsend_app/util/shared_preferences/shared_preferences_portable.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

void main() {
  test('should put settings.json next to the executable', () {
    expect(
      buildSettingsPath(
        executablePath: path.join('opt', 'lotus-share', 'lotus_share'),
        fallbackDirectory: () => fail('The fallback should not be used when the executable is known'),
      ),
      path.join('opt', 'lotus-share', 'settings.json'),
    );
  });

  test('should fall back to the working directory when the executable is unknown', () {
    expect(
      buildSettingsPath(
        executablePath: null,
        fallbackDirectory: () => path.join('home', 'user'),
      ),
      path.join('home', 'user', 'settings.json'),
    );
  });
}
