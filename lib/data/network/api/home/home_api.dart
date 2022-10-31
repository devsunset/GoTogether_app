import 'package:dio/dio.dart';
import 'package:gotogether/data/network/api/constant/endpoints.dart';
import 'package:gotogether/data/network/dio_client.dart';

class HomeApi {
  final DioClient dioClient;

  HomeApi({required this.dioClient});

  Future<Response> getHomeApi() async {
    try {
      final Response response = await dioClient.get(Endpoints.home);
      return response;
    } catch (e) {
      rethrow;
    }
  }

}
