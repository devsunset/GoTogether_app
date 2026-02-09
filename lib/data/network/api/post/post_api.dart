import 'package:dio/dio.dart';
import 'package:gotogether/data/network/api/constant/endpoints.dart';
import 'package:gotogether/data/network/dio_client.dart';

class PostApi {
  final DioClient dioClient;

  PostApi({required this.dioClient});

  Future<Response> getList(int page, int size, Map<String, dynamic>? body) async {
    return dioClient.post(
      Endpoints.postList(),
      queryParameters: {'page': page, 'size': size},
      data: body ?? {'category': null, 'keyword': null},
    );
  }

  Future<Response> get(int postId) async {
    return dioClient.get(Endpoints.postDetail(postId));
  }

  Future<Response> create(Map<String, dynamic> data) async {
    return dioClient.post(Endpoints.post, data: data);
  }

  Future<Response> update(int postId, Map<String, dynamic> data) async {
    return dioClient.put(Endpoints.postDetail(postId), data: data);
  }

  Future<Response> delete(int postId) async {
    return dioClient.delete(Endpoints.postDetail(postId));
  }

  Future<Response> getCommentList(int postId) async {
    return dioClient.get(Endpoints.postCommentList(postId));
  }

  Future<Response> createComment(Map<String, dynamic> data) async {
    return dioClient.post(Endpoints.postComment, data: data);
  }

  Future<Response> deleteComment(int commentId) async {
    return dioClient.delete(Endpoints.postCommentDelete(commentId));
  }
}
