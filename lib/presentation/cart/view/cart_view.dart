import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';

class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  final List<Map<String, dynamic>> _cartItems = [
    {
      'name': 'Samsung M13',
      'detail': '\"256GB inch Display\"',
      'price': 550.0,
      'quantity': 1,
      'image': 'https://m.media-amazon.com/images/I/817WWpa7xIL._AC_SL1500_.jpg',
    },
    {
      'name': 'LG Refrigerator',
      'detail': 'Smart Cooling',
      'price': 820.0,
      'quantity': 1,
      'image': 'https://m.media-amazon.com/images/I/61iVusLwA4L._AC_SL1500_.jpg',
    },
    {
      'name': 'Summer Dress',
      'detail': 'Women\'s Fashion',
      'price': 820.0,
      'quantity': 1,
      'image': 'https://m.media-amazon.com/images/I/61M-c19nQdL._AC_SL1001_.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Shopping Cart',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.dark_mode_outlined, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Order Summary',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _cartItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return _buildCartItem(index);
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildAddMoreItems(),
                  const SizedBox(height: 32),
                  const Text(
                    'Discount Coupon',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildPromoCodeField(),
                  const SizedBox(height: 32),
                  _buildPriceBreakdown(),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.checkout),
              child: const Text('Check Out'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(int index) {
    final item = _cartItems[index];
    return Dismissible(
      key: Key(item['name']),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.delete_outline, color: Colors.white),
            Text('delete', style: TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
      onDismissed: (direction) {
        setState(() {
          _cartItems.removeAt(index);
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF1F1F1)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item['image'],
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    item['detail'],
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${item['price']}',
                        style: const TextStyle(
                          color: Color(0xFF1B4E8B),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            _buildQtyBtn(Icons.remove, () {
                              if (item['quantity'] > 1) {
                                setState(() => item['quantity']--);
                              }
                            }),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text('${item['quantity']}'),
                            ),
                            _buildQtyBtn(Icons.add, () {
                              setState(() => item['quantity']++);
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Icon(icon, size: 16, color: const Color(0xFF1B4E8B)),
      ),
    );
  }

  Widget _buildAddMoreItems() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD8E6E3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.add, size: 20),
        label: const Text('Add More Items'),
      ),
    );
  }

  Widget _buildPromoCodeField() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Promo Code',
              hintStyle: const TextStyle(color: Color(0xFFBDBDBD)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(100, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Apply'),
        ),
      ],
    );
  }

  Widget _buildPriceBreakdown() {
    return Column(
      children: [
        _buildPriceRow('Sub Total', '\$5.95'),
        _buildPriceRow('Delivery Fees', '\$1.00'),
        _buildPriceRow('Taxes', '\$50.10', isRed: true),
        const Divider(height: 32, thickness: 1, color: Color(0xFFF1F1F1)),
        _buildPriceRow('Total', '\$100.00', isBold: true),
      ],
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isRed = false, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: isRed ? const Color(0xFFE57373) : const Color(0xFF616161),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: isRed ? const Color(0xFFE57373) : const Color(0xFF1B1B29),
            ),
          ),
        ],
      ),
    );
  }
}
