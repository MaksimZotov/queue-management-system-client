import 'package:json_annotation/json_annotation.dart';

part 'services_sequence_model.g.dart';

@JsonSerializable()
class ServicesSequenceModel {
  final int id;
  final String name;
  final String? description;

  ServicesSequenceModel(
      this.id,
      this.name,
      this.description
  );

  static ServicesSequenceModel fromJson(Map<String, dynamic> json) => _$ServicesSequenceModelFromJson(json);
  Map<String, dynamic> toJson() => _$ServicesSequenceModelToJson(this);
}