import 'package:flutter/material.dart';

import '../../domain/models/location/services_sequence_model.dart';

class ServicesSequenceItemWidget extends StatefulWidget {
  final ValueChanged<ServicesSequenceModel> onDelete;
  final ServicesSequenceModel servicesSequence;

  const ServicesSequenceItemWidget({
    Key? key,
    required this.onDelete,
    required this.servicesSequence,
  }) : super(key: key);

  @override
  State createState() => _ServicesSequenceItemState();
}

class _ServicesSequenceItemState extends State<ServicesSequenceItemWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
        child: ListTile(
            leading: const SizedBox(
                height: double.infinity,
                child: Icon(Icons.people_alt_outlined, color: Colors.teal)),
            title: Text(widget.servicesSequence.name, maxLines: 1),
            subtitle: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 200),
              child: widget.servicesSequence.description != null
                  ? Text(
                      widget.servicesSequence.description!,
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
                        onPressed: () => widget.onDelete(widget.servicesSequence)),
                  )
                : null));
  }
}
