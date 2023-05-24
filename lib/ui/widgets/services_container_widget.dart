import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:queue_management_system_client/ui/models/client/services_container.dart';

class ServicesContainerWidget extends StatefulWidget {
  final ServicesContainer servicesContainer;

  const ServicesContainerWidget({
    Key? key,
    required this.servicesContainer,
  }) : super(key: key);

  @override
  State createState() => _ServicesContainerState();
}

class _ServicesContainerState extends State<ServicesContainerWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 5,
        color: Colors.white,
        child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: <Widget>[
                Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                        AppLocalizations.of(context)!.servicesWithPriorityPattern(
                            widget.servicesContainer.priorityNumber
                        ),
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18
                        )
                    )
                )
              ] + widget.servicesContainer.services.map((service) =>
                  Card(
                      elevation: 2,
                      color: Colors.white,
                      child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                              service.name,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16
                              )
                          )
                      )
                  )
              ).toList(),
            )
        )
    );
  }
}
