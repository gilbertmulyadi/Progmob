import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:progmob_flutter/anggota/addAnggotaDialog.dart';
import 'package:progmob_flutter/anggota/editAnggotaDialog.dart';
import 'package:progmob_flutter/anggota/detailAnggotaDialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final _storage = GetStorage();
  final _dio = Dio();
  final _apiUrlAnggota = 'https://mobileapis.manpits.xyz/api/anggota';
  final _apiUrlSaldo = 'https://mobileapis.manpits.xyz/api/saldo';

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
        _apiUrlAnggota,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      final anggotas = response.data['data']['anggotas'] ?? [];
      await fetchSaldoAnggota(anggotas);
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

  Future<void> fetchSaldoAnggota(List<dynamic> anggotas) async {
    try {
      final token = _storage.read('token');
      if (token == null) {
        print('Authorization token not found');
        return;
      }

      for (var anggota in anggotas) {
        final response = await _dio.get(
          '$_apiUrlSaldo/${anggota['id']}',
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
          ),
        );

        anggota['saldo'] = response.data['data']['saldo'] ?? 0;
      }

      setState(() {
        anggotaList = anggotas;
      });
    } on DioError catch (e) {
      print(
          'Failed to fetch saldo: ${e.response?.statusCode} ${e.response?.data}');
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
    if (!mounted) return; // Check if the widget is still mounted
    try {
      final token = _storage.read('token');
      if (token == null) {
        print('Authorization token not found');
        return;
      }

      await _dio.delete(
        '$_apiUrlAnggota/$id',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (!mounted) return; // Re-check if the widget is still mounted
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Anggota berhasil dihapus'),
        ),
      );

      await fetchAnggota(); // Refresh the list after delete
      setState(() {});
    } catch (e) {
      print(e);
      if (!mounted) return; // Re-check if the widget is still mounted
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus anggota'),
        ),
      );
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Konfirmasi Hapus"),
          content: Text("Apakah Anda yakin ingin menghapus anggota ini?"),
          actions: <Widget>[
            TextButton(
              child: Text("Tidak"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Ya"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                deleteAnggota(context, id); // Call delete method
              },
            ),
          ],
        );
      },
    );
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
                  subtitle: Text('Saldo: Rp.${anggota['saldo']}'),
                  onTap: () {
                    _showDetailDialog(anggota);
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: FaIcon(
                          FontAwesomeIcons.wallet,
                        ),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/tabungan',
                            arguments: anggota,
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _showEditDialog(anggota);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _showDeleteConfirmationDialog(context, anggota['id']);
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
