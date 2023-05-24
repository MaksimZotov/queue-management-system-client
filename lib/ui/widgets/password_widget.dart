import 'package:flutter/material.dart';
import 'package:queue_management_system_client/ui/widgets/text_field_widget.dart';

import '../../dimens.dart';

class PasswordWidget extends TextFieldWidget {

  const PasswordWidget({
    super.key,
    super.onTextChanged,
    required super.label,
    required super.text,
    super.error
  });

  @override
  int? get maxLines => 1;

  @override
  State createState() => _PasswordState();
}

class _PasswordState extends TextFieldState<PasswordWidget> {

    @override
    TextFormField getTextFormField() => TextFormField(
      initialValue: widget.text,
      decoration: const InputDecoration(
        border: InputBorder.none,
      ),
      onChanged: widget.onTextChanged,
      style: const TextStyle(fontSize: Dimens.textFormFieldFontSize),
      obscureText: true,
      enableSuggestions: false,
      autocorrect: false,
    );
}