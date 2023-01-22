import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../dimens.dart';

class TextFieldWidget extends StatefulWidget {
  final ValueChanged<String>? onTextChanged;
  final String label;
  final String text;
  final int? maxLines;
  final String? error;

  const TextFieldWidget({
    Key? key,
    this.onTextChanged,
    required this.label,
    required this.text,
    this.maxLines = 1,
    this.error
  }) : super(key: key);

  @override
  State createState() => _TextFieldState();
}

class _TextFieldState extends State<TextFieldWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (
          defaultTargetPlatform != TargetPlatform.iOS &&
          defaultTargetPlatform != TargetPlatform.android
      ) ? Dimens.fieldWidthForWeb : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                  widget.label
              ),
            ),
            const SizedBox(height: 5),
            Container(
              decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: widget.error != null ? Colors.red : Colors.grey),
                  borderRadius: BorderRadius.circular(12)
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  maxLines: widget.maxLines,
                  initialValue: widget.text,
                  decoration: const InputDecoration(
                      border: InputBorder.none
                  ),
                  onChanged: widget.onTextChanged,
                ),
              ),
            ),
          ] + (widget.error != null ? [
            const SizedBox(height: 5),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.error!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ] : []),
        ),
      ),
    );
  }
}