import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/models/board/board_position.dart';
import 'package:queue_management_system_client/domain/models/board/board_queue.dart';

import '../json_converter.dart';

@singleton
class BoardPositionFields {
  final String number = 'number';
  final String publicCode = 'public_code';
}

@singleton
class BoardPositionConverter extends JsonConverter<BoardPosition> {
  final BoardPositionFields _boardPositionFields;

  BoardPositionConverter(
      this._boardPositionFields,
  );

  @override
  BoardPosition fromJson(Map<String, dynamic> json) {
    return BoardPosition(
        number: json[_boardPositionFields.number] as int,
        publicCode: json[_boardPositionFields.publicCode] as int
    );
  }

  @override
  Map<String, dynamic> toJson(BoardPosition data) => {
    _boardPositionFields.number: data.number,
    _boardPositionFields.publicCode: data.publicCode
  };
}