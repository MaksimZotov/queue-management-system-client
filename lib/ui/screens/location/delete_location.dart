import 'package:flutter/material.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';

class DeleteLocationParams {
  final int id;

  DeleteLocationParams({
    required this.id,
  });
}

class DeleteLocationResult {
  final int id;

  DeleteLocationResult({
    required this.id,
  });
}

class DeleteLocationWidget extends StatefulWidget {
  final DeleteLocationParams params;

  const DeleteLocationWidget({super.key, required this.params});

  @override
  State<DeleteLocationWidget> createState() => _DeleteLocationState();
}

class _DeleteLocationState extends State<DeleteLocationWidget> {
  final String title = 'Удалить локацию?';
  final String yesText = 'Удалить';
  final String cancelText = 'Отмена';

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(title),
      contentPadding: const EdgeInsets.all(20),
      children: [
        ButtonWidget(
            text: yesText,
            onClick: () => Navigator.of(context).pop(
                DeleteLocationResult(
                    id: widget.params.id
                )
            )
        ),
        ButtonWidget(
            text: cancelText,
            onClick: Navigator.of(context).pop
        )
      ],
    );
  }
}