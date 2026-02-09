import 'package:dio/dio.dart';
import 'package:gotogether/data/network/api/constant/endpoints.dart';
import 'package:gotogether/data/network/dio_client.dart';

class TogetherApi {
  final DioClient dioClient;

  TogetherApi({required this.dioClient});

  Future<Response> getList(int page, int size, Map<String, dynamic>? body) async {
    return dioClient.post(
      Endpoints.togetherList(),
      queryParameters: {'page': page, 'size': size},
      data: body ?? {'category': null, 'keyword': null},
    );
  }

  Future<Response> get(int togetherId) async {
    return dioClient.get(Endpoints.togetherDetail(togetherId));
  }

  Future<Response> create(Map<String, dynamic> data) async {
    return dioClient.post(Endpoints.together, data: data);
  }

  Future<Response> update(int togetherId, Map<String, dynamic> data) async {
    return dioClient.put(Endpoints.togetherDetail(togetherId), data: data);
  }

  Future<Response> delete(int togetherId) async {
    return dioClient.delete(Endpoints.togetherDetail(togetherId));
  }

  Future<Response> getCommentList(int togetherId) async {
    return dioClient.get(Endpoints.togetherCommentList(togetherId));
  }

  Future<Response> createComment(Map<String, dynamic> data) async {
    return dioClient.post(Endpoints.togetherComment, data: data);
  }

  Future<Response> deleteComment(int commentId) async {
    return dioClient.delete(Endpoints.togetherCommentDelete(commentId));
  }
}
