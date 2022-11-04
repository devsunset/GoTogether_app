import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:gotogether/data/models/datat_model.dart';
import 'package:gotogether/data/network/api/user/user_api.dart';
import 'package:gotogether/data/network/dio_exception.dart';

class UserRepository {
  final UserApi userApi;

  UserRepository(this.userApi);

  Future<DataModel> getUserInfo() async {
    try {
      final response = await userApi.getUserInfoApi();
      Map<String, dynamic> jsonData = jsonDecode(response.toString());
      return DataModel.fromJson(jsonData);
    } on DioError catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      throw errorMessage;
    }
  }
}
