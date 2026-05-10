import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rem_pass/models/users.dart';
import 'package:rem_pass/screens/parent_home.dart';
import 'package:rem_pass/core/constants/strings.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  // Function to create snackbar with Modern look
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

  // Validates and authorizes user
  void _loginUser() {
    // If form is valid
    if (_formKey.currentState!.validate()) {
      // Fetches user details from the box who has been registered
      var userBox = Hive.box<User>('userBox');
      User? storedUser = userBox.get('user');

      if (storedUser != null &&
          storedUser.password == _passwordController.text) {
        _showModernSnackBar(AppStrings.loginSuccess, isError: false);
        // If there is user in the box and his credentials are valid -> set his state to Active -> Go to HomePage() via ParentHome()
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ParentHome()),
        );
      } else {
        _passwordController.clear();
        _showModernSnackBar(AppStrings.invalidPassword, isError: true);
      }
    }
  }

  // Forgot Password function
  /// Shows a dialog to reset the master password.
  /// 
  /// The user must answer the security question set during registration.
  /// If correct, they can set a new master password.
  void _showForgotPasswordDialog() {
    final TextEditingController answerController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    bool answerVerified = false;
    String? answerError;
    final scheme = Theme.of(context).colorScheme;
    
    var userBox = Hive.box<User>('userBox');
    User? storedUser = userBox.get('user');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          answerVerified
                              ? AppStrings.setNewPassword
                              : "Verify Security Question",
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),

                        if (!answerVerified) ...[
                          Text(
                            storedUser?.securityQuestion ?? "No security question set.",
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: scheme.primary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: answerController,
                            decoration: InputDecoration(
                              labelText: AppStrings.securityAnswerLabel,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              errorText: answerError, // <-- show inline error
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppStrings.securityAnswerRequired;
                              }
                              return null;
                            },
                          ),
                        ],

                        if (answerVerified)
                          TextFormField(
                            controller: newPasswordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: AppStrings.enterNewPasswordLabel,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppStrings.passwordEmpty;
                              }
                              if (value.length < 6) {
                                return AppStrings.passwordTooShort;
                              }
                              return null;
                            },
                          ),

                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text(AppStrings.cancel),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: scheme.primary,
                                foregroundColor: Colors.white,
                              ),
                              child: Text(
                                answerVerified
                                    ? AppStrings.save
                                    : AppStrings.verify,
                              ),
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  if (!answerVerified) {
                                    // Verify answer
                                    if (storedUser != null &&
                                        storedUser.securityAnswer.trim().toLowerCase() ==
                                            answerController.text.trim().toLowerCase()) {
                                      setState(() {
                                        answerVerified = true;
                                        answerError = null; // clear error
                                      });
                                    } else {
                                      setState(() {
                                        answerError = "Incorrect answer!"; // inline error
                                      });
                                    }
                                  } else {
                                    // Save new password
                                    storedUser!.password =
                                        newPasswordController.text;
                                    userBox.put('user', storedUser);

                                    Navigator.pop(ctx);
                                    _showModernSnackBar(
                                      AppStrings.passwordResetSuccess,
                                      isError: false,
                                    );
                                  }
                                }
                              },
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(backgroundColor: colorScheme.surface, elevation: 0),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 32.0,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        AppStrings.welcomeBack,
                        style: Theme.of(
                          context,
                        ).textTheme.headlineMedium!.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.loginSubtitle,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Password field
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: AppStrings.passwordLabel,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          prefixIcon: Icon(
                            Icons.lock_rounded,
                            color: colorScheme.primary,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              color: colorScheme.primary,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        obscureText: _obscurePassword,
                        validator:
                            (value) =>
                                value!.isEmpty
                                    ? AppStrings.enterPasswordHint
                                    : null,
                      ),
                      const SizedBox(height: 32),

                      // Login button
                      ElevatedButton(
                        onPressed: _loginUser,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          AppStrings.loginButton,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Forgot password button
                      TextButton(
                        onPressed: _showForgotPasswordDialog,
                        child: Text(
                          AppStrings.forgotPassword,
                          style: TextStyle(color: colorScheme.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
