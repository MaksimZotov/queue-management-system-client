import 'package:flutter/material.dart';

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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
        ),
        onPressed: widget.onClick,
        child: Text(
            widget.text
        ),
      ),
    );
  }
}