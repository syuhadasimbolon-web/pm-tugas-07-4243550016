import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => TugasModel(),
      child: const PlannerApp(),
    ),
  );
}

// MODEL DATA TUGAS
class Tugas {
  Tugas({
    required this.id,
    required this.judul,
    required this.mataKuliah,
    required this.deadline,
    this.selesai = false,
  });

  final int id;
  final String judul;
  final String mataKuliah;
  final DateTime deadline;
  bool selesai;
}

// STATE MANAGEMENT MENGGUNAKAN PROVIDER
class TugasModel extends ChangeNotifier {
  final List<Tugas> _daftar = [];
  int _idBerikutnya = 1;

  List<Tugas> get daftar => List.unmodifiable(_daftar);

  int get total => _daftar.length;

  int get jumlahSelesai => _daftar.where((tugas) => tugas.selesai).length;

  int get jumlahAktif => total - jumlahSelesai;

  double get persentase => total == 0 ? 0 : jumlahSelesai / total;

  void tambah({
    required String judul,
    required String mataKuliah,
    required DateTime deadline,
  }) {
    if (judul.trim().isEmpty || mataKuliah.trim().isEmpty) {
      return;
    }

    _daftar.add(
      Tugas(
        id: _idBerikutnya++,
        judul: judul.trim(),
        mataKuliah: mataKuliah.trim(),
        deadline: deadline,
      ),
    );

    notifyListeners();
  }

  void ubahStatus(int id) {
    for (final tugas in _daftar) {
      if (tugas.id == id) {
        tugas.selesai = !tugas.selesai;
        notifyListeners();
        return;
      }
    }
  }

  void hapus(int id) {
    _daftar.removeWhere((tugas) => tugas.id == id);
    notifyListeners();
  }
}

// NAVIGASI APLIKASI
final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HalamanDaftar()),
    GoRoute(
      path: '/tambah',
      builder: (context, state) => const HalamanTambah(),
    ),
    GoRoute(
      path: '/statistik',
      builder: (context, state) => const HalamanStatistik(),
    ),
  ],
);

class PlannerApp extends StatelessWidget {
  const PlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Planner Tugas Kuliah',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        scaffoldBackgroundColor: const Color(0xFFF7F8FC),
      ),
      routerConfig: router,
    );
  }
}

enum FilterTugas { semua, aktif, selesai }

// HALAMAN DAFTAR TUGAS
class HalamanDaftar extends StatefulWidget {
  const HalamanDaftar({super.key});

  @override
  State<HalamanDaftar> createState() => _HalamanDaftarState();
}

class _HalamanDaftarState extends State<HalamanDaftar> {
  FilterTugas filter = FilterTugas.semua;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<TugasModel>();

    final daftar = model.daftar.where((tugas) {
      switch (filter) {
        case FilterTugas.aktif:
          return !tugas.selesai;
        case FilterTugas.selesai:
          return tugas.selesai;
        case FilterTugas.semua:
          return true;
      }
    }).toList();

