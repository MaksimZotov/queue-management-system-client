import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/data/converters/json_converter.dart';
import 'package:queue_management_system_client/domain/models/location/location.dart';

import '../../../domain/models/client/client.dart';
import '../../../domain/models/client/client_join_info.dart';

@singleton
class ClientJoinInfoFields {
  final String email = 'email';
  final String firstName = 'first_name';
  final String lastName = 'last_name';
}

@singleton
class ClientJoinInfoConverter extends JsonConverter<ClientJoinInfo> {
  final ClientJoinInfoFields _clientFields;
  ClientJoinInfoConverter(this._clientFields);

  @override
  ClientJoinInfo fromJson(Map<String, dynamic> json) => ClientJoinInfo(
    email: json[_clientFields.email] as String,
    firstName: json[_clientFields.firstName] as String,
    lastName: json[_clientFields.lastName] as String
  );

  @override
  Map<String, dynamic> toJson(ClientJoinInfo data) => {
    _clientFields.email: data.email,
    _clientFields.firstName: data.firstName,
    _clientFields.lastName: data.lastName
  };
}