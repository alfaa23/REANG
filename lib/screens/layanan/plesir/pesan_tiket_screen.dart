import 'package:flutter/material.dart';

class PesanTiketScreen extends StatelessWidget {
  const PesanTiketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF0FDF4),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Reservasi Tiket",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const Text(
            "Temukan pengalaman wisata dan event terbaik di sekitar Anda.",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 20),

          // Card Candi Borobudur - URL diperbarui agar gambar muncul
          _buildTicketCard(
            context,
            title: "Candi Borobudur",
            location: "Magelang, Jawa Tengah",
            price: "Rp 50.000",
            rating: "4.9",
            category: "Wisata",
            isEvent: false,
            imageUrl:
                "https://images.unsplash.com/photo-1626082895617-2c6de3476af7?q=80&w=500",
          ),

          // Card Jazz Gunung 2024
          _buildTicketCard(
            context,
            title: "Jazz Gunung 2024",
            location: "21-23 Juli 2024",
            price: "Rp 250.000",
            rating: "4.8",
            category: "Event",
            isEvent: true,
            imageUrl:
                "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?q=80&w=500",
          ),

          // Card Gunung Bromo - URL diperbarui agar gambar muncul
          _buildTicketCard(
            context,
            title: "Gunung Bromo",
            location: "Probolinggo, Jawa Timur",
            price: "Rp 450.000",
            rating: "4.9",
            category: "Wisata",
            labelPrice: "Paket Jeep",
            isEvent: false,
            imageUrl:
                "https://images.unsplash.com/photo-1510252113203-899478f69168?q=80&w=500",
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(
    BuildContext context, {
    required String title,
    required String location,
    required String price,
    required String rating,
    required String category,
    required String imageUrl,
    String labelPrice = "Harga mulai",
    bool isEvent = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(25),
                ),
                child: Image.network(
                  imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  // Menambahkan loading builder agar jika internet lambat tidak langsung error
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    );
                  },
                ),
              ),
              // Badge "Bisa Dipesan" hanya muncul jika isEvent true atau sesuai kebutuhan desainmu
              // Berdasarkan gambar, Jazz Gunung punya badge ini
              if (isEvent)
                Positioned(
                  top: 15,
                  left: 15,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          "Bisa Dipesan",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Positioned(
                top: 15,
                right: 15,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 16),
                        Text(
                          rating,
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      isEvent ? Icons.calendar_today : Icons.location_on,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          labelPrice,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          price,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF0D674D),
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D674D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                      child: const Text(
                        "Pesan Sekarang",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
