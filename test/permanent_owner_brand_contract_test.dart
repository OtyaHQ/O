import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('O uses the permanent Otya mark and canonical owner-app branding', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final manifest = File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    final app = File('lib/app/next_app.dart').readAsStringSync();
    final home = File('lib/features/home/home_screen.dart').readAsStringSync();
    final mark = File('lib/shared/widgets/otya_brand_mark.dart').readAsStringSync();
    final workspace = File('lib/features/company/company_workspace_screen.dart').readAsStringSync();

    expect(pubspec, contains('assets/branding/'));
    expect(File('assets/branding/otya_app_icon.webp').existsSync(), isTrue);
    expect(mark, contains("'assets/branding/otya_app_icon.webp'"));
    expect(home, contains('OtyaBrandMark(size: 30)'));
    expect(home, isNot(contains('OTYA NEXT')));
    expect(manifest, contains('android:label="O"'));
    expect(app, contains("title: 'O'"));
    expect(app, contains('Color(0xFF126BFF)'));
    expect(workspace, contains("name: 'Opoint'"));
    expect(workspace, contains("name: 'Omy Play'"));
    expect(workspace, contains("name: 'O'"));
  });

  test('the owner app keeps its existing Android install identity', () {
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();
    expect(gradle, contains('applicationId = "com.petersmartlink.next"'));
  });
}
