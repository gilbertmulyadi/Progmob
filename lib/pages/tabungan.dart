import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class TabunganPage extends StatefulWidget {
  @override
  _TabunganPageState createState() => _TabunganPageState();
}

class _TabunganPageState extends State<TabunganPage> {
  dynamic anggota;
  List<Map<String, dynamic>> _historiTransaksi = [];

  final _storage = GetStorage();
  final _dio = Dio();
  final _apiUrl = 'https://mobileapis.manpits.xyz/api';

  final _nomerIndukController = TextEditingController();
  final _namaController = TextEditingController();

  final Map<int, String> transaksiTypes = {
    1: 'Saldo Awal',
    2: 'Simpanan',
    3: 'Penarikan',
    4: 'Bunga Simpanan',
    5: 'Koreksi Penambahan',
    6: 'Koreksi Pengurangan',
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      setState(() {
        anggota = args;
        _nomerIndukController.text = anggota['nomor_induk'].toString();
        _namaController.text = anggota['nama'];
      });
      getTabunganAnggota();
    } else {
      print('Error: Anggota is null or arguments are not valid');
    }
  }

  void getTabunganAnggota() async {
    final token = _storage.read('token');
    final idAnggota = anggota['id'];

    try {
      final response = await _dio.get(
        '$_apiUrl/tabungan/$idAnggota',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        print('Response Data: ${response.data}');
        final data = response.data['data'];
        final tabungan = data['tabungan'];
        if (tabungan is List) {
          setState(() {
            _historiTransaksi = List<Map<String, dynamic>>.from(tabungan);
          });
        } else {
          print('Error: Data format is not correct');
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tabungan Anggota',
          style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
        ),
        backgroundColor: Colors.blue[900],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage(
                        'images/gambar.png'), // Replace with the actual profile picture asset
                  ),
                  SizedBox(height: 20),
                  Text(
                    _namaController.text,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Nomor Induk: ${_nomerIndukController.text}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Histori Transaksi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _historiTransaksi.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _historiTransaksi.length,
                    itemBuilder: (context, index) {
                      final transaksi = _historiTransaksi[index];
                      final trxType = transaksiTypes[transaksi['trx_id']] ??
                          'Tipe Transaksi Tidak Tersedia';
                      return ListTile(
                        title: Text(trxType),
                        subtitle: Text(
                            'Nominal: Rp.${transaksi['trx_nominal'] ?? 'Nominal Tidak Tersedia'}'),
                        trailing: Text(transaksi['trx_tanggal'] ??
                            'Tanggal Transaksi Tidak Tersedia'),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
