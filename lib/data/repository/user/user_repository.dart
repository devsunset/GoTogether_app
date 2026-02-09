/// 회원 목록·상세(멤버 화면). Vue userinfo 서비스와 동일.
import 'package:dio/dio.dart';
import 'package:gotogether/data/models/datat_model.dart';
import 'package:gotogether/data/models/user/user_info_item.dart';
import 'package:gotogether/data/network/api/user/user_api.dart';
import 'package:gotogether/data/network/dio_exception.dart';

class UserRepository {
  final UserApi userApi;

  UserRepository(this.userApi);

  Future<DataModel> getUserInfo() async {
    try {
      final response = await userApi.getUserInfoApi();
      final body = response.data;
      if (body is Map<String, dynamic>) return DataModel.fromJson(body);
      return DataModel.fromJson({'data': body, 'status': response.statusCode});
    } on DioError catch (e) {
      throw DioExceptions.fromDioError(e).toString();
    }
  }

  Future<UserInfoListPage> getUserInfoList(int page, int size, {String? keyword}) async {
    try {
      final response = await userApi.getUserInfoList(page, size, {'category': null, 'keyword': keyword});
      final body = response.data;
      final data = body is Map && body.containsKey('data') ? body['data'] : body;
      return UserInfoListPage.fromJson(data as Map<String, dynamic>);
    } on DioError catch (e) {
      throw DioExceptions.fromDioError(e).toString();
    }
  }

  Future<DataModel> saveUserInfo(Map<String, dynamic> data) async {
    try {
      final response = await userApi.saveUserInfo(data);
      final body = response.data;
      if (body is Map<String, dynamic>) return DataModel.fromJson(body);
      return DataModel.fromJson({'data': body, 'status': response.statusCode});
    } on DioError catch (e) {
      throw DioExceptions.fromDioError(e).toString();
    }
  }
}
