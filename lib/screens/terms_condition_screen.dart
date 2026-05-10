import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text("Terms and Conditions"),
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
                "Welcome to Our App",
                style: textTheme.headlineMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "These Terms and Conditions (\"Terms\") govern your use of the App and its services. By using the App, you agree to be bound by these Terms.",
                style: textTheme.bodyLarge!.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 24),
              _buildSection(
                context,
                title: "1. Your Responsibilities",
                content:
                    "• Master Password: You are solely responsible for remembering and securing your master password. We cannot recover it if it is lost or forgotten, and losing it will result in the permanent loss of all your encrypted data.\n• Account Security: You are responsible for all activity that occurs under your account. You must notify us immediately of any unauthorized use or security breaches.",
              ),
              const SizedBox(height: 16),
              _buildSection(
                context,
                title: "2. License to Use the App",
                content:
                    "We grant you a limited, non-exclusive, non-transferable, and revocable license to use the App for your personal, non-commercial use, subject to these Terms. You may not copy, modify, distribute, sell, or lease any part of our services or software.",
              ),
              const SizedBox(height: 16),
              _buildSection(
                context,
                title: "3. Intellectual Property",
                content:
                    "The App, its software, content, and all intellectual property rights belong exclusively to Abhishek Bhat. You may not use our trademarks, logos, or proprietary graphics without our prior written consent.",
              ),
              const SizedBox(height: 16),
              _buildSection(
                context,
                title: "4. Disclaimer of Warranties",
                content:
                    "The App is provided \"as is\" and \"as available,\" without any warranties. We do not warrant that the App will be uninterrupted, error-free, or free of viruses or other harmful components.",
              ),
              const SizedBox(height: 16),
              _buildSection(
                context,
                title: "5. Limitation of Liability",
                content:
                    "We are not liable for any indirect, incidental, special, consequential, or punitive damages, including any loss of profits or revenues, data, or goodwill, resulting from your use of the App.",
              ),
              const SizedBox(height: 16),
              _buildSection(
                context,
                title: "6. Governing Law",
                content:
                    "These Terms shall be governed by and construed in accordance with the laws of Abhishek Bhat, without regard to its conflict of law provisions.",
              ),
              const SizedBox(height: 16),
              _buildSection(
                context,
                title: "7. Changes to Terms",
                content:
                    "We reserve the right to modify these Terms at any time. We will notify you of any changes by posting the new Terms within the App. Your continued use of the App constitutes your acceptance of the new Terms.",
              ),
              const SizedBox(height: 16),
              _buildSection(
                context,
                title: "8. Contact Us",
                content:
                    "If you have any questions, please contact us at rempass.dev@gmail.com",
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
