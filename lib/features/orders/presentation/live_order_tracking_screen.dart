import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../data/models/order_model.dart';
import '../../../providers/order_provider.dart';

class LiveOrderTrackingScreen extends ConsumerStatefulWidget {
  final String orderId;

  const LiveOrderTrackingScreen({super.key, required this.orderId});

  @override
  ConsumerState<LiveOrderTrackingScreen> createState() => _LiveOrderTrackingScreenState();
}

class _LiveOrderTrackingScreenState extends ConsumerState<LiveOrderTrackingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<Map<String, dynamic>> _steps = [
    {
      'key': 'pending_confirmation',
      'title': 'Menunggu Konfirmasi',
      'subtitle': 'Pesanan telah dikirim ke sistem kasir kafe.',
      'icon': Icons.hourglass_top_rounded,
    },
    {
      'key': 'accepted',
      'title': 'Pesanan Diterima',
      'subtitle': 'Kasir telah mengonfirmasi pesanan kamu.',
      'icon': Icons.check_circle_outline_rounded,
    },
    {
      'key': 'processing',
      'title': 'Sedang Diproses',
      'subtitle': 'Barista sedang menyiapkan minuman & makananmu.',
      'icon': Icons.coffee_maker_outlined,
    },
    {
      'key': 'ready',
      'title': 'Siap Disajikan',
      'subtitle': 'Pesanan siap diantar ke meja atau diambil di kasir.',
      'icon': Icons.notifications_active_outlined,
    },
    {
      'key': 'completed',
      'title': 'Pesanan Selesai',
      'subtitle': 'Selamat menikmati! Poin loyalitas telah ditambahkan.',
      'icon': Icons.celebration_outlined,
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  int _getStatusStepIndex(String status) {
    switch (status) {
      case 'pending_confirmation':
      case 'pending_payment':
      case 'pending':
        return 0;
      case 'accepted':
        return 1;
      case 'processing':
        return 2;
      case 'ready':
        return 3;
      case 'completed':
        return 4;
      default:
        return 0;
    }
  }

  Future<void> _advanceOrderStatus(OrderModel order) async {
    final currentIdx = _getStatusStepIndex(order.status);
    if (currentIdx < _steps.length - 1) {
      final nextStatus = _steps[currentIdx + 1]['key'] as String;
      await ref.read(orderProvider.notifier).updateOrderStatus(order.id, nextStatus);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status pesanan diperbarui menjadi: ${AppUtils.orderStatusLabel(nextStatus)}'),
            backgroundColor: AppColors.primary,
            duration: const Duration(milliseconds: 1200),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderAsync = ref.watch(orderDetailProvider(widget.orderId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Live Order Tracking'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: orderAsync.when(
        data: (order) {
          if (order == null) {
            return const Center(child: Text('Pesanan tidak ditemukan.'));
          }

          final currentStep = _getStatusStepIndex(order.status);
          final isCompleted = order.status == 'completed';
          final isCancelled = order.status == 'cancelled';

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header Status Card ──────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF5B3023),
                        Color(0xFF3D211A),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x20000000),
                        blurRadius: 14,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              order.orderNumber,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE67E22),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              order.diningOption == 'dine_in'
                                  ? (order.tableNumber != null ? 'Dine-In (${order.tableNumber})' : 'Dine-In')
                                  : 'Takeaway',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      Text(
                        order.placeName,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isCancelled
                            ? 'Pesanan ini telah dibatalkan.'
                            : _steps[currentStep]['subtitle'] as String,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Interactive Timeline ────────────────────────────────
                const Text(
                  'Perjalanan Pesanan Kamu',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
                    boxShadow: const [
                      BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
                    ],
                  ),
                  child: Column(
                    children: List.generate(_steps.length, (idx) {
                      final step = _steps[idx];
                      final isPassed = currentStep > idx;
                      final isCurrent = currentStep == idx && !isCancelled;
                      final isLast = idx == _steps.length - 1;

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Icon & Vertical Line
                          Column(
                            children: [
                              isCurrent
                                  ? ScaleTransition(
                                      scale: _pulseAnimation,
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFE67E22),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Color(0x44E67E22),
                                              blurRadius: 10,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                        child: Icon(step['icon'] as IconData, size: 18, color: Colors.white),
                                      ),
                                    )
                                  : Container(
                                      width: 34,
                                      height: 34,
                                      decoration: BoxDecoration(
                                        color: isPassed
                                            ? const Color(0xFF27AE60)
                                            : Colors.grey.shade200,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        isPassed ? Icons.check : (step['icon'] as IconData),
                                        size: 16,
                                        color: isPassed ? Colors.white : Colors.grey.shade500,
                                      ),
                                    ),
                              if (!isLast)
                                Container(
                                  width: 2,
                                  height: 36,
                                  color: isPassed
                                      ? const Color(0xFF27AE60)
                                      : Colors.grey.shade300,
                                ),
                            ],
                          ),
                          const SizedBox(width: 16),

                          // Right Text Description
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 4, bottom: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    step['title'] as String,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 13,
                                      fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                                      color: isCurrent
                                          ? AppColors.primary
                                          : (isPassed ? AppColors.textPrimary : AppColors.textSecondary),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    step['subtitle'] as String,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 11,
                                      color: isCurrent
                                          ? AppColors.textPrimary
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Live Kasir Demonstration Simulator Tool ─────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDF6F0),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE67E22).withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.storefront_rounded, color: Color(0xFFE67E22), size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Simulasi Sinkronisasi Kasir (Demo Pameran)',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Untuk kebutuhan pameran dan juri, kamu dapat mengubah status pesanan ini secara langsung seperti seorang kasir kafe.',
                        style: AppTextStyles.caption.copyWith(fontSize: 11),
                      ),
                      const SizedBox(height: 12),

                      if (!isCompleted && !isCancelled)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () => _advanceOrderStatus(order),
                            icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                            label: Text(
                              currentStep == 0
                                  ? 'Sebagai Kasir: Terima Pesanan'
                                  : (currentStep == 1
                                      ? 'Sebagai Kasir: Mulai Proses Barista'
                                      : (currentStep == 2
                                          ? 'Sebagai Kasir: Tandai Siap Disajikan'
                                          : 'Sebagai Kasir: Selesaikan Pesanan & Beri Poin')),
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        )
                      else if (isCompleted)
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF27AE60).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.stars_rounded, color: Color(0xFF27AE60), size: 18),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Pesanan selesai! Poin NONGKI telah masuk ke saldo pelanggan.',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF27AE60),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Order Items Brief ───────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Pembayaran', style: AppTextStyles.labelMedium),
                          Text(
                            AppUtils.formatCurrency(order.total),
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        order.items.map((i) => '${i.quantity}x ${i.name}').join(', '),
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // View Detail Link
                Center(
                  child: TextButton.icon(
                    onPressed: () => context.push('/order/${order.id}'),
                    icon: const Icon(Icons.receipt_long_outlined, size: 16),
                    label: const Text('Buka Lembar Tanda Terima Lengkap'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
        loading: () => const BrandedLoadingWidget(message: 'Memuat pelacakan pesanan...'),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }
}
