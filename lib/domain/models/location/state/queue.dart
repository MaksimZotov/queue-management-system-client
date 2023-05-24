import 'package:json_annotation/json_annotation.dart';

part 'queue.g.dart';

@JsonSerializable()
class Queue {
  final int id;
  final String name;

  Queue(
    this.id,
    this.name
  );

  static Queue fromJson(Map<String, dynamic> json) => _$QueueFromJson(json);
  Map<String, dynamic> toJson() => _$QueueToJson(this);
}