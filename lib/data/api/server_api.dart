import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/data/converters/verification/confirm_converter.dart';
import 'package:queue_management_system_client/domain/models/base/container_for_list.dart';
import 'package:queue_management_system_client/domain/models/location/location.dart';
import 'package:queue_management_system_client/domain/models/verification/Confirm.dart';

import '../../domain/models/base/result.dart';
import '../../domain/models/verification/login.dart';
import '../../domain/models/verification/signup.dart';
import '../../domain/models/verification/tokens.dart';
import '../converters/base/container_for_list_converter.dart';
import '../converters/base/error_result_converter.dart';
import '../converters/json_converter.dart';
import '../converters/location/location.dart';
import '../converters/verification/login_converter.dart';
import '../converters/verification/signup_converters.dart';
import '../converters/verification/tokens_converter.dart';
import '../local/tokens_storage.dart';

@lazySingleton
class ServerApi {
  final String unknownError = 'Неизвестная ошибка';
  final String responseTimeoutError = 'Вышло время ожидания ответа';
  final String noConnectionError = 'Нет соединения';

  static const url = 'http://localhost:8080';

  static const signupMethod = '/verification/signup';
  static const confirmMethod = '/verification/confirm';
  static const loginMethod = '/verification/login';

  final Dio _dioApi;
  final TokensStorage _tokensStorage;

  final ErrorResultConverter _errorResultConverter;
  final ContainerForListConverter _containerForListConverter;

  final TokensConverter _tokensConverter;
  final SignupConverter _signupConverter;
  final ConfirmConverter _confirmConverter;
  final LoginConverter _loginConverter;

  final LocationConverter _locationConverter;

  ServerApi(
      this._dioApi,
      this._tokensStorage,
      this._errorResultConverter,
      this._containerForListConverter,
      this._tokensConverter,
      this._signupConverter,
      this._confirmConverter,
      this._loginConverter,
      this._locationConverter
  );

  Future<Result<T>> _execRequest<T>({
    required JsonConverter? converter,
    required Future<Response> request,
    required bool isList
  }) async {
    try {
      Response response = await request;
      int? code = response.statusCode;
      if (code != null && code >= 200 && code < 300) {
        if (isList) {
          return SuccessResult(
              data: _containerForListConverter.fromJson(
                json: response.data,
                converter: converter!
              ) as T
          );
        } else {
          return SuccessResult(
              data: converter?.fromJson(response.data)
          );
        }
      } else {
        final ErrorResult error = _errorResultConverter.fromJson(
            response.data
        );
        return ErrorResult(
            description: error.description ?? unknownError,
            errors: error.errors
        );
      }
    } on TimeoutException {
      return ErrorResult(description: responseTimeoutError, errors: null);
    } on SocketException catch(e) {
      if (e.osError?.errorCode == 101) {
        return ErrorResult(description: noConnectionError, errors: null);
      } else {
        return ErrorResult(description: unknownError, errors: null);
      }
    } on Exception {
      return ErrorResult(description: unknownError, errors: null);
    }
  }

  Future<void> _saveTokens(SuccessResult<TokensModel> result) async {
    final tokens = (result).data;
    await _tokensStorage.setAccessToken(accessToken: tokens.access);
    await _tokensStorage.setRefreshToken(refreshToken: tokens.refresh);
  }





  Future<Result> signup(SignupModel signup) async {
    final result = await _execRequest(
        converter: null,
        request: _dioApi.post(
          '$url$signupMethod',
          data: _signupConverter.toJson(signup)
        ),
        isList: false
    );
    return result;
  }

  Future<Result> confirm(ConfirmModel confirm) async {
    final result = await _execRequest(
        converter: null,
        request: _dioApi.post(
            '$url$confirmMethod',
            data: _confirmConverter.toJson(confirm)
        ),
        isList: false
    );
    return result;
  }

  Future<Result<TokensModel>> login(LoginModel login) async {
    final result = await _execRequest<TokensModel>(
        converter: _tokensConverter,
        request: _dioApi.post(
            '$url$loginMethod',
            data: _loginConverter.toJson(login)
        ),
        isList: false
    );
    if (result is SuccessResult) {
      await _saveTokens(result as SuccessResult<TokensModel>);
    }
    return result;
  }





  Future<Result<ContainerForList<LocationModel>>> getMyLocations(int page, int pageSize) async {
    return await _execRequest(
        converter: _locationConverter,
        request: _dioApi.get(
          '$url/locations/me',
          queryParameters: {
            'page': page,
            'page_size': pageSize
          }
        ),
        isList: true
    );
  }

  Future<Result<LocationModel>> createLocation(LocationModel location) async {
    return await _execRequest(
        converter: _locationConverter,
        request: _dioApi.post(
            '$url/locations/me/create',
             data: _locationConverter.toJson(location)
        ),
        isList: false
    );
  }

  Future<Result> deleteLocation(int id) async {
    return await _execRequest(
        converter: null,
        request: _dioApi.delete(
          '$url/locations/me/$id/delete',
        ),
        isList: false
    );
  }
}