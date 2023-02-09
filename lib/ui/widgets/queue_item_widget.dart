import 'package:flutter/material.dart';

import '../../domain/models/queue/queue_model.dart';

class QueueItemWidget extends StatefulWidget {
  final ValueChanged<QueueModel> onTap;
  final ValueChanged<QueueModel> onDelete;
  final QueueModel queue;

  const QueueItemWidget({
    Key? key,
    required this.onTap,
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
            child: Icon(Icons.people_alt_outlined, color: Colors.teal)
        ),
        title: Text(
          widget.queue.name,
          maxLines: 1
        ),
        subtitle: widget.queue.description != null
            ? ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 200),
              child: Text(
                widget.queue.description!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              )
            )
            : null,
        trailing: widget.queue.hasRights == true
            ? SizedBox(
              height: double.infinity,
              child: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => widget.onDelete(widget.queue)
              ),
            )
            : null,
        onTap: () => widget.onTap(widget.queue)
      ),
    );
  }
}