import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/service/service_wrapper.dart';

class ServiceItemWidget extends StatefulWidget {
  final ValueChanged<ServiceWrapper>? onClick;
  final ValueChanged<ServiceWrapper>? onLongClick;
  final ValueChanged<ServiceWrapper>? onDelete;
  final int? index;
  final ServiceWrapper serviceWrapper;

  const ServiceItemWidget({
    Key? key,
    this.onClick,
    this.onLongClick,
    this.onDelete,
    this.index,
    required this.serviceWrapper,
  }) : super(key: key);

  @override
  State createState() => _ServiceItemState();
}

class _ServiceItemState extends State<ServiceItemWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
          leading: widget.serviceWrapper.selected
              ? const SizedBox(
                  height: double.infinity,
                  child: Icon(Icons.done, color: Colors.teal)
              )
              : null,
          title: Text(widget.serviceWrapper.service.name, maxLines: 1),
          subtitle: widget.serviceWrapper.service.description != null
              ? ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 200),
                child: Text(
                    widget.serviceWrapper.service.description!,
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
                      onPressed: () => widget.onDelete?.call(widget.serviceWrapper)),
                )
              : widget.index != null
              ? ReorderableDragStartListener(
                index: widget.index!,
                child: const Icon(Icons.drag_handle),
              )
              : null,
          onTap: widget.onClick != null
              ? () => widget.onClick?.call(widget.serviceWrapper)
              : null,
          onLongPress: widget.onLongClick != null
              ? () => widget.onLongClick?.call(widget.serviceWrapper)
              : null,
      )
    );
  }
}
