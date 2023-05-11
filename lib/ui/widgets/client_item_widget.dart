import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../domain/models/location/state/client.dart';
import '../../domain/models/location/state/service.dart';

class ClientItemWidget extends StatefulWidget {
  final Client client;
  final ValueChanged<Client>? onChange;
  final ValueChanged<Client> onNotify;
  final ValueChanged<Client>? onServe;
  final ValueChanged<Client>? onReturn;
  final ValueChanged<Client>? onCall;
  final ValueChanged<Client> onDelete;

  const ClientItemWidget({
    Key? key,
    required this.client,
    required this.onChange,
    required this.onNotify,
    required this.onServe,
    required this.onReturn,
    required this.onCall,
    required this.onDelete
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
              elevation: 2,
              color: Colors.white,
              child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text(service.name, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16))
              )
          )
      );
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                    'Информация о клиенте:',
                    style: TextStyle(color: Colors.black, fontSize: 18)
                ),
                const SizedBox(height: 5),
                Card(
                    elevation: 2,
                    color: Colors.white,
                    child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Text(
                            AppLocalizations.of(context)!.codeWithColonPattern(
                                widget.client.code
                            ),
                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)
                        )
                    )
                ),
                Card(
                    elevation: 2,
                    color: Colors.white,
                    child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Text(
                            AppLocalizations.of(context)!.phoneWithColonPattern(
                                widget.client.phone ?? '-'
                            ),
                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)
                        )
                    )
                ),
                Card(
                    elevation: 2,
                    color: Colors.white,
                    child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Text(
                            AppLocalizations.of(context)!.waitTimeInMinutesPattern(
                                widget.client.waitTimeInMinutes
                            ),
                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)
                        )
                    )
                ),
                Card(
                    elevation: 2,
                    color: Colors.white,
                    child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Text(
                            AppLocalizations.of(context)!.totalTimeInMinutesPattern(
                                widget.client.totalTimeInMinutes
                            ),
                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)
                        )
                    )
                ),
                const SizedBox(height: 10),
                Text(
                    AppLocalizations.of(context)!.servicesWithColon,
                    style: const TextStyle(color: Colors.black, fontSize: 18)
                ),
                const SizedBox(height: 5)
              ] + services,
            )
          ] + [_getButtons()],
        )
      )
    );
  }

  Widget _getButtons() {
    if (widget.onServe != null && widget.onReturn != null && widget.onChange != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
              padding: const EdgeInsets.all(16),
              child: IconButton(
                tooltip: AppLocalizations.of(context)!.deleteClient,
                icon: const Icon(Icons.close, size: 35, color: Colors.grey),
                onPressed: () => widget.onDelete(widget.client),
              )
          ),
          Padding(
              padding: const EdgeInsets.all(16),
              child: IconButton(
                tooltip: AppLocalizations.of(context)!.notify,
                icon: const Icon(Icons.notifications, size: 35, color: Colors.grey),
                onPressed: () => widget.onNotify(widget.client),
              )
          ),
          Padding(
              padding: const EdgeInsets.all(16),
              child: IconButton(
                tooltip: AppLocalizations.of(context)!.redirectClient,
                icon: const Icon(Icons.track_changes, size: 35, color: Colors.grey),
                onPressed: () => widget.onChange!.call(widget.client),
              )
          ),
          Padding(
              padding: const EdgeInsets.all(16),
              child: IconButton(
                tooltip: AppLocalizations.of(context)!.returnClientToQueue,
                icon: const Icon(Icons.call_received, size: 35, color: Colors.grey),
                onPressed: () => widget.onReturn!.call(widget.client),
              )
          ),
          Padding(
              padding: const EdgeInsets.all(16),
              child: IconButton(
                tooltip: AppLocalizations.of(context)!.finishServing,
                icon: const Icon(Icons.done, size: 35, color: Colors.grey),
                onPressed: () => widget.onServe!.call(widget.client),
              )
          )
        ],
      );
    }
    if (widget.onCall != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
              padding: const EdgeInsets.all(16),
              child: IconButton(
                tooltip: AppLocalizations.of(context)!.deleteClient,
                icon: const Icon(Icons.close, size: 35, color: Colors.grey),
                onPressed: () => widget.onDelete(widget.client),
              )
          ),
          Padding(
              padding: const EdgeInsets.all(16),
              child: IconButton(
                tooltip: AppLocalizations.of(context)!.notify,
                icon: const Icon(Icons.notifications, size: 35, color: Colors.grey),
                onPressed: () => widget.onNotify(widget.client),
              )
          ),
          Padding(
              padding: const EdgeInsets.all(16),
              child: IconButton(
                tooltip: AppLocalizations.of(context)!.callClient,
                icon: const Icon(Icons.call_made, size: 35, color: Colors.grey),
                onPressed: () => widget.onCall!.call(widget.client),
              )
          )
        ],
      );
    }
    throw Exception();
  }
}