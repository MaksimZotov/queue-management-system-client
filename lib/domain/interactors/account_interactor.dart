import '../models/base/result.dart';
import '../models/account/confirm_model.dart';
import '../models/account/login_model.dart';
import '../models/account/signup_model.dart';

abstract class AccountInteractor {
  Future<Result> signup(SignupModel signup);
  Future<Result> confirm(ConfirmModel confirm);
  Future<Result> login(LoginModel login);
  Future<bool> checkToken();
  Future<void> logout();
  Future<String?> getCurrentUsername();
}