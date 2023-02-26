import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:queue_management_system_client/domain/enums/client_in_queue_status.dart';
import 'package:queue_management_system_client/domain/models/queue/client_in_queue_model.dart';

class ClientItemWidget extends StatefulWidget {
  final ValueChanged<ClientInQueueModel> onNotify;
  final ValueChanged<ClientInQueueModel> onServe;
  final ValueChanged<ClientInQueueModel> onDelete;
  final ClientInQueueModel client;

  const ClientItemWidget({
    Key? key,
    required this.onNotify,
    required this.onServe,
    required this.onDelete,
    required this.client,
  }) : super(key: key);

  @override
  State createState() => _ClientItemState();
}

class _ClientItemState extends State<ClientItemWidget> {
  @override
  Widget build(BuildContext context) {
    List<Padding> services = [];
    for (String service in widget.client.services) {
      services.add(
          Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(64, 0, 0, 0),
              child: Card(
                color: Colors.teal,
                child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Text(service, style: const TextStyle(color: Colors.white))
                )
            )
          )
      );
    }
    return Card(
      color: widget.client.status == ClientInQueueStatus.confirmed
          ? Colors.white
          : Colors.white54,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
              title: Text('${widget.client.firstName} ${widget.client.lastName}'),
              subtitle: Text(
                  ((widget.client.email == null)
                      ? ''
                      : ('${widget.client.email} ') + '(${widget.client.accessKey})')
              ),
              leading: IconButton(
                tooltip: AppLocalizations.of(context)!.finishServing,
                icon: const Icon(Icons.done_outline_rounded),
                onPressed: () => widget.onServe(widget.client),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: AppLocalizations.of(context)!.callClient,
                    icon: const Icon(Icons.notifications),
                    onPressed: () => widget.onNotify(widget.client),
                  ),
                  IconButton(
                    tooltip: AppLocalizations.of(context)!.deleteClient,
                    icon: const Icon(Icons.close),
                    onPressed: () => widget.onDelete(widget.client),
                  ),
                ],
              )
          ),
        ] + services,
      )
    );
  }
}