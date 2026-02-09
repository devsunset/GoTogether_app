import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/adapter.dart';

void setupDioHttpClient(Dio dio) {
  (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
      (HttpClient client) {
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return client;
  };
}
