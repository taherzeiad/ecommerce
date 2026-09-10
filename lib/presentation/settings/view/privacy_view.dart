import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extension.dart';
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
        title: Text(
          context.tr('privacy'),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.verified_user_outlined, size: 120, color: AppColors.primary),
            const SizedBox(height: 32),
            Text(
              context.tr('privacy_subtitle'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            ExpandableCard(
              title: context.tr('intro_title'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.tr('privacy_intro_1')),
                  const SizedBox(height: 8),
                  Text(context.tr('privacy_intro_2')),
                ],
              ),
            ),
            ExpandableCard(title: context.tr('privacy_info_collect'), content: Text(context.tr('faq_info'))),
            ExpandableCard(title: context.tr('privacy_info_use'), content: Text(context.tr('faq_info'))),
            ExpandableCard(title: context.tr('privacy_sharing'), content: Text(context.tr('faq_info'))),
            ExpandableCard(title: context.tr('privacy_protection'), content: Text(context.tr('faq_info'))),
            ExpandableCard(title: context.tr('privacy_rights'), content: Text(context.tr('faq_info'))),
            ExpandableCard(title: context.tr('privacy_cookies'), content: Text(context.tr('faq_info'))),
          ],
        ),
      ),
    );
  }
}
