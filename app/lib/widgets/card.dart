import 'package:flutter/material.dart';
import 'package:flywind/flywind.dart';

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
      bg: 'white',
      border: variant == CardVariant.outlined ? 1 : 0,
      borderColor: 'gray200',
      rounded: 'lg',
      p: _getPadding(),
      m: 's4',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (variant == CardVariant.unstyled) {
      return FlyBox(children: children ?? []).col().items('start').gap('s2');
    }

    return FlyBox(children: children ?? [])
        .bg(variant == CardVariant.filled ? 'gray100' : 'white')
        .border(variant == CardVariant.outlined ? 1 : 0)
        .borderColor('gray200')
        .rounded('lg')
        .p(_getPadding())
        .m('s4')
        .col()
        .items('start')
        .gap('s2');
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
