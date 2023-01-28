import 'package:json_annotation/json_annotation.dart';

part 'queue_type_model.g.dart';

@JsonSerializable()
class QueueTypeModel {
  final int id;
  final String name;
  final String? description;

  QueueTypeModel(
      this.id,
      this.name,
      this.description
  );

  static QueueTypeModel fromJson(Map<String, dynamic> json) => _$QueueTypeModelFromJson(json);
  Map<String, dynamic> toJson() => _$QueueTypeModelToJson(this);
}