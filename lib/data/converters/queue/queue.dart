import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/data/converters/json_converter.dart';

import '../../../domain/models/queue/queue.dart';

@singleton
class QueueFields {
  final String id = 'id';
  final String name = 'name';
  final String description = 'description';
}

@singleton
class QueueConverter extends JsonConverter<QueueModel> {
  final QueueFields _clientInRoomFields;
  QueueConverter(this._clientInRoomFields);

  @override
  QueueModel fromJson(Map<String, dynamic> json) => QueueModel(
    id: json[_clientInRoomFields.id] as int?,
    name: json[_clientInRoomFields.name] as String,
    description: json[_clientInRoomFields.description] as String
  );

  @override
  Map<String, dynamic> toJson(QueueModel data) => {
    _clientInRoomFields.id: data.id,
    _clientInRoomFields.name: data.name,
    _clientInRoomFields.description: data.description
  };
}