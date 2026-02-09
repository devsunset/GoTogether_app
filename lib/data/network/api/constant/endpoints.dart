/// 백엔드 API 경로·타임아웃 상수
///
/// gotogether-backend 기준. baseUrl만 변경하면 다른 서버 연동 가능.
class Endpoints {
  Endpoints._();

  static const String baseUrl = "https://193.123.252.22:8282/api";
  static const int receiveTimeout = 30000;
  static const int connectionTimeout = 30000;

  // --- Auth ---
  static const String signin = '/auth/signin';
  static const String signup = '/auth/signup';
  static const String refreshtoken = '/auth/refreshtoken';
  static const String logout = '/auth/logout';

  // --- Common ---
  static const String home = '/common/home';

  // --- UserInfo ---
  static const String userinfo = '/userinfo/';
  static const String userinfoList = '/userinfo/list';

  // --- Together ---
  static const String together = '/together';
  static String togetherDetail(int id) => '/together/$id';
  static String togetherList() => '/together/list';
  static String togetherChangeCategory(int id) => '/together/changecategory/$id';

  // --- TogetherComment ---
  static String togetherCommentList(int togetherId) => '/togethercomment/list/$togetherId';
  static const String togetherComment = '/togethercomment/';
  static String togetherCommentDelete(int id) => '/togethercomment/$id';

  // --- Post ---
  static const String post = '/post';
  static String postDetail(int id) => '/post/$id';
  static String postList() => '/post/list';
  static String postChangeCategory(int id) => '/post/changecategory/$id';

  // --- PostComment ---
  static String postCommentList(int postId) => '/postcomment/list/$postId';
  static const String postComment = '/postcomment/';
  static String postCommentDelete(int id) => '/postcomment/$id';

  // --- Memo ---
  static const String memo = '/memo';
  static String memoUpdateread(int memoId) => '/memo/updateread/$memoId';
  static const String memoNewreceive = '/memo/newreceive';
  static const String memoReceivelist = '/memo/receivelist';
  static const String memoSendlist = '/memo/sendlist';
  static const String memoDeletereceive = '/memo/deletereceive';
  static const String memoDeletesend = '/memo/deletesend';
}
