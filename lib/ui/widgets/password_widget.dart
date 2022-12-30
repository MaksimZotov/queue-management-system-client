import 'package:flutter/material.dart';

class PasswordWidget extends StatefulWidget {
  const PasswordWidget({
    Key? key,
    this.onTextChanged,
    required this.label,
    required this.text
  }) : super(key: key);

  final ValueChanged<String>? onTextChanged;
  final String label;
  final String text;

  @override
  State createState() => _PasswordState();
}

class _PasswordState extends State<PasswordWidget> {
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
        obscureText: true,
        enableSuggestions: false,
        autocorrect: false,
        onChanged: widget.onTextChanged,
      ),
    );
  }
}