    daftar.sort((a, b) => a.deadline.compareTo(b.deadline));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planner Tugas Kuliah'),
        actions: [
          IconButton(
            tooltip: 'Statistik',
            onPressed: () => context.push('/statistik'),
            icon: const Icon(Icons.bar_chart_rounded),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Badge(
                label: Text('${model.jumlahAktif}'),
                child: const Icon(Icons.assignment_outlined),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        const Icon(Icons.school_rounded, size: 45),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Semangat Kuliahnya!',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${model.jumlahAktif} tugas aktif • '
                                '${model.jumlahSelesai} tugas selesai',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('Semua'),
                      selected: filter == FilterTugas.semua,
                      onSelected: (_) =>
                          setState(() => filter = FilterTugas.semua),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Aktif'),
                      selected: filter == FilterTugas.aktif,
                      onSelected: (_) =>
                          setState(() => filter = FilterTugas.aktif),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Selesai'),
                      selected: filter == FilterTugas.selesai,
                      onSelected: (_) =>
                          setState(() => filter = FilterTugas.selesai),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: daftar.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.event_note_outlined,
                              size: 72,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              model.total == 0
                                  ? 'Belum ada tugas kuliah'
                                  : 'Tidak ada tugas pada filter ini',
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: daftar.length,
                        itemBuilder: (context, index) {
                          final tugas = daftar[index];

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              leading: Checkbox(
                                value: tugas.selesai,
                                onChanged: (_) {
                                  context.read<TugasModel>().ubahStatus(
                                    tugas.id,
                                  );
                                },
                              ),
                              title: Text(
                                tugas.judul,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  decoration: tugas.selesai
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(tugas.mataKuliah),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Deadline: '
                                    '${tugas.deadline.day}/'
                                    '${tugas.deadline.month}/'
                                    '${tugas.deadline.year}',
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                tooltip: 'Hapus tugas',
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () {
                                  context.read<TugasModel>().hapus(tugas.id);
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/tambah'),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Tugas'),
      ),
    );
  }
}

// HALAMAN FORM TAMBAH TUGAS
class HalamanTambah extends StatefulWidget {
  const HalamanTambah({super.key});

  @override
  State<HalamanTambah> createState() => _HalamanTambahState();
}

class _HalamanTambahState extends State<HalamanTambah> {
  final _formKey = GlobalKey<FormState>();

  final _judulController = TextEditingController();
  final _mataKuliahController = TextEditingController();

  DateTime deadline = DateTime.now();

  @override
  void dispose() {
    _judulController.dispose();
    _mataKuliahController.dispose();
    super.dispose();
  }

  Future<void> pilihTanggal() async {
    final hasil = await showDatePicker(
      context: context,
      initialDate: deadline,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (!mounted) return;

    if (hasil != null) {
      setState(() => deadline = hasil);
    }
  }

  void simpan() {
    if (!_formKey.currentState!.validate()) return;

    context.read<TugasModel>().tambah(
      judul: _judulController.text,
      mataKuliah: _mataKuliahController.text,
      deadline: deadline,
    );

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Tugas')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Buat Tugas Baru',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _judulController,
                  decoration: const InputDecoration(
                    labelText: 'Judul Tugas',
                    hintText: 'Contoh: Laporan Praktikum Flutter',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.edit_note),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Judul tugas wajib diisi'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _mataKuliahController,
                  decoration: const InputDecoration(
                    labelText: 'Mata Kuliah',
                    hintText: 'Contoh: Pemrograman Mobile',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.school_outlined),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Mata kuliah wajib diisi'
                      : null,
                ),
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.calendar_month),
                    title: const Text('Tenggat Waktu'),
                    subtitle: Text(
                      '${deadline.day}/${deadline.month}/'
                      '${deadline.year}',
                    ),
                    trailing: const Icon(Icons.edit_calendar),
                    onTap: pilihTanggal,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: simpan,
                  icon: const Icon(Icons.save),
                  label: const Text('Simpan Tugas'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// HALAMAN STATISTIK
class HalamanStatistik extends StatelessWidget {
  const HalamanStatistik({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<TugasModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Statistik Tugas')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Icon(
                Icons.analytics_outlined,
                size: 80,
                color: Colors.indigo,
              ),
              const SizedBox(height: 16),
              Text(
                'Progres Penyelesaian Tugas',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              LinearProgressIndicator(
                value: model.persentase,
                minHeight: 16,
                borderRadius: BorderRadius.circular(12),
              ),
              const SizedBox(height: 12),
              Text(
                '${(model.persentase * 100).toStringAsFixed(1)}%',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.assignment_outlined),
                  title: const Text('Total Tugas'),
                  trailing: Text('${model.total}'),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.pending_actions,
                    color: Colors.orange,
                  ),
                  title: const Text('Tugas Aktif'),
                  trailing: Text('${model.jumlahAktif}'),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                  ),
                  title: const Text('Tugas Selesai'),
                  trailing: Text('${model.jumlahSelesai}'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
