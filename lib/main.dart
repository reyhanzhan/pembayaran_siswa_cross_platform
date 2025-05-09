import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart'; // Tambahkan impor ini
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/siswa_list_screen.dart';
import 'screens/siswa_detail_screen.dart';
import 'screens/payment_screen.dart';
import 'services/auth_service.dart';

void main() async {
  // Pastikan inisialisasi locale dilakukan sebelum runApp
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null); // Inisialisasi locale 'id_ID'
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        title: 'School Payment App',
        theme: ThemeData(primarySwatch: Colors.blue),
        initialRoute: '/login',
        routes: {
          '/login': (context) => LoginScreen(),
          '/dashboard': (context) => DashboardScreen(),
          '/siswa_list': (context) => SiswaListScreen(),
          '/payment': (context) => PaymentScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/siswa_detail') {
            final args = settings.arguments as int;
            return MaterialPageRoute(
              builder: (context) => SiswaDetailScreen(siswaId: args),
            );
          }
          return null;
        },
      ),
    );
  }
}