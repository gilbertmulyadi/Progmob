import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

class AddAnggotaDialog extends StatefulWidget {
  final Map<String, dynamic>? anggota;
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

  late TextEditingController _namaController;
  late TextEditingController _alamatController;
  late TextEditingController _tglLahirController;
  late TextEditingController _teleponController;

  @override
  void initState() {
    super.initState();
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
    _namaController.dispose();
    _alamatController.dispose();
    _tglLahirController.dispose();
    _teleponController.dispose();
    super.dispose();
  }

  String _generateNomorInduk() {
    return DateTime.now()
        .millisecondsSinceEpoch
        .toString()
        .substring(0, 10); // 10-digit timestamp
  }

  Future<void> _addAnggota(Map<String, dynamic> anggota) async {
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

  Future<void> _editAnggota(String id, Map<String, dynamic> anggota) async {
    try {
      final token = _storage.read('token');
      if (token == null) {
        print('Authorization token not found');
        return;
      }

      await _dio.put('$_apiUrl/$id',
          data: anggota,
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
          ));
      widget.onAnggotaAdded();
      Navigator.of(context).pop();
    } on DioError catch (e) {
      print(
          'Failed to edit anggota: ${e.response?.statusCode} ${e.response?.data}');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _tglLahirController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.anggota == null ? 'Add Anggota' : 'Edit Anggota',
          style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
        ),
        backgroundColor: Colors.blue[900],
        iconTheme: const IconThemeData(color: Colors.white),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              final newAnggota = {
                'nomor_induk': _generateNomorInduk(),
                'nama': _namaController.text,
                'alamat': _alamatController.text,
                'tgl_lahir': _tglLahirController.text,
                'telepon': _teleponController.text,
              };
              if (widget.anggota == null) {
                _addAnggota(newAnggota);
              } else {
                _editAnggota(widget.anggota!['id'].toString(), newAnggota);
              }
            },
            child: Text(
              widget.anggota == null ? 'Add' : 'Save',
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
                controller: _tglLahirController,
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration: InputDecoration(
                  labelText: 'Tanggal Lahir',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _teleponController,
                decoration: InputDecoration(
                  labelText: 'Telepon',
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
