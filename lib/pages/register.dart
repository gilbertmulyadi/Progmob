import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _storage = GetStorage();
  final _dio = Dio();
  final _apiUrl = 'https://mobileapis.manpits.xyz/api';

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  bool _isEmailValid = false;
  bool _isPasswordValid = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void goRegister() async {
    if (!_emailController.text.contains("@gmail.com") ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _passwordController.text.length < 6 ||
        _passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _isEmailValid = !_emailController.text.contains("@gmail.com") ||
            _emailController.text.isEmpty;
        _isPasswordValid = _passwordController.text.isEmpty ||
            _passwordController.text.length < 6 ||
            _passwordController.text != _confirmPasswordController.text;
      });
    } else {
      try {
        final _register = await _dio.post(
          '${_apiUrl}/register',
          data: {
            'name': _nameController.text,
            'email': _emailController.text,
            'password': _passwordController.text
          },
        );
        _storage.write('registered', true); // Flag to indicate registration
        print(_register.data);
        // Navigate to login page
        Navigator.pushReplacementNamed(context, '/login');
      } on DioException catch (e) {
        print('Error response: ${e.response}');
        print('Error code: ${e.response?.statusCode}');
        print('Error message: ${e.message}');
        print('${e.response} - ${e.response?.statusCode}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FractionallySizedBox(
          widthFactor: 0.8,
          heightFactor: 0.7,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.lightBlue[100],
              boxShadow: [
                BoxShadow(
                  color:
                      const Color.fromARGB(255, 116, 178, 226).withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 3),
                ),
              ],
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      'Register',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20.0),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Username',
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        print(_nameController.text);
                      },
                    ),
                    const SizedBox(height: 15.0),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        errorText: _isEmailValid ? 'Enter a valid email' : null,
                      ),
                      onChanged: (value) {
                        print(_emailController.text);
                      },
                    ),
                    const SizedBox(height: 15.0),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                        errorText: _isPasswordValid ? 'Enter a password' : null,
                      ),
                    ),
                    const SizedBox(height: 15.0),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Confirm Password',
                        labelText: 'Confirm Password',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: _isPasswordValid ? Colors.red : Colors.black,
                          ),
                        ),
                        errorText:
                            _isPasswordValid ? "Passwords do not match" : null,
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: () {
                        goRegister(); // Call the goRegister method for registration
                      },
                      child: const Text('Register',
                          style: TextStyle(fontFamily: 'Poppins')),
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
}
