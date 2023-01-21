import 'board_position.dart';
import 'package:json_annotation/json_annotation.dart';

part 'board_queue.g.dart';

@JsonSerializable()
class BoardQueue {
  final String title;
  final List<BoardPosition> positions;

  BoardQueue({
    required this.title,
    required this.positions
  });

  static BoardQueue fromJson(Map<String, dynamic> json) => _$BoardQueueFromJson(json);
  Map<String, dynamic> toJson() => _$BoardQueueToJson(this);
}