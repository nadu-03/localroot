import 'package:flutter/material.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _InfoScaffold(
      title: 'Privacy Policy',
      body:
          'We collect only the data needed to provide marketplace features. '
          'Your personal information is protected and is not sold to third parties.',
    );
  }
}

class TermsConditionsView extends StatelessWidget {
  const TermsConditionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _InfoScaffold(
      title: 'Terms & Conditions',
      body:
          'By using LocalRoot, you agree to provide accurate item details, '
          'follow community guidelines, and complete transactions responsibly.',
    );
  }
}

class AboutUsView extends StatelessWidget {
  const AboutUsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _InfoScaffold(
      title: 'About Us',
      body:
          'LocalRoot helps people buy, sell, and donate pre-loved items. '
          'Our mission is to make local communities more sustainable and connected.',
    );
  }
}

class ContactUsView extends StatelessWidget {
  const ContactUsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _InfoScaffold(
      title: 'Contact Us',
      body:
          'Email: support@localroot.app\nPhone: +94 11 234 5678\n'
          'Address: 25 Green Street, Colombo',
    );
  }
}

class _InfoScaffold extends StatelessWidget {
  final String title;
  final String body;

  const _InfoScaffold({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(body, style: Theme.of(context).textTheme.bodyLarge),
      ),
    );
  }
}
