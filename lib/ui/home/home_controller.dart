import 'package:gotogether/data/models/datat_model.dart';
import 'package:gotogether/data/repository/home_repository.dart';
import 'package:gotogether/data/di/service_locator.dart';

class HomeController {
  final homeRepository = getIt.get<HomeRepository>();

  Future<DataModel> getHome() async {
    final response = await homeRepository.getHome();
    return response;
  }

}
