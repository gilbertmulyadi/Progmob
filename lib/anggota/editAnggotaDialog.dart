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

  TextEditingController _nomerIndukController = TextEditingController();
  TextEditingController _teleponController = TextEditingController();
  TextEditingController _namaController = TextEditingController();
  TextEditingController _alamatController = TextEditingController();
  TextEditingController _tglLahirController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nomerIndukController.text = widget.anggota['nomor_induk'].toString();
    _teleponController.text = widget.anggota['telepon'];
    _namaController.text = widget.anggota['nama'];
    _alamatController.text = widget.anggota['alamat'];
    _tglLahirController.text = widget.anggota['tgl_lahir'];
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Anggota'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nomerIndukController,
              decoration: InputDecoration(labelText: 'Nomer Induk'),
            ),
            TextField(
              controller: _teleponController,
              decoration: InputDecoration(labelText: 'Telepon'),
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
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            editAnggota(
              widget.anggota['id'],
              _nomerIndukController.text,
              _teleponController.text,
              _namaController.text,
              _alamatController.text,
              _tglLahirController.text,
            );
          },
          child: Text('Simpan Perubahan'),
        ),
      ],
    );
  }

  Future<void> editAnggota(
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
}
