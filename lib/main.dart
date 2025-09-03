import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; // <-- 1. TAMBAHKAN IMPORT INI
import 'package:provider/provider.dart';
import 'package:reang_app/app/theme/app_theme.dart';
import 'package:reang_app/providers/theme_provider.dart';
import 'package:reang_app/screens/splash_screen.dart';

// 2. UBAH FUNGSI main MENJADI ASYNC
void main() async {
  // 3. TAMBAHKAN DUA BARIS INI
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  // AKHIR BAGIAN TAMBAHAN

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
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
          // Halaman home sekarang memanggil SplashScreen dari file yang di-import
          home: const SplashScreen(),
        );
      },
    );
  }
}
