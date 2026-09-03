import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class AddReviewView extends StatelessWidget {
  const AddReviewView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Reviews & Rating',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    'https://m.media-amazon.com/images/I/71TPda7cwUL._AC_SL1500_.jpg',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Apple MacBook\nAir M2',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B1B29)),
                    ),
                    SizedBox(height: 8),
                    Text('Laptop', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Center(
              child: Text(
                'Your overall rating of this product',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) => const Icon(Icons.star, size: 40, color: Color(0xFFD8E6E3))),
            ),
            const SizedBox(height: 48),
            const Text(
              'Your Feedback',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'Share Your thoughts',
                hintStyle: const TextStyle(color: Color(0xFFBDBDBD)),
                filled: true,
                fillColor: const Color(0xFFF1F5F9).withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 8),
            const Text('3000 Character', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
