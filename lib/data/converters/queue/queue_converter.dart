import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/data/converters/json_converter.dart';

import '../../../domain/models/queue/queue_model.dart';
import 'client_in_queue_converter.dart';

@singleton
class QueueFields {
  final String id = 'id';
  final String name = 'name';
  final String description = 'description';
  final String clients = 'clients';
  final String hasRules = 'has_rules';
  final String ownerUsername = 'owner_username';
}

@singleton
class QueueConverter extends JsonConverter<QueueModel> {
  final QueueFields _queueFields;
  final ClientInQueueConverter _clientInQueueConverter;

  QueueConverter(
      this._queueFields,
      this._clientInQueueConverter
  );

  @override
  QueueModel fromJson(Map<String, dynamic> json) {
    return QueueModel(
        id: json[_queueFields.id] as int?,
        name: json[_queueFields.name] as String,
        description: json[_queueFields.description] as String,
        clients: (json[_queueFields.clients] as List<dynamic>?)
            ?.map((client) =>
                _clientInQueueConverter.fromJson(client as Map<String, dynamic>)
            ).toList(),
        hasRules: json[_queueFields.hasRules] as bool?,
        ownerUsername: json[_queueFields.ownerUsername] as String?
    );
  }

  @override
  Map<String, dynamic> toJson(QueueModel data) => {
    _queueFields.id: data.id,
    _queueFields.name: data.name,
    _queueFields.description: data.description,
    _queueFields.clients: data.clients?.map(_clientInQueueConverter.toJson),
    _queueFields.hasRules: data.hasRules,
    _queueFields.ownerUsername: data.ownerUsername
  };
}