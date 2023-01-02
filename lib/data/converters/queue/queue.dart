import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/data/converters/json_converter.dart';

import '../../../domain/models/queue/queue.dart';
import 'client_in_queue.dart';

@singleton
class QueueFields {
  final String id = 'id';
  final String name = 'name';
  final String description = 'description';
  final String clients = 'clients';
}

@singleton
class QueueConverter extends JsonConverter<QueueModel> {
  final QueueFields _clientInRoomFields;
  final ClientInQueueConverter _clientInQueueConverter;

  QueueConverter(
      this._clientInRoomFields,
      this._clientInQueueConverter
  );

  @override
  QueueModel fromJson(Map<String, dynamic> json) {
    return QueueModel(
        id: json[_clientInRoomFields.id] as int?,
        name: json[_clientInRoomFields.name] as String,
        description: json[_clientInRoomFields.description] as String,
        clients: (json[_clientInRoomFields.clients] as List<dynamic>?)
            ?.map((client) =>
                _clientInQueueConverter.fromJson(client as Map<String, dynamic>)
            ).toList()
    );
  }

  @override
  Map<String, dynamic> toJson(QueueModel data) => {
    _clientInRoomFields.id: data.id,
    _clientInRoomFields.name: data.name,
    _clientInRoomFields.description: data.description,
    _clientInRoomFields.clients: data.clients?.map(_clientInQueueConverter.toJson)
  };
}