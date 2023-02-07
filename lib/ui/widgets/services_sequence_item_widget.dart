import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../domain/models/location/services_sequence_model.dart';

class ServicesSequenceItemWidget extends StatefulWidget {
  final ValueChanged<ServicesSequenceModel>? onTap;
  final ValueChanged<ServicesSequenceModel>? onDelete;
  final ServicesSequenceModel servicesSequence;

  const ServicesSequenceItemWidget({
    Key? key,
    this.onTap,
    this.onDelete,
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
            trailing: widget.onDelete != null
                ? SizedBox(
                    height: double.infinity,
                    child: IconButton(
                        tooltip: AppLocalizations.of(context)!.delete,
                        icon: const Icon(Icons.delete),
                        onPressed: () => widget.onDelete?.call(widget.servicesSequence)),
                  )
                : null,
            onTap: widget.onTap != null ? () => widget.onTap?.call(widget.servicesSequence) : null,
        )
    );
  }
}
