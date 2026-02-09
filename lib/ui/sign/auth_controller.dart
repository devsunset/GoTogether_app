import 'package:gotogether/data/di/service_locator.dart';
import 'package:gotogether/data/models/data_model.dart';

import '../../data/repository/auth/auth_repository.dart';

class AuthController {
  final authRepository = getIt.get<AuthRepository>();

  Future<DataModel> singIn(String username, String password) async {
    return authRepository.signIn(username, password);
  }

  Future<DataModel> signUp(String username, String nickname, String email, String password) async {
    return authRepository.signUp(username, nickname, email, password);
  }
}
