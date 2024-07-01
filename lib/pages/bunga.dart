import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class Bunga extends StatefulWidget {
  @override
  _BungaState createState() => _BungaState();
}

class _BungaState extends State<Bunga> {
  final _storage = GetStorage();
  final _dio = Dio();
  final _apiUrl = 'https://mobileapis.manpits.xyz/api';
  List<dynamic> _bungas = [];
  String id = '';
  String persen = '';
  String isaktif = '1'; // Inisialisasi dengan nilai default
  TextEditingController persenController = TextEditingController();
  String dropdownValue = 'Aktif'; // Default value for dropdown

  @override
  void initState() {
    super.initState();
    GetListBunga();
  }

  @override
  void dispose() {
    persenController.dispose();
    super.dispose();
  }

  Future<void> AddBunga(context, persen, isaktif) async {
    print('createAnggota');
    print('Persen Bunga: ${persen}');
    print('Status Aktif: ${isaktif}');

    final token = _storage.read('token');
    if (token == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    try {
      final _response = await _dio.post(
        '${_apiUrl}/addsettingbunga',
        data: {
          'persen': persen,
          'isaktif': isaktif,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      print(_response.data);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bunga Berhasil Ditambahkan'),
        ),
      );
      Navigator.pop(context);
      Navigator.pushNamed(context, '/homepage');
    } on DioException catch (e) {
      print('${e.response} - ${e.response?.statusCode}');
      if (e.response?.statusCode == 401) {
        // Unauthorized, token might be invalid
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Token tidak valid. Silahkan login ulang.'),
          ),
        );
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menambahkan bunga'),
          ),
        );
      }
    }
  }

  Future<void> GetListBunga() async {
    final token = _storage.read('token');
    if (token == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    try {
      final _response = await _dio.get(
        '${_apiUrl}/settingbunga',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      setState(() {
        _bungas = _response.data['data']['settingbungas'] ?? [];
      });

      print(_response.data);
    } on DioException catch (e) {
      print('${e.response} - ${e.response?.statusCode}');
      if (e.response?.statusCode == 401) {
        // Unauthorized, token might be invalid
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Token tidak valid. Silahkan login ulang.'),
          ),
        );
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mendapatkan list bunga'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 40),
        height: MediaQuery.of(context).size.height - 50,
        width: double.infinity,
        child: Column(
          children: [
            SizedBox(height: 15),
            Center(
              child: Column(
                children: [
                  Text(
                    'Bunga',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: persenController,
              decoration: InputDecoration(
                labelText: 'Persen Bunga',
                hintText: 'Masukan Persen Bunga',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 14.0,
                ),
                labelStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w400),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  persen = value;
                });
              },
            ),
            SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: dropdownValue,
              decoration: InputDecoration(
                labelText: 'Status Aktif',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 14.0,
                ),
                labelStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w400),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
              ),
              items: <String>['Aktif', 'Tidak Aktif']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  dropdownValue = newValue!;
                  isaktif = newValue == 'Aktif'
                      ? '1'
                      : '0'; // Convert to desired value
                });
              },
            ),
            SizedBox(height: 20),
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                AddBunga(
                  context,
                  persenController.text,
                  isaktif,
                );
              },
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  border:
                      Border.all(color: const Color.fromARGB(255, 13, 71, 161)),
                  color: Colors.blue[900],
                ),
                child: Container(
                  width: double.infinity,
                  height: 40,
                  alignment: Alignment.center,
                  child: Text(
                    "Simpan Bunga",
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w200,
                      fontFamily: 'Poppins',
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Text(
                  'List Bunga',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    color: const Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // List Bunga
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _bungas.length,
                itemBuilder: (context, index) {
                  final bunga = _bungas[index];
                  // title list bunga
                  return Card(
                    color: Colors.blue[900],
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                      side: BorderSide(color: Colors.grey),
                    ),
                    child: ListTile(
                      title: Text(
                        'Bunga: ${bunga['persen']}%',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w300,
                          fontFamily: 'Poppins',
                          color: Colors.white,
                        ),
                      ),
                      trailing: Text(
                        bunga['isaktif'] == 1 ? 'Aktif' : 'Tidak Aktif',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w300,
                          fontFamily: 'Poppins',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
