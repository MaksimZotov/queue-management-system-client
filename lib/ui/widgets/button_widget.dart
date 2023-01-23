import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../dimens.dart';

class ButtonWidget extends StatefulWidget {
  const ButtonWidget({
    Key? key,
    this.onClick,
    required this.text,
  }) : super(key: key);

  final VoidCallback? onClick;
  final String text;

  @override
  State createState() => _ButtonState();
}

class _ButtonState extends State<ButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (
          defaultTargetPlatform != TargetPlatform.iOS &&
          defaultTargetPlatform != TargetPlatform.android
      ) ? Dimens.fieldWidthForWeb : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Dimens.contentMargin),
        child: ElevatedButton(
          onPressed: widget.onClick,
          style: ElevatedButton.styleFrom(
            textStyle: const TextStyle(
                fontSize: Dimens.buttonFontSize,
                fontWeight: FontWeight.bold
            ),
            minimumSize: const Size.fromHeight(Dimens.buttonMinimumHeight),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Dimens.fieldsBorderRadius),
            ),
            tapTargetSize: MaterialTapTargetSize.padded,
          ),
          child: Text(widget.text),
        ),
      ),
    );
  }
}