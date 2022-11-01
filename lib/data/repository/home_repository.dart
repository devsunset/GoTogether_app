import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:gotogether/data/models/datat_model.dart';
import 'package:gotogether/data/network/api/home/home_api.dart';
import 'package:gotogether/data/network/dio_exception.dart';

class HomeRepository {
  final HomeApi homeApi;

  HomeRepository(this.homeApi);

  Future<DataModel> getHome() async {
    try {
      final response = await homeApi.getHomeApi();
      Map<String, dynamic> jsonData = jsonDecode(response.toString());
      return DataModel.fromJson(jsonData);
    } on DioError catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      throw errorMessage;
    }
  }
}
