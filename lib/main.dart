import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/user_provider.dart';
import 'screens/employee_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SQLite & API CRUD',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.orange,
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),
      ),
      home: const EmployeeScreen(),
    );
  }
}