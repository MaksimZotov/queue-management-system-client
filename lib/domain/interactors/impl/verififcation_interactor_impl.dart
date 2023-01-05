import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/data/repositories/repository.dart';
import 'package:queue_management_system_client/domain/interactors/verification_interactor.dart';
import 'package:queue_management_system_client/domain/models/verification/login_model.dart';
import 'package:queue_management_system_client/domain/models/verification/signup_model.dart';
import 'package:queue_management_system_client/domain/models/verification/tokens_model.dart';

import '../../models/base/result.dart';
import '../../models/verification/confirm_model.dart';

@Singleton(as: VerificationInteractor)
class VerificationInteractorImpl extends VerificationInteractor {
  final Repository _repository;

  VerificationInteractorImpl(this._repository);

  @override
  Future<Result> signup(SignupModel signup) async {
    return await _repository.signup(signup);
  }

  @override
  Future<Result> confirm(ConfirmModel confirm) async {
    return await _repository.confirm(confirm);
  }

  @override
  Future<Result<TokensModel>> login(LoginModel login) async {
    return await _repository.login(login);
  }

  @override
  Future<bool> checkToken() async {
    return await _repository.checkToken();
  }

  @override
  Future logout() async {
    await _repository.logout();
  }
}