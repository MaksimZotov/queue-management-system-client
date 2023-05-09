import 'package:json_annotation/json_annotation.dart';

import 'client.dart';
import 'location_state.dart';

part 'board.g.dart';

@JsonSerializable()
class Board {
  List<List<Client>> clientsColumns;

  Board(this.clientsColumns);

  static Board fromLocationState(
      LocationState locationState,
      int rowsAmount
  ) {
    List<List<Client>> clientsColumns = [];
    List<Client> currentRows = [];

    List<Client> clients = locationState.clients;
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