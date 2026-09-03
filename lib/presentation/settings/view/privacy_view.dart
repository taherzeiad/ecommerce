import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/expandable_card.dart';

class PrivacyView extends StatelessWidget {
  const PrivacyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Privacy',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.verified_user_outlined, size: 120, color: AppColors.primary),
            const SizedBox(height: 32),
            const Text(
              'We respect your privacy and protect your data.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            ExpandableCard(
              title: 'Introduction',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('In our online store, we are committed to protecting your privacy and personal data...'),
                  SizedBox(height: 8),
                  Text('Important Note: By using this application, you agree to the collection and use of your information...'),
                ],
              ),
            ),
            const ExpandableCard(title: 'The Information We Collect', content: Text('Info...')),
            const ExpandableCard(title: 'How We Use Your Information', content: Text('Info...')),
            const ExpandableCard(title: 'Sharing Information', content: Text('Info...')),
            const ExpandableCard(title: 'Protecting Your Information', content: Text('Info...')),
            const ExpandableCard(title: 'Your Rights', content: Text('Info...')),
            const ExpandableCard(title: 'Cookies', content: Text('Info...')),
          ],
        ),
      ),
    );
  }
}
