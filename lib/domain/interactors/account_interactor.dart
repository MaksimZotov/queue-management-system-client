import '../models/account/tokens_model.dart';
import '../models/base/result.dart';
import '../models/account/confirm_model.dart';
import '../models/account/login_model.dart';
import '../models/account/signup_model.dart';

abstract class AccountInteractor {
  Future<Result> signup(SignupModel signup);
  Future<Result> confirm(ConfirmModel confirm);
  Future<Result<TokensModel>> login(LoginModel login);
  Future<bool> checkToken();
  Future<void> logout();
  Future<int?> getCurrentAccountId();
}