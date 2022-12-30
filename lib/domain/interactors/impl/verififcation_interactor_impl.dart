import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/data/repositories/repository.dart';
import 'package:queue_management_system_client/domain/interactors/verification_interactor.dart';
import 'package:queue_management_system_client/domain/models/verification/login.dart';
import 'package:queue_management_system_client/domain/models/verification/signup.dart';
import 'package:queue_management_system_client/domain/models/verification/tokens.dart';

import '../../models/base/result.dart';
import '../../models/verification/Confirm.dart';

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

}