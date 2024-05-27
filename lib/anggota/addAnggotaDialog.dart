import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

class AddAnggotaDialog extends StatefulWidget {
  final Map<String, String>? anggota;
  final Function() onAnggotaAdded;

  const AddAnggotaDialog({this.anggota, required this.onAnggotaAdded, Key? key})
      : super(key: key);

  @override
  _AddAnggotaDialogState createState() => _AddAnggotaDialogState();
}

class _AddAnggotaDialogState extends State<AddAnggotaDialog> {
  final _storage = GetStorage();
  final _dio = Dio();
  final _apiUrl = 'https://mobileapis.manpits.xyz/api/anggota';

  late TextEditingController _nomorIndukController;
  late TextEditingController _namaController;
  late TextEditingController _alamatController;
  late TextEditingController _tglLahirController;
  late TextEditingController _teleponController;

  @override
  void initState() {
    super.initState();
    _nomorIndukController =
        TextEditingController(text: widget.anggota?['nomor_induk'] ?? '');
    _namaController =
        TextEditingController(text: widget.anggota?['nama'] ?? '');
    _alamatController =
        TextEditingController(text: widget.anggota?['alamat'] ?? '');
    _tglLahirController =
        TextEditingController(text: widget.anggota?['tgl_lahir'] ?? '');
    _teleponController =
        TextEditingController(text: widget.anggota?['telepon'] ?? '');
  }

  @override
  void dispose() {
    _nomorIndukController.dispose();
    _namaController.dispose();
    _alamatController.dispose();
    _tglLahirController.dispose();
    _teleponController.dispose();
    super.dispose();
  }

  Future<void> _addAnggota(Map<String, String> anggota) async {
    try {
      final token = _storage.read('token');
      if (token == null) {
        print('Authorization token not found');
        return;
      }

      await _dio.post(
        _apiUrl,
        data: anggota,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      widget.onAnggotaAdded();
      Navigator.of(context).pop();
    } on DioError catch (e) {
      print(
          'Failed to add anggota: ${e.response?.statusCode} ${e.response?.data}');
    }
  }

  Future<void> _editAnggota(String id, Map<String, String> anggota) async {
    try {
      await _dio.put('$_apiUrl/$id', data: anggota);
      widget.onAnggotaAdded();
      Navigator.of(context).pop();
    } on DioError catch (e) {
      print(
          'Failed to edit anggota: ${e.response?.statusCode} ${e.response?.data}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.anggota == null ? 'Add Anggota' : 'Edit Anggota'),
      content: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            TextField(
              controller: _nomorIndukController,
              decoration: InputDecoration(labelText: 'Nomor Induk'),
            ),
            TextField(
              controller: _namaController,
              decoration: InputDecoration(labelText: 'Nama'),
            ),
            TextField(
              controller: _alamatController,
              decoration: InputDecoration(labelText: 'Alamat'),
            ),
            TextField(
              controller: _tglLahirController,
              decoration: InputDecoration(labelText: 'Tanggal Lahir'),
            ),
            TextField(
              controller: _teleponController,
              decoration: InputDecoration(labelText: 'Telepon'),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final newAnggota = {
              'nomor_induk': _nomorIndukController.text,
              'nama': _namaController.text,
              'alamat': _alamatController.text,
              'tgl_lahir': _tglLahirController.text,
              'telepon': _teleponController.text,
            };
            if (widget.anggota == null) {
              _addAnggota(newAnggota);
            } else {
              _editAnggota(widget.anggota!['id']!, newAnggota);
            }
          },
          child: Text(widget.anggota == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }
}
