import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:gotogether/data/network/api/auth/auth_api.dart';
import 'package:gotogether/data/network/api/home/home_api.dart';
import 'package:gotogether/data/network/dio_client.dart';
import 'package:gotogether/data/repository/home/home_repository.dart';
import 'package:gotogether/ui/home/home_controller.dart';
import 'package:gotogether/ui/sign/auth_controller.dart';

import '../repository/auth/auth_repository.dart';

final getIt = GetIt.instance;

Future<void> setup() async {
  getIt.registerSingleton(Dio());
  getIt.registerSingleton(DioClient(getIt<Dio>()));

  getIt.registerSingleton(AuthApi(dioClient: getIt<DioClient>()));
  getIt.registerSingleton(AuthRepository(getIt.get<AuthApi>()));

  getIt.registerSingleton(HomeApi(dioClient: getIt<DioClient>()));
  getIt.registerSingleton(HomeRepository(getIt.get<HomeApi>()));

  getIt.registerSingleton(AuthController());
  getIt.registerSingleton(HomeController());
}
