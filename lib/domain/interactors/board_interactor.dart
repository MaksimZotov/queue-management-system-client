import '../models/base/result.dart';
import '../models/board/board_model.dart';

abstract class BoardInteractor {
  Future<Result<BoardModel>> getBoard(int locationId);
}