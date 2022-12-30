import 'package:flutter/material.dart';
import 'package:queue_management_system_client/domain/models/queue/client_in_queue.dart';

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
        child: ListTile(
          title: Text('${widget.client.firstName} ${widget.client.lastName}'),
          subtitle: Text(widget.client.email),
          leading:  widget.client.orderNumber == 1 ? IconButton(
            icon: const Icon(Icons.done_outline_rounded),
            onPressed: () => widget.onServe(widget.client),
          ) : null,
          trailing: IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => widget.onNotify(widget.client),
          ),
        ),
      ),
    );
  }
}