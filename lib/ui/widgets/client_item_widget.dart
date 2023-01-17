import 'package:flutter/material.dart';
import 'package:queue_management_system_client/domain/enums/client_in_queue_status.dart';
import 'package:queue_management_system_client/domain/models/queue/client_in_queue_model.dart';

class ClientItemWidget extends StatefulWidget {
  final ValueChanged<ClientInQueueModel> onNotify;
  final ValueChanged<ClientInQueueModel> onServe;
  final ClientInQueueModel client;

  const ClientItemWidget({
    Key? key,
    required this.onNotify,
    required this.onServe,
    required this.client,
  }) : super(key: key);

  @override
  State createState() => _ClientItemState();
}

class _ClientItemState extends State<ClientItemWidget> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        color: widget.client.status == ClientInQueueStatus.confirmed
            ? Colors.white
            : Colors.white54,
        child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: ListTile(
          title: Transform.translate(
            offset: Offset(16, 0),
            child: Text('${widget.client.firstName} ${widget.client.lastName}', style: TextStyle(fontSize: 18),),
          ),
          subtitle: Transform.translate(
            offset: Offset(16, 0),
            child: Text(
              (widget.client.email == null
                  ? ''
                  : '${widget.client.email} '
              ) + '(${widget.client.accessKey})',
              style: TextStyle(fontSize: 18),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.done_outline_rounded, size: 30),
            onPressed: () => widget.onServe(widget.client),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.notifications, size: 35),
            onPressed: () => widget.onNotify(widget.client),
          ),
        ),
        ),
      ),
    );
  }
}