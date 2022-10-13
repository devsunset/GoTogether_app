import 'package:flutter/material.dart';
import 'package:gotogether/sign/sign.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool _isPasswordVisible = false;
  bool _isPasswordConfirmVisible = false;

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
                        // add email validation
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }

                        if (value.length < 2) {
                          return 'nickname must be at least 2 characters';
                        }

                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'nickname',
                        hintText: 'Enter your nickname',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    // TextFormField(
                    //   validator: (value) {
                    //     // add email validation
                    //     if (value == null || value.isEmpty) {
                    //       return 'Please enter some text';
                    //     }
                    //
                    //     bool _emailValid = RegExp(
                    //         r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                    //         .hasMatch(value);
                    //     if (!_emailValid) {
                    //       return 'Please enter a valid email';
                    //     }
                    //
                    //     return null;
                    //   },
                    //   decoration: const InputDecoration(
                    //     labelText: 'Email',
                    //     hintText: 'Enter your email',
                    //     prefixIcon: Icon(Icons.email_outlined),
                    //     border: OutlineInputBorder(),
                    //   ),
                    // ),
                    _gap(),
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }

                        if (value.length < 6) {
                          return 'password must be at least 6 characters';
                        }
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
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }

                        if (value.length < 6) {
                          return 'password must be at least 6 characters';
                        }
                        return null;
                      },
                      obscureText: !_isPasswordConfirmVisible,
                      decoration: InputDecoration(
                          labelText: 'retype password',
                          hintText: 'Enter your retype password',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(_isPasswordConfirmVisible
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _isPasswordConfirmVisible = !_isPasswordConfirmVisible;
                              });
                            },
                          )),
                    ),
                    _gap(),
                    new InkWell(
                        child: new Text('I already have a membership '),
                        onTap: () =>  Navigator.push(context, MaterialPageRoute(builder: (context) => SignIn()))
                    ),
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
                            'Register',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            /// do something
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

  Widget _gap() => const SizedBox(height: 16);
}
