import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text("Privacy Policy"),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Our Commitment to Your Privacy",
                style: textTheme.headlineMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "This policy explains how our password manager application handles your information, built on a commitment to security and privacy.",
                style: textTheme.bodyLarge!.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 24),
              _buildSection(
                context,
                title: "1. Information We Collect",
                content:
                    "Our primary goal is a \"zero-knowledge\" model. We do not store or access your sensitive data, including your passwords or encryption keys. All sensitive data is encrypted on your device and can only be decrypted with your master password.\n\nWe may collect the following non-sensitive, non-identifiable information:\n\n• Feedback: We collect only your feedback which helps us to improve.",
              ),
              const SizedBox(height: 16),
              _buildSection(
                context,
                title: "2. How We Use Your Information",
                content:
                    "The information we collect is used solely to provide, maintain, and improve the App's functionality, analyze usage patterns to enhance the user experience, and address technical issues.",
              ),
              const SizedBox(height: 16),
              _buildSection(
                context,
                title: "3. Data Security",
                content:
                    "Your data's security is paramount. We use industry-standard encryption protocols to ensure that all your stored passwords and information are encrypted on your device before being saved or synced. Your data remains encrypted at all times and cannot be accessed by us or any third party.",
              ),
              const SizedBox(height: 16),
              _buildSection(
                context,
                title: "4. Third-Party Services",
                content:
                    "We do not share any of your data or your feedback whether encrypted or not, with any third-party services, advertisers, or partners.",
              ),
              const SizedBox(height: 16),
              _buildSection(
                context,
                title: "5. Children's Privacy",
                content:
                    "The App is not intended for users under 13. We do not knowingly collect personal information from children under 13. If we become aware that we have collected such data, we will take steps to delete it.",
              ),
              const SizedBox(height: 16),
              _buildSection(
                context,
                title: "6. Changes to This Policy",
                content:
                    "We may update our Privacy Policy. We will notify you of changes by posting the new policy in the App. You are advised to review this policy periodically.",
              ),
              const SizedBox(height: 16),
              _buildSection(
                context,
                title: "7. Contact Us",
                content:
                    "If you have questions, please contact us at rempass.dev@gmail.com",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.titleLarge!.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: textTheme.bodyLarge!.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
