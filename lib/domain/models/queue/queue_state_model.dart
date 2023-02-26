import 'client_in_queue_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'queue_state_model.g.dart';

@JsonSerializable()
class QueueStateModel {
  final int id;
  final String name;
  final String? description;
  final List<ClientInQueueModel> clients;
  @JsonKey(name: 'has_rights')
  final bool? hasRights;
  @JsonKey(name: 'owner_email')
  final String? ownerEmail;
  final bool? enabled;

  QueueStateModel({
    required this.id,
    required this.name,
    this.description,
    required this.clients,
    this.hasRights,
    this.ownerEmail,
    this.enabled
  });

  static QueueStateModel fromJson(Map<String, dynamic> json) => _$QueueStateModelFromJson(json);
  Map<String, dynamic> toJson() => _$QueueStateModelToJson(this);
}