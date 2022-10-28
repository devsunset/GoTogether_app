import 'package:gotogether/data/models/user/new_user_model.dart';
import 'package:gotogether/data/models/user/user_model.dart';
import 'package:gotogether/data/repository/user_repository.dart';
import 'package:gotogether/data/di/service_locator.dart';
import 'package:flutter/material.dart';

class HomeController {
  final userRepository = getIt.get<UserRepository>();

  final nameController = TextEditingController();
  final jobController = TextEditingController();

  final List<NewUser> newUsers = [];

  Future<List<UserModel>> getUsers() async {
    final users = await userRepository.getUsersRequested();
    return users;
  }

  Future<NewUser> addNewUser() async {
    final newlyAddedUser = await userRepository.addNewUserRequested(
      nameController.text,
      jobController.text,
    );
    newUsers.add(newlyAddedUser);
    return newlyAddedUser;
  }

  Future<NewUser> updateUser(int id, String name, String job) async {
    final updatedUser = await userRepository.updateUserRequested(
      id,
      name,
      job,
    );
    newUsers[id] = updatedUser;
    return updatedUser;
  }

  Future<void> deleteNewUser(int id) async {
    await userRepository.deleteNewUserRequested(id);
    newUsers.removeAt(id);
  }
}
