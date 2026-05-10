import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import 'package:rem_pass/models/password_entry.dart';
import 'package:rem_pass/core/constants/strings.dart';
import 'package:rem_pass/screens/app_selection_screen.dart';

class AddPassScreen extends StatefulWidget {
  const AddPassScreen({super.key});

  @override
  State<AddPassScreen> createState() => _AddPassScreenState();
}

class _AddPassScreenState extends State<AddPassScreen> {
  final _formKey = GlobalKey<FormState>();

  final _autocompleteCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _obscure = true;
  bool _saving = false;
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

  @override
  void dispose() {
    _autocompleteCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  /// Saves the new password entry to Hive.
  /// 
  /// Validates the form, constructs a [PasswordEntry], and adds it to the box.
  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final box = Hive.box<PasswordEntry>('passwordsBox');

      //  Adjust field names if your PasswordEntry model differs
      final entry = PasswordEntry(
        appName: _autocompleteCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
        username: _usernameCtrl.text,
        appIcon: _selectedAppInfo?.icon,
      );

      await box.add(entry);

      if (!mounted) return;
      _showModernSnackBar(AppStrings.passwordSaved, isError: false);

      // pop back and let caller refresh
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showModernSnackBar(AppStrings.failedToSave, isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
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
                  (isError
                      ? Icons.error_rounded
                      : Icons.check_circle_rounded),
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

  /// Shows a dialog to enter the app or site name manually.
  /// 
  /// Used when the user selects "Add manually" from the app selection screen.
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

  /// Generates a strong random password.
  /// 
  /// Ensures at least one uppercase, one lowercase, one digit, and one symbol.
  /// The password length is fixed at 16 characters.
  void _generatePassword() {
    const upper = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
    const lower = 'abcdefghijkmnopqrstuvwxyz';
    const digits = '23456789';
    const symbols = r'!@#%^&*()-_=+[]{}?';

    String pick(String s) => s[Random.secure().nextInt(s.length)];

    // ensure at least one from each, then fill up
    final length = 16;
    final pool = (upper + lower + digits + symbols).split('');

    final chars = <String>[
      pick(upper),
      pick(lower),
      pick(digits),
      pick(symbols),
    ];

    while (chars.length < length) {
      chars.add(pool[Random.secure().nextInt(pool.length)]);
    }

    chars.shuffle(Random.secure());
    setState(() => _passwordCtrl.text = chars.join());
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.addPasswordTitle),
        backgroundColor: scheme.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child: AbsorbPointer(
          absorbing: _saving,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _autocompleteCtrl,
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
                              _autocompleteCtrl.text = manualName;
                              _selectedAppInfo = null;
                            });
                          }
                        } else {
                          setState(() {
                            _autocompleteCtrl.text = selectedAppName;
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
                      labelText: AppStrings.appOrSiteNameLabel,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      prefixIcon: Icon(
                        Icons.widgets_rounded,
                        color: scheme.primary,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    textInputAction: TextInputAction.next,
                    validator:
                        (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),

                  // Username / Email (optional)
                  TextFormField(
                    controller: _usernameCtrl,
                    decoration: InputDecoration(
                      labelText: AppStrings.usernameOrEmailLabel,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      prefixIcon: Icon(
                        Icons.person_rounded,
                        color: scheme.primary,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    textInputAction: TextInputAction.next,
                    validator:
                        (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),

                  // Password
                  TextFormField(
                    controller: _passwordCtrl,
                    decoration: InputDecoration(
                      labelText: AppStrings.passwordLabel,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      prefixIcon: Icon(
                        Icons.lock_rounded,
                        color: scheme.primary,
                      ),
                      // two buttons in suffix: generate + show/hide
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: AppStrings.generateStrongPasswordTooltip,
                            onPressed: _generatePassword,
                            icon: Icon(
                              Icons.key_rounded,
                              color: scheme.primary,
                            ),
                          ),
                          IconButton(
                            tooltip:
                                _obscure
                                    ? AppStrings.showTooltip
                                    : AppStrings.hideTooltip,
                            onPressed:
                                () => setState(() => _obscure = !_obscure),
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              color: scheme.primary,
                            ),
                          ),
                        ],
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    obscureText: _obscure,
                    validator:
                        (v) =>
                            (v == null || v.isEmpty)
                                ? AppStrings.passwordEmpty
                                : null,
                  ),
                  const SizedBox(height: 16),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _saving ? null : _saveEntry,
                      icon:
                          _saving
                              ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Icon(
                                Icons.collections_bookmark_rounded,
                              ),
                      label: Text(
                        _saving
                            ? AppStrings.saving
                            : AppStrings.savePasswordButton,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: scheme.primary,
                        foregroundColor: scheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
