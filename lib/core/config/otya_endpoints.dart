/// Replaceable public endpoint configuration for Otya Next.
///
/// Otya product identity, owner identity, service IDs and device IDs are
/// independent of hostnames. Build/release configuration can change these
/// origins without changing the app's identity or backend data contracts.
abstract final class OtyaEndpoints {
  static const String apiBaseUrl = String.fromEnvironment(
    'OTYA_BASE_URL',
    defaultValue: 'https://api.otya.site',
  );

  static const String publicSiteUrl = String.fromEnvironment(
    'OTYA_PUBLIC_URL',
    defaultValue: 'https://otya.site',
  );

  static const String spaceUrl = String.fromEnvironment(
    'OTYA_SPACE_URL',
    defaultValue: 'https://space.otya.site',
  );

  static const String docsUrl = String.fromEnvironment(
    'OTYA_DOCS_URL',
    defaultValue: 'https://docs.otya.site',
  );

  static const String assetsUrl = String.fromEnvironment(
    'OTYA_ASSETS_URL',
    defaultValue: 'https://assets.otya.site',
  );

  static const String additionalTrustedOrigins = String.fromEnvironment(
    'OTYA_TRUSTED_ORIGINS',
    defaultValue: '',
  );

  /// Exact HTTPS origins that the app may use for Otya cross-surface handoffs.
  /// Additional domains are opt-in at build time; arbitrary runtime URLs are
  /// never accepted as trusted infrastructure endpoints.
  static List<String> get allowedOrigins {
    final values = <String>[
      publicSiteUrl,
      apiBaseUrl,
      spaceUrl,
      docsUrl,
      assetsUrl,
      ...additionalTrustedOrigins.split(',').map((value) => value.trim()),
    ];
    final origins = <String>{};
    for (final value in values) {
      final uri = Uri.tryParse(value);
      if (uri != null &&
          uri.scheme == 'https' &&
          uri.userInfo.isEmpty &&
          uri.host.isNotEmpty) {
        origins.add(uri.origin);
      }
    }
    return origins.toList(growable: false);
  }
}
