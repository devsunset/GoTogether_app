import 'package:gotogether/data/di/service_locator.dart';
import 'package:gotogether/data/models/data_model.dart';
import 'package:gotogether/data/repository/home/home_repository.dart';

class HomeController {
  final homeRepository = getIt.get<HomeRepository>();

  Future<DataModel> getHome() async {
    final response = await homeRepository.getHome();
    return response;
  }
}
