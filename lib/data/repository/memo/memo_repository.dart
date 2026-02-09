import 'package:dio/dio.dart';
import 'package:gotogether/data/models/datat_model.dart';
import 'package:gotogether/data/models/memo/memo_list_item.dart';
import 'package:gotogether/data/network/api/memo/memo_api.dart';
import 'package:gotogether/data/network/dio_exception.dart';

class MemoRepository {
  final MemoApi memoApi;

  MemoRepository(this.memoApi);

  Future<int> getNewReceiveCount() async {
    try {
      final response = await memoApi.getNewReceive();
      final data = _extractData(response);
      return data is int ? data : 0;
    } on DioError catch (e) {
      throw DioExceptions.fromDioError(e).toString();
    }
  }

  Future<MemoListPage> getReceiveList(int page, int size) async {
    try {
      final response = await memoApi.getReceiveList(page, size);
      final data = _extractData(response);
      return MemoListPage.fromJson(data as Map<String, dynamic>);
    } on DioError catch (e) {
      throw DioExceptions.fromDioError(e).toString();
    }
  }

  Future<MemoListPage> getSendList(int page, int size) async {
    try {
      final response = await memoApi.getSendList(page, size);
      final data = _extractData(response);
      return MemoListPage.fromJson(data as Map<String, dynamic>);
    } on DioError catch (e) {
      throw DioExceptions.fromDioError(e).toString();
    }
  }

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
