import 'package:flutter_test/flutter_test.dart';
import 'package:pm_tugas_07_4243550016/main.dart';

void main() {
  group('Pengujian TugasModel', () {
    late TugasModel model;

    setUp(() {
      model = TugasModel();
    });

    test('Menambahkan tugas baru', () {
      model.tambah(
        judul: 'Laporan Flutter',
        mataKuliah: 'Pemrograman Mobile',
        deadline: DateTime(2026, 11, 10),
      );

      expect(model.total, 1);
      expect(model.jumlahAktif, 1);
      expect(model.jumlahSelesai, 0);
      expect(model.daftar.first.judul, 'Laporan Flutter');
    });

    test('Mengubah status tugas menjadi selesai', () {
      model.tambah(
        judul: 'Presentasi Algoritma',
        mataKuliah: 'Algoritma Optimasi',
        deadline: DateTime(2026, 11, 12),
      );

      final id = model.daftar.first.id;

      model.ubahStatus(id);

      expect(model.daftar.first.selesai, true);
      expect(model.jumlahAktif, 0);
      expect(model.jumlahSelesai, 1);
    });

    test('Menghapus tugas dari daftar', () {
      model.tambah(
        judul: 'Mini Riset',
        mataKuliah: 'Pengenalan Pola',
        deadline: DateTime(2026, 11, 15),
      );

      expect(model.total, 1);

      final id = model.daftar.first.id;

      model.hapus(id);

      expect(model.total, 0);
      expect(model.daftar.isEmpty, true);
    });

    test('Menghitung persentase penyelesaian tugas', () {
      model.tambah(
        judul: 'Tugas A',
        mataKuliah: 'Mobile',
        deadline: DateTime(2026, 11, 10),
      );

      model.tambah(
        judul: 'Tugas B',
        mataKuliah: 'Mobile',
        deadline: DateTime(2026, 11, 11),
      );

      model.tambah(
        judul: 'Tugas C',
        mataKuliah: 'Mobile',
        deadline: DateTime(2026, 11, 12),
      );

      model.ubahStatus(model.daftar.first.id);

      expect(model.total, 3);
      expect(model.jumlahSelesai, 1);
      expect(model.jumlahAktif, 2);
      expect(model.persentase, closeTo(1 / 3, 0.0001));
    });
  });
}
