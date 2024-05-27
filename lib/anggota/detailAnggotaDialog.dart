import 'package:flutter/material.dart';

class DetailAnggotaDialog extends StatelessWidget {
  final Map<String, dynamic> anggota;

  const DetailAnggotaDialog({required this.anggota, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Detail Anggota'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text('Nomor Induk: ${anggota['nomor_induk']}'),
            Text('Nama: ${anggota['nama']}'),
            Text('Alamat: ${anggota['alamat']}'),
            Text('Tanggal Lahir: ${anggota['tgl_lahir']}'),
            Text('Telepon: ${anggota['telepon']}'),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Close'),
        ),
      ],
    );
  }
}
