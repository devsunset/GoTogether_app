/// Post(Talk/Q&A) 목록·상세·생성·수정·삭제·댓글·카테고리 변경 API. Vue post 서비스와 동일.
import 'package:dio/dio.dart';
import 'package:gotogether/data/network/api/constant/endpoints.dart';
import 'package:gotogether/data/network/dio_client.dart';

class PostApi {
  final DioClient dioClient;

  PostApi({required this.dioClient});

  /// [body] 에 category (TALK | QA), keyword 포함
  Future<Response> getList(int page, int size, Map<String, dynamic>? body) async {
    return dioClient.post(
      Endpoints.postList(),
      queryParameters: {'page': page, 'size': size},
      data: body ?? {'category': 'TALK', 'keyword': null},
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

  /// Vue와 동일: Admin용 Post 유형(TALK↔QA) 변경
  Future<Response> changeCategory(int postId) async {
    return dioClient.put(Endpoints.postChangeCategory(postId));
  }
}
