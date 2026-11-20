import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('owner-device enrollment requires email OTP before linked Telegram confirmation', () {
    final auth = File('lib/core/auth/owner_auth_service.dart').readAsStringSync();
    final gate = File('lib/features/auth/owner_gate.dart').readAsStringSync();

    expect(auth, contains("'/auth/admin/start'"));
    expect(auth, contains("'/auth/admin/verify-otp'"));
    expect(auth, contains("'/auth/admin/mobile-grant'"));
    expect(auth, contains('Future<String> verifyOwnerOtp(String otp)'));
    expect(auth, contains("final challenge = data?['telegram_challenge']"));
    expect(auth, contains('startTelegramOwnerVerification(String challenge)'));
    expect(auth, contains("scheme: 'tg'"));
    expect(auth, contains("'start': 'owner_$value'"));

    expect(gate, contains('_verifyOtpAndOpenTelegram'));
    expect(gate, contains('await _auth.verifyOwnerOtp(code)'));
    expect(gate, contains('await _auth.startTelegramOwnerVerification(challenge)'));
    expect(gate, contains('_OwnerStage.ownerTelegram'));
    expect(gate, contains('_completeTelegram'));
    expect(gate, isNot(contains("mode: 'login'")));
    expect(gate, isNot(contains('authorization_url')));
    expect(gate, isNot(contains('TELEGRAM_LOGIN_CLIENT_SECRET')));
  });

  test('owner app endpoints use canonical Otya origins by default', () {
    final auth = File('lib/core/auth/owner_auth_service.dart').readAsStringSync();
    final api = File('lib/core/network/next_owner_api.dart').readAsStringSync();
    final endpoints = File('lib/core/config/otya_endpoints.dart').readAsStringSync();

    expect(auth, contains('baseUrl: OtyaEndpoints.apiBaseUrl'));
    expect(api, contains('baseUrl: OtyaEndpoints.apiBaseUrl'));
    expect(endpoints, contains("defaultValue: 'https://api.otya.site'"));
    expect(endpoints, contains("defaultValue: 'https://otya.site'"));
    expect(endpoints, isNot(contains('petersmartlink.com')));
  });
}
