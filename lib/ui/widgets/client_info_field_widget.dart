import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../dimens.dart';

class ClientInfoFieldWidget extends StatefulWidget {
  final String fieldName;
  final String fieldValue;

  const ClientInfoFieldWidget({
    Key? key,
    required this.fieldName,
    required this.fieldValue,
  }) : super(key: key);

  @override
  State createState() => ClientInfoFieldState();
}

class ClientInfoFieldState extends State<ClientInfoFieldWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (
        defaultTargetPlatform != TargetPlatform.iOS &&
        defaultTargetPlatform != TargetPlatform.android
      ) ? Dimens.fieldWidthForWeb : null,
      child: Card(
        elevation: 4,
        color: Colors.blueGrey,
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(5),
                child: Text(
                  widget.fieldName,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Text(
                    widget.fieldValue,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
