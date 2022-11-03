import 'package:gotogether/data/di/service_locator.dart';
import 'package:gotogether/data/models/datat_model.dart';

import '../../data/repository/auth/auth_repository.dart';

class AuthController {
  final authRepository = getIt.get<AuthRepository>();

  Future<DataModel> singIn(String username, String password) async {
    final response = await authRepository.signIn(username, password);
    return response;
  }
}
