/// Dio 기반 HTTP 클라이언트
///
/// - JWT: 요청 시 Authorization 헤더 자동 첨부
/// - 401 시 refresh token으로 갱신 후 원래 요청 1회 재시도
/// - 웹 빌드: LogInterceptor 비활성화 (브라우저 fetch와 Future 충돌 방지)
/// - 플랫폼별: IO에서는 SSL 검증 무시, 웹에서는 브라우저 기본 사용
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gotogether/data/network/api/constant/endpoints.dart';
import 'package:gotogether/data/network/dio_client_stub.dart'
    if (dart.library.io) 'dio_client_io.dart' as platform;

class DioClient {
  final Dio _dio;

  DioClient(this._dio) {
    _dio
      ..options.baseUrl = Endpoints.baseUrl
      ..options.connectTimeout = Endpoints.connectionTimeout
      ..options.receiveTimeout = Endpoints.receiveTimeout
      ..options.responseType = ResponseType.json;

    // 웹에서는 LogInterceptor가 브라우저 fetch와 충돌해 "Future already completed" 발생할 수 있어 비활성화
    if (!kIsWeb) {
      _dio.interceptors.add(LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
      ));
    }

    platform.setupDioHttpClient(_dio);

    final storage = FlutterSecureStorage();

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final accessToken = await storage.read(key: 'ACCESS_TOKEN');
        options.headers['Authorization'] = 'Bearer $accessToken';
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode != 401) {
          return handler.next(error);
        }

        final refreshToken = await storage.read(key: 'REFRESH_TOKEN');
        if (refreshToken == null || refreshToken.isEmpty) {
          return handler.next(error);
        }

        try {
          var refreshDio = Dio();
          refreshDio
            ..options.baseUrl = Endpoints.baseUrl
            ..options.connectTimeout = Endpoints.connectionTimeout
            ..options.receiveTimeout = Endpoints.receiveTimeout
            ..options.responseType = ResponseType.json;

          refreshDio.interceptors.add(InterceptorsWrapper(
            onError: (err, h) async {
              if (err.response?.statusCode == 401) {
                await storage.deleteAll();
                showToast("LogIn Token Invalid.");
              }
              return h.next(err);
            },
          ));

          final refreshResponse = await refreshDio.post(
            Endpoints.refreshtoken,
            data: <String, dynamic>{'refreshToken': refreshToken},
          );

          final responseData = refreshResponse.data;
          final payload = responseData is Map && responseData.containsKey('data')
              ? responseData['data']
              : responseData;
          final newAccessToken = payload is Map && payload.containsKey('token')
              ? payload['token']?.toString() ?? ''
              : '';
          final newRefreshToken = payload is Map && payload.containsKey('refreshToken')
              ? payload['refreshToken']?.toString()
              : null;

          if (newAccessToken.isEmpty) {
            return handler.next(error);
          }

          await storage.write(key: 'ACCESS_TOKEN', value: newAccessToken);
          if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
            await storage.write(key: 'REFRESH_TOKEN', value: newRefreshToken);
          }

          error.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

          // 재요청 시 _dio.request 사용 (interceptor 체인 통과). handler.resolve는 한 번만 호출
          final clonedResponse = await _dio.request(
            error.requestOptions.path,
            options: Options(
              method: error.requestOptions.method,
              headers: error.requestOptions.headers,
            ),
            data: error.requestOptions.data,
            queryParameters: error.requestOptions.queryParameters,
          );

          return handler.resolve(clonedResponse);
        } catch (_) {
          return handler.next(error);
        }
      },
    ));
  }

  Future<Response> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final Response response = await _dio.get(
        url,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> post(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final Response response = await _dio.post(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> put(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final Response response = await _dio.put(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> delete(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final Response response = await _dio.delete(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  void showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM_RIGHT,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}
