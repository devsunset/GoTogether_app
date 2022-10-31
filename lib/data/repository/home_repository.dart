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
      final data = (response as List)
          .map((e) => DataModel.fromJson(response))
          .toList();
      return data;
    } on DioError catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      throw errorMessage;
    }
  }
}
