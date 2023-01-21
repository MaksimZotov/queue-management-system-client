import 'board_queue.dart';
import 'package:json_annotation/json_annotation.dart';

part 'board_model.g.dart';

@JsonSerializable()
class BoardModel {
  final List<BoardQueue> queues;

  BoardModel({
    required this.queues
  });

  static BoardModel fromJson(Map<String, dynamic> json) => _$BoardModelFromJson(json);
  Map<String, dynamic> toJson() => _$BoardModelToJson(this);
}