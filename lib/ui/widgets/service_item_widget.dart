import 'package:flutter/material.dart';

import '../../domain/models/location/service_model.dart';

class ServiceItemWidget extends StatefulWidget {
  final ValueChanged<ServiceModel> onDelete;
  final ServiceModel service;

  const ServiceItemWidget({
    Key? key,
    required this.onDelete,
    required this.service,
  }) : super(key: key);

  @override
  State createState() => _ServiceItemState();
}

class _ServiceItemState extends State<ServiceItemWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
          leading: const SizedBox(
              height: double.infinity,
              child: Icon(Icons.people_alt_outlined, color: Colors.teal)),
          title: Text(widget.service.name, maxLines: 1),
          subtitle: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 200),
            child: widget.service.description != null
                ? Text(
                    widget.service.description!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  )
                : null,
          ),
          trailing: true // widget.service.hasRights == true
              ? SizedBox(
                  height: double.infinity,
                  child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => widget.onDelete(widget.service)),
                )
              : null
      )
    );
  }
}
