import 'package:flutter/material.dart';
import 'checkout_screen.dart'; // Import layar checkout yang baru

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Data dummy (dijadikan state agar bisa diubah)
  late List<Map<String, dynamic>> cartItems;

  @override
  void initState() {
    super.initState();
    cartItems = [
      {
        'name': 'iPhone 15 Pro Max 256GB',
        'location': 'Jakarta Pusat',
        'discount_text': '14% OFF',
        'price_final': '18.999.000',
        'price_original': '21.999.000',
        'quantity': 1,
        'isSelected': true,
      },
      {
        'name': 'Samsung Galaxy S24 Ultra',
        'location': 'Surabaya',
        'discount_text': '15% OFF',
        'price_final': '16.999.000',
        'price_original': '19.999.000',
        'quantity': 2,
        'isSelected': true,
      },
      {
        'name': 'MacBook Air M3 13 inch',
        'location': 'Bandung',
        'discount_text': '16% OFF',
        'price_final': '15.999.000',
        'price_original': '18.999.000',
        'quantity': 1,
        'isSelected': true,
      },
    ];
  }

  void _updateQuantity(int index, int newQuantity) {
    if (newQuantity > 0) {
      setState(() {
        cartItems[index]['quantity'] = newQuantity;
      });
    }
  }

  void _toggleItemSelection(int index, bool isSelected) {
    setState(() {
      cartItems[index]['isSelected'] = isSelected;
    });
  }

  void _toggleSelectAll(bool isSelected) {
    setState(() {
      for (var item in cartItems) {
        item['isSelected'] = isSelected;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isSelectAll = cartItems.every((item) => item['isSelected']);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: Text(
          'Keranjang Belanja',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _buildSelectAllHeader(cartItems.length, isSelectAll, theme),
                  ...cartItems.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, dynamic> item = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: CartProductCard(
                        product: item,
                        onQuantityChanged: (newQuantity) {
                          _updateQuantity(index, newQuantity);
                        },
                        onSelected: (isSelected) {
                          _toggleItemSelection(index, isSelected);
                        },
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
          _buildSummaryFooter(context, theme),
        ],
      ),
    );
  }

  Widget _buildSelectAllHeader(
    int itemCount,
    bool isSelected,
    ThemeData theme,
  ) {
    return Container(
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          _buildCheckIndicator(
            isSelected: isSelected,
            theme: theme,
            onToggle: (value) => _toggleSelectAll(value),
          ),
          const SizedBox(width: 8),
          const Text(
            'Pilih Semua',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Text(
            '$itemCount produk',
            style: TextStyle(color: theme.hintColor, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryFooter(BuildContext context, ThemeData theme) {
    const String totalProdukText = '4 item';
    const String totalHargaText = 'Rp 68.996.000';

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Ringkasan Belanja',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Produk', style: TextStyle(color: theme.hintColor)),
              const Text(
                totalProdukText,
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Harga', style: TextStyle(color: theme.hintColor)),
              const Text(
                totalHargaText,
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Divider(thickness: 1, height: 1, color: theme.dividerColor),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Pembayaran',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
              Text(
                totalHargaText,
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CheckoutScreen(),
                  ),
                );
              },
              child: const Text(
                'Beli Sekarang',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckIndicator({
    required bool isSelected,
    required ThemeData theme,
    required ValueChanged<bool> onToggle,
  }) {
    return InkWell(
      onTap: () => onToggle(!isSelected),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.hintColor,
            width: 1.5,
          ),
        ),
        child: isSelected
            ? const Icon(Icons.check, size: 16, color: Colors.white)
            : null,
      ),
    );
  }
}

// =========================================================================
// WIDGET KARTU PRODUK DI KERANJANG
// =========================================================================

class CartProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final ValueChanged<int> onQuantityChanged;
  final ValueChanged<bool> onSelected;

  const CartProductCard({
    required this.product,
    required this.onQuantityChanged,
    required this.onSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = product['isSelected'] ?? false;
    final quantity = product['quantity'] ?? 1;

    return Container(
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCheckIndicator(
            isSelected: isSelected,
            theme: theme,
            onToggle: onSelected,
          ),
          const SizedBox(width: 12),
          Container(
            width: 80,
            height: 80,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.image,
              color: theme.hintColor.withOpacity(0.5),
              size: 40,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product['name']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.delete_outline,
                      color: theme.hintColor,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        product['discount_text']!,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.location_on_outlined,
                      color: theme.hintColor,
                      size: 14,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      product['location']!,
                      style: TextStyle(fontSize: 11, color: theme.hintColor),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rp ${product['price_final']!}',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Rp ${product['price_original']!}',
                          style: TextStyle(
                            color: theme.hintColor,
                            fontSize: 11,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                    _buildQuantityControl(theme, quantity),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckIndicator({
    required bool isSelected,
    required ThemeData theme,
    required ValueChanged<bool> onToggle,
  }) {
    return InkWell(
      onTap: () => onToggle(!isSelected),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.hintColor,
            width: 1.5,
          ),
        ),
        child: isSelected
            ? const Icon(Icons.check, size: 16, color: Colors.white)
            : null,
      ),
    );
  }

  Widget _buildQuantityControl(ThemeData theme, int quantity) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => onQuantityChanged(quantity - 1),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Icon(Icons.remove, size: 18, color: theme.hintColor),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Text(
              quantity.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          InkWell(
            onTap: () => onQuantityChanged(quantity + 1),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Icon(
                Icons.add,
                size: 18,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
