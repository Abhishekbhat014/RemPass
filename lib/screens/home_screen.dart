import 'package:flutter/material.dart';
import 'package:rem_pass/core/constants/strings.dart';
import 'package:rem_pass/models/password_entry.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rem_pass/models/users.dart';
import 'package:rem_pass/screens/add_pass.dart';
import 'package:rem_pass/screens/security_tips_screen.dart';

class HomeScreen extends StatefulWidget {
  final String firstName;
  const HomeScreen({required this.firstName, super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Box<User> userBox;
  late Box<PasswordEntry> passwordBox;

  @override
  void initState() {
    super.initState();
    userBox = Hive.box<User>('userBox');
    passwordBox = Hive.box<PasswordEntry>('passwordsBox');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: ValueListenableBuilder(
          valueListenable: userBox.listenable(),
          builder: (context, box, _) {
            final user = box.get("user");
            final firstName = user?.firstName ?? widget.firstName;

            return RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  color: colorScheme.onSurface,
                ),
                children: [
                  TextSpan(
                    text: AppStrings.helloPrefix,
                    style: TextStyle(
                      fontWeight: FontWeight.w100,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 18.0,
                    ),
                  ),
                  TextSpan(
                    text: firstName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          },
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: ValueListenableBuilder(
        valueListenable: passwordBox.listenable(),
        builder: (context, Box<PasswordEntry> box, _) {
          final savedPasswordsCount = box.length;

          final recentPasswords =
              (savedPasswordsCount > 0)
                  ? List.generate(
                    savedPasswordsCount >= 3 ? 3 : savedPasswordsCount,
                    (i) => box.getAt(savedPasswordsCount - 1 - i)!,
                  )
                  : <PasswordEntry>[];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DashboardCard(
                  cardColor: colorScheme.primary,
                  icon: const Icon(
                    Icons.security_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                  title: AppStrings.newPasswordCardTitle,
                  subtitle: AppStrings.newPasswordCardSubtitle,
                  buttonText: AppStrings.addNewButton,
                  onTap: () {},
                  onButtonTap: () {
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                            builder: (context) => const AddPassScreen(),
                          ),
                        )
                        .then((_) => setState(() {}));
                  },
                ),

                const SizedBox(height: 20),
                // NEW: Security Tips Card
                DashboardCard(
                  cardColor: colorScheme.surface,
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: colorScheme.secondaryContainer,
                    ),
                    child: Icon(
                      Icons.lightbulb_rounded,
                      color: colorScheme.onSecondaryContainer,
                      size: 24,
                    ),
                  ),
                  title: AppStrings.securityTipsCardTitle,
                  subtitle: AppStrings.securityTipsCardSubtitle,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SecurityTipsScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                if (recentPasswords.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Theme(
                      data: Theme.of(
                        context,
                      ).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        collapsedShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: const Color(0xFF4856D7),
                          ),
                          child: const Icon(Icons.history_rounded, color: Colors.white),
                        ),
                        title: const Text(
                          AppStrings.recentlyAdded,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        children:
                            recentPasswords
                                .map(
                                  (entry) => ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 4,
                                    ),
                                    leading:
                                        entry.appIcon != null
                                            ? Image.memory(
                                              entry.appIcon!,
                                              width: 40,
                                              height: 40,
                                            )
                                            : const Icon(Icons.lock_rounded),
                                    title: Text(entry.appName),
                                    subtitle: Text(entry.username),
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ------------------- Placeholder for other files -------------------

class DashboardCard extends StatelessWidget {
  final Color cardColor;
  final Widget icon;
  final String title;
  final String subtitle;
  final String? buttonText;
  final VoidCallback onTap;
  final VoidCallback? onButtonTap;

  const DashboardCard({
    super.key,
    required this.cardColor,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.buttonText,
    required this.onTap,
    this.onButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor =
        cardColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
    final subtitleColor = textColor.withValues(alpha: 0.7);

    return Material(
      color: cardColor,
      elevation: 3,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: buttonText != null ? onButtonTap : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  icon,
                  if (buttonText == null)
                    Icon(Icons.arrow_forward_rounded, color: subtitleColor),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 14, color: subtitleColor),
              ),
              if (buttonText != null) ...[
                const SizedBox(height: 16),
                InkWell(
                  onTap: onButtonTap,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      buttonText!,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
