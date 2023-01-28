import 'client_in_queue_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'queue_model.g.dart';

@JsonSerializable()
class QueueModel {
  final int id;
  final String name;
  final String? description;
  @JsonKey(name: 'has_rights')
  final bool hasRights;
  final bool paused;

  QueueModel(
    this.id,
    this.name,
    this.description,
    this.hasRights,
    this.paused
  );

  static QueueModel fromJson(Map<String, dynamic> json) => _$QueueModelFromJson(json);
  Map<String, dynamic> toJson() => _$QueueModelToJson(this);
}