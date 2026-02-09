/// Post(Talk/Q&A) 목록·상세·CRUD·댓글·changeCategory. Vue post 서비스와 동일.
import 'package:dio/dio.dart';
import 'package:gotogether/data/models/data_model.dart';
import 'package:gotogether/data/models/post/post_list_item.dart';
import 'package:gotogether/data/network/api/post/post_api.dart';
import 'package:gotogether/data/network/dio_exception.dart';

class PostRepository {
  final PostApi postApi;

  PostRepository(this.postApi);

  Future<PostListPage> getList(int page, int size, {String? category, String? keyword}) async {
    try {
      final response = await postApi.getList(page, size, {'category': category ?? '', 'keyword': keyword ?? ''});
      final data = _extractData(response);
      if (data is! Map<String, dynamic>) return _emptyPostPage();
      return PostListPage.fromJson(data);
    } on DioError catch (e) {
      throw DioExceptions.fromDioError(e).toString();
    }
  }

  static PostListPage _emptyPostPage() => PostListPage(
    content: [],
    totalPages: 0,
    totalElements: 0,
    number: 0,
    size: 10,
  );

  Future<DataModel> get(int postId) async {
    try {
      final response = await postApi.get(postId);
      return _toDataModel(response);
    } on DioError catch (e) {
      throw DioExceptions.fromDioError(e).toString();
    }
  }

  Future<DataModel> create(Map<String, dynamic> data) async {
    try {
      final response = await postApi.create(data);
      return _toDataModel(response);
    } on DioError catch (e) {
      throw DioExceptions.fromDioError(e).toString();
    }
  }

  Future<DataModel> update(int postId, Map<String, dynamic> data) async {
    try {
      final response = await postApi.update(postId, data);
      return _toDataModel(response);
    } on DioError catch (e) {
      throw DioExceptions.fromDioError(e).toString();
    }
  }

  Future<void> delete(int postId) async {
    try {
      await postApi.delete(postId);
    } on DioError catch (e) {
      throw DioExceptions.fromDioError(e).toString();
    }
  }

  /// Vue와 동일: Admin용 Post 유형(TALK↔QA) 변경
  Future<DataModel> changeCategory(int postId) async {
    try {
      final response = await postApi.changeCategory(postId);
      return _toDataModel(response);
    } on DioError catch (e) {
      throw DioExceptions.fromDioError(e).toString();
    }
  }

  Future<List<dynamic>> getCommentList(int postId) async {
    try {
      final response = await postApi.getCommentList(postId);
      final data = _extractData(response);
      return data is List ? data : [];
    } on DioError catch (e) {
      throw DioExceptions.fromDioError(e).toString();
    }
  }

  Future<DataModel> createComment(Map<String, dynamic> data) async {
    try {
      final response = await postApi.createComment(data);
      return _toDataModel(response);
    } on DioError catch (e) {
      throw DioExceptions.fromDioError(e).toString();
    }
  }

  Future<void> deleteComment(int commentId) async {
    try {
      await postApi.deleteComment(commentId);
    } on DioError catch (e) {
      throw DioExceptions.fromDioError(e).toString();
    }
  }

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
}
