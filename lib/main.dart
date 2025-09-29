import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:reang_app/app/theme/app_theme.dart';
import 'package:reang_app/providers/theme_provider.dart';
// --- TAMBAHAN BARU: Import AuthProvider ---
import 'package:reang_app/providers/auth_provider.dart';
import 'package:reang_app/screens/splash_screen.dart';

// --- PERBAIKAN: Fungsi main diubah untuk memuat sesi sebelum aplikasi berjalan ---
Future<void> main() async {
  // Pastikan Flutter sudah siap sebelum menjalankan kode async
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  // --- PENAMBAHAN: Inisialisasi AuthProvider dan muat sesi dari penyimpanan aman ---
  final authProvider = AuthProvider();
  await authProvider.loadUserFromStorage();
  // --- AKHIR PENAMBAHAN ---

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        // --- PERBAIKAN: Menggunakan .value karena authProvider sudah dibuat ---
        ChangeNotifierProvider.value(value: authProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Reang App',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: const SplashScreen(),
        );
      },
    );
  }
}
