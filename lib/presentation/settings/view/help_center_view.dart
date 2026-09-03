import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/expandable_card.dart';

class HelpCenterView extends StatelessWidget {
  const HelpCenterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Helps Center',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.help, size: 80, color: Colors.white),
            ),
            const SizedBox(height: 32),
            const Text(
              'By using our app and services, you agree to comply with the following Terms and Conditions.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Frequently Asked Questions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            const ExpandableCard(title: 'How can I track my order?', content: Text('Info...')),
            const ExpandableCard(title: 'What payment methods are available?', content: Text('Info...')),
            const ExpandableCard(title: 'How long does delivery take?', content: Text('Info...')),
            const ExpandableCard(title: 'Can I return or exchange a product?', content: Text('Info...')),
            const ExpandableCard(title: 'How can I contact customer service?', content: Text('Info...')),
            const ExpandableCard(title: 'Are the products genuine and guaranteed?', content: Text('Info...')),
            const ExpandableCard(title: 'Ways to Contact Us?', content: Text('Info...')),
          ],
        ),
      ),
    );
  }
}
