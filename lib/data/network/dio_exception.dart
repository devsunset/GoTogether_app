import 'package:dio/dio.dart';

class DioExceptions implements Exception {
  late String message;

  DioExceptions.fromDioError(DioError dioError) {
    switch (dioError.type) {
      case DioErrorType.cancel:
        message = "Request to API server was cancelled";
        break;
      case DioErrorType.connectTimeout:
        message = "Connection timeout with API server";
        break;
      case DioErrorType.receiveTimeout:
        message = "Receive timeout in connection with API server";
        break;
      case DioErrorType.response:
        message = _handleError(
          dioError.response?.statusCode,
          dioError.response?.data,
        );
        break;
      case DioErrorType.sendTimeout:
        message = "Send timeout in connection with API server";
        break;
      case DioErrorType.other:
        if (dioError.message.contains("SocketException")) {
          message = 'No Internet';
          break;
        }
        message = "Unexpected error occurred";
        break;
      default:
        message = "Something went wrong";
        break;
    }
  }

  String _handleError(int? statusCode, dynamic error) {
    String? serverMessage;
    if (error is Map) {
      serverMessage = error['message']?.toString() ?? error['description']?.toString() ?? error['error']?.toString();
    }
    switch (statusCode) {
      case 400:
        return serverMessage ?? 'Bad request';
      case 401:
        return serverMessage ?? 'Unauthorized';
      case 403:
        return serverMessage ?? 'Forbidden';
      case 404:
        return serverMessage ?? 'Not found';
      case 500:
        return serverMessage ?? 'Internal server error';
      case 502:
        return serverMessage ?? 'Bad gateway';
      default:
        return serverMessage ?? 'Oops something went wrong';
    }
  }

  @override
  String toString() => message;
}
