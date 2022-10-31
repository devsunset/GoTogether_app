import 'package:dio/dio.dart';
import 'package:gotogether/data/models/home/home_model.dart';
import 'package:gotogether/data/network/api/home/home_api.dart';
import 'package:gotogether/data/network/dio_exception.dart';

class HomeRepository {
  final HomeApi homeApi;

  HomeRepository(this.homeApi);

  Future<List<UserModel>> getHome() async {
    try {
      final response = await homeApi.getHomeApi();
      final users = (response.data['data'] as List)
          .map((e) => UserModel.fromJson(e))
          .toList();
      return users;
    } on DioError catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      throw errorMessage;
    }
  }
}
