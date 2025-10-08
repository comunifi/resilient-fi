import 'package:flutter/material.dart';
import 'package:flywind/flywind.dart';

import 'spinner.dart';

enum CardVariant { outlined, filled, unstyled }

enum CardSize { small, medium, large }

class CardContext {
  final CardVariant variant;
  final CardSize size;

  const CardContext({required this.variant, required this.size});
}

class _CardInheritedWidget extends InheritedWidget {
  final CardContext cardContext;

  const _CardInheritedWidget({required this.cardContext, required super.child});

  @override
  bool updateShouldNotify(_CardInheritedWidget oldWidget) {
    return cardContext != oldWidget.cardContext;
  }

  static CardContext? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_CardInheritedWidget>()
        ?.cardContext;
  }
}

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
      m: incomingStyle.m ?? 's4',
    );
  }

  @override
  Widget build(BuildContext context) {
    final mergedStyle = getDefaultStyle(flyStyle);
    final cardContext = CardContext(variant: variant, size: size);

    return _CardInheritedWidget(
      cardContext: cardContext,
      child: FlyBox(
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
      ),
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
    final cardContext = _CardInheritedWidget.of(context);
    if (cardContext == null) {
      return const SizedBox.shrink();
    }

    final borderRadius = _getImageBorderRadius(cardContext.variant);

    Widget imageWidget = FlyImage(
      key: key,
      imageUrl: imageUrl,
      assetPath: assetPath,
      onLoadingStateChange: onLoadingStateChange,
      fit: fit,
      width: width,
      height: height,
      alignment: alignment,
      flyStyle: flyStyle.copyWith(
        rounded: borderRadius == BorderRadius.zero ? null : 'lg',
      ),
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

  BorderRadius _getImageBorderRadius(CardVariant variant) {
    if (variant == CardVariant.unstyled) {
      return BorderRadius.zero;
    }
    // Top corners rounded, bottom corners square for card images
    return const BorderRadius.only(
      topLeft: Radius.circular(8),
      topRight: Radius.circular(8),
    );
  }
}

class FlyCardHeader extends FlyBox {
  FlyCardHeader({
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
    this.title,
    this.subtitle,
    this.leadingWidget,
    this.trailing,
  });

  final String? title;
  final String? subtitle;
  final Widget? leadingWidget;
  final Widget? trailing;

  bool get hasDefaultStyle => false;

  @override
  Widget build(BuildContext context) {
    final cardContext = _CardInheritedWidget.of(context);
    if (cardContext == null) {
      return const SizedBox.shrink();
    }

    Widget content = child ?? const SizedBox.shrink();

    if (content is SizedBox && content.child == null) {
      content = _buildHeaderContent(cardContext);
    }

    return FlyBox(
      key: key,
      child: content,
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
      flyStyle: flyStyle,
    );
  }

  Widget _buildHeaderContent(CardContext cardContext) {
    final textSize = _getTextSize(cardContext.size);
    final titleSize = _getTitleSize(cardContext.size);

    return FlyBox(
      children: [
        if (leadingWidget != null) leadingWidget!,
        FlyBox(
          children: [
            if (title != null)
              FlyText(
                title!,
              ).text(titleSize).weight('semibold').color('gray800'),
            if (subtitle != null)
              FlyText(subtitle!).text(textSize).color('gray600'),
          ],
        ).col().items('start').gap('s1').flex(1),
        if (trailing != null) trailing!,
      ],
    ).row().items('center').gap('s3');
  }

  @override
  FlyCardHeader Function(FlyStyle newStyle) get copyWith => (newStyle) {
    return FlyCardHeader(
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
      title: title,
      subtitle: subtitle,
      leadingWidget: leadingWidget,
      trailing: trailing,
    );
  };

  String _getTextSize(CardSize size) {
    switch (size) {
      case CardSize.small:
        return 'sm';
      case CardSize.medium:
        return 'base';
      case CardSize.large:
        return 'lg';
    }
  }

  String _getTitleSize(CardSize size) {
    switch (size) {
      case CardSize.small:
        return 'base';
      case CardSize.medium:
        return 'lg';
      case CardSize.large:
        return 'xl';
    }
  }
}

class FlyCardContent extends FlyBox {
  FlyCardContent({
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
  });

  bool get hasDefaultStyle => false;

  @override
  Widget build(BuildContext context) {
    final cardContext = _CardInheritedWidget.of(context);
    if (cardContext == null) {
      return const SizedBox.shrink();
    }

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
      flyStyle: flyStyle,
    );
  }

  @override
  FlyCardContent Function(FlyStyle newStyle) get copyWith => (newStyle) {
    return FlyCardContent(
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
    );
  };
}

class FlyCardFooter extends FlyBox {
  FlyCardFooter({
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
  });

  bool get hasDefaultStyle => false;

  @override
  Widget build(BuildContext context) {
    final cardContext = _CardInheritedWidget.of(context);
    if (cardContext == null) {
      return const SizedBox.shrink();
    }

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
      flyStyle: flyStyle,
    );
  }

  @override
  FlyCardFooter Function(FlyStyle newStyle) get copyWith => (newStyle) {
    return FlyCardFooter(
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
    );
  };
}
