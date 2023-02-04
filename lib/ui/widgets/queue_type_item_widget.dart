import 'package:flutter/material.dart';

import '../../domain/models/location/specialist_model.dart';

class SpecialistItemWidget extends StatefulWidget {
  final ValueChanged<SpecialistModel>? onTap;
  final ValueChanged<SpecialistModel>? onDelete;
  final SpecialistModel specialist;

  const SpecialistItemWidget({
    Key? key,
    this.onTap,
    this.onDelete,
    required this.specialist,
  }) : super(key: key);

  @override
  State createState() => _SpecialistItemState();
}

class _SpecialistItemState extends State<SpecialistItemWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
        child: ListTile(
            title: Text(widget.specialist.name, maxLines: 1),
            subtitle: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 200),
              child: widget.specialist.description != null
                  ? Text(
                      widget.specialist.description!,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    )
                  : null,
            ),
            trailing: widget.onDelete != null
                ? SizedBox(
                    height: double.infinity,
                    child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => widget.onDelete?.call(widget.specialist)),
                  )
                : null,
          onTap: () => widget.onTap?.call(widget.specialist),
        )
    );
  }
}
