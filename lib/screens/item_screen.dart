import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_autofill_service/flutter_autofill_service.dart';
import 'package:rem_pass/models/password_entry.dart';
import 'package:rem_pass/core/constants/strings.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';

class ItemScreen extends StatefulWidget {
  const ItemScreen({super.key});

  @override
  State<ItemScreen> createState() => _ItemScreenState();
}

class _ItemScreenState extends State<ItemScreen> {
  Box<PasswordEntry>? passwordBox;

  @override
  void initState() {
    super.initState();
    passwordBox = Hive.box<PasswordEntry>('passwordsBox');
  }

  void _confirmDeleteAll(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(AppStrings.deleteAllPasswords),
            content: const Text(AppStrings.deleteAllPasswordsWarning),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(AppStrings.cancel),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  await passwordBox?.clear();
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  _showModernSnackBar(
                    AppStrings.allPasswordsDeleted,
                    isError: true,
                  );
                },
                child: const Text(
                  AppStrings.delete,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (passwordBox == null) {
      // While box is opening
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.savedPasswords,
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
            fontWeight: FontWeight.normal,
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
              tooltip: AppStrings.deleteAllPasswords,
              icon: const Icon(Icons.delete_rounded),
              color: Colors.redAccent,
              onPressed: () => _confirmDeleteAll(context),
            ),
          ),
        ],
      ),

      body: ValueListenableBuilder(
        valueListenable: passwordBox!.listenable(),
        builder: (context, Box<PasswordEntry> box, _) {
          if (box.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_rounded,
                    size: 80,
                    color: colorScheme.primary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    AppStrings.noPasswords,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: box.length,
            itemBuilder: (context, index) {
              final entry = box.getAt(index);
              return _PasswordEntryCard(
                entry: entry!,
                onTap: () => _showPasswordDialog(context, entry),
                onTrailingTap:
                    () => _showOptionsBottomSheet(context, entry, index),
              );
            },
          );
        },
      ),
    );
  }

  void _showPasswordDialog(BuildContext context, PasswordEntry entry) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              entry.appName,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${AppStrings.usernameColon}${entry.username}",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                _PasswordTextWithVisibility(password: entry.password),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(AppStrings.close),
              ),
            ],
          ),
    );
  }

  // Dialog to edit an entry
  void _showEditDialog(BuildContext context, PasswordEntry entry, int index) {
    final scheme = Theme.of(context).colorScheme;

    final TextEditingController appNameController = TextEditingController(
      text: entry.appName,
    );
    final TextEditingController usernameController = TextEditingController(
      text: entry.username,
    );
    final TextEditingController passwordController = TextEditingController(
      text: entry.password,
    );

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.edit,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: appNameController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.appNameLabel,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.usernameLabel,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.passwordLabel,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: scheme.onSurface,
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(AppStrings.cancel),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: scheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        final updated = PasswordEntry(
                          appName: appNameController.text,
                          username: usernameController.text,
                          password: passwordController.text,
                        );
                        Hive.box<PasswordEntry>(
                          'passwordsBox',
                        ).putAt(index, updated);
                        _showModernSnackBar(AppStrings.passwordUpdatedSuccess);
                        Navigator.pop(context);
                      },
                      child: const Text(
                        AppStrings.save,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Function to copy to clipboard and show snack bar
  void _copyToClipboard(String text, String type) {
    Clipboard.setData(ClipboardData(text: text));
    _showModernSnackBar("$type Copied!");
  }

  // Function to delete a password entry
  void _deleteEntry(int index) {
    passwordBox!.deleteAt(index);
    _showModernSnackBar(AppStrings.passwordDeleted, isError: true);
  }

  void _showModernSnackBar(String message, {bool isError = false}) {
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
              isError ? Icons.error_rounded : Icons.check_circle_rounded,
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

  // A dialog to show copy/delete options
  void _showOptionsBottomSheet(
    BuildContext context,
    PasswordEntry entry,
    int index,
  ) {
    final scheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: scheme.surface,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: scheme.onSurface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Icon(Icons.edit_rounded, color: scheme.primary),
                title: const Text(AppStrings.edit),
                onTap: () {
                  Navigator.pop(context);
                  _showEditDialog(context, entry, index);
                },
              ),
              ListTile(
                leading: Icon(Icons.open_in_new_rounded, color: scheme.primary),
                title: const Text('Login'),
                  onTap: () async {
                    Navigator.pop(context);
                    try {
                      List<AppInfo> apps = await InstalledApps.getInstalledApps(
                        excludeSystemApps: false,
                        withIcon: true,
                      );
                      final targetApp = apps.cast<AppInfo?>().firstWhere(
                        (app) => app?.name == entry.appName,
                        orElse: () => null,
                      );

                      if (targetApp != null &&
                          targetApp.packageName.isNotEmpty &&
                          mounted) {
                        // Save pending login info before starting the app
                        await AutofillService().savePendingLogin(
                          packageName: targetApp.packageName,
                          username: entry.username,
                          password: entry.password,
                        );

                        InstalledApps.startApp(targetApp.packageName);
                      } else if (mounted) {
                        _showModernSnackBar(
                          'App not found on this device',
                          isError: true,
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        _showModernSnackBar(
                          'Could not launch app',
                          isError: true,
                        );
                      }
                    }
                  },
              ),
              ListTile(
                leading: Icon(Icons.copy_rounded, color: scheme.primary),
                title: const Text(AppStrings.copyUsername),
                onTap: () {
                  _copyToClipboard(entry.username, "Username");
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.security_rounded, color: scheme.primary),
                title: const Text(AppStrings.copyPassword),
                onTap: () {
                  _copyToClipboard(entry.password, "Password");
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_rounded,
                  color: Colors.redAccent,
                ),
                title: const Text(
                  AppStrings.delete,
                  style: TextStyle(color: Colors.redAccent),
                ),
                onTap: () {
                  _deleteEntry(index);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PasswordTextWithVisibility extends StatefulWidget {
  final String password;
  const _PasswordTextWithVisibility({required this.password});

  @override
  State<_PasswordTextWithVisibility> createState() =>
      _PasswordTextWithVisibilityState();
}

class _PasswordTextWithVisibilityState
    extends State<_PasswordTextWithVisibility> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Text(
          AppStrings.passwordColon,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Expanded(
          child: Text(
            _isPasswordVisible ? widget.password : '•' * widget.password.length,
            style: Theme.of(context).textTheme.bodyLarge,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          icon: Icon(
            _isPasswordVisible
                ? Icons.visibility_rounded
                : Icons.visibility_off_rounded,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
      ],
    );
  }
}

class _PasswordEntryCard extends StatelessWidget {
  final PasswordEntry entry;
  final VoidCallback onTap;
  final VoidCallback onTrailingTap;

  const _PasswordEntryCard({
    required this.entry,
    required this.onTap,
    required this.onTrailingTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading:
            entry.appIcon != null
                ? Image.memory(entry.appIcon!, width: 40, height: 40)
                : CircleAvatar(
                  backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                  child: Icon(
                    Icons.lock_open_rounded,
                    color: colorScheme.primary,
                  ),
                ),
        title: Text(
          entry.appName,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          entry.username,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.more_vert_rounded,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          onPressed: onTrailingTap,
        ),
        onTap: onTap,
      ),
    );
  }
}
