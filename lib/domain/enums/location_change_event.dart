import 'package:json_annotation/json_annotation.dart';

enum LocationChangeEvent {

  @JsonValue('ADD_CLIENT')
  addClient('ADD_CLIENT'),
  @JsonValue('UPDATE_CLIENT')
  updateClient('UPDATE_CLIENT'),
  @JsonValue('DELETE_CLIENT')
  deleteClient('DELETE_CLIENT');

  final String serverName;

  const LocationChangeEvent(
      this.serverName
  );

}