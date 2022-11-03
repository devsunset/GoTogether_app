import 'package:dio/dio.dart';
import 'package:gotogether/data/network/api/constant/endpoints.dart';
import 'package:gotogether/data/network/dio_client.dart';

class AuthApi {
  final DioClient dioClient;

  AuthApi({required this.dioClient});

  Future<Response> signIn(String username, String password) async {
    try {
      Map<String, dynamic>? data = Map<String, dynamic>();
      data['username'] = username;
      data['password'] = password;
      final Response response =
          await dioClient.post(Endpoints.signin, data: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
