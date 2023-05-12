import 'package:json_annotation/json_annotation.dart';

part 'queue_state_model.g.dart';

@JsonSerializable()
class QueueStateModel {
  final int id;
  final String name;
  final String? description;
  @JsonKey(name: 'owner_email')
  final String? ownerEmail;
  final List<int> services;

  QueueStateModel({
    required this.id,
    required this.name,
    this.description,
    this.ownerEmail,
    required this.services
  });

  static QueueStateModel fromJson(Map<String, dynamic> json) => _$QueueStateModelFromJson(json);
  Map<String, dynamic> toJson() => _$QueueStateModelToJson(this);
}