import '../models/base/result.dart';
import '../models/verification/confirm_model.dart';
import '../models/verification/login_model.dart';
import '../models/verification/signup_model.dart';

abstract class VerificationInteractor {
  Future<Result> signup(SignupModel signup);
  Future<Result> confirm(ConfirmModel confirm);
  Future<Result> login(LoginModel login);
  Future<bool> checkToken();
  Future logout();
  Future<String?> getCurrentUsername();
}