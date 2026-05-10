import 'dart:io';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:installed_apps/installed_apps.dart';
import 'dart:typed_data';
import 'package:rem_pass/models/password_entry.dart';
import 'package:rem_pass/models/users.dart';
import 'package:rem_pass/screens/about_us_screen.dart';
import 'package:rem_pass/screens/faq_screen.dart';
import 'package:rem_pass/screens/login_screen.dart';
import 'package:rem_pass/screens/privacy_policy_screen.dart';
import 'package:rem_pass/screens/register_screen.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:rem_pass/screens/terms_condition_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_autofill_service/flutter_autofill_service.dart';
import 'package:rem_pass/core/constants/strings.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? currentUser;
  late final Box<User> userBox;
  late final Box<PasswordEntry> passwordBox;

  @override
  void initState() {
    super.initState();
    userBox = Hive.box<User>('userBox');
    passwordBox = Hive.box<PasswordEntry>('passwordsBox');
    _loadUser();
  }

  /// Imports passwords from a CSV file.
  /// 
  /// The CSV file must have a specific format:
  /// Line 1: FILE_PASSWORD,`encrypted_password`
  /// Line 2: Header (App,Username,Password)
  /// Line 3+: Data rows
  /// 
  /// This method prompts for the file password to decrypt the contents.
  /// It also attempts to restore app icons by matching names with installed apps.
  Future<void> _importPasswords() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ["csv"],
      );
      if (result == null) return;

      final file = File(result.files.single.path!);
      final csvString = await file.readAsString();
      final lines =
          csvString
              .split("\n")
              .where((line) => line.trim().isNotEmpty)
              .toList();

      if (lines.isEmpty) {
        _showModernSnackBar(AppStrings.fileIsEmpty, isError: true);
        return;
      }

      // First row: FILE_PASSWORD
      final filePasswordRow = lines[0].split(",");
      if (filePasswordRow.length < 2 || filePasswordRow[0] != "FILE_PASSWORD") {
        _showModernSnackBar(AppStrings.invalidFileFormat, isError: true);
        return;
      }

      final encryptedFilePassword = filePasswordRow[1].trim();
      final enteredPassword = await _askUserForPassword(
        AppStrings.enterFilePassword,
      );
      if (enteredPassword == null || enteredPassword.isEmpty) {
        _showModernSnackBar(AppStrings.importCancelled, isError: true);
        return;
      }

      // Decrypt file password using CryptoHelper
      String? decryptedFilePassword;
      try {
        decryptedFilePassword = CryptoHelper.decryptText(encryptedFilePassword);
      } catch (_) {
        decryptedFilePassword = null;
      }

      // Validation
      if (decryptedFilePassword == null ||
          decryptedFilePassword != enteredPassword) {
        _showModernSnackBar(AppStrings.wrongPasswordOrCorrupted, isError: true);
        return;
      }

      // Fetch apps to restore icons if possible
      final apps = await InstalledApps.getInstalledApps(
        excludeSystemApps: false,
        withIcon: true,
      );

      int importedCount = 0;
      for (var i = 2; i < lines.length; i++) {
        final parts = lines[i].split(",");
        if (parts.length < 3) continue;

        final app = parts[0].trim();
        final user = parts[1].trim();
        final encryptedPass = parts[2].trim();

        String? pass;
        try {
          pass = CryptoHelper.decryptText(encryptedPass);
        } catch (_) {
          continue;
        }

        final exists = passwordBox.values.any(
          (e) => e.appName == app && e.username == user && e.password == pass,
        );
        if (!exists) {
          Uint8List? icon;
          try {
            icon = apps.firstWhere((element) => element.name == app).icon;
          } catch (_) {
            icon = null;
          }

          final entry = PasswordEntry(
            appName: app,
            username: user,
            password: pass,
            appIcon: icon,
          );
          await passwordBox.add(entry);
          importedCount++;
        }
      }

      if (importedCount > 0) {
        _showModernSnackBar(
          "Imported $importedCount passwords!",
          isError: false,
        );
      } else {
        _showModernSnackBar(AppStrings.noNewPasswords, isError: true);
      }
    } catch (e) {
      _showModernSnackBar("Import failed: $e", isError: true);
    }
  }

  /// Exports all stored passwords to a CSV file.
  /// 
  /// The file is protected by a password entered by the user.
  /// The passwords themselves are also encrypted in the CSV file.
  Future<void> _exportPasswords() async {
    try {
      final filePassword = await _askUserForPassword(
        AppStrings.enterExportPassword,
      );
      if (filePassword == null || filePassword.isEmpty) return;

      final buffer = StringBuffer();

      final encryptedFilePassword = CryptoHelper.encryptText(filePassword);
      buffer.writeln("FILE_PASSWORD,$encryptedFilePassword");

      // Header
      buffer.writeln("App,Username,Password");

      // Encrypt each password
      for (var entry in passwordBox.values) {
        final app = entry.appName;
        final user = entry.username;
        final encryptedPass = CryptoHelper.encryptText(entry.password);
        buffer.writeln("$app,$user,$encryptedPass");
      }

      final bytes = utf8.encode(buffer.toString());

      final filePath = await FilePicker.platform.saveFile(
        fileName: "passwords.csv",
        allowedExtensions: ["csv"],
        type: FileType.custom,
        bytes: bytes,
      );

      if (filePath != null) {
        _showModernSnackBar(
          AppStrings.passwordsExportedSuccess,
          isError: false,
        );
      }
    } catch (e) {
      _showModernSnackBar("Export failed: $e", isError: true);
    }
  }

  void _loadUser() {
    setState(() {
      currentUser = userBox.get('user');
    });
  }

  Future<void> logout(BuildContext context) async {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );

    _showModernSnackBar(
      AppStrings.logoutSuccess,
      isError: false,
      icon: Icons.logout_rounded,
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppStrings.deleteAccount,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    AppStrings.deleteAccountWarning,
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(AppStrings.cancel),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          userBox.delete('user');
                          Hive.box<PasswordEntry>('passwordsBox').clear();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                            (_) => false,
                          );
                        },
                        child: const Text(AppStrings.delete),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  /// Shows a dialog to edit the user's profile information.
  /// 
  /// Allows updating first name, email, and date of birth.
  /// Validates inputs before saving to Hive.
  void _editProfile() {
    final controllers = {
      AppStrings.firstNameLabel: TextEditingController(
        text: currentUser?.firstName,
      ),
      AppStrings.emailLabel: TextEditingController(text: currentUser?.email),
      AppStrings.dobLabel: TextEditingController(text: currentUser?.dob),
    };

    final scheme = Theme.of(context).colorScheme;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.editProfile,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildValidatedField(
                        AppStrings.firstNameLabel,
                        controllers[AppStrings.firstNameLabel]!,
                        validator:
                            (v) =>
                                v == null || v.trim().isEmpty
                                    ? AppStrings.firstNameRequired
                                    : null,
                      ),
                      _buildValidatedField(
                        AppStrings.emailLabel,
                        controllers[AppStrings.emailLabel]!,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return AppStrings.emailRequired;
                          }
                          final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                          return regex.hasMatch(v)
                              ? null
                              : AppStrings.emailInvalid;
                        },
                      ),
                      _buildValidatedField(
                        AppStrings.dobLabel,
                        controllers[AppStrings.dobLabel]!,
                        validator:
                            (v) =>
                                v == null || v.isEmpty
                                    ? AppStrings.dobRequired
                                    : null,
                        readOnly: true,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate:
                                _parseDob(currentUser?.dob) ?? DateTime(2000),

                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            controllers[AppStrings.dobLabel]!.text =
                                "${picked.day.toString().padLeft(2, '0')}/"
                                "${picked.month.toString().padLeft(2, '0')}/"
                                "${picked.year}";
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel"),
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
                              if (formKey.currentState!.validate()) {
                                currentUser!
                                  ..firstName =
                                      controllers[AppStrings.firstNameLabel]!
                                          .text
                                          .trim()
                                  ..email =
                                      controllers[AppStrings.emailLabel]!.text
                                          .trim()
                                  ..dob =
                                      controllers[AppStrings.dobLabel]!.text
                                          .trim();

                                userBox.put('user', currentUser!);
                                setState(() {});
                                Navigator.pop(context);

                                _showModernSnackBar(
                                  AppStrings.profileUpdatedSuccess,
                                  isError: false,
                                );
                              }
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
              ),
            ),
          ),
    );
  }

  DateTime? _parseDob(String? dob) {
    if (dob == null || dob.isEmpty) return null;
    try {
      final parts = dob.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (_) {}
    return null;
  }

  Widget _buildValidatedField(
    String label,
    TextEditingController controller, {
    String? Function(String?)? validator,
    bool obscure = false,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        validator: validator,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 12,
          ),
        ),
      ),
    );
  }

  void _changeUserPassword() {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final scheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppStrings.changeAppPassword,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildValidatedField(
                        AppStrings.currentPassword,
                        currentController,
                        obscure: true,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return AppStrings.currentPasswordRequired;
                          }
                          if (v != currentUser!.password) {
                            return AppStrings.currentPasswordIncorrect;
                          }
                          return null;
                        },
                      ),
                      _buildValidatedField(
                        AppStrings.passwordLabel,
                        newController,
                        obscure: true,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return AppStrings.passwordEmpty;
                          }
                          if (v.length < 6) {
                            return AppStrings.passwordTooShort;
                          }
                          return null;
                        },
                      ),
                      _buildValidatedField(
                        AppStrings.confirmPassword,
                        confirmController,
                        obscure: true,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return AppStrings.confirmPasswordRequired;
                          }
                          if (v != newController.text) {
                            return AppStrings.passwordsDoNotMatch;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel"),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              foregroundColor: Colors.white,
                              backgroundColor: scheme.primary,
                            ),
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                currentUser!.password = newController.text;
                                userBox.put('user', currentUser!);
                                Navigator.pop(context);
                                _showModernSnackBar(
                                  AppStrings.passwordUpdatedSuccess,
                                  isError: false,
                                );
                              }
                            },
                            child: const Text(AppStrings.save),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }

  /// Shows a dialog to change the user's security question.
  /// 
  /// The user must first verify their current security answer
  /// before they can set a new question and answer.
  void _changeSecurityQuestion() {
    final currentAnswerController = TextEditingController();
    final newAnswerController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final scheme = Theme.of(context).colorScheme;
    String? selectedQuestion;
    bool currentAnswerVerified = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currentAnswerVerified ? "Set New Security Question" : "Verify Current Answer",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (!currentAnswerVerified) ...[
                        Text(
                          currentUser?.securityQuestion ?? "No security question set.",
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: scheme.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildValidatedField(
                          AppStrings.currentAnswerLabel,
                          currentAnswerController,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return AppStrings.currentAnswerRequired;
                            }
                            return null;
                          },
                        ),
                      ],
                      if (currentAnswerVerified) ...[
                        DropdownButtonFormField<String>(
                          initialValue: selectedQuestion,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: AppStrings.securityQuestionLabel,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: AppStrings.securityQuestions.map((String question) {
                            return DropdownMenuItem<String>(
                              value: question,
                              child: Text(
                                question,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedQuestion = newValue;
                            });
                          },
                          validator: (value) =>
                              value == null ? AppStrings.securityQuestionRequired : null,
                        ),
                        const SizedBox(height: 12),
                        _buildValidatedField(
                          AppStrings.securityAnswerLabel,
                          newAnswerController,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return AppStrings.securityAnswerRequired;
                            }
                            return null;
                          },
                        ),
                      ],
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel"),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              foregroundColor: Colors.white,
                              backgroundColor: scheme.primary,
                            ),
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                if (!currentAnswerVerified) {
                                  if (currentAnswerController.text.trim().toLowerCase() ==
                                      currentUser!.securityAnswer.trim().toLowerCase()) {
                                    setState(() {
                                      currentAnswerVerified = true;
                                    });
                                  } else {
                                    _showModernSnackBar(
                                      AppStrings.currentAnswerIncorrect,
                                      isError: true,
                                    );
                                  }
                                } else {
                                  currentUser!.securityQuestion = selectedQuestion!;
                                  currentUser!.securityAnswer = newAnswerController.text.trim();
                                  userBox.put('user', currentUser!);
                                  Navigator.pop(context);
                                  _showModernSnackBar(
                                    "Security question updated successfully!",
                                    isError: false,
                                  );
                                }
                              }
                            },
                            child: Text(currentAnswerVerified ? AppStrings.save : AppStrings.verify),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (currentUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.myProfile),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
              tooltip: AppStrings.logout,
              color: Colors.redAccent,
              onPressed: () => logout(context),
              icon: const Icon(Icons.logout_rounded),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: colorScheme.primary.withValues(alpha: 0.2),
              child: Text(
                currentUser!.firstName[0].toUpperCase(),
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              currentUser!.firstName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const Divider(height: 32),
            InfoCard(
              icon: Icons.email_rounded,
              label: AppStrings.emailLabel,
              value: currentUser!.email,
            ),
            const SizedBox(height: 16),
            InfoCard(
              icon: Icons.calendar_today_rounded,
              label: AppStrings.dobLabel,
              value: currentUser!.dob,
            ),
            const SizedBox(height: 48),

            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.accountSettings,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildActionListTile(
                    AppStrings.editProfile,
                    _editProfile,
                    icon: Icons.edit_rounded,
                    color: Colors.black,
                  ),
                  _buildActionListTile(
                    AppStrings.changeAppPassword,
                    _changeUserPassword,
                    icon: Icons.lock_rounded,
                    color: Colors.black,
                  ),
                  _buildActionListTile(
                    "Change Security Question",
                    _changeSecurityQuestion,
                    icon: Icons.help_outline_rounded,
                    color: Colors.black,
                  ),
                  _buildActionListTile(
                    AppStrings.exportPasswords,
                    _exportPasswords,
                    icon: Icons.import_export_rounded,
                    color: Colors.black,
                  ),
                  _buildActionListTile(
                    AppStrings.importPasswords,
                    _importPasswords,
                    icon: Icons.save_alt_rounded,
                    color: Colors.black,
                  ),
                  _buildActionListTile(
                    "Enable System Autofill",
                    () async {
                      bool hasSupport =
                          await AutofillService().hasAutofillServicesSupport;
                      if (!hasSupport && mounted) {
                        _showModernSnackBar(
                          "Autofill not supported on this device.",
                          isError: true,
                        );
                        return;
                      }
                      await AutofillService().requestSetAutofillService();
                    },
                    icon: Icons.settings_applications_rounded,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.privacyCenter,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildActionListTile(
                    AppStrings.privacyPolicy,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PrivacyPolicyScreen(),
                        ),
                      );
                    },
                    icon: Icons.shield_rounded,
                    color: Colors.black,
                  ),
                  _buildActionListTile(
                    AppStrings.termsAndConditions,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TermsAndConditionsScreen(),
                        ),
                      );
                    },
                    icon: Icons.gavel_rounded,
                    color: Colors.black,
                  ),
                  _buildActionListTile(
                    AppStrings.deleteAccount,
                    _deleteAccount,
                    icon: Icons.delete_rounded,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.general,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildActionListTile(
                    AppStrings.faq,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FAQScreen()),
                      );
                    },
                    icon: Icons.help_rounded,
                    color: Colors.black,
                  ),
                  _buildActionListTile(
                    AppStrings.sendFeedback,
                    _shareFeedback,
                    icon: Icons.mail_rounded,
                    color: Colors.black,
                  ),
                  _buildActionListTile(
                    AppStrings.aboutUs,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AboutUsScreen(),
                        ),
                      );
                    },
                    icon: Icons.info_rounded,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionListTile(
    String title,
    VoidCallback onTap, {
    required IconData icon,
    required Color color,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.transparent,
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_rounded, size: 16),
      onTap: onTap,
    );
  }

  Future<void> _shareFeedback() async {
    final TextEditingController feedbackController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Send Feedback",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      controller: feedbackController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: "Enter your feedback here...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Feedback cannot be empty.";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel"),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              Navigator.pop(context);
                              _sendFeedback(context, feedbackController.text);
                            }
                          },
                          child: const Text("Send"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _sendFeedback(BuildContext context, String feedback) async {
    final Uri emailUri = Uri.parse(
      "mailto:rempass.dev@gmail.com?subject=${Uri.encodeComponent('App Feedback')}&body=${Uri.encodeComponent(feedback)}",
    );

    // Ask user how they want to send feedback
    final choice = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Send Feedback"),
          content: const Text("How would you like to send your feedback?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, "email"),
              child: const Text("Email"),
            ),
          ],
        );
      },
    );

    if (choice == "email") {
      try {
        if (await canLaunchUrl(emailUri)) {
          await launchUrl(emailUri, mode: LaunchMode.platformDefault);
        } else {
          _showModernSnackBar(
            "Email not supported on this device.",
            isError: true,
          );
        }
      } catch (e) {
        _showModernSnackBar("Failed to send email.", isError: true);
      }
    }
  }

  Future<String?> _askUserForPassword(String title) async {
    String? input;
    await showDialog(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            obscureText: true,
            decoration: InputDecoration(hintText: "Enter password"),
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(ctx),
            ),
            TextButton(
              child: Text("OK"),
              onPressed: () {
                input = controller.text;
                Navigator.pop(ctx);
              },
            ),
          ],
        );
      },
    );
    return input;
  }

  void _showModernSnackBar(
    String message, {
    bool isError = false,
    IconData? icon,
  }) {
    if (!mounted) return;
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
}

class InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const InfoCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.primary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CryptoHelper {
  // Using key (32 chars = 256-bit AES key)
  static final _key = enc.Key.fromUtf8('12345678901234567890123456789012');

  // Using fixed IV (16 chars)
  static final _iv = enc.IV.fromUtf8('1234567890123456');

  static String encryptText(String plainText) {
    final encrypter = enc.Encrypter(enc.AES(_key));
    final encrypted = encrypter.encrypt(plainText, iv: _iv);
    return encrypted.base64;
  }

  static String decryptText(String cipherText) {
    try {
      final encrypter = enc.Encrypter(enc.AES(_key));
      final decrypted = encrypter.decrypt64(cipherText, iv: _iv);
      return decrypted;
    } catch (e) {
      // Debugging help if CSV is wrong
      throw ArgumentError("Failed to decrypt");
    }
  }
}
