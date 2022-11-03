import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:gotogether/data/models/datat_model.dart';
import 'package:gotogether/data/network/dio_exception.dart';

import '../../network/api/auth/auth_api.dart';

class AuthRepository {
  final AuthApi authApi;

  AuthRepository(this.authApi);

  Future<DataModel> signIn(String username, String password) async {
    try {
      final response = await authApi.signIn(username, password);
      Map<String, dynamic> jsonData = jsonDecode(response.toString());
      return DataModel.fromJson(jsonData);
    } on DioError catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      throw errorMessage;
    }
  }
}
