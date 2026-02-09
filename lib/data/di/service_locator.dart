/// 의존성 주입 (GetIt)
///
/// Dio·DioClient·API·Repository·Controller 싱글톤 등록.
/// main()에서 setup() 호출 후 getIt<T>()로 사용.
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:gotogether/data/network/api/auth/auth_api.dart';
import 'package:gotogether/data/network/api/home/home_api.dart';
import 'package:gotogether/data/network/api/memo/memo_api.dart';
import 'package:gotogether/data/network/api/post/post_api.dart';
import 'package:gotogether/data/network/api/together/together_api.dart';
import 'package:gotogether/data/network/api/user/user_api.dart';
import 'package:gotogether/data/network/dio_client.dart';
import 'package:gotogether/data/repository/auth/auth_repository.dart';
import 'package:gotogether/data/repository/home/home_repository.dart';
import 'package:gotogether/data/repository/memo/memo_repository.dart';
import 'package:gotogether/data/repository/post/post_repository.dart';
import 'package:gotogether/data/repository/together/together_repository.dart';
import 'package:gotogether/data/repository/user/user_repository.dart';
import 'package:gotogether/ui/home/home_controller.dart';
import 'package:gotogether/ui/profile/user_controller.dart';
import 'package:gotogether/ui/sign/auth_controller.dart';

final getIt = GetIt.instance;

Future<void> setup() async {
  getIt.registerSingleton(Dio());
  getIt.registerSingleton(DioClient(getIt<Dio>()));

  getIt.registerSingleton(AuthApi(dioClient: getIt<DioClient>()));
  getIt.registerSingleton(AuthRepository(getIt.get<AuthApi>()));

  getIt.registerSingleton(HomeApi(dioClient: getIt<DioClient>()));
  getIt.registerSingleton(HomeRepository(getIt.get<HomeApi>()));

  getIt.registerSingleton(UserApi(dioClient: getIt<DioClient>()));
  getIt.registerSingleton(UserRepository(getIt.get<UserApi>()));

  getIt.registerSingleton(TogetherApi(dioClient: getIt<DioClient>()));
  getIt.registerSingleton(TogetherRepository(getIt.get<TogetherApi>()));

  getIt.registerSingleton(PostApi(dioClient: getIt<DioClient>()));
  getIt.registerSingleton(PostRepository(getIt.get<PostApi>()));

  getIt.registerSingleton(MemoApi(dioClient: getIt<DioClient>()));
  getIt.registerSingleton(MemoRepository(getIt.get<MemoApi>()));

  getIt.registerSingleton(AuthController());
  getIt.registerSingleton(HomeController());
  getIt.registerSingleton(UserController());
}
