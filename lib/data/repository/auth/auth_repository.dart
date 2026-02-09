import 'package:dio/dio.dart';
import 'package:gotogether/data/models/data_model.dart';
import 'package:gotogether/data/network/dio_exception.dart';

import '../../network/api/auth/auth_api.dart';

class AuthRepository {
  final AuthApi authApi;

  AuthRepository(this.authApi);

  Future<DataModel> signIn(String username, String password) async {
    try {
      final response = await authApi.signIn(username, password);
      final body = response.data;
      if (body is Map<String, dynamic>) return DataModel.fromJson(body);
      return DataModel.fromJson({'data': body, 'status': response.statusCode});
    } on DioError catch (e) {
      throw DioExceptions.fromDioError(e).toString();
    }
  }

  Future<DataModel> signUp(String username, String nickname, String email, String password) async {
    try {
      final response = await authApi.signUp(username, nickname, email, password);
      final body = response.data;
      if (body is Map<String, dynamic>) return DataModel.fromJson(body);
      return DataModel.fromJson({'data': body, 'status': response.statusCode});
    } on DioError catch (e) {
      throw DioExceptions.fromDioError(e).toString();
    }
  }
}
