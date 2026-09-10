import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extension.dart';
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
        title: Text(
          context.tr('terms_condition'),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
            Text(
              context.tr('help_center_intro'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            ExpandableCard(
              title: context.tr('terms_acceptance_title'),
              content: Text(context.tr('terms_acceptance_content')),
            ),
            ExpandableCard(title: context.tr('terms_accounts'), content: Text(context.tr('faq_info'))),
            ExpandableCard(title: context.tr('terms_orders'), content: Text(context.tr('faq_info'))),
            ExpandableCard(title: context.tr('terms_shipping'), content: Text(context.tr('faq_info'))),
            ExpandableCard(title: context.tr('terms_returns'), content: Text(context.tr('faq_info'))),
            ExpandableCard(title: context.tr('terms_ip'), content: Text(context.tr('faq_info'))),
            ExpandableCard(title: context.tr('terms_liability'), content: Text(context.tr('faq_info'))),
            ExpandableCard(title: context.tr('terms_modifications'), content: Text(context.tr('faq_info'))),
          ],
        ),
      ),
    );
  }
}
