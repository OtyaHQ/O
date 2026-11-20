import 'package:flutter/material.dart';

/// The same owner-approved Otya mark used by the public website and Omy Play.
/// Keep this as an image asset; do not redraw or substitute the mark.
class OtyaBrandMark extends StatelessWidget {
  const OtyaBrandMark({super.key, this.size = 36});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: 'Otya brand mark',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * .24),
        child: Image.asset(
          'assets/branding/otya_app_icon.webp',
          width: size,
          height: size,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}
