import 'package:flutter/material.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';

class DeleteQueueParams {
  final int id;

  DeleteQueueParams({
    required this.id,
  });
}

class DeleteQueueResult {
  final int id;

  DeleteQueueResult({
    required this.id,
  });
}

class DeleteQueueWidget extends StatefulWidget {
  final DeleteQueueParams params;

  const DeleteQueueWidget({super.key, required this.params});

  @override
  State<DeleteQueueWidget> createState() => _DeleteQueueState();
}

class _DeleteQueueState extends State<DeleteQueueWidget> {
  final String title = 'Удалить очередь?';
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
                DeleteQueueResult(
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