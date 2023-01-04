import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/data/converters/json_converter.dart';
import 'package:queue_management_system_client/domain/models/queue/client_in_queue_model.dart';

import '../../../domain/enums/client_in_queue_status.dart';

@singleton
class ClientInQueueFields {
  final String email = 'email';
  final String firstName = 'first_name';
  final String lastName = 'last_name';
  final String orderNumber = 'order_number';
  final String status = 'status';
}

@singleton
class ClientInQueueConverter extends JsonConverter<ClientInQueueModel> {
  final ClientInQueueFields _clientInQueueField;
  ClientInQueueConverter(this._clientInQueueField);

  @override
  ClientInQueueModel fromJson(Map<String, dynamic> json) => ClientInQueueModel(
      email: json[_clientInQueueField.email] as String,
      firstName: json[_clientInQueueField.firstName] as String,
      lastName: json[_clientInQueueField.lastName] as String,
      orderNumber: json[_clientInQueueField.orderNumber] as int,
      status: ClientInQueueStatus.get(json[_clientInQueueField.status] as String)!,
  );

  @override
  Map<String, dynamic> toJson(ClientInQueueModel data) => {
    _clientInQueueField.email: data.email,
    _clientInQueueField.firstName: data.firstName,
    _clientInQueueField.lastName: data.lastName,
    _clientInQueueField.orderNumber: data.orderNumber,
    _clientInQueueField.status: data.status.name
  };
}