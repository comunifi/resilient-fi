import 'package:flutter/material.dart';
import 'package:flywind/flywind.dart';

import 'spinner.dart';

enum CardVariant { outlined, filled, unstyled }

enum CardSize { small, medium, large }

class FlyCard extends FlyBox {
  FlyCard({
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
    required this.variant,
    required this.size,
  });

  final CardVariant variant;
  final CardSize size;

  bool get hasDefaultStyle => true;

  @override
  FlyStyle getDefaultStyle(FlyStyle incomingStyle) {
    return incomingStyle.copyWith(
      bg: variant == CardVariant.filled ? 'gray100' : 'white',
      border: variant == CardVariant.outlined ? 1 : 0,
      borderColor: 'gray200',
      rounded: 'lg',
      p: incomingStyle.p ?? _getPadding(),
      m: incomingStyle.m ?? '0',
    );
  }

  @override
  Widget build(BuildContext context) {
    final mergedStyle = getDefaultStyle(flyStyle);

    return FlyBox(
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
      flyStyle: mergedStyle,
    );
  }

  @override
  FlyCard Function(FlyStyle newStyle) get copyWith => (newStyle) {
    return FlyCard(
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
      variant: variant,
      size: size,
    );
  };

  String _getPadding() {
    switch (size) {
      case CardSize.small:
        return 's4';
      case CardSize.medium:
        return 's6';
      case CardSize.large:
        return 's8';
    }
  }
}

class FlyCardImage extends FlyBox {
  FlyCardImage({
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
    this.aspectRatio,
    this.fit = BoxFit.cover,
    this.overlay,
  });

  final String? imageUrl;
  final String? assetPath;
  final ValueChanged<bool>? onLoadingStateChange;
  final double? aspectRatio;
  final BoxFit fit;
  final Widget? overlay;

  bool get hasDefaultStyle => false;

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = FlyImage(
      key: key,
      imageUrl: imageUrl,
      assetPath: assetPath,
      onLoadingStateChange: onLoadingStateChange,
      fit: fit,
      width: width,
      height: height,
      alignment: alignment,
      flyStyle: flyStyle.copyWith(rounded: 'lg'),
      loadingWidget: FlySpinner(
        FlyIcon(Icons.image),
        durationMs: 1000,
      ).color('gray500'),
      errorWidget: child ?? const SizedBox.shrink(),
    );

    // Add overlay if provided
    if (overlay != null) {
      imageWidget = Stack(children: [imageWidget, overlay!]);
    }

    return imageWidget;
  }

  @override
  FlyCardImage Function(FlyStyle newStyle) get copyWith => (newStyle) {
    return FlyCardImage(
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
      aspectRatio: aspectRatio,
      fit: fit,
      overlay: overlay,
    );
  };
}
