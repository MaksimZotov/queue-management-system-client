import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/data/repositories/repository.dart';
import 'package:queue_management_system_client/domain/interactors/account_interactor.dart';
import 'package:queue_management_system_client/domain/models/account/login_model.dart';
import 'package:queue_management_system_client/domain/models/account/signup_model.dart';
import 'package:queue_management_system_client/domain/models/account/tokens_model.dart';

import '../../models/base/result.dart';
import '../../models/account/confirm_model.dart';

@Singleton(as: AccountInteractor)
class AccountInteractorImpl extends AccountInteractor {
  final Repository _repository;

  AccountInteractorImpl(this._repository);

  @override
  Future<Result> signup(SignupModel signup) {
    return _repository.signup(signup);
  }

  @override
  Future<Result> confirm(ConfirmModel confirm) {
    return _repository.confirm(confirm);
  }

  @override
  Future<Result<TokensModel>> login(LoginModel login) {
    return _repository.login(login);
  }

  @override
  Future<bool> checkToken() {
    return _repository.checkToken();
  }

  @override
  Future<void> logout() async {
    _repository.logout();
  }

  @override
  Future<int?> getCurrentAccountId() {
    return _repository.getCurrentAccountId();
  }
}