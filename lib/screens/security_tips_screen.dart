import 'package:flutter/material.dart';

class SecurityTipsScreen extends StatelessWidget {
  const SecurityTipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final List<Map<String, dynamic>> tips = [
      {
        'icon': const Icon(
          Icons.admin_panel_settings_rounded,
          color: Colors.blueAccent,
        ),
        'title': 'Use a Password Manager',
        'subtitle':
            'The single best way to stay secure is to use a password manager. It helps you create and remember unique, strong passwords for every single account.',
      },
      {
        'icon': const Icon(
          Icons.warning_amber_rounded,
          color: Colors.orangeAccent,
        ),
        'title': 'Enable Two-Factor Authentication (2FA)',
        'subtitle':
            'Adding an extra layer of security, 2FA requires a second piece of information (like a code from your phone) to log in, making it much harder for hackers to access your accounts.',
      },
      {
        'icon': const Icon(
          Icons.wifi_rounded,
          color: Colors.greenAccent,
        ),
        'title': 'Be Careful with Public Wi-Fi',
        'subtitle':
            'Public networks are often unencrypted and can be monitored by others. Avoid accessing sensitive information like banking details or personal logins while on public Wi-Fi.',
      },
      {
        'icon': const Icon(
          Icons.help_rounded,
          color: Colors.redAccent,
        ),
        'title': 'Watch Out for Phishing',
        'subtitle':
            'Be suspicious of emails or messages that ask for your personal information, especially if they look urgent or have strange links. Always verify the sender and the website URL.',
      },
      {
        'icon': const Icon(
          Icons.edit_rounded,
          color: Colors.purpleAccent,
        ),
        'title': 'Keep Your Software Updated',
        'subtitle':
            'Updates often include critical security patches. Make sure your operating system, apps, and browsers are always running the latest version to protect against known vulnerabilities.',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Security Tips"),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children:
                tips.map((tip) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: TipCard(
                      icon: tip['icon'] as Widget,
                      title: tip['title'] as String,
                      subtitle: tip['subtitle'] as String,
                    ),
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }
}

class TipCard extends StatelessWidget {
  final Widget icon;
  final String title;
  final String subtitle;

  const TipCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surface,
      elevation: 3,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: colorScheme.primaryContainer,
              ),
              child: icon,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
