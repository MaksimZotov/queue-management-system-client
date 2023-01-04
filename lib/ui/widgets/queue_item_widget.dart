import 'package:flutter/material.dart';
import 'package:queue_management_system_client/domain/models/location/location_model.dart';

import '../../domain/models/queue/queue_model.dart';

class QueueItemWidget extends StatefulWidget {
  final ValueChanged<QueueModel> onClick;
  final ValueChanged<QueueModel> onDelete;
  final QueueModel queue;

  const QueueItemWidget({
    Key? key,
    required this.onClick,
    required this.onDelete,
    required this.queue,
  }) : super(key: key);

  @override
  State createState() => _QueueItemState();
}

class _QueueItemState extends State<QueueItemWidget> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: ListTile(
          onTap: () => widget.onClick(widget.queue),
          title: Text(widget.queue.name),
          subtitle: Text(widget.queue.description),
          trailing: widget.queue.hasRules == true ? IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => widget.onDelete(widget.queue),
          ) : null,
        ),
      ),
    );
  }
}