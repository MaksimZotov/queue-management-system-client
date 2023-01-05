import 'package:flutter/material.dart';
import 'package:queue_management_system_client/domain/models/location/location_model.dart';

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
    return Card(
      child: ListTile(
        leading: const SizedBox(
          height: double.infinity,
          child: Icon(Icons.location_on, color: Colors.teal, size: 35)
        ),
        title: Text(
          widget.location.name,
          maxLines: 1,
        ),
        subtitle: SizedBox(
          width: 5,
          child: Text(
            widget.location.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: widget.location.hasRules == true
            ? SizedBox(
                height: double.infinity,
                child: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 25),
                  onPressed: () => widget.onDelete(widget.location),
                ),
              )
            : null,
        onTap: () => widget.onClick(widget.location),
      ),
    );
  }
}
