import 'package:flutter/material.dart';
import 'package:queue_management_system_client/domain/models/location/location_model.dart';

import '../../domain/models/queue/queue_model.dart';
import '../../domain/models/rights/rights_model.dart';

class RightsItemWidget extends StatefulWidget {
  final ValueChanged<RightsModel> onDelete;
  final RightsModel rights;

  const RightsItemWidget({
    Key? key,
    required this.onDelete,
    required this.rights,
  }) : super(key: key);

  @override
  State createState() => _RightsItemState();
}

class _RightsItemState extends State<RightsItemWidget> {
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
          widget.rights.email,
          maxLines: 1,
          style: TextStyle(fontSize: 24),
        ),
        trailing: SizedBox(
          height: double.infinity,
          child: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red, size: 30),
            onPressed: () => widget.onDelete(widget.rights),
          ),
        ),
      ),
      ),
    );
  }
}