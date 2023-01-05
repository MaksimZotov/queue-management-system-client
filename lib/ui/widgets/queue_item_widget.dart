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
    return Card(
      child: ListTile(
        leading: const SizedBox(
            height: double.infinity,
            child: Icon(Icons.people_alt_outlined, color: Colors.teal, size: 35)
        ),
        title: Text(
          widget.queue.name,
          maxLines: 1,
        ),
        subtitle: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 200),
          child: Text(
            widget.queue.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: widget.queue.hasRules == true
            ? SizedBox(
          height: double.infinity,
          child: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red, size: 25),
            onPressed: () => widget.onDelete(widget.queue),
          ),
        )
            : null,
        onTap: () => widget.onClick(widget.queue),
      ),
    );
  }
}