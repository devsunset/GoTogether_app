class Endpoints {
  Endpoints._();

  // base url
  static const String baseUrl = "http://193.123.252.22:8282/api";

  // receiveTimeout
  static const int receiveTimeout = 30000;

  // connectTimeout
  static const int connectionTimeout = 30000;

  static const String signin = '/auth/signin';

  static const String refreshtoken = '/auth/refreshtoken';

  static const String home = '/common/home';

  static const String userinfo = '/userinfo/';
}
