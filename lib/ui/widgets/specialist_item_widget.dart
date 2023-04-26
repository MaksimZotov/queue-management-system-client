import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../domain/models/specialist/specialist_model.dart';

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
            subtitle: widget.specialist.description != null
                ? ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 200),
                  child: Text(
                    widget.specialist.description!,
                    overflow: TextOverflow.ellipsis,
                  )
                )
                : null,
            trailing: widget.onDelete != null
                ? SizedBox(
                    height: double.infinity,
                    child: IconButton(
                        tooltip: AppLocalizations.of(context)!.delete,
                        icon: const Icon(Icons.delete),
                        onPressed: () => widget.onDelete?.call(widget.specialist)),
                  )
                : null,
          onTap: widget.onTap != null
              ? () => widget.onTap?.call(widget.specialist)
              : null
        )
    );
  }
}
