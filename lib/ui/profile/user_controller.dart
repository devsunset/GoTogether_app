import 'package:gotogether/data/di/service_locator.dart';
import 'package:gotogether/data/models/datat_model.dart';

import '../../data/repository/user/user_repository.dart';

class UserController {
  final userRepository = getIt.get<UserRepository>();

  Future<DataModel> getUserInfo() async {
    final response = await userRepository.getUserInfo();
    return response;
  }
}
