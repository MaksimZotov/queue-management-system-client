import 'package:flutter/material.dart';
import 'package:queue_management_system_client/domain/models/location/location_model.dart';

import '../../domain/models/queue/queue_model.dart';
import '../../domain/models/rules/rules_model.dart';

class RulesItemWidget extends StatefulWidget {
  final ValueChanged<RulesModel> onDelete;
  final RulesModel rules;

  const RulesItemWidget({
    Key? key,
    required this.onDelete,
    required this.rules,
  }) : super(key: key);

  @override
  State createState() => _RulesItemState();
}

class _RulesItemState extends State<RulesItemWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 16),
        child: ListTile(
        leading: const SizedBox(
            height: double.infinity,
            child: Icon(Icons.man, color: Colors.teal, size: 50)
        ),
        title: Text(
          widget.rules.email,
          maxLines: 1,
          style: TextStyle(fontSize: 24),
        ),
        trailing: SizedBox(
          height: double.infinity,
          child: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red, size: 30),
            onPressed: () => widget.onDelete(widget.rules),
          ),
        ),
      ),
      ),
    );
  }
}