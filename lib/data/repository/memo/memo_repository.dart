/// 쪽지 수신/발신 목록·읽음 처리·삭제·전송. Vue memo 서비스와 동일.
import 'package:dio/dio.dart';
import 'package:gotogether/data/models/datat_model.dart';
import 'package:gotogether/data/models/memo/memo_list_item.dart';
import 'package:gotogether/data/network/api/memo/memo_api.dart';
import 'package:gotogether/data/network/dio_exception.dart';

class MemoRepository {
  final MemoApi memoApi;

  MemoRepository(this.memoApi);

  /// 백엔드 반환: { data: { MEMO: Long } }
  Future<int> getNewReceiveCount() async {
    try {
      final response = await memoApi.getNewReceive();
      final data = _extractData(response);
      if (data is Map && data['MEMO'] != null) {
        final v = data['MEMO'];
        return v is int ? v : (v is num ? v.toInt() : 0);
      }
      return 0;
    } on DioError catch (e) {
      throw DioExceptions.fromDioError(e).toString();
    }
  }

  Future<MemoListPage> getReceiveList(int page, int size) async {
    try {
      final response = await memoApi.getReceiveList(page, size);
      final data = _extractData(response);
      if (data is! Map<String, dynamic>) return _emptyMemoPage();
      return MemoListPage.fromJson(data);
    } on DioError catch (e) {
      throw DioExceptions.fromDioError(e).toString();
    }
  }

  Future<MemoListPage> getSendList(int page, int size) async {
    try {
      final response = await memoApi.getSendList(page, size);
      final data = _extractData(response);
      if (data is! Map<String, dynamic>) return _emptyMemoPage();
      return MemoListPage.fromJson(data);
    } on DioError catch (e) {
      throw DioExceptions.fromDioError(e).toString();
    }
  }

  static MemoListPage _emptyMemoPage() => MemoListPage(
    content: [],
    totalPages: 0,
    totalElements: 0,
    number: 0,
    size: 10,
  );

  Future<DataModel> send(String memo, String receiver) async {
    try {
      final response = await memoApi.send({'memo': memo, 'receiver': receiver});
      return _toDataModel(response);
    } on DioError catch (e) {
      throw DioExceptions.fromDioError(e).toString();
    }
  }

  Future<void> updateRead(int memoId) async {
    try {
      await memoApi.updateRead(memoId);
    } on DioError catch (e) {
      throw DioExceptions.fromDioError(e).toString();
    }
  }

  Future<void> deleteReceive(List<int> ids) async {
    try {
      await memoApi.deleteReceive(ids);
    } on DioError catch (e) {
      throw DioExceptions.fromDioError(e).toString();
    }
  }

  Future<void> deleteSend(List<int> ids) async {
    try {
      await memoApi.deleteSend(ids);
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
