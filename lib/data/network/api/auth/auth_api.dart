import 'package:dio/dio.dart';
import 'package:gotogether/data/network/api/constant/endpoints.dart';
import 'package:gotogether/data/network/dio_client.dart';

class AuthApi {
  final DioClient dioClient;

  AuthApi({required this.dioClient});

  Future<Response> signIn(String username, String password) async {
    try {
      final Map<String, dynamic> data = {
        'username': username,
        'password': password,
      };
      return await dioClient.post(Endpoints.signin, data: data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> signUp(String username, String nickname, String email, String password) async {
    try {
      final Map<String, dynamic> data = {
        'username': username,
        'nickname': nickname,
        'email': email,
        'password': password,
        if (email.isNotEmpty) 'role': ['user'],
      };
      return await dioClient.post(Endpoints.signup, data: data);
    } catch (e) {
      rethrow;
    }
  }
}
