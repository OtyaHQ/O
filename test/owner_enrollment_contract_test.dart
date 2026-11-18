import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Next owner enrollment is completed by email OTP with optional Telegram delivery', () {
    final auth = File('lib/core/auth/owner_auth_service.dart').readAsStringSync();
    final gate = File('lib/features/auth/owner_gate.dart').readAsStringSync();

    expect(auth, contains("'/auth/admin/start'"));
    expect(auth, contains("'/auth/admin/verify-otp'"));
    expect(auth, contains("'/auth/admin/mobile-grant'"));
    expect(auth, contains('Future<void> verifyOwnerOtp(String otp)'));
    expect(auth, isNot(contains('telegram_challenge')));
    expect(auth, isNot(contains('startTelegramOwnerVerification')));
    expect(auth, isNot(contains("scheme: 'tg'")));

    expect(gate, contains('_verifyOtpAndComplete'));
    expect(gate, contains('await _auth.completeOwnerVerification()'));
    expect(gate, contains('the same code may also arrive there as a convenience'));
    expect(gate, isNot(contains('_OwnerStage.ownerTelegram')));
    expect(gate, isNot(contains('_telegramChallenge')));
    expect(gate, isNot(contains('Confirm in Telegram')));
    expect(gate, isNot(contains('OtyaPlayerBot')));
  });
}
