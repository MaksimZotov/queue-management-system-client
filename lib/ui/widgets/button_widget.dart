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
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: ElevatedButton(
          onPressed: widget.onClick,
          style: ElevatedButton.styleFrom(
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            minimumSize: const Size.fromHeight(64),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            tapTargetSize: MaterialTapTargetSize.padded,
          ),
          child: Text(widget.text),
        ),
      ),
    );
  }
}