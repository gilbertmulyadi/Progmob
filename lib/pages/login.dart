import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/gestures.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _storage = GetStorage();
  final _dio = Dio();
  final _apiUrl = 'https://mobileapis.manpits.xyz/api';

  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _isPasswordVisible = false;
  bool _isEmailValid = false;
  bool _isPasswordValid = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void goLogin() async {
    if (!_emailController.text.contains("@gmail.com") ||
        _emailController.text.isEmpty && _passwordController.text.isEmpty) {
      setState(() {
        _isEmailValid = true;
        _isPasswordValid = true;
      });
    } else {
      try {
        final _response = await _dio.post(
          '${_apiUrl}/login',
          data: {
            'email': _emailController.text,
            'password': _passwordController.text
          },
        );
        print(_response.data);
        _storage.write('token', _response.data['data']['token']);
        final _userInfo = await _dio.get(
          '${_apiUrl}/user',
          options: Options(
            headers: {'Authorization': 'Bearer ${_storage.read('token')}'},
          ),
        );
        print(_response.data);
        _storage.write('id', _userInfo.data['data']['user']['id']);
        _storage.write('email', _userInfo.data['data']['user']['email']);
        _storage.write('name', _userInfo.data['data']['user']['name']);
        print(_storage.read('id'));
        print(_storage.read('email'));
        print(_storage.read('name'));
        Navigator.pushReplacementNamed(context, '/homepage');
      } on DioException catch (e) {
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
                      'Login',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 50.0),
                    TextField(
                      controller: _emailController,
                      // ignore: prefer_const_constructors
                      decoration: InputDecoration(
                        hintText: 'Email',
                        labelText: 'Email',
                        border: const OutlineInputBorder(),
                        errorText: _isEmailValid ? 'Enter a valid email' : null,
                      ),
                    ),
                    const SizedBox(height: 15.0),
                    TextField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      // ignore: prefer_const_constructors
                      decoration: InputDecoration(
                        hintText: 'Password',
                        labelText: 'Password',
                        border: const OutlineInputBorder(),
                        errorText: _isPasswordValid ? 'Enter a password' : null,
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: () {
                        goLogin();
                      },
                      child: const Text('Login',
                          style: TextStyle(fontFamily: 'Poppins')),
                    ),
                    const SizedBox(height: 20.0),
                    RichText(
                      text: TextSpan(
                        text: 'Belum punya akun? ',
                        style:
                            const TextStyle(color: Colors.black, fontSize: 14),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Buat akun',
                            style: const TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.pushNamed(context, '/register');
                              },
                          ),
                        ],
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
}
