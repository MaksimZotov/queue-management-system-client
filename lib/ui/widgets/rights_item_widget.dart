import 'package:flutter/material.dart';

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
      child: ListTile(
        leading: const SizedBox(
            height: double.infinity,
            child: Icon(Icons.man, color: Colors.teal)
        ),
        title: Text(
          widget.rights.email,
          maxLines: 1
        ),
        trailing: SizedBox(
          height: double.infinity,
          child: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => widget.onDelete(widget.rights)
          ),
        ),
      ),
    );
  }
}