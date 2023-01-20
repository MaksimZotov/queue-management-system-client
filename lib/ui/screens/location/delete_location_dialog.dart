import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';

class DeleteLocationConfig {
  final int id;

  DeleteLocationConfig({
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
  final DeleteLocationConfig config;

  const DeleteLocationWidget({super.key, required this.config});

  @override
  State<DeleteLocationWidget> createState() => _DeleteLocationState();
}

class _DeleteLocationState extends State<DeleteLocationWidget> {

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(AppLocalizations.of(context)!.deleteLocationQuestion),
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
                DeleteLocationResult(
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