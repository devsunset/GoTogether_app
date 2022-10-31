import 'package:dio/dio.dart';
import 'package:gotogether/data/network/api/home/home_api.dart';
import 'package:gotogether/data/network/dio_client.dart';
import 'package:gotogether/data/repository/home_repository.dart';
import 'package:gotogether/ui/home/home_controller.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> setup() async {
  getIt.registerSingleton(Dio());
  getIt.registerSingleton(DioClient(getIt<Dio>()));
  getIt.registerSingleton(HomeApi(dioClient: getIt<DioClient>()));
  getIt.registerSingleton(HomeRepository(getIt.get<HomeApi>()));

  getIt.registerSingleton(HomeController());
}
