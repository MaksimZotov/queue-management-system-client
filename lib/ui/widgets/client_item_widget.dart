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
        child: ListTile(
          title: Text('${widget.client.firstName} ${widget.client.lastName}'),
          subtitle: Text(widget.client.email),
          leading: IconButton(
            icon: const Icon(Icons.done_outline_rounded),
            onPressed: () => widget.onServe(widget.client),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => widget.onNotify(widget.client),
          ),
        ),
      ),
    );
  }
}