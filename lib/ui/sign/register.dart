import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gotogether/data/di/service_locator.dart';
import 'package:gotogether/ui/sign/sign.dart';
import 'package:gotogether/ui/sign/auth_controller.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool _isPasswordVisible = false;
  bool _isPasswordConfirmVisible = false;
  bool _saving = false;
  final _usernameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameController.dispose();
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

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
                      controller: _usernameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter userid';
                        if (value.length < 3) return 'userid must be at least 3 characters';
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
                      controller: _nicknameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter nickname';
                        if (value.length < 2) return 'nickname must be at least 2 characters';
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'nickname',
                        hintText: 'Enter your nickname',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    _gap(),
                    TextFormField(
                      controller: _emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter email';
                        final emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value);
                        if (!emailValid) return 'Please enter a valid email';
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter your email',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    _gap(),
                    TextFormField(
                      controller: _passwordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter password';
                        if (value.length < 6) return 'password must be at least 6 characters';
                        return null;
                      },
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'password',
                        hintText: 'Enter your password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                        ),
                      ),
                    ),
                    _gap(),
                    TextFormField(
                      controller: _passwordConfirmController,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please retype password';
                        if (value != _passwordController.text) return 'Passwords do not match';
                        return null;
                      },
                      obscureText: !_isPasswordConfirmVisible,
                      decoration: InputDecoration(
                        labelText: 'retype password',
                        hintText: 'Enter your retype password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(_isPasswordConfirmVisible ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _isPasswordConfirmVisible = !_isPasswordConfirmVisible),
                        ),
                      ),
                    ),
                    _gap(),
                    InkWell(
                      child: const Text('I already have a membership'),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SignIn())),
                    ),
                    _gap(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: _saving
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Text('Register', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                        onPressed: _saving
                            ? null
                            : () async {
                                if (!(_formKey.currentState?.validate() ?? false)) return;
                                setState(() => _saving = true);
                                try {
                                  final authController = getIt<AuthController>();
                                  await authController.signUp(
                                    _usernameController.text.trim(),
                                    _nicknameController.text.trim(),
                                    _emailController.text.trim(),
                                    _passwordController.text,
                                  );
                                  Fluttertoast.showToast(msg: 'Registered. Please sign in.');
                                  if (mounted) Navigator.pop(context);
                                } catch (e) {
                                  Fluttertoast.showToast(msg: e.toString());
                                } finally {
                                  if (mounted) setState(() => _saving = false);
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
