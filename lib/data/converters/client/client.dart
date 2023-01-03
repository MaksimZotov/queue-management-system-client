import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/data/converters/json_converter.dart';
import 'package:queue_management_system_client/domain/models/location/location.dart';

import '../../../domain/models/client/client.dart';

@singleton
class ClientFields {
  final String inQueue = 'in_queue';
  final String queueName = 'queue_name';
  final String queueLength = 'queue_length';
  final String email = 'email';
  final String firstName = 'first_name';
  final String lastName = 'last_name';
  final String beforeMe = 'before_me';
  final String accessKey = 'access_key';
}

@singleton
class ClientConverter extends JsonConverter<ClientModel> {
  final ClientFields _clientFields;
  ClientConverter(this._clientFields);

  @override
  ClientModel fromJson(Map<String, dynamic> json) => ClientModel(
    inQueue: json[_clientFields.inQueue] as bool,
    queueName: json[_clientFields.queueName] as String,
    queueLength: json[_clientFields.queueLength] as int,
    email: json[_clientFields.email] as String?,
    firstName: json[_clientFields.firstName] as String?,
    lastName: json[_clientFields.lastName] as String?,
    beforeMe: json[_clientFields.beforeMe] as int?,
    accessKey: json[_clientFields.accessKey] as String?
  );

  @override
  Map<String, dynamic> toJson(ClientModel data) => {
    _clientFields.inQueue: data.inQueue,
    _clientFields.queueName: data.queueName,
    _clientFields.queueLength: data.queueLength,
    _clientFields.email: data.email,
    _clientFields.firstName: data.firstName,
    _clientFields.lastName: data.lastName,
    _clientFields.beforeMe: data.beforeMe,
    _clientFields.accessKey: data.accessKey
  };
}