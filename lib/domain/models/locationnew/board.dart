import 'package:json_annotation/json_annotation.dart';
import 'package:queue_management_system_client/domain/models/locationnew/location_state.dart';

import 'client.dart';

part 'board.g.dart';

@JsonSerializable()
class Board {
  List<List<Client>> clientsColumns;

  Board(this.clientsColumns);

  static Board fromLocationState(
      LocationState locationState,
      int rowsAmount
  ) {
    List<Client> clients = locationState.clients
      ..sort((a, b) => a.waitTimestamp.second.compareTo(b.waitTimestamp.second));

    List<List<Client>> clientsColumns = [];
    List<Client> currentRows = [];

    for (int i = 1; i <= clients.length; i++) {
      currentRows.add(clients[i - 1]);
      if ((i >= rowsAmount && i % rowsAmount == 0) || i == clients.length) {
        clientsColumns.add(currentRows);
        currentRows = [];
      }
    }

    return Board(clientsColumns);
  }

  static Board fromJson(Map<String, dynamic> json) => _$BoardFromJson(json);
  Map<String, dynamic> toJson() => _$BoardToJson(this);
}