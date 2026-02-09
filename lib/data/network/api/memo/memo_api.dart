import 'package:dio/dio.dart';
import 'package:gotogether/data/network/api/constant/endpoints.dart';
import 'package:gotogether/data/network/dio_client.dart';

class MemoApi {
  final DioClient dioClient;

  MemoApi({required this.dioClient});

  Future<Response> getNewReceive() async {
    return dioClient.get(Endpoints.memoNewreceive);
  }

  Future<Response> getReceiveList(int page, int size) async {
    return dioClient.get(
      Endpoints.memoReceivelist,
      queryParameters: {'page': page, 'size': size},
    );
  }

  Future<Response> getSendList(int page, int size) async {
    return dioClient.get(
      Endpoints.memoSendlist,
      queryParameters: {'page': page, 'size': size},
    );
  }

  /// Vue: api.post("/memo/", ...)
  Future<Response> send(Map<String, dynamic> data) async {
    return dioClient.post(Endpoints.memoPost, data: data);
  }

  Future<Response> updateRead(int memoId) async {
    return dioClient.post(Endpoints.memoUpdateread(memoId));
  }

  Future<Response> deleteReceive(List<int> ids) async {
    return dioClient.delete(
      Endpoints.memoDeletereceive,
      data: {'idSeparatorValues': ids.join(',')},
    );
  }

  Future<Response> deleteSend(List<int> ids) async {
    return dioClient.delete(
      Endpoints.memoDeletesend,
      data: {'idSeparatorValues': ids.join(',')},
    );
  }
}
