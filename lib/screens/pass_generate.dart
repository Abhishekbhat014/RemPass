import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rem_pass/models/password_entry.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import 'package:rem_pass/screens/app_selection_screen.dart';

class PassGenerate extends StatefulWidget {
  const PassGenerate({super.key});

  @override 
  State<PassGenerate> createState() => _PassGenerateState();
}

class _PassGenerateState extends State<PassGenerate> {
  final TextEditingController _appController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  String generatedPassword = "";

  int length = 8;
  bool includeNumbers = true;
  bool includeSymbols = true;
  bool includeUppercase = true;

  List<AppInfo> _installedApps = [];
  AppInfo? _selectedAppInfo;

  @override
  void initState() {
    super.initState();
    _fetchInstalledApps();
  }

  Future<void> _fetchInstalledApps() async {
    try {
      final apps = await InstalledApps.getInstalledApps(
        excludeSystemApps: false,
        withIcon: true,
      );
      if (mounted) {
        setState(() {
          _installedApps =
              apps.where((app) => app.name.isNotEmpty).toList()
                ..sort((a, b) => a.name.compareTo(b.name));
        });
      }
    } catch (e) {
      debugPrint("Could not fetch apps: $e");
    }
  }

  Future<String?> _showManualAppDialog() async {
    final TextEditingController controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Enter App/Site Name"),
        content: TextFormField(
          controller: controller,
          decoration: const InputDecoration(hintText: "e.g. Facebook, Amazon"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  // Generate password function
  String generatePassword() {
    const String lowercase = "abcdefghijklmnopqrstuvwxyz";
    const String numbers = "0123456789";
    const String symbols = "!@#\$%^&*()_-+=<>?{}[]|";
    const String uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

    String chars = lowercase;
    if (includeUppercase) chars += uppercase;
    if (includeNumbers) chars += numbers;
    if (includeSymbols) chars += symbols;

    Random random = Random.secure();
    return List.generate(
      length,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
  }

  Future<void> _savePassword() async {
    if (_appController.text.isEmpty || generatedPassword.isEmpty) {
      _showModernSnackBar(
        "Fill all Fields and Generate Password!",
        isError: true,
      );
      return;
    }

    final box = Hive.box<PasswordEntry>('passwordsBox');
    final entry = PasswordEntry(
      appName: _appController.text,
      username: _usernameController.text,
      password: generatedPassword,
      appIcon: _selectedAppInfo?.icon,
    );

    await box.add(entry);

    if (!mounted) return;

    _showModernSnackBar("Password Saved!", isError: false);

    setState(() {
      _appController.clear();
      _usernameController.clear();
      generatedPassword = "";
    });
  }

  void _showModernSnackBar(
    String message, {
    bool isError = false,
    IconData? icon,
  }) {
    final colorscheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        backgroundColor: isError ? Colors.redAccent : colorscheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Row(
          children: [
            Icon(
              icon ??
                  (isError ? Icons.error_rounded : Icons.check_circle_rounded),
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Generate Password",
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
            fontWeight: FontWeight.normal,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Name input
              TextFormField(
                controller: _appController,
                readOnly: true,
                onTap: () async {
                  if (_installedApps.isEmpty) {
                    _showModernSnackBar(
                      "Loading apps, please wait...",
                      isError: false,
                    );
                    return;
                  }

                  final selectedAppName = await Navigator.push<String>(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => AppSelectionScreen(
                            installedApps: _installedApps,
                          ),
                    ),
                  );

                  if (selectedAppName != null) {
                    if (selectedAppName == "__ADD_MANUALLY__") {
                      final manualName = await _showManualAppDialog();
                      if (manualName != null && manualName.isNotEmpty) {
                        setState(() {
                          _appController.text = manualName;
                          _selectedAppInfo = null;
                        });
                      }
                    } else {
                      setState(() {
                        _appController.text = selectedAppName;
                        try {
                          _selectedAppInfo = _installedApps.firstWhere(
                            (element) => element.name == selectedAppName,
                          );
                        } catch (e) {
                          _selectedAppInfo = null;
                        }
                      });
                    }
                  }
                },
                decoration: InputDecoration(
                  labelText: 'App / Site Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  prefixIcon: Icon(
                    Icons.widgets_rounded,
                    color: colorScheme.primary,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                textInputAction: TextInputAction.next,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              // Username input
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username / Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  prefixIcon: Icon(
                    Icons.person_rounded,
                    color: colorScheme.primary,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                textInputAction: TextInputAction.next,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Password options
              Text(
                "Password Length: $length",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Slider(
                value: length.toDouble(),
                min: 6,
                max: 32,
                divisions: 26,
                label: "$length",
                onChanged: (value) {
                  setState(() {
                    length = value.toInt();
                  });
                },
              ),
              SwitchListTile(
                title: const Text("Include Uppercase Letters"),
                value: includeUppercase,
                onChanged: (val) => setState(() => includeUppercase = val),
              ),
              SwitchListTile(
                title: const Text("Include Numbers"),
                value: includeNumbers,
                onChanged: (val) => setState(() => includeNumbers = val),
              ),
              SwitchListTile(
                title: const Text("Include Symbols"),
                value: includeSymbols,
                onChanged: (val) => setState(() => includeSymbols = val),
              ),
              const SizedBox(height: 16),

              // Generated Password
              if (generatedPassword.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: colorScheme.primary),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          generatedPassword,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy_rounded),
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: generatedPassword),
                          );
                          _showModernSnackBar(
                            "Password Copied!",
                            isError: false,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text(
                        "Generate",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        setState(() {
                          generatedPassword = generatePassword();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      // Style the button
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor:
                            Colors.white, // Set the color for the icon and text
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            10,
                          ), // Optional: Add rounded corners for a nicer look
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ), // Optional: Adjust padding for size
                      ),
                      icon: const Icon(
                        Icons.collections_bookmark_rounded,
                      ),
                      label: const Text(
                        "Save",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: _savePassword,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
