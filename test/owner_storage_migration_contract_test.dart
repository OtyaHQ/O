import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('O migrates private owner session keys without changing server device identity', () {
    final auth = File('lib/core/auth/owner_auth_service.dart').readAsStringSync();

    expect(auth, contains("static const _accessKey = 'o_otya_access_token'"));
    expect(auth, contains("static const _refreshKey = 'o_otya_refresh_token'"));
    expect(auth, contains("static const _ownerGrantKey = 'o_owner_grant'"));
    expect(auth, contains("static const _deviceIdKey = 'o_owner_device_id'"));
    expect(auth, contains("static const _legacyAccessKey = 'next_otya_access_token'"));
    expect(auth, contains("static const _legacyDeviceIdKey = 'next_owner_device_id'"));
    expect(auth, contains('_readMigratedValue(_deviceIdKey, _legacyDeviceIdKey)'));
    expect(auth, contains('await _storage.write(key: key, value: legacy)'));
    expect(auth, contains('await _storage.delete(key: legacyKey)'));
    expect(auth, contains("return 'o-$encoded'"));
    expect(auth, contains("defaultValue: 'https://otya.site'"));

    // The O API must use the same canonical host as OID account calls.
    final api = File('lib/core/network/o_owner_api.dart').readAsStringSync();
    expect(api, contains("defaultValue: 'https://otya.site'"));
  });
}
