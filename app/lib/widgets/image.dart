import 'package:flutter/material.dart';
import 'package:flywind/flywind.dart';

import 'spinner.dart';

class FlyImage extends FlyBox {
  FlyImage({
    super.key,
    super.child,
    super.children,
    super.alignment,
    super.padding,
    super.margin,
    super.decoration,
    super.foregroundDecoration,
    super.width,
    super.height,
    super.constraints,
    super.transform,
    super.transformAlignment,
    super.clipBehavior,
    super.flyStyle,
    this.imageUrl,
    this.assetPath,
    this.onLoadingStateChange,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.loadingIcon = Icons.image,
    this.loadingDurationMs = 1000,
  });

  final String? imageUrl;
  final String? assetPath;
  final ValueChanged<bool>? onLoadingStateChange;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final IconData loadingIcon;
  final int loadingDurationMs;

  bool get hasDefaultStyle => false;

  @override
  Widget build(BuildContext context) {
    final imageProvider = _getImageProvider();
    if (imageProvider == null) {
      return child ?? const SizedBox.shrink();
    }

    return FlyBox(
      key: key,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: Image(
          image: imageProvider,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            print('FlyImage error: $error');
            return child ?? const SizedBox.shrink();
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              onLoadingStateChange?.call(false);
              return child;
            }
            onLoadingStateChange?.call(true);
            return FlySpinner(
              FlyIcon(loadingIcon),
              durationMs: loadingDurationMs,
            ).color('gray500');
          },
        ),
      ),
      children: children,
      alignment: alignment,
      padding: padding,
      margin: margin,
      decoration: decoration,
      foregroundDecoration: foregroundDecoration,
      constraints: constraints,
      transform: transform,
      transformAlignment: transformAlignment,
      clipBehavior: clipBehavior,
      flyStyle: flyStyle,
    );
  }

  @override
  FlyImage Function(FlyStyle newStyle) get copyWith => (newStyle) {
    return FlyImage(
      key: key,
      child: child,
      children: children,
      alignment: alignment,
      padding: padding,
      margin: margin,
      decoration: decoration,
      foregroundDecoration: foregroundDecoration,
      width: width,
      height: height,
      constraints: constraints,
      transform: transform,
      transformAlignment: transformAlignment,
      clipBehavior: clipBehavior,
      flyStyle: newStyle,
      imageUrl: imageUrl,
      assetPath: assetPath,
      onLoadingStateChange: onLoadingStateChange,
      fit: fit,
      borderRadius: borderRadius,
      loadingIcon: loadingIcon,
      loadingDurationMs: loadingDurationMs,
    );
  };

  ImageProvider? _getImageProvider() {
    if (imageUrl != null) {
      return NetworkImage(imageUrl!);
    } else if (assetPath != null) {
      return AssetImage(assetPath!);
    }
    return null;
  }
}
