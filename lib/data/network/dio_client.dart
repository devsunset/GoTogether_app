import 'package:dio/dio.dart';
import 'package:gotogether/data/network/api/constant/endpoints.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DioClient {
  final Dio _dio;

  DioClient(this._dio) {
    _dio
      ..options.baseUrl = Endpoints.baseUrl
      ..options.connectTimeout = Endpoints.connectionTimeout
      ..options.receiveTimeout = Endpoints.receiveTimeout
      ..options.responseType = ResponseType.json
      ..interceptors.add(LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
      ));

    final storage = new FlutterSecureStorage();
    // _dio.interceptors.clear();

    _dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) async {
      // 기기에 저장된 AccessToken 로드
      // To-Do login token save
      await storage.write(key: 'ACCESS_TOKEN', value: 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJkZXZzdW5zZXQiLCJpYXQiOjE2Njc0NTA1NDQsImV4cCI6MTY2NzUzNjk0NH0.BN-fIH5ggqX2xmuu09GdsOPm7-yhkUuUlJX6dO291htxoC5UyrGoIj_YrK_8bYJa34DdFnaWmFcTfyyZBdQJNw');
      final accessToken = await storage.read(key: 'ACCESS_TOKEN');
      options.headers['Authorization'] = 'Bearer $accessToken';
      return handler.next(options);
    }, onError: (error, handler) async {
      // 인증 오류가 발생했을 경우: AccessToken의 만료
      if (error.response?.statusCode == 401) {
        // 기기에 저장된 AccessToken과 RefreshToken 로드
        final accessToken = await storage.read(key: 'ACCESS_TOKEN');
        final refreshToken = await storage.read(key: 'REFRESH_TOKEN');

        // 토큰 갱신 요청을 담당할 dio 객체 구현 후 그에 따른 interceptor 정의
        var refreshDio = Dio();
            refreshDio
              ..options.baseUrl = Endpoints.baseUrl
              ..options.connectTimeout = Endpoints.connectionTimeout
              ..options.receiveTimeout = Endpoints.receiveTimeout
              ..options.responseType = ResponseType.json
              ..interceptors.add(LogInterceptor(
              request: true,
              requestHeader: true,
              requestBody: true,
              responseHeader: true,
              responseBody: true,
              ));

        // refreshDio.interceptors.clear();

        refreshDio.interceptors
            .add(InterceptorsWrapper(onError: (error, handler) async {
          // 다시 인증 오류가 발생했을 경우: RefreshToken의 만료
          if (error.response?.statusCode == 401) {
            // 기기의 자동 로그인 정보 삭제
            await storage.deleteAll();
            // . . .
            // 로그인 만료 dialog 발생 후 로그인 페이지로 이동
            // . . .
          }
          return handler.next(error);
        }));

        // 토큰 갱신 API 요청 시 AccessToken(만료), RefreshToken 포함
        // refreshDio.options.headers['Authorization'] = 'Bearer $accessToken';
        // refreshDio.options.headers['Refresh'] = 'Bearer $refreshToken';

        // 토큰 갱신 API 요청
        final refreshResponse = await refreshDio.get('/auth/refreshtoken');

        // response로부터 새로 갱신된 AccessToken과 RefreshToken 파싱
        final newAccessToken = ''; //refreshResponse.data.data;
        // final newRefreshToken = '';
        // 기기에 저장된 AccessToken과 RefreshToken 갱신
        await storage.write(key: 'ACCESS_TOKEN', value: newAccessToken);
        // await storage.write(key: 'REFRESH_TOKEN', value: newRefreshToken);

        // AccessToken의 만료로 수행하지 못했던 API 요청에 담겼던 AccessToken 갱신
        error.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

        // 수행하지 못했던 API 요청 복사본 생성
        final clonedRequest = await _dio.request(error.requestOptions.path,
            options: Options(
                method: error.requestOptions.method,
                headers: error.requestOptions.headers),
            data: error.requestOptions.data,
            queryParameters: error.requestOptions.queryParameters);

        // API 복사본으로 재요청
        return handler.resolve(clonedRequest);
      }

      return handler.next(error);
    }));
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

  Future<dynamic> delete(
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
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}


