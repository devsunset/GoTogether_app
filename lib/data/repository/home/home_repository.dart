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
      final body = response.data;
      if (body is Map<String, dynamic>) return DataModel.fromJson(body);
      return DataModel.fromJson({'data': body, 'status': response.statusCode});
    } on DioError catch (e) {
      throw DioExceptions.fromDioError(e).toString();
    }
  }
}
