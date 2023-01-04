import 'package:flutter/material.dart';
import 'package:queue_management_system_client/domain/models/location/location.dart';

class LocationItemWidget extends StatefulWidget {
  final ValueChanged<LocationModel> onClick;
  final ValueChanged<LocationModel> onDelete;
  final LocationModel location;

  const LocationItemWidget({
    Key? key,
    required this.onClick,
    required this.onDelete,
    required this.location,
  }) : super(key: key);

  @override
  State createState() => _LocationItemState();
}

class _LocationItemState extends State<LocationItemWidget> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: ListTile(
          title: Text(widget.location.name),
          subtitle: Text(widget.location.description),
          trailing: widget.location.hasRules == true ? IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => widget.onDelete(widget.location),
          ) : null,
          onTap: () => widget.onClick(widget.location),
        ),
      ),
    );
  }
}