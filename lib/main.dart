import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rem_pass/models/users.dart';
import 'package:rem_pass/models/password_entry.dart';
import 'package:rem_pass/screens/splash_screen.dart';
import 'package:rem_pass/screens/autofill_screen.dart';

import 'package:rem_pass/core/constants/strings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(PasswordEntryAdapter());

  await Hive.openBox<User>('userBox');
  await Hive.openBox<PasswordEntry>('passwordsBox');

  runApp(const RootApp());
}

@pragma('vm:entry-point')
void autofillEntryPoint() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(PasswordEntryAdapter());
  await Hive.openBox<User>('userBox');
  await Hive.openBox<PasswordEntry>('passwordsBox');

  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AutofillScreen(),
    ),
  );
}

class RootApp extends StatelessWidget {
  const RootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appTitle,
      theme: ThemeData(
        fontFamily: "Inter",
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
