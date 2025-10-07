import 'package:flutter/material.dart';
import 'package:flywind/flywind.dart';

class FlyCard extends StatelessWidget {
  const FlyCard({
    super.key,
    required this.title,
    required this.description,
    this.buttonText,
    this.onButtonPressed,
  });

  final String title;
  final String description;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  @override
  Widget build(BuildContext context) {
    return FlyContainer(
          child: FlyLayout([
            FlyText(title).text('xl').weight('bold').color('gray900').mb('s2'),
            FlyText(
              description,
            ).text('base').color('gray600').leading('relaxed').mb('s4'),
            if (buttonText != null)
              FlyContainer(
                child: FlyText(
                  buttonText!,
                ).color('white').text('sm').weight('medium').p('s2'),
              ).bg('blue500').rounded('sm').p('s3'),
          ]).col().items('start'),
        )
        .bg('white')
        .border(1)
        .borderColor('gray200')
        .rounded('lg')
        .p('s6')
        .m('s4');
  }
}
