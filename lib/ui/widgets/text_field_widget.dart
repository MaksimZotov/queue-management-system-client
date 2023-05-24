import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../dimens.dart';

class TextFieldWidget extends StatefulWidget {
  final ValueChanged<String>? onTextChanged;
  final String label;
  final String text;
  final String? error;
  final int? maxLines;
  final TextInputType? keyboardType;

  const TextFieldWidget({
    Key? key,
    this.onTextChanged,
    required this.label,
    required this.text,
    this.error,
    this.maxLines = 1,
    this.keyboardType
  }) : super(key: key);

  @override
  State createState() => TextFieldState();
}

class TextFieldState<T extends TextFieldWidget> extends State<T> {

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (
          defaultTargetPlatform != TargetPlatform.iOS &&
          defaultTargetPlatform != TargetPlatform.android
      ) ? Dimens.fieldWidthForWeb : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Dimens.contentMargin),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                  widget.label,
                  style: const TextStyle(
                      fontSize: Dimens.labelFontSize
                  )
              ),
            ),
            const SizedBox(height: Dimens.fieldElementsMargin),
            Container(
              decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(
                      color: widget.error != null ? Colors.red : Colors.grey
                  ),
                  borderRadius: BorderRadius.circular(Dimens.fieldsBorderRadius)
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimens.textFormFieldsHorizontalPadding,
                    vertical: Dimens.textFormFieldsVerticalPadding
                ),
                child: getTextFormField()
              ),
            ),
          ] + (widget.error != null ? [
            const SizedBox(height: Dimens.fieldElementsMargin),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.error!,
                style: const TextStyle(
                    fontSize: Dimens.errorFontSize,
                    color: Colors.red
                ),
              ),
            ),
          ] : []),
        ),
      ),
    );
  }

  TextFormField getTextFormField() => TextFormField(
      initialValue: widget.text,
      keyboardType: widget.keyboardType,
      decoration: const InputDecoration(
          border: InputBorder.none
      ),
      onChanged: widget.onTextChanged,
      maxLines: widget.maxLines,
      style: const TextStyle(fontSize: Dimens.textFormFieldFontSize),
  );
}