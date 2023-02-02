import 'package:flutter/material.dart';

import '../../domain/models/location/queue_type_model.dart';

class QueueTypeItemWidget extends StatefulWidget {
  final ValueChanged<QueueTypeModel>? onTap;
  final ValueChanged<QueueTypeModel>? onDelete;
  final QueueTypeModel queueType;

  const QueueTypeItemWidget({
    Key? key,
    this.onTap,
    this.onDelete,
    required this.queueType,
  }) : super(key: key);

  @override
  State createState() => _QueueTypeItemState();
}

class _QueueTypeItemState extends State<QueueTypeItemWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
        child: ListTile(
            title: Text(widget.queueType.name, maxLines: 1),
            subtitle: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 200),
              child: widget.queueType.description != null
                  ? Text(
                      widget.queueType.description!,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    )
                  : null,
            ),
            trailing: widget.onDelete != null
                ? SizedBox(
                    height: double.infinity,
                    child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => widget.onDelete?.call(widget.queueType)),
                  )
                : null,
          onTap: () => widget.onTap?.call(widget.queueType),
        )
    );
  }
}
