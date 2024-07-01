import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

class AddTransaksiDialog extends StatefulWidget {
  final Function() onTransaksiAdded;

  const AddTransaksiDialog({required this.onTransaksiAdded, Key? key})
      : super(key: key);

  @override
  _AddTransaksiDialogState createState() => _AddTransaksiDialogState();
}

class _AddTransaksiDialogState extends State<AddTransaksiDialog> {
  final _storage = GetStorage();
  final _dio = Dio();
  final _anggotaApiUrl = 'https://mobileapis.manpits.xyz/api/anggota';
  final _jenisTransaksiApiUrl =
      'https://mobileapis.manpits.xyz/api/jenistransaksi';

  List<dynamic> anggotaList = [];
  List<dynamic> jenisTransaksiList = [];
  String? selectedAnggota;
  String? selectedJenisTransaksi;
  final TextEditingController _saldoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchAnggota();
    fetchJenisTransaksi();
  }

  Future<void> fetchAnggota() async {
    try {
      final token = _storage.read('token');
      if (token == null) {
        print('Authorization token not found');
        return;
      }

      final response = await _dio.get(
        _anggotaApiUrl,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      setState(() {
        anggotaList = response.data['data']['anggotas'] ?? [];
      });
    } on DioError catch (e) {
      print(
          'Failed to fetch anggota: ${e.response?.statusCode} ${e.response?.data}');
    }
  }

  Future<void> fetchJenisTransaksi() async {
    try {
      final token = _storage.read('token');
      if (token == null) {
        print('Authorization token not found');
        return;
      }

      final response = await _dio.get(
        _jenisTransaksiApiUrl,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      setState(() {
        jenisTransaksiList = response.data['data']['jenistransaksi'] ?? [];
      });
    } on DioError catch (e) {
      print(
          'Failed to fetch jenis transaksi: ${e.response?.statusCode} ${e.response?.data}');
    }
  }

  Future<void> _addTransaksi() async {
    try {
      final token = _storage.read('token');
      if (token == null) {
        print('Authorization token not found');
        return;
      }

      final newTransaksi = {
        'anggota_id': selectedAnggota,
        'trx_id': selectedJenisTransaksi,
        'trx_nominal': _saldoController.text,
      };

      await _dio.post(
        'https://mobileapis.manpits.xyz/api/tabungan',
        data: newTransaksi,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      widget.onTransaksiAdded();
      Navigator.of(context).pop();
    } on DioError catch (e) {
      print(
          'Failed to add transaksi: ${e.response?.statusCode} ${e.response?.data}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Text(
                'Add Transaksi',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedAnggota,
                hint: Text('Pilih Anggota'),
                decoration: InputDecoration(border: OutlineInputBorder()),
                items: anggotaList.map<DropdownMenuItem<String>>((anggota) {
                  return DropdownMenuItem<String>(
                    value: anggota['id'].toString(),
                    child: Text(anggota['nama']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedAnggota = value;
                  });
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedJenisTransaksi,
                hint: Text('Pilih Jenis Transaksi'),
                decoration: InputDecoration(border: OutlineInputBorder()),
                items:
                    jenisTransaksiList.map<DropdownMenuItem<String>>((jenis) {
                  return DropdownMenuItem<String>(
                    value: jenis['id'].toString(),
                    child: Text(jenis['trx_name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedJenisTransaksi = value;
                  });
                },
              ),
              SizedBox(height: 16),
              TextField(
                controller: _saldoController,
                decoration: InputDecoration(
                  labelText: 'Isi Saldo',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _addTransaksi,
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
