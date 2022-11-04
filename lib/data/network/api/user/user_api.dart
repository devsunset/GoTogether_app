import 'package:dio/dio.dart';
import 'package:gotogether/data/network/api/constant/endpoints.dart';
import 'package:gotogether/data/network/dio_client.dart';

class UserApi {
  final DioClient dioClient;

  UserApi({required this.dioClient});

  Future<Response> getUserInfoApi() async {
    try {
      final Response response = await dioClient.get(Endpoints.userinfo);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
