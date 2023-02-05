import 'package:flutter/material.dart';

import '../models/service/service_wrapper.dart';

class ServiceItemWidget extends StatefulWidget {
  final ValueChanged<ServiceWrapper>? onTap;
  final ValueChanged<ServiceWrapper>? onDelete;
  final ServiceWrapper serviceWrapper;

  const ServiceItemWidget({
    Key? key,
    this.onTap,
    this.onDelete,
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
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
              )
            )
            : null,
          trailing: widget.onDelete != null
              ? SizedBox(
                  height: double.infinity,
                  child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => widget.onDelete?.call(widget.serviceWrapper)),
                )
              : null,
          onTap: () => widget.onTap?.call(widget.serviceWrapper),
      )
    );
  }
}
