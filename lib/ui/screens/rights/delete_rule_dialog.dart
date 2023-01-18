import 'package:flutter/material.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';

class DeleteRuleConfig {
  final String email;

  DeleteRuleConfig({
    required this.email,
  });
}

class DeleteRuleResult {
  final String email;

  DeleteRuleResult({
    required this.email,
  });
}

class DeleteRuleWidget extends StatefulWidget {
  final DeleteRuleConfig config;

  const DeleteRuleWidget({super.key, required this.config});

  @override
  State<DeleteRuleWidget> createState() => _DeleteRuleState();
}

class _DeleteRuleState extends State<DeleteRuleWidget> {
  final String title = 'Отозвать права?';
  final String yesText = 'Отозвать';
  final String cancelText = 'Отмена';

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(title),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
              Radius.circular(16.0)
          )
      ),
      children: [
        ButtonWidget(
            text: yesText,
            onClick: () => Navigator.of(context).pop(
                DeleteRuleResult(
                    email: widget.config.email
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