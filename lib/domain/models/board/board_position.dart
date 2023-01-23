import 'package:json_annotation/json_annotation.dart';

part 'board_position.g.dart';

@JsonSerializable()
class BoardPosition {
  final int number;
  @JsonKey(name: 'public_code')
  final int publicCode;

  BoardPosition({
    required this.number,
    required this.publicCode
  });

  static BoardPosition fromJson(Map<String, dynamic> json) => _$BoardPositionFromJson(json);
  Map<String, dynamic> toJson() => _$BoardPositionToJson(this);
}