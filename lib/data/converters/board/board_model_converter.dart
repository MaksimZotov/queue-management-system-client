import 'package:injectable/injectable.dart';

import '../../../domain/models/board/board_model.dart';
import '../json_converter.dart';
import 'board_queue_converter.dart';

@singleton
class BoardModelFields {
  final String queues = 'queues';
}

@singleton
class BoardConverter extends JsonConverter<BoardModel> {
  final BoardModelFields _boardModelFields;
  final BoardQueueConverter _boardQueueConverter;

  BoardConverter(
      this._boardModelFields,
      this._boardQueueConverter
  );

  @override
  BoardModel fromJson(Map<String, dynamic> json) {
    return BoardModel(
        queues: (json[_boardModelFields.queues] as List<dynamic>)
            .map((queue) =>
              _boardQueueConverter.fromJson(queue as Map<String, dynamic>)
            ).toList(),
    );
  }

  @override
  Map<String, dynamic> toJson(BoardModel data) => {
    _boardModelFields.queues: data.queues
  };
}