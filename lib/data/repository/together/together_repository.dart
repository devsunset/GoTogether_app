import 'package:dio/dio.dart';
import 'package:gotogether/data/models/data_model.dart';
import 'package:gotogether/data/models/together/together_list_item.dart';
import 'package:gotogether/data/network/api/together/together_api.dart';
import 'package:gotogether/data/network/dio_exception.dart';

class TogetherRepository {
  final TogetherApi togetherApi;

  TogetherRepository(this.togetherApi);

  dynamic _extractData(Response response) {
    final body = response.data;
    if (body is Map && body.containsKey('data')) return body['data'];
    return body;
  }

  DataModel _toDataModel(Response response) {
    final body = response.data;
    if (body is Map<String, dynamic>) return DataModel.fromJson(body);
    return DataModel.fromJson({'data': body, 'status': response.statusCode});
  }

  Future<TogetherListPage> getList(int page, int size, {String? category, String? keyword}) async {
    try {
      final response = await togetherApi.getList(page, size, {'category': category ?? '', 'keyword': keyword ?? ''});
      final data = _extractData(response);
      return TogetherListPage.fromJson(data as Map<String, dynamic>);
    } on DioError catch (e) {
      throw DioExceptions.fromDioError(e).toString();
    }
  }

  Future<DataModel> get(int togetherId) async {
    try {
      final response = await togetherApi.get(togetherId);
      return _toDataModel(response);
    } on DioError catch (e) {
      throw DioExceptions.fromDioError(e).toString();
    }
  }

  Future<DataModel> create(Map<String, dynamic> data) async {
    try {
      final response = await togetherApi.create(data);
      return _toDataModel(response);
    } on DioError catch (e) {
      throw DioExceptions.fromDioError(e).toString();
    }
  }

  Future<DataModel> update(int togetherId, Map<String, dynamic> data) async {
    try {
      final response = await togetherApi.update(togetherId, data);
      return _toDataModel(response);
    } on DioError catch (e) {
      throw DioExceptions.fromDioError(e).toString();
    }
  }

  Future<void> delete(int togetherId) async {
    try {
      await togetherApi.delete(togetherId);
    } on DioError catch (e) {
      throw DioExceptions.fromDioError(e).toString();
    }
  }

  Future<List<dynamic>> getCommentList(int togetherId) async {
    try {
      final response = await togetherApi.getCommentList(togetherId);
      final data = _extractData(response);
      return data is List ? data : [];
    } on DioError catch (e) {
      throw DioExceptions.fromDioError(e).toString();
    }
  }

  Future<DataModel> createComment(Map<String, dynamic> data) async {
    try {
      final response = await togetherApi.createComment(data);
      return _toDataModel(response);
    } on DioError catch (e) {
      throw DioExceptions.fromDioError(e).toString();
    }
  }

  /// Together 댓글 삭제 (본인/관리자만)
  Future<void> deleteComment(int commentId) async {
    try {
      await togetherApi.deleteComment(commentId);
    } on DioError catch (e) {
      throw DioExceptions.fromDioError(e).toString();
    }
  }
}

