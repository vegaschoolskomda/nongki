import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../data/models/order_model.dart';
import '../../../providers/order_provider.dart';

class MerchantInsightScreen extends ConsumerStatefulWidget {
  const MerchantInsightScreen({super.key});

  @override
  ConsumerState<MerchantInsightScreen> createState() => _MerchantInsightScreenState();
}

class _MerchantInsightScreenState extends ConsumerState<MerchantInsightScreen> {
  int _selectedTabIndex = 0; // 0 = Kasir & Pesanan, 1 = Analitik & Insight
  String _orderFilter = 'Semua';

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return const Color(0xFF27AE60);
      case 'processing':
      case 'accepted':
      case 'ready':
      case 'pending_confirmation':
      case 'pending':
        return const Color(0xFFE67E22);
      case 'cancelled':
        return const Color(0xFFC0392B);
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final allOrdersAsync = ref.watch(allOrdersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Kasir & Merchant Insight'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Pesanan',
            onPressed: () => ref.invalidate(allOrdersProvider),
          ),
        ],
      ),
      body: allOrdersAsync.when(
        data: (orders) {
          // Analytics Computations from real order data
          final completedOrders = orders.where((o) => o.status == 'completed').toList();
          final totalRevenue = completedOrders.fold<int>(0, (sum, o) => sum + o.total);
          final activeOrders = orders.where((o) => o.status != 'completed' && o.status != 'cancelled').toList();

          // Compute Top Selling Menu Items
          final Map<String, int> itemFrequency = {};
          for (final ord in orders) {
            for (final it in ord.items) {
              itemFrequency[it.name] = (itemFrequency[it.name] ?? 0) + it.quantity;
            }
          }
          final sortedItems = itemFrequency.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          return Column(
            children: [
              // ── Header Segmented Control ─────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _selectedTabIndex = 0),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _selectedTabIndex == 0 ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.point_of_sale_rounded,
                                    size: 16,
                                    color: _selectedTabIndex == 0 ? Colors.white : AppColors.textPrimary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Kelola Pesanan (${activeOrders.length})',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                      fontWeight: _selectedTabIndex == 0 ? FontWeight.w700 : FontWeight.w500,
                                      color: _selectedTabIndex == 0 ? Colors.white : AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _selectedTabIndex = 1),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _selectedTabIndex == 1 ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.insights_rounded,
                                    size: 16,
                                    color: _selectedTabIndex == 1 ? Colors.white : AppColors.textPrimary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Insight & Analitik',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                      fontWeight: _selectedTabIndex == 1 ? FontWeight.w700 : FontWeight.w500,
                                      color: _selectedTabIndex == 1 ? Colors.white : AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Tab 0: Kasir & Manajemen Pesanan Masuk ────────────
              if (_selectedTabIndex == 0)
                Expanded(
                  child: Column(
                    children: [
                      // Filter bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: ['Semua', 'Perlu Konfirmasi', 'Sedang Diproses', 'Siap', 'Selesai'].map((f) {
                              final isSel = _orderFilter == f;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  label: Text(f),
                                  selected: isSel,
                                  labelStyle: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 11,
                                    fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                                    color: isSel ? Colors.white : AppColors.textPrimary,
                                  ),
                                  backgroundColor: AppColors.surface,
                                  selectedColor: AppColors.primary,
                                  showCheckmark: false,
                                  side: BorderSide(color: isSel ? AppColors.primary : AppColors.border),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  onSelected: (_) => setState(() => _orderFilter = f),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                      // Order cards list
                      Expanded(
                        child: _buildKasirOrderList(orders),
                      ),
                    ],
                  ),
                )

              // ── Tab 1: Insight Analitik Penjualan UMKM ────────────
              else
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Stat Cards Row
                        Row(
                          children: [
                            Expanded(
                              child: _buildMetricCard(
                                title: 'Total Pendapatan',
                                value: AppUtils.formatCurrency(totalRevenue),
                                icon: Icons.account_balance_wallet_outlined,
                                color: const Color(0xFF27AE60),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildMetricCard(
                                title: 'Total Pesanan',
                                value: '${orders.length} Transaksi',
                                icon: Icons.shopping_basket_outlined,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Daily Sales Chart Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
                            boxShadow: const [
                              BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Grafik Penjualan Mingguan',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    '7 Hari Terakhir',
                                    style: AppTextStyles.caption,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                height: 140,
                                width: double.infinity,
                                child: CustomPaint(
                                  painter: _SalesBarChartPainter(),
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Text('Sen', style: AppTextStyles.caption),
                                  Text('Sel', style: AppTextStyles.caption),
                                  Text('Rab', style: AppTextStyles.caption),
                                  Text('Kam', style: AppTextStyles.caption),
                                  Text('Jum', style: AppTextStyles.caption),
                                  Text('Sab', style: AppTextStyles.caption),
                                  Text('Min', style: AppTextStyles.caption),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),

                        // Best Selling Menu Items Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
                            boxShadow: const [
                              BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Menu Paling Laris',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (sortedItems.isEmpty)
                                const Text('Belum ada data menu terjual.', style: AppTextStyles.caption)
                              else
                                ...sortedItems.take(4).map((entry) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 6),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF7EFE9),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(Icons.coffee, size: 16, color: AppColors.primary),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            entry.key,
                                            style: const TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '${entry.value} Terjual',
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
        loading: () => const BrandedLoadingWidget(message: 'Memuat dashboard kasir & insight...'),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }

  Widget _buildKasirOrderList(List<OrderModel> allOrders) {
    List<OrderModel> filtered = List.from(allOrders);

    if (_orderFilter == 'Perlu Konfirmasi') {
      filtered = filtered.where((o) => o.status == 'pending_confirmation' || o.status == 'pending_payment' || o.status == 'pending').toList();
    } else if (_orderFilter == 'Sedang Diproses') {
      filtered = filtered.where((o) => o.status == 'processing' || o.status == 'accepted').toList();
    } else if (_orderFilter == 'Siap') {
      filtered = filtered.where((o) => o.status == 'ready').toList();
    } else if (_orderFilter == 'Selesai') {
      filtered = filtered.where((o) => o.status == 'completed').toList();
    }

    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_rounded, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text(
                'Tidak ada pesanan untuk filter "$_orderFilter".',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: filtered.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final order = filtered[index];
        final statusColor = _getStatusColor(order.status);

        return Container(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        order.orderNumber,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      if (order.tableNumber != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            order.tableNumber!,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      AppUtils.orderStatusLabel(order.status),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Items
              Text(
                order.items.map((i) => '${i.quantity}x ${i.name}').join(', '),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),

              // Total & Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppUtils.formatDateTime(order.createdAt),
                    style: AppTextStyles.caption.copyWith(fontSize: 11),
                  ),
                  Text(
                    AppUtils.formatCurrency(order.total),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const Divider(height: 18),

              // Kasir Actions Row
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Detail button
                  TextButton.icon(
                    onPressed: () => context.push('/order-tracking/${order.id}'),
                    icon: const Icon(Icons.track_changes_rounded, size: 16),
                    label: const Text('Live Track', style: TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(width: 8),

                  // Status advancement button
                  if (order.status != 'completed' && order.status != 'cancelled')
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () async {
                        String nextStatus = 'accepted';
                        if (order.status == 'accepted') { nextStatus = 'processing'; }
                        else if (order.status == 'processing') { nextStatus = 'ready'; }
                        else if (order.status == 'ready') { nextStatus = 'completed'; }

                        await ref.read(orderProvider.notifier).updateOrderStatus(order.id, nextStatus);
                        ref.invalidate(allOrdersProvider);

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Pesanan #${order.orderNumber} diubah ke: ${AppUtils.orderStatusLabel(nextStatus)}'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                      child: Text(
                        order.status == 'pending_confirmation' || order.status == 'pending_payment'
                            ? 'Terima Pesanan'
                            : (order.status == 'accepted'
                                ? 'Proses Barista'
                                : (order.status == 'ready'
                                    ? 'Selesaikan'
                                    : 'Pesanan Siap')),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(title, style: AppTextStyles.caption),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Custom Painter for Weekly Sales Bar Chart ───────────────────────────────
class _SalesBarChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final barPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final highlightPaint = Paint()
      ..color = const Color(0xFFE67E22)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.5)
      ..strokeWidth = 1.0;

    // Draw grid lines
    canvas.drawLine(Offset(0, size.height * 0.25), Offset(size.width, size.height * 0.25), linePaint);
    canvas.drawLine(Offset(0, size.height * 0.75), Offset(size.width, size.height * 0.75), linePaint);
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), linePaint);

    final values = [0.4, 0.65, 0.5, 0.85, 0.7, 0.95, 0.8]; // Normalized 7 days
    final barWidth = size.width / 11;
    final spacing = size.width / 7;

    for (int i = 0; i < values.length; i++) {
      final x = (i * spacing) + (spacing - barWidth) / 2;
      final h = values[i] * size.height;
      final y = size.height - h;

      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, y, barWidth, h),
        topLeft: const Radius.circular(6),
        topRight: const Radius.circular(6),
      );

      // Highlight the weekend (Saturday/Sunday)
      canvas.drawRRect(rect, i >= 5 ? highlightPaint : barPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
