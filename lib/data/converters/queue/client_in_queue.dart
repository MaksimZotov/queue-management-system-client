import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/data/converters/json_converter.dart';
import 'package:queue_management_system_client/domain/models/queue/client_in_queue.dart';

@singleton
class ClientInQueueFields {
  final String id = 'id';
  final String email = 'email';
  final String firstName = 'first_name';
  final String lastName = 'last_name';
  final String orderNumber = 'order_number';
}

@singleton
class ClientInQueueConverter extends JsonConverter<ClientInQueueModel> {
  final ClientInQueueFields _clientInRoomFields;
  ClientInQueueConverter(this._clientInRoomFields);

  @override
  ClientInQueueModel fromJson(Map<String, dynamic> json) => ClientInQueueModel(
      id: json[_clientInRoomFields.id] as int,
      email: json[_clientInRoomFields.email] as String,
      firstName: json[_clientInRoomFields.firstName] as String,
      lastName: json[_clientInRoomFields.lastName] as String,
      orderNumber: json[_clientInRoomFields.orderNumber] as int
  );

  @override
  Map<String, dynamic> toJson(ClientInQueueModel data) => {
    _clientInRoomFields.id: data.id,
    _clientInRoomFields.email: data.email,
    _clientInRoomFields.firstName: data.firstName,
    _clientInRoomFields.lastName: data.lastName,
    _clientInRoomFields.orderNumber: data.orderNumber
  };
}