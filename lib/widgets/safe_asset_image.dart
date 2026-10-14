import 'package:flutter/material.dart';

class SafeAssetImage extends StatelessWidget {
  const SafeAssetImage(
    this.assetPath, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.fallbackIcon = Icons.image_outlined,
    this.borderRadius,
  });

  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final IconData fallbackIcon;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, _, _) => _fallback(),
    );

    if (borderRadius == null) return image;

    return ClipRRect(borderRadius: borderRadius!, child: image);
  }

  Widget _fallback() {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF111738),
        borderRadius: borderRadius,
      ),
      child: Icon(
        fallbackIcon,
        color: Colors.white.withValues(alpha: 0.45),
        size: (width != null && height != null)
            ? (width! < height! ? width! : height!) * 0.45
            : 24,
      ),
    );
  }
}
