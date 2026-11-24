import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/order_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String _diningOption = 'dine_in';
  String _paymentType = 'offline'; // 'offline' (cash) vs 'online' (qris)
  final _tableController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _tableController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirmOrder() async {
    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
    });

    try {
      final isOnline = _paymentType == 'online';
      final order = await ref.read(orderProvider.notifier).createOrder(
            diningOption: _diningOption,
            tableNumber: _diningOption == 'dine_in' ? _tableController.text.trim() : null,
            notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
            paymentMethod: isOnline ? 'online_qris' : 'cash',
            paymentStatus: isOnline ? 'paid' : 'unpaid',
          );

      if (mounted) {
        context.go('/order-success/${order.id}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Konfirmasi Pesanan'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Tempat Nongki Info ──────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border.withValues(alpha: 0.8), width: 0.8),
                boxShadow: const [
                  BoxShadow(color: Color(0x06000000), blurRadius: 6, offset: Offset(0, 2)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.storefront_rounded, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cartState.placeName ?? 'Tempat Nongki',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (cartState.placeAddress != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            cartState.placeAddress!,
                            style: AppTextStyles.caption.copyWith(fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // ── Pilihan Opsi Nongkrong ─────────────────────────────────
            const Text(
              'Opsi Pemesanan',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _diningOption = 'dine_in';
                      });
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _diningOption == 'dine_in'
                            ? const Color(0xFFF7EFE9)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _diningOption == 'dine_in'
                              ? AppColors.primary
                              : AppColors.border,
                          width: _diningOption == 'dine_in' ? 1.5 : 0.8,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.table_restaurant_outlined,
                            color: _diningOption == 'dine_in'
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            size: 24,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Nongki di Kafe',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: _diningOption == 'dine_in'
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: _diningOption == 'dine_in'
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _diningOption = 'takeaway';
                      });
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _diningOption == 'takeaway'
                            ? const Color(0xFFF7EFE9)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _diningOption == 'takeaway'
                              ? AppColors.primary
                              : AppColors.border,
                          width: _diningOption == 'takeaway' ? 1.5 : 0.8,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            color: _diningOption == 'takeaway'
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            size: 24,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Bawa Pulang',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: _diningOption == 'takeaway'
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: _diningOption == 'takeaway'
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Nomor Meja (jika dine-in)
            if (_diningOption == 'dine_in') ...[
              CustomTextField(
                label: 'Nomor Meja (Opsional)',
                hint: 'Contoh: Meja 04 atau Meja Outdoor',
                controller: _tableController,
                prefixIcon: const Icon(Icons.pin_outlined, size: 20, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
            ],

            // Catatan
            CustomTextField(
              label: 'Catatan Tambahan (Opsional)',
              hint: 'Contoh: Kurangi manis, es pisah...',
              controller: _notesController,
              maxLines: 2,
              prefixIcon: const Icon(Icons.edit_note_rounded, size: 22, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 22),

            // ── Metode Pembayaran ───────────────────────────────────────
            const Text(
              'Metode Pembayaran',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                // Option 1: Bayar di Kasir (offline)
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _paymentType = 'offline'),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                      decoration: BoxDecoration(
                        color: _paymentType == 'offline'
                            ? AppColors.primary.withValues(alpha: 0.08)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _paymentType == 'offline'
                              ? AppColors.primary
                              : AppColors.border,
                          width: _paymentType == 'offline' ? 2 : 1,
                        ),
                        boxShadow: const [
                          BoxShadow(color: Color(0x06000000), blurRadius: 6, offset: Offset(0, 2)),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.payments_outlined,
                            size: 26,
                            color: _paymentType == 'offline'
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Bayar di Kasir',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _paymentType == 'offline'
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Tunai / QRIS saat tiba',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              color: _paymentType == 'offline'
                                  ? AppColors.primary.withValues(alpha: 0.7)
                                  : AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Option 2: QRIS Digital (online)
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _paymentType = 'online'),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                      decoration: BoxDecoration(
                        color: _paymentType == 'online'
                            ? AppColors.primary.withValues(alpha: 0.08)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _paymentType == 'online'
                              ? AppColors.primary
                              : AppColors.border,
                          width: _paymentType == 'online' ? 2 : 1,
                        ),
                        boxShadow: const [
                          BoxShadow(color: Color(0x06000000), blurRadius: 6, offset: Offset(0, 2)),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.qr_code_rounded,
                            size: 26,
                            color: _paymentType == 'online'
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'QRIS / Digital',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _paymentType == 'online'
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'GoPay, OVO, DANA, BCA',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              color: _paymentType == 'online'
                                  ? AppColors.primary.withValues(alpha: 0.7)
                                  : AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // If online selected: show QRIS info card
            if (_paymentType == 'online') ...[ 
              const SizedBox(height: 12),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.qr_code_2_rounded,
                      size: 44,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Bayar via QRIS Digital',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Scan kode QRIS di kasir setelah pesanan dikonfirmasi.\nMendukung GoPay, OVO, DANA, BCA Mobile, dan semua dompet digital.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption.copyWith(fontSize: 11, height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 22),

            // ── Ringkasan Menu ──────────────────────────────────────────
            Text(
              'Rincian Menu (${cartState.totalItemsCount} item)',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
                boxShadow: const [
                  BoxShadow(color: Color(0x06000000), blurRadius: 6, offset: Offset(0, 2)),
                ],
              ),
              child: Column(
                children: [
                  ...cartState.items.map((ci) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Text(
                            '${ci.quantity}x',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              ci.item.name,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Text(
                            AppUtils.formatCurrency(ci.subtotal),
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal Menu', style: AppTextStyles.caption),
                      Text(AppUtils.formatCurrency(cartState.subtotal),
                          style: AppTextStyles.caption),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Biaya Layanan', style: AppTextStyles.caption),
                      Text(AppUtils.formatCurrency(cartState.serviceFee),
                          style: AppTextStyles.caption),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Tagihan',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        AppUtils.formatCurrency(cartState.total),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── Submit Button ───────────────────────────────────────────
            CustomButton(
              text: 'Konfirmasi & Buat Pesanan',
              icon: Icons.check_circle_outline_rounded,
              isLoading: _isSubmitting,
              onPressed: _handleConfirmOrder,
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}
