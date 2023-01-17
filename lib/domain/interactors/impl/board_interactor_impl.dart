import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/interactors/board_interactor.dart';
import 'package:queue_management_system_client/domain/models/base/result.dart';
import 'package:queue_management_system_client/domain/models/board/board_model.dart';

import '../../../data/repositories/repository.dart';

@Singleton(as: BoardInteractor)
class BoardInteractorImpl extends BoardInteractor {
  final Repository _repository;

  BoardInteractorImpl(this._repository);

  @override
  Future<Result<BoardModel>> getBoard(int locationId) {
    return _repository.getBoard(locationId);
  }
}