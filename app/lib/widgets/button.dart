import 'package:flutter/material.dart';
import 'package:flywind/flywind.dart';

import 'spinner.dart';

enum ButtonVariant { primary, secondary, success, danger, unstyled }

enum ButtonSize { small, medium, large }

class FlyButton extends FlyGestureDetector {
  FlyButton(
    this.buttonText,
    this.onPressed, {
    super.key,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
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
    super.onTapDown,
    super.onTapUp,
    super.onTapCancel,
    super.onTap,
    super.onDoubleTap,
    super.onLongPress,
    super.onLongPressStart,
    super.onLongPressEnd,
    super.onLongPressMoveUpdate,
    super.onLongPressUp,
    super.onLongPressCancel,
  });

  final String buttonText;
  final VoidCallback onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool isLoading;

  @override
  bool get hasDefaultStyle => true;

  @override
  FlyStyle getDefaultStyle(FlyStyle incomingStyle) {
    String bgColor = 'blue500';
    String textColor = 'white';

    switch (variant) {
      case ButtonVariant.primary:
        bgColor = 'blue500';
        textColor = 'white';
        break;
      case ButtonVariant.secondary:
        bgColor = 'gray500';
        textColor = 'white';
        break;
      case ButtonVariant.success:
        bgColor = 'green500';
        textColor = 'white';
        break;
      case ButtonVariant.danger:
        bgColor = 'red500';
        textColor = 'white';
        break;
      case ButtonVariant.unstyled:
        textColor = 'black';
        break;
    }

    String padding = 's3';
    switch (size) {
      case ButtonSize.small:
        padding = 's1';
        break;
      case ButtonSize.medium:
        padding = 's2';
        break;
      case ButtonSize.large:
        padding = 's3';
        break;
    }

    return incomingStyle.copyWith(
      color: incomingStyle.color ?? textColor,
      p: incomingStyle.p ?? padding,
      rounded: incomingStyle.rounded ?? 'md',
      bg: variant == ButtonVariant.unstyled
          ? null
          : (incomingStyle.bg ?? bgColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mergedStyle = getDefaultStyle(flyStyle);

    return FlyGestureDetector(
      key: key,
      onTap: isLoading ? null : onPressed,
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
      child: isLoading
          ? IntrinsicWidth(
              child: FlyBox(
                children: [
                  FlySpinner(FlyIcon(Icons.refresh), durationMs: 1000),
                  FlyText('Loading...')
                      .color(mergedStyle.color ?? 'white')
                      .text('sm')
                      .weight('medium'),
                ],
              ).row().items('center').gap('s2'),
            )
          : FlyText(buttonText)
                .color(mergedStyle.color ?? 'white')
                .text('sm')
                .weight('medium')
                .p(mergedStyle.p ?? 's3'),
    );
  }

  @override
  FlyButton Function(FlyStyle newStyle) get copyWith => (newStyle) {
    return FlyButton(
      buttonText,
      onPressed,
      key: key,
      variant: variant,
      size: size,
      isLoading: isLoading,
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
      onTapDown: onTapDown,
      onTapUp: onTapUp,
      onTapCancel: onTapCancel,
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      onLongPressStart: onLongPressStart,
      onLongPressEnd: onLongPressEnd,
      onLongPressMoveUpdate: onLongPressMoveUpdate,
      onLongPressUp: onLongPressUp,
      onLongPressCancel: onLongPressCancel,
    );
  };
}
