import 'package:dio/dio.dart';
import 'package:gotogether/data/network/api/constant/endpoints.dart';
import 'package:gotogether/data/network/dio_client.dart';

class UserApi {
  final DioClient dioClient;

  UserApi({required this.dioClient});

  Future<Response> getUserInfoApi() async {
    return dioClient.get(Endpoints.userinfo);
  }

  Future<Response> getUserInfoList(int page, int size, Map<String, dynamic>? body) async {
    return dioClient.post(
      Endpoints.userinfoList,
      queryParameters: {'page': page, 'size': size},
      data: body ?? {'category': null, 'keyword': ''},
    );
  }

  Future<Response> saveUserInfo(Map<String, dynamic> data) async {
    return dioClient.post(Endpoints.userinfo, data: data);
  }
}
