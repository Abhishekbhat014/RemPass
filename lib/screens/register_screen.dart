import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rem_pass/models/users.dart';
import 'package:rem_pass/screens/login_screen.dart';
import 'package:intl/intl.dart';
import 'package:rem_pass/core/constants/strings.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();
  String? _selectedQuestion;

  @override
  void dispose() {
    _firstNameController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  /// Registers a new user and saves their profile to Hive.
  /// 
  /// Validates the form, creates a [User] object, and saves it with the key 'user'.
  /// Also sets the security question and answer for recovery.
  void _registerUser() async {
    if (_formKey.currentState!.validate()) {
      // Create user with isActive true
      User newUser = User(
        firstName: _firstNameController.text,
        lastName: "",
        dob: _dobController.text,
        contact: "",
        email: _emailController.text,
        password: _passwordController.text,
        securityQuestion: _selectedQuestion!,
        securityAnswer: _answerController.text.trim(),
      );

      var userBox = Hive.box<User>('userBox');

      // Save user with key 'user' which we are using in main.dart for checking user session and  user availability
      await userBox.put('user', newUser);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  //  Function to show calendar and set DOB
  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      // Set default selected date
      initialDate: DateTime(2000),
      // Earliest date which can be selected
      firstDate: DateTime(1900),
      // Max to max today is can be selected
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      String formattedDate = DateFormat("dd/MM/yyyy").format(pickedDate);
      setState(() {
        _dobController.text = formattedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(backgroundColor: colorScheme.surface, elevation: 0),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
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
                      AppStrings.welcome,
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
                      AppStrings.registerSubtitle,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // First Name field
                    TextFormField(
                      controller: _firstNameController,
                      decoration: InputDecoration(
                        labelText: AppStrings.firstNameLabel,
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
                      validator:
                          (value) =>
                              value!.isEmpty
                                  ? AppStrings.firstNameRequired
                                  : null,
                    ),
                    const SizedBox(height: 16),



                    //  Date of Birth field with Calendar
                    TextFormField(
                      controller: _dobController,
                      readOnly: true, // disable typing
                      onTap: _selectDate, // open calendar picker
                      decoration: InputDecoration(
                        labelText: AppStrings.dobLabel,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        prefixIcon: Icon(
                          Icons.event_rounded,
                          color: colorScheme.primary,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      validator:
                          (value) =>
                              value!.isEmpty ? AppStrings.dobRequired : null,
                    ),
                    const SizedBox(height: 16),



                    // Email field
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: AppStrings.emailLabel,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        prefixIcon: Icon(
                          Icons.email_rounded,
                          color: colorScheme.primary,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppStrings.emailRequired;
                        }

                        // Basic email regex
                        const emailPattern =
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
                        final regex = RegExp(emailPattern);

                        if (!regex.hasMatch(value.trim())) {
                          return AppStrings.emailInvalid;
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Password field
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: AppStrings.appPasswordLabel,
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
                              _obscurePassword =
                                  !_obscurePassword; // toggle state
                            });
                          },
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      obscureText: _obscurePassword, // show as * when true
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
                    const SizedBox(height: 16),

                    // Security Question Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _selectedQuestion,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: AppStrings.securityQuestionLabel,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        prefixIcon: Icon(
                          Icons.help_outline_rounded,
                          color: colorScheme.primary,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
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
                          _selectedQuestion = newValue;
                        });
                      },
                      validator: (value) =>
                          value == null ? AppStrings.securityQuestionRequired : null,
                    ),
                    const SizedBox(height: 16),

                    // Security Answer field
                    TextFormField(
                      controller: _answerController,
                      decoration: InputDecoration(
                        labelText: AppStrings.securityAnswerLabel,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        prefixIcon: Icon(
                          Icons.question_answer_rounded,
                          color: colorScheme.primary,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? AppStrings.securityAnswerRequired
                              : null,
                    ),

                    const SizedBox(height: 32),

                    // Register button
                    ElevatedButton(
                      onPressed: _registerUser,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        AppStrings.registerButton,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
