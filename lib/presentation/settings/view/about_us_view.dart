import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
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
        title: const Text(
          'About Us',
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
              child: Icon(Icons.info, size: 80, color: Colors.white),
            ),
            const SizedBox(height: 32),
            const Text(
              'We are a mobile application designed to make online shopping easy, secure, and reliable for everyone',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            const ExpandableCard(
              title: 'About the App',
              content: Text('Details about the application and its features.'),
            ),
            const ExpandableCard(
              title: 'When We Started',
              content: Text('Our journey began in 2023 with a vision to revolutionize shopping.'),
            ),
            const ExpandableCard(
              title: 'Who We Are',
              content: Text('We are a team of passionate developers and retail experts.'),
            ),
            const ExpandableCard(
              title: 'Our Goal',
              content: Text('To provide the best shopping experience globally.'),
            ),
            ExpandableCard(
              title: 'Why Choose Our App?',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('• Easy and intuitive user experience'),
                  Text('• Secure payments'),
                  Text('• Fast and reliable delivery'),
                  Text('• Professional customer support'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
