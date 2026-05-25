import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import 'injection_container.dart' as di;
import 'core/router/app_router.dart';
import 'core/services/auth_event_bus.dart';
import 'core/theme/app_theme.dart';

// Global variable for camera access across the app
late List<CameraDescription> cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    cameras = await availableCameras();
  } catch (e) {
    cameras = [];
    debugPrint('Camera initialization failed: $e');
  }

  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription _authSubscription;

  @override
  void initState() {
    super.initState();

    _authSubscription = di.sl<AuthEventBus>().authStream.listen((event) {
      if (event == AuthEvent.sessionExpired) {
        _handleSessionExpired();
      }
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  void _handleSessionExpired() {
    final context = rootNavigatorKey.currentContext;
    if (context == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Session Expired',
              style: TextStyle(color: Color(0xFF8B0000))),
          content: const Text(
              'Your authentication token has expired. Please log in again.'),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal, foregroundColor: Colors.white),
              child: const Text('BACK TO LOGIN'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.go('/'); // Route back to the Admin Login
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Manappuram ERP Portal',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: AppTheme.lightTheme,
    );
  }
}
