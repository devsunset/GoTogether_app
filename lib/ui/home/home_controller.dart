import 'package:gotogether/data/models/home/home_model.dart';
import 'package:gotogether/data/repository/home_repository.dart';
import 'package:gotogether/data/di/service_locator.dart';

class HomeController {
  final homeRepository = getIt.get<HomeRepository>();

  Future<List<UserModel>> getHome() async {
    final users = await homeRepository.getHome();
    return users;
  }

}
