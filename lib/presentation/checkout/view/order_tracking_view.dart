import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extension.dart';

class OrderTrackingView extends StatelessWidget {
  const OrderTrackingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.tr('order_tracking'),
          style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.wb_sunny_outlined, color: AppColors.white)),
        ],
      ),
      body: Stack(
        children: [
          _buildMapPlaceholder(),
          _buildTrackingDetails(context),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.dividerExtraLight,
      child: Image.network(
        'https://api.mapbox.com/styles/v1/mapbox/streets-v11/static/-73.935242,40.730610,13/600x600?access_token=dummy', // Placeholder map
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.image_not_supported, size: 100, color: AppColors.grey)),
      ),
    );
  }

  Widget _buildTrackingDetails(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.4,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: AppColors.borderLight, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 24),
              Text(context.tr('details_card'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildMainCard(context),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(context.tr('confirm')),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderTeal),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLocationRow(Icons.location_on_outlined, 'John F. Kennedy Int’l Airport, Queens, NY'),
          Padding(
            padding: const EdgeInsets.only(left: 11),
            child: Container(width: 2, height: 20, color: AppColors.borderLight),
          ),
          _buildLocationRow(Icons.access_time, 'The Times Square Edition, 475 Lefant plz.'),
          const SizedBox(height: 24),
          Text(context.tr('more'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.grey, letterSpacing: 1.2)),
          const SizedBox(height: 16),
          _buildDetailRow('Order ID:', '#BH-2391'),
          const Divider(height: 24),
          _buildDetailRow('Order Date:', 'Jan 3, 2026'),
          const Divider(height: 24),
          _buildDetailRow('Order Total:', '\$24.27'),
          const Divider(height: 24),
          _buildDetailRow('${context.tr('delivery_address')}:', context.tr('home_address')),
        ],
      ),
    );
  }

  Widget _buildLocationRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 22, color: AppColors.black),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w500))),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.black)),
        Text(value, style: const TextStyle(color: AppColors.grey)),
      ],
    );
  }
}
