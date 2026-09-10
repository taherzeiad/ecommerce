import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extension.dart';
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
        title: Text(
          context.tr('help_center'),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
            Text(
              context.tr('help_center_intro'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                context.tr('faq_title'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            ExpandableCard(title: context.tr('faq_1'), content: Text(context.tr('faq_info'))),
            ExpandableCard(title: context.tr('faq_2'), content: Text(context.tr('faq_info'))),
            ExpandableCard(title: context.tr('faq_3'), content: Text(context.tr('faq_info'))),
            ExpandableCard(title: context.tr('faq_4'), content: Text(context.tr('faq_info'))),
            ExpandableCard(title: context.tr('faq_5'), content: Text(context.tr('faq_info'))),
            ExpandableCard(title: context.tr('faq_6'), content: Text(context.tr('faq_info'))),
            ExpandableCard(title: context.tr('faq_7'), content: Text(context.tr('faq_info'))),
          ],
        ),
      ),
    );
  }
}
