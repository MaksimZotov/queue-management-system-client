import '../client/client_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'queue_model.g.dart';

@JsonSerializable()
class QueueModel {
  final int id;
  final String name;
  final String? description;
  @JsonKey(name: 'has_rights')
  final bool hasRights;

  QueueModel(
    this.id,
    this.name,
    this.description,
    this.hasRights
  );

  static QueueModel fromJson(Map<String, dynamic> json) => _$QueueModelFromJson(json);
  Map<String, dynamic> toJson() => _$QueueModelToJson(this);
}