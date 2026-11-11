/// Shared, replaceable public endpoint configuration for Next.
///
/// Otya product identity is independent of hostnames. Change OTYA_BASE_URL at
/// build/release configuration time when the public API address changes; do not
/// store a domain as an owner, account, device, or service identifier.
abstract final class OtyaEndpoints {
  static const String apiBaseUrl = String.fromEnvironment(
    'OTYA_BASE_URL',
    defaultValue: 'https://api.otya.site',
  );
}
