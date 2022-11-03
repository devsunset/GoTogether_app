import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gotogether/ui/sign/register.dart';

import '../../data/di/service_locator.dart';
import '../../data/models/datat_model.dart';
import 'auth_controller.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  bool _isPasswordVisible = false;
  String username = '';
  String password = '';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Center(
          child: Card(
            elevation: 8,
            child: Container(
              padding: const EdgeInsets.all(32.0),
              constraints: const BoxConstraints(maxWidth: 350),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/userImage.png'),
                    _gap(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "GoTogether",
                        style: Theme.of(context).textTheme.headline5,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        "Enter your userid and password to continue.",
                        style: Theme.of(context).textTheme.caption,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    _gap(),
                    TextFormField(
                      validator: (value) {
                        // add email validation
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }

                        if (value.length < 3) {
                          return 'userid must be at least 3 characters';
                        }
                        username = value;
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'userid',
                        hintText: 'Enter your userid',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    _gap(),
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }

                        if (value.length < 6) {
                          return 'password must be at least 6 characters';
                        }

                        password = value;
                        return null;
                      },
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                          labelText: 'password',
                          hintText: 'Enter your password',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(_isPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          )),
                    ),
                    _gap(),
                    new InkWell(
                        child: new Text('Register a new membership'),
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Register()))),
                    _gap(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text(
                            'Sign in',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            /// do something
                            if (await confirm(
                              context,
                              title: const Text('Confirm'),
                              content: const Text('Do you want login ?'),
                              textOK: const Text('Yes'),
                              textCancel: const Text('No'),
                            )) {
                              final authController = getIt<AuthController>();

                              try {
                                DataModel dataModel = await authController
                                    .singIn(username, password);

                                final storage = new FlutterSecureStorage();
                                // showToast(dataModel.data.toString());

                                if (dataModel.status == 200) {
                                  await storage.write(
                                      key: 'ACCESS_TOKEN',
                                      value: dataModel.data?['token']);
                                  await storage.write(
                                      key: 'REFRESH_TOKEN',
                                      value: dataModel.data?['refreshToken']);
                                  await storage.write(
                                      key: 'USER_NAME',
                                      value: dataModel.data?['username']);
                                  await storage.write(
                                      key: 'NICK_NAME',
                                      value: dataModel.data?['nickname']);
                                  await storage.write(
                                      key: 'ROLE',
                                      value: dataModel.data?['roles'][0]);

                                  showToast("Success");
                                } else {
                                  showToast("Invalid User Info.");
                                }
                              } catch (e) {
                                print(e.toString());
                                showToast("Invalid User Info.");
                              }
                            } else {
                              showToast('Cancle Click');
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM_RIGHT,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  Widget _gap() => const SizedBox(height: 16);
}
