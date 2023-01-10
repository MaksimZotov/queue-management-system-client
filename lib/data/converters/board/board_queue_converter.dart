import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/models/board/board_position.dart';
import 'package:queue_management_system_client/domain/models/board/board_queue.dart';

import '../../../domain/models/board/board_model.dart';
import '../json_converter.dart';
import 'board_position_converter.dart';

@singleton
class BoardQueueFields {
  final String title = 'title';
  final String positions = 'positions';
}

@singleton
class BoardQueueConverter extends JsonConverter<BoardQueue> {
  final BoardQueueFields _boardQueueFields;
  final BoardPositionConverter _boardPositionConverter;

  BoardQueueConverter(
      this._boardQueueFields,
      this._boardPositionConverter
  );

  @override
  BoardQueue fromJson(Map<String, dynamic> json) {
    return BoardQueue(
      title: json[_boardQueueFields.title] as String,
      positions: (json[_boardQueueFields.positions] as List<dynamic>)
          .map((position) =>
              _boardPositionConverter.fromJson(position as Map<String, dynamic>)
          ).toList(),
    );
  }

  @override
  Map<String, dynamic> toJson(BoardQueue data) => {
    _boardQueueFields.title: data.title,
    _boardQueueFields.positions: data.positions
  };
}