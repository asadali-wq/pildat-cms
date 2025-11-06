// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pildat_cms/providers/auth_provider.dart';
import 'package:pildat_cms/providers/dropdown_provider.dart'; // <-- IMPORT
import 'package:pildat_cms/screens/dashboard_screen.dart';
import 'package:pildat_cms/screens/loading_screen.dart';
import 'package:pildat_cms/screens/login_screen.dart';
import 'package:pildat_cms/services/api_service.dart';

void main() {
  runApp(const MyApp());
}

// --- REPLACE THE ENTIRE MyApp WIDGET WITH THIS ---
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>(
          create: (_) => ApiService(),
        ),
        
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            Provider.of<ApiService>(context, listen: false),
          ),
        ),
        
        // --- ADD THIS NEW PROVIDER ---
        ChangeNotifierProvider<DropdownProvider>(
          create: (context) => DropdownProvider(
            Provider.of<ApiService>(context, listen: false),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'PILDAT CMS',
        theme: ThemeData(
          primaryColor: const Color(0xFF008CBA),
          fontFamily: 'Inter',
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authStatus = Provider.of<AuthProvider>(context).status;

    switch (authStatus) {
      case AuthStatus.loading:
      case AuthStatus.uninitialized:
        return const LoadingScreen();
      case AuthStatus.authenticated:
        return const DashboardScreen();
      case AuthStatus.unauthenticated:
        return const LoginScreen();
    }
  }
}