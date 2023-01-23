import 'client_in_queue_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'queue_model.g.dart';

@JsonSerializable()
class QueueModel {
  final int? id;
  final String name;
  final String description;
  final List<ClientInQueueModel>? clients;
  @JsonKey(name: 'has_rights')
  final bool? hasRights;
  @JsonKey(name: 'owner_username')
  final String? ownerUsername;

  QueueModel({
    this.id,
    required this.name,
    required this.description,
    this.clients,
    this.hasRights,
    this.ownerUsername
  });

  static QueueModel fromJson(Map<String, dynamic> json) => _$QueueModelFromJson(json);
  Map<String, dynamic> toJson() => _$QueueModelToJson(this);
}