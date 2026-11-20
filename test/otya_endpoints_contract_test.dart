import 'package:flutter_test/flutter_test.dart';
import 'package:next/core/config/otya_endpoints.dart';

void main() {
  test('Otya Next defaults to the canonical Otya public service addresses', () {
    expect(OtyaEndpoints.apiBaseUrl, 'https://api.otya.site');
    expect(OtyaEndpoints.publicSiteUrl, 'https://otya.site');
    expect(OtyaEndpoints.spaceUrl, 'https://space.otya.site');
    expect(OtyaEndpoints.docsUrl, 'https://docs.otya.site');
    expect(OtyaEndpoints.assetsUrl, 'https://assets.otya.site');
  });

  test('trusted service origins are HTTPS and exact host origins', () {
    final origins = OtyaEndpoints.allowedOrigins.toSet();

    expect(origins, containsAll([
      'https://api.otya.site',
      'https://otya.site',
      'https://space.otya.site',
      'https://docs.otya.site',
      'https://assets.otya.site',
    ]));

    for (final origin in origins) {
      final uri = Uri.parse(origin);
      expect(uri.scheme, 'https');
      expect(uri.userInfo, isEmpty);
      expect(uri.path, isEmpty);
      expect(uri.query, isEmpty);
      expect(uri.fragment, isEmpty);
    }

    expect(origins, isNot(contains('https://petersmartlink.com')));
    expect(origins, isNot(contains('https://otya.site.attacker.example')));
    expect(origins, isNot(contains('http://api.otya.site')));
  });
}
