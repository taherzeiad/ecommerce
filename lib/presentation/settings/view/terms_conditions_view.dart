import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/expandable_card.dart';

class TermsConditionsView extends StatelessWidget {
  const TermsConditionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Terms & Condition',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.notes, size: 80, color: Colors.white),
            ),
            const SizedBox(height: 32),
            const Text(
              'By using our app and services, you agree to comply with the following Terms and Conditions.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            const ExpandableCard(
              title: 'Acceptance and Agreement',
              content: Text('By using this application and online store, you agree to comply with these Terms and Conditions...'),
            ),
            const ExpandableCard(title: 'Accounts and Registration', content: Text('Info...')),
            const ExpandableCard(title: 'Orders and Payments', content: Text('Info...')),
            const ExpandableCard(title: 'Shipping and Delivery', content: Text('Info...')),
            const ExpandableCard(title: 'Returns and Exchanges', content: Text('Info...')),
            const ExpandableCard(title: 'Intellectual Property', content: Text('Info...')),
            const ExpandableCard(title: 'Limitation of Liability', content: Text('Info...')),
            const ExpandableCard(title: 'Modifications', content: Text('Info...')),
          ],
        ),
      ),
    );
  }
}
