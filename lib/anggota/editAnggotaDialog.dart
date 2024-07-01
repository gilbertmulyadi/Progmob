import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class EditAnggotaDialog extends StatefulWidget {
  final Map<String, dynamic> anggota;
  final VoidCallback onAnggotaEdited;

  EditAnggotaDialog({required this.anggota, required this.onAnggotaEdited});

  @override
  _EditAnggotaDialogState createState() => _EditAnggotaDialogState();
}

class _EditAnggotaDialogState extends State<EditAnggotaDialog> {
  final _storage = GetStorage();
  final _dio = Dio();
  final _apiUrl = 'https://mobileapis.manpits.xyz/api/anggota';

  late TextEditingController _nomerIndukController;
  late TextEditingController _teleponController;
  late TextEditingController _namaController;
  late TextEditingController _alamatController;
  late TextEditingController _tglLahirController;

  @override
  void initState() {
    super.initState();
    _nomerIndukController =
        TextEditingController(text: widget.anggota['nomor_induk'].toString());
    _teleponController = TextEditingController(text: widget.anggota['telepon']);
    _namaController = TextEditingController(text: widget.anggota['nama']);
    _alamatController = TextEditingController(text: widget.anggota['alamat']);
    _tglLahirController =
        TextEditingController(text: widget.anggota['tgl_lahir']);
  }

  @override
  void dispose() {
    _nomerIndukController.dispose();
    _teleponController.dispose();
    _namaController.dispose();
    _alamatController.dispose();
    _tglLahirController.dispose();
    super.dispose();
  }

  Future<void> _editAnggota(
    int id,
    String nomerInduk,
    String telepon,
    String nama,
    String alamat,
    String tglLahir,
  ) async {
    try {
      final response = await _dio.put(
        '$_apiUrl/$id',
        data: {
          'nomor_induk': nomerInduk,
          'nama': nama,
          'alamat': alamat,
          'tgl_lahir': tglLahir,
          'telepon': telepon,
          'status_aktif': 1,
        },
        options: Options(
          headers: {'Authorization': 'Bearer ${_storage.read('token')}'},
        ),
      );
      print(response.data);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Perubahan berhasil disimpan'),
        ),
      );
      Navigator.of(context).pop();
      widget.onAnggotaEdited();
    } on DioException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan perubahan'),
        ),
      );
      print('${e.response} - ${e.response?.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Anggota',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[900],
        iconTheme: const IconThemeData(color: Colors.white),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              _editAnggota(
                widget.anggota['id'],
                _nomerIndukController.text,
                _teleponController.text,
                _namaController.text,
                _alamatController.text,
                _tglLahirController.text,
              );
            },
            child: Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              SizedBox(height: 16.0),
              TextField(
                readOnly: true,
                controller: _nomerIndukController,
                decoration: InputDecoration(
                  labelText: 'Nomor Induk',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _namaController,
                decoration: InputDecoration(
                  labelText: 'Nama',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _alamatController,
                decoration: InputDecoration(
                  labelText: 'Alamat',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _teleponController,
                decoration: InputDecoration(
                  labelText: 'Nomor Telepon',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _tglLahirController,
                decoration: InputDecoration(
                  labelText: 'Tanggal Lahir',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
