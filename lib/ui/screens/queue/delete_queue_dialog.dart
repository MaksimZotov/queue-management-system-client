import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';

class DeleteQueueConfig {
  final int id;

  DeleteQueueConfig({
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
  final DeleteQueueConfig config;

  const DeleteQueueWidget({super.key, required this.config});

  @override
  State<DeleteQueueWidget> createState() => _DeleteQueueState();
}

class _DeleteQueueState extends State<DeleteQueueWidget> {

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(AppLocalizations.of(context)!.deleteQueueQuestion),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
              Radius.circular(16.0)
          )
      ),
      children: [
        ButtonWidget(
            text: AppLocalizations.of(context)!.delete,
            onClick: () => Navigator.of(context).pop(
                DeleteQueueResult(
                    id: widget.config.id
                )
            )
        ),
        ButtonWidget(
            text: AppLocalizations.of(context)!.cancel,
            onClick: Navigator.of(context).pop
        )
      ],
    );
  }
}