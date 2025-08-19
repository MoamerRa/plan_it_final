import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:planit_mt/providers/admin_provider.dart';
import 'package:planit_mt/providers/booking_provider.dart';
import 'package:planit_mt/providers/chat_provider.dart';
import 'package:planit_mt/providers/event_provider.dart';
import 'package:planit_mt/providers/expense_provider.dart';
import 'package:planit_mt/providers/guest_provider.dart';
import 'package:planit_mt/providers/post_provider.dart';
import 'package:planit_mt/providers/recommendationprovider.dart';
import 'package:planit_mt/providers/report_provider.dart';
import 'package:planit_mt/providers/task_provider.dart';
import 'package:planit_mt/providers/user_provider.dart';
import 'package:planit_mt/providers/vendor_provider.dart';
import 'package:planit_mt/routes/app_routes.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    runApp(const MyApp());
  } catch (e, stackTrace) {
    if (kDebugMode) {
      print('Error during app startup: $e');
    }
    if (kDebugMode) {
      print('Stack trace: $stackTrace');
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => VendorProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => RecommendationProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => GuestProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
      ],
      child: MaterialApp(
        title: 'PlanIt App',
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: AppRoutes.routes,
      ),
    );
  }
}
