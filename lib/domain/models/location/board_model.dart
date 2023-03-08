import 'package:json_annotation/json_annotation.dart';

import 'board_queue.dart';

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