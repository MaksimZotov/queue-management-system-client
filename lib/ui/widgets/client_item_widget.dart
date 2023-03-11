import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:queue_management_system_client/domain/enums/client_in_queue_status.dart';
import 'package:queue_management_system_client/domain/models/locationnew/service.dart';
import 'package:queue_management_system_client/domain/models/queue/client_in_queue_model.dart';

import '../../dimens.dart';
import '../../domain/models/locationnew/client.dart';

class ClientItemWidget extends StatefulWidget {
  final ValueChanged<Client> onNotify;
  final ValueChanged<Client>? onServe;
  final ValueChanged<Client>? onReturn;
  final ValueChanged<Client>? onCall;
  final ValueChanged<Client> onDelete;
  final Client client;

  const ClientItemWidget({
    Key? key,
    required this.onNotify,
    required this.onServe,
    required this.onReturn,
    required this.onCall,
    required this.onDelete,
    required this.client,
  }) : super(key: key);

  @override
  State createState() => _ClientItemState();
}

class _ClientItemState extends State<ClientItemWidget> {

  @override
  Widget build(BuildContext context) {
    List<Widget> services = [];
    for (Service service in widget.client.services) {
      services.add(
          Card(
              color: Colors.teal,
              child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text(service.name, style: const TextStyle(color: Colors.white))
              )
          )
      );
    }
    services.add(const SizedBox(height: Dimens.contentMargin));

    return Card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                  AppLocalizations.of(context)!.codeWithColonPattern(
                      widget.client.code
                  )
              ),
              Text(
                  AppLocalizations.of(context)!.waitTimeInMinutesPattern(
                      widget.client.waitTimeInMinutes
                  )
              ),
            ] + services,
          )
        ] + [_getButtons()],
      )
    );
  }

  Widget _getButtons() {
    if (widget.onServe != null && widget.onReturn != null) {
      return Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                  padding: const EdgeInsets.all(8),
                  child: IconButton(
                    tooltip: AppLocalizations.of(context)!.deleteClient,
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => widget.onDelete(widget.client),
                  )
              ),
              Padding(
                  padding: const EdgeInsets.all(8),
                  child: IconButton(
                      tooltip: AppLocalizations.of(context)!.notify,
                      icon: const Icon(Icons.notifications, color: Colors.grey),
                      onPressed: () => widget.onNotify(widget.client)
                  )
              )
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                  padding: const EdgeInsets.all(8),
                  child: IconButton(
                    tooltip: AppLocalizations.of(context)!.returnClientToQueue,
                    icon: const Icon(Icons.call_received, color: Colors.grey),
                    onPressed: () => widget.onReturn!.call(widget.client),
                  )
              ),
              Padding(
                  padding: const EdgeInsets.all(8),
                  child: IconButton(
                    tooltip: AppLocalizations.of(context)!.finishServing,
                    icon: const Icon(Icons.done, color: Colors.grey),
                    onPressed: () => widget.onServe!.call(widget.client),
                  )
              )
            ],
          )
        ],
      );
    }
    if (widget.onCall != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
              padding: const EdgeInsets.all(8),
              child: IconButton(
                tooltip: AppLocalizations.of(context)!.deleteClient,
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => widget.onDelete(widget.client),
              )
          ),
          Padding(
              padding: const EdgeInsets.all(8),
              child: IconButton(
                tooltip: AppLocalizations.of(context)!.notify,
                icon: const Icon(Icons.notifications, color: Colors.grey),
                onPressed: () => widget.onNotify(widget.client),
              )
          ),
          Padding(
              padding: const EdgeInsets.all(8),
              child: IconButton(
                tooltip: AppLocalizations.of(context)!.callClient,
                icon: const Icon(Icons.call_made, color: Colors.grey),
                onPressed: () => widget.onCall!.call(widget.client),
              )
          )
        ],
      );
    }
    throw Exception();
  }
}