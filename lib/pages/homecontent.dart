import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:progmob_flutter/anggota/addAnggotaDialog.dart';
import 'package:progmob_flutter/anggota/editAnggotaDialog.dart';
import 'package:progmob_flutter/anggota/detailAnggotaDialog.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final _storage = GetStorage();
  final _dio = Dio();
  final _apiUrl = 'https://mobileapis.manpits.xyz/api/anggota';

  List<dynamic> anggotaList = [];

  @override
  void initState() {
    super.initState();
    fetchAnggota();
  }

  Future<void> fetchAnggota() async {
    try {
      final token = _storage.read('token');
      if (token == null) {
        print('Authorization token not found');
        return;
      }

      final response = await _dio.get(
        _apiUrl,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      print(
          'Response data: ${response.data}'); // Debugging: Print the response data

      setState(() {
        anggotaList = response.data['data']['anggotas'] ??
            []; // Correctly access the nested list
      });
    } on DioError catch (e) {
      print(
          'Failed to fetch anggota: ${e.response?.statusCode} ${e.response?.data}');
      if (e.response != null) {
        print('Error data: ${e.response?.data}');
      } else {
        print('Error message: ${e.message}');
      }
    } catch (e) {
      print('Unexpected error: $e');
    }
  }

  void deleteAnggota(BuildContext context, int id) async {
    try {
      final token = _storage.read('token');
      if (token == null) {
        print('Authorization token not found');
        return;
      }

      await _dio.delete(
        '$_apiUrl/$id',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Anggota berhasil dihapus'),
        ),
      );
      // Refresh the list after delete
      fetchAnggota();
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus anggota'),
        ),
      );
    }
  }

  void _showAddEditDialog({Map<String, String>? anggota}) {
    showDialog(
      context: context,
      builder: (context) {
        return AddAnggotaDialog(
          anggota: anggota,
          onAnggotaAdded: fetchAnggota,
        );
      },
    );
  }

  void _showEditDialog(Map<String, dynamic> anggota) {
    showDialog(
      context: context,
      builder: (context) {
        return EditAnggotaDialog(
          anggota: anggota,
          onAnggotaEdited: fetchAnggota,
        );
      },
    );
  }

  void _showDetailDialog(Map<String, dynamic> anggota) {
    showDialog(
      context: context,
      builder: (context) {
        return DetailAnggotaDialog(anggota: anggota);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          const Text(
            'Anggota',
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20.0,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: anggotaList.length,
              itemBuilder: (context, index) {
                final anggota = anggotaList[index];
                return ListTile(
                  title: Text(anggota['nama']),
                  subtitle: Text(anggota['alamat']),
                  onTap: () {
                    _showDetailDialog(anggota);
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _showEditDialog(anggota);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          deleteAnggota(context, anggota['id']);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddEditDialog();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
