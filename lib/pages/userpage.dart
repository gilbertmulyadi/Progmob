import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  Future<void> _logout() async {
    final _storage = GetStorage();
    final _dio = Dio();
    final _apiUrl = 'https://mobileapis.manpits.xyz/api';

    try {
      final _response = await _dio.get(
        '$_apiUrl/logout',
        options: Options(
          headers: {'Authorization': 'Bearer ${_storage.read('token')}'},
        ),
      );
      print('Logout successful: ${_response.data}');
      _storage.erase();
      Get.offAllNamed('/login'); // Navigate to login page
    } on DioException catch (e) {
      print('Logout failed: ${e.response} - ${e.response?.statusCode}');
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin logout?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Tidak'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Ya'),
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final _storage = GetStorage();
    final String name = _storage.read('name') ?? 'Guest';
    final String email = _storage.read('email') ?? 'guest@example.com';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage(
                'images/gambar.png'),
          ),
          const SizedBox(height: 20),
          Text(
            name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            email,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _showLogoutDialog(context),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
