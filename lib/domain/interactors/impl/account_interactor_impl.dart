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

  @override
  Future<String?> getCurrentUsername() async {
    return await _repository.getCurrentUsername();
  }
}