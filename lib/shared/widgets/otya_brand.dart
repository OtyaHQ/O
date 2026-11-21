import 'package:flutter/material.dart';

/// Loads the exact owner-approved Otya artwork from the public Cloudflare asset origin.
class OtyaBrandLogo extends StatelessWidget {
  const OtyaBrandLogo({super.key, this.width = 320});

  final double width;

  static const _url =
      'https://assets.otya.site/brand/otya/v4/otya-master-lockup.webp';

  @override
  Widget build(BuildContext context) {
    return Image.network(
      _url,
      width: width,
      height: width * (208 / 560),
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      semanticLabel: 'Otya — One ecosystem. Endless possibilities.',
      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
    );
  }
}

/// The exact orbital symbol crop from the approved Otya artwork.
class OtyaBrandMark extends StatelessWidget {
  const OtyaBrandMark({super.key, this.size = 36});

  final double size;

  static const _url =
      'https://assets.otya.site/brand/otya/v4/otya-orbital-mark.webp';

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * .18),
      child: SizedBox(
        width: size,
        height: size,
        child: ColoredBox(
          color: Colors.white,
          child: Image.network(
            _url,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            semanticLabel: 'Otya orbital mark',
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
