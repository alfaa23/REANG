import 'package:flutter/material.dart';

class DetailPlesirScreen extends StatefulWidget {
  // PERBAIKAN: Menerima data destinasi dari halaman sebelumnya
  final Map<String, dynamic> destinationData;
  const DetailPlesirScreen({super.key, required this.destinationData});

  @override
  State<DetailPlesirScreen> createState() => _DetailPlesirScreenState();
}

class _DetailPlesirScreenState extends State<DetailPlesirScreen> {
  late double ratingAverage;
  late int reviewCount;
  late List<Map<String, dynamic>> _reviews;

  final TextEditingController _reviewCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Inisialisasi dari data yang dikirim, fallback nilai default
    ratingAverage = (widget.destinationData['rating'] is num)
        ? (widget.destinationData['rating'] as num).toDouble()
        : 0.0;
    // Asumsi awal jumlah ulasan 120 agar tampilan lama tetap; jika ada key count di data, gunakan itu.
    reviewCount = (widget.destinationData['review_count'] is int)
        ? widget.destinationData['review_count'] as int
        : 120;

    // Inisialisasi daftar ulasan dengan contoh dua ulasan seperti versi sebelumnya
    _reviews = [
      {
        'nama': 'Rimba',
        'tanggal': '24/07/25',
        'ulasan':
            'Tempatnya indah dan bagus, cocok untuk liburan bareng keluarga. Pemandangannya juga sangat memukau.',
        'rating': 5,
      },
      {
        'nama': 'Siti',
        'tanggal': '22/07/25',
        'ulasan':
            'Akses jalannya mudah dan pantainya bersih. Sangat direkomendasikan!',
        'rating': 4,
      },
    ];
  }

  @override
  void dispose() {
    _reviewCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Mengambil data dari map yang dikirim
    final String title = widget.destinationData['title'] ?? 'Detail Wisata';
    final String locationName = widget.destinationData['name'] ?? 'Lokasi';
    final String address =
        widget.destinationData['location'] ?? 'Alamat tidak tersedia';
    final String description =
        widget.destinationData['description'] ?? 'Deskripsi tidak tersedia.';
    final String category = widget.destinationData['category'] ?? 'Kategori';
    final String imagePath =
        widget.destinationData['image'] ??
        'assets/images/pantai_balongan.png'; // Ganti dengan path gambar dinamis jika ada

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 220.0,
            pinned: true,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  color: theme.colorScheme.surface,
                  child: Center(
                    child: Text(
                      'Article Image',
                      style: TextStyle(color: theme.hintColor),
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // -- KATEGORI: tampilkan tepat di bawah judul --
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Chip(
                          label: Text(
                            category,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          backgroundColor: theme.colorScheme.surfaceVariant,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                        ),
                      ],
                    ),

                    // -- akhir kategori --
                    const SizedBox(height: 16),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: theme.dividerColor),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow(
                              theme,
                              Icons.location_on,
                              "Lokasi:",
                              "$locationName\n$address",
                            ),
                            const Divider(height: 32),
                            _buildDetailRow(
                              theme,
                              Icons.description,
                              "Deskripsi:",
                              description,
                            ),
                            const SizedBox(height: 24),
                            Center(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  // TODO: Aksi untuk membuka peta
                                },
                                icon: const Icon(Icons.map_outlined, size: 18),
                                label: const Text('Lihat Lokasi di Peta'),
                                style: ElevatedButton.styleFrom(
                                  // PERUBAHAN: Mengubah warna tombol
                                  backgroundColor: Colors.blue.shade800,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Rating dan Ulasan",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // -- RATING SUMMARY + TOMBOL TAMBAH ULASAN (dengan input bintang) --
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          ratingAverage.toStringAsFixed(1),
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: List.generate(5, (index) {
                                  if (ratingAverage >= index + 1) {
                                    return const Icon(
                                      Icons.star_rounded,
                                      color: Colors.amber,
                                      size: 22,
                                    );
                                  } else if (ratingAverage > index) {
                                    return const Icon(
                                      Icons.star_half_rounded,
                                      color: Colors.amber,
                                      size: 22,
                                    );
                                  }
                                  return const Icon(
                                    Icons.star_border_rounded,
                                    color: Colors.amber,
                                    size: 22,
                                  );
                                }),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "dari $reviewCount ulasan",
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.hintColor,
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: _showAddReviewSheet,
                                    icon: const Icon(Icons.add, size: 18),
                                    label: const Text("Tambah Ulasan"),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),

                    // -- LIST ULASAN (dinamis) --
                    Column(
                      children: _reviews.map((r) {
                        return _buildUlasan(
                          theme,
                          r['nama'] as String,
                          r['tanggal'] as String,
                          r['ulasan'] as String,
                          rating: (r['rating'] as int?) ?? 0,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    ThemeData theme,
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: theme.colorScheme.primary),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.5,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAddReviewSheet() {
    _reviewCtrl.clear();
    // tempRating sekarang diinisialisasi 0 supaya bintang kosong pada awalnya
    int tempRating = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final mq = MediaQuery.of(ctx);
        // Menggunakan SingleChildScrollView dan StatefulBuilder untuk interaksi bintang
        return Padding(
          padding: EdgeInsets.only(
            bottom: mq.viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (contextSheet, setSheetState) {
                // canSubmit true jika user sudah memilih bintang (>0)
                final bool canSubmit = tempRating > 0;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    Text(
                      'Tambah Ulasan',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Baris bintang (rating) — awalnya kosong (tempRating == 0)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Rating',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: List.generate(5, (i) {
                        final idx = i + 1;
                        return IconButton(
                          onPressed: () {
                            setSheetState(() => tempRating = idx);
                          },
                          icon: Icon(
                            idx <= tempRating
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            size: 30,
                            color: Colors.amber,
                          ),
                          splashRadius: 20,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 36),
                        );
                      }),
                    ),

                    const SizedBox(height: 8),

                    TextField(
                      controller: _reviewCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Ulasan',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      minLines: 3,
                      maxLines: 6,
                    ),
                    const SizedBox(height: 12),
                    // Tombol dikompakkan dan diletakkan segera setelah TextField agar mudah dijangkau
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        // hanya aktif jika tempRating > 0 (user wajib pilih bintang)
                        onPressed: canSubmit
                            ? () {
                                final review = _reviewCtrl.text.trim();
                                // sekarang ulasan boleh kosong -> tidak ada validasi review.isEmpty

                                final now = DateTime.now();
                                final tanggal =
                                    '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year.toString().substring(2)}';

                                setState(() {
                                  // tambahkan ulasan di awal list (simpan nama kosong -> tampil 'Pengunjung')
                                  _reviews.insert(0, {
                                    'nama': '',
                                    'tanggal': tanggal,
                                    'ulasan': review,
                                    'rating': tempRating,
                                  });

                                  // update jumlah ulasan dan rata-rata rating
                                  final prevTotal = ratingAverage * reviewCount;
                                  reviewCount = reviewCount + 1;
                                  ratingAverage =
                                      (prevTotal + tempRating) / reviewCount;
                                });

                                Navigator.of(
                                  context,
                                ).pop(); // tutup bottom sheet
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Ulasan berhasil ditambahkan',
                                    ),
                                  ),
                                );
                              }
                            : null,
                        style: ButtonStyle(
                          // warna biru saat aktif, abu saat disabled
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color?>((
                                states,
                              ) {
                                if (states.contains(MaterialState.disabled)) {
                                  return Colors.grey.shade300;
                                }
                                return Colors.blue.shade800;
                              }),
                          foregroundColor:
                              MaterialStateProperty.resolveWith<Color?>((
                                states,
                              ) {
                                if (states.contains(MaterialState.disabled)) {
                                  return Colors.black38;
                                }
                                return Colors.white;
                              }),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          padding: MaterialStateProperty.all(
                            const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                        child: const Text('Kirim Ulasan'),
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildUlasan(
    ThemeData theme,
    String nama,
    String tanggal,
    String ulasan, {
    int rating = 0,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(nama.isNotEmpty ? nama[0] : '?'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      nama.isNotEmpty ? nama : 'Pengunjung',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      tanggal,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < rating
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: Colors.amber,
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  ulasan,
                  style: theme.textTheme.bodyLarge?.copyWith(fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
