import '../models/base/result.dart';
import '../models/verification/Confirm.dart';
import '../models/verification/login.dart';
import '../models/verification/signup.dart';

abstract class VerificationInteractor {
  Future<Result> signup(SignupModel signup);
  Future<Result> confirm(ConfirmModel confirm);
  Future<Result> login(LoginModel login);
}