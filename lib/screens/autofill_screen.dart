import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_autofill_service/flutter_autofill_service.dart';
import 'package:rem_pass/models/password_entry.dart';

class AutofillScreen extends StatefulWidget {
  const AutofillScreen({super.key});

  @override
  State<AutofillScreen> createState() => _AutofillScreenState();
}

class _AutofillScreenState extends State<AutofillScreen> {
  List<PasswordEntry> _matches = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAutofillMatches();
  }

  Future<void> _loadAutofillMatches() async {
    try {
      final metadata = await AutofillService().autofillMetadata;
      final packageNames = metadata?.packageNames.toList() ?? [];

      var box = Hive.box<PasswordEntry>('passwordsBox');
      final allEntries = box.values.toList();

      if (packageNames.isNotEmpty) {
        String targetPackage = packageNames.first.toLowerCase();

        _matches =
            allEntries.where((entry) {
              final appName = entry.appName.toLowerCase();
              return targetPackage.contains(appName) ||
                  appName.contains(targetPackage);
            }).toList();

        // If no fuzzy match, just show all passwords
        if (_matches.isEmpty) {
          _matches = allEntries;
        }
      } else {
        _matches = allEntries;
      }
    } catch (e) {
      debugPrint("Error loading autofill matches: \$e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSelect(PasswordEntry entry) async {
    final dataset = PwDataset(
      label: entry.appName,
      username: entry.username,
      password: entry.password,
    );

    await AutofillService().resultWithDatasets([dataset]);
    // The OS should close this UI automatically after result is set.
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_matches.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('RemPass Autofill')),
        body: const Center(child: Text("No passwords saved yet.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select account to Autofill'),
        leading: const Icon(Icons.security_rounded),
      ),
      body: ListView.separated(
        itemCount: _matches.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final entry = _matches[index];
          return ListTile(
            leading:
                entry.appIcon != null
                    ? Image.memory(entry.appIcon!, width: 40, height: 40)
                    : const Icon(Icons.lock_rounded, size: 40),
            title: Text(entry.appName),
            subtitle: Text(entry.username),
            onTap: () => _onSelect(entry),
          );
        },
      ),
    );
  }
}
