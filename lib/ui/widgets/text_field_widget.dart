import 'package:flutter/material.dart';

class TextFieldWidget extends StatefulWidget {
  const TextFieldWidget({
    Key? key,
    this.onTextChanged,
    required this.label,
    required this.text
  }) : super(key: key);

  final ValueChanged<String>? onTextChanged;
  final String label;
  final String text;

  @override
  State createState() => _TextFieldState();
}

class _TextFieldState extends State<TextFieldWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: TextFormField(
        initialValue: widget.text,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: widget.label,
        ),
        onChanged: widget.onTextChanged,
      ),
    );
  }
}