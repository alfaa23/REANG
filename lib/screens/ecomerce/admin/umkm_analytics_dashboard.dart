import 'package:flutter/material.dart';

/// ============================================================================
///  UMKM ANALYTICS DASHBOARD (CONTENT ONLY)
///  - Tidak menggunakan Scaffold, karena akan ditempatkan di halaman admin
///  - Semua warna menggunakan ThemeData → mendukung dark/light mode
/// ============================================================================
class UMKMAnalyticsDashboardContent extends StatelessWidget {
  const UMKMAnalyticsDashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(theme),
          const SizedBox(height: 24),

          _buildAnalyticSection(theme),
          const SizedBox(height: 24),

          _buildWeeklySalesChart(theme),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HEADER
  // ---------------------------------------------------------------------------
  Widget _buildHeader(ThemeData theme) {
    return Text(
      'Analitik Penjualan',
      style: theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  //  BAGIAN 2: KARTU ANALITIK (Seragam)
  // ---------------------------------------------------------------------------
  Widget _buildAnalyticSection(ThemeData theme) {
    return Column(
      children: [
        _buildAnalyticCard(
          theme: theme,
          title: 'Total Penjualan',
          value: 'Rp 1.250.000',
          icon: Icons.attach_money,
          iconColor: const Color(0xFF32CD32),
        ),
        const SizedBox(height: 18),

        _buildAnalyticCard(
          theme: theme,
          title: 'Total Pesanan',
          value: '156',
          icon: Icons.shopping_bag_outlined,
          iconColor: const Color(0xFF42A5F5),
        ),
        const SizedBox(height: 18),

        _buildAnalyticCard(
          theme: theme,
          title: 'Total Produk',
          value: '23',
          icon: Icons.inventory_2_outlined,
          iconColor: const Color(0xFFFFB74D),
        ),
        const SizedBox(height: 18),

        _buildAnalyticCard(
          theme: theme,
          title: 'Pertumbuhan Bulanan',
          value: '+15.2%',
          icon: Icons.trending_up,
          iconColor: Colors.green,
        ),
      ],
    );
  }

  Widget _buildAnalyticCard({
    required ThemeData theme,
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Teks (judul + nilai)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          // Ikon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  //  BAGIAN 3: GRAFIK PENJUALAN MINGGUAN
  // ---------------------------------------------------------------------------
  Widget _buildWeeklySalesChart(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Grafik Penjualan Mingguan',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            height: 240,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBar(theme, 'Sen', 0.50),
                _buildBar(theme, 'Sel', 0.75),
                _buildBar(theme, 'Rab', 0.95),
                _buildBar(theme, 'Kam', 0.45),
                _buildBar(theme, 'Jum', 1.00),
                _buildBar(theme, 'Sab', 0.60),
                _buildBar(theme, 'Min', 0.70),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Bar tunggal
  Widget _buildBar(ThemeData theme, String day, double factor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 30,
          height: 180 * factor,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          day,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
