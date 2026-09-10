import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extension.dart';
import '../widgets/expandable_card.dart';

class AboutUsView extends StatelessWidget {
  const AboutUsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.tr('about_us'),
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
              child: Icon(Icons.info, size: 80, color: Colors.white),
            ),
            const SizedBox(height: 32),
            Text(
              context.tr('about_us_intro'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            ExpandableCard(
              title: context.tr('about_the_app_title'),
              content: Text(context.tr('about_the_app_content')),
            ),
            ExpandableCard(
              title: context.tr('when_started_title'),
              content: Text(context.tr('when_started_content')),
            ),
            ExpandableCard(
              title: context.tr('who_we_are_title'),
              content: Text(context.tr('who_we_are_content')),
            ),
            ExpandableCard(
              title: context.tr('our_goal_title'),
              content: Text(context.tr('our_goal_content')),
            ),
            ExpandableCard(
              title: context.tr('why_choose_title'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.tr('why_choose_1')),
                  Text(context.tr('why_choose_2')),
                  Text(context.tr('why_choose_3')),
                  Text(context.tr('why_choose_4')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
