import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../data/models/order_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/cashier_provider.dart';

class CashierDashboardScreen extends ConsumerStatefulWidget {
  const CashierDashboardScreen({super.key});

  @override
  ConsumerState<CashierDashboardScreen> createState() => _CashierDashboardScreenState();
}

class _CashierDashboardScreenState extends ConsumerState<CashierDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cashierState = ref.watch(cashierProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 16,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.textPrimary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'POS Kasir: ${cashierState.store?.name ?? "Toko Mitra"}',
              style: AppTextStyles.headingSmall.copyWith(fontSize: 15),
            ),
            Text(
              'Petugas: ${user?.name ?? "Kasir"} (@${user?.username ?? "kasir"})',
              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            tooltip: 'Segarkan Pesanan',
            onPressed: () => ref.read(cashierProvider.notifier).refreshData(),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            tooltip: 'Keluar',
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryDark,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 13),
          tabs: [
            Tab(text: 'Pesanan Aktif (${cashierState.activeOrders.length})'),
            Tab(text: 'Riwayat & Struk (${cashierState.completedOrders.length})'),
          ],
        ),
      ),
      body: cashierState.isLoading
          ? Center(child: LoadingIndicator(message: 'Memuat pesanan kasir...'))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildActiveOrdersView(cashierState),
                _buildCompletedOrdersView(cashierState),
              ],
            ),
    );
  }

  Widget _buildActiveOrdersView(CashierState state) {
    final activeOrders = state.activeOrders;

    if (activeOrders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline, size: 64, color: AppColors.success),
              const SizedBox(height: 12),
              const Text('Semua pesanan selesai diproses.', style: AppTextStyles.headingSmall),
              const SizedBox(height: 8),
              const Text('Pesanan baru dari pelanggan akan otomatis masuk ke daftar ini.', textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: activeOrders.length,
      separatorBuilder: (ctx, i) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final order = activeOrders[index];
        return _buildOrderCard(order, isActive: true);
      },
    );
  }

  Widget _buildCompletedOrdersView(CashierState state) {
    final completed = state.completedOrders;

    if (completed.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.receipt_outlined, size: 64, color: AppColors.textSecondary),
              const SizedBox(height: 12),
              const Text('Belum ada riwayat transaksi.', style: AppTextStyles.headingSmall),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: completed.length,
      separatorBuilder: (ctx, i) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final order = completed[index];
        return _buildOrderCard(order, isActive: false);
      },
    );
  }

  Widget _buildOrderCard(OrderModel order, {required bool isActive}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #${order.orderNumber}',
                style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 14),
              ),
              _buildStatusBadge(order.status),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${order.diningOption == "dine_in" ? "Dine In (Makan di Tempat)" : "Takeaway (Bawa Pulang)"} ${order.tableNumber != null ? "• Meja ${order.tableNumber}" : ""}',
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
          ),
          const Divider(height: 16),
          ...order.items.map(
            (it) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${it.quantity}x ${it.name}', style: AppTextStyles.bodyMedium),
                  Text(AppUtils.formatRupiah(it.subtotal), style: AppTextStyles.bodyMedium),
                ],
              ),
            ),
          ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total:', style: TextStyle(fontWeight: FontWeight.w600)),
              Text(
                AppUtils.formatRupiah(order.total),
                style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.primaryDark),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Receipt Button
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryDark,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.receipt_long_outlined, size: 16),
                  label: const Text('Lihat Struk', style: TextStyle(fontFamily: 'Poppins', fontSize: 12)),
                  onPressed: () => _showReceiptModal(context, order),
                ),
              ),
              if (isActive) ...[
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () async {
                      String next = 'accepted';
                      if (order.status == 'accepted') next = 'processing';
                      if (order.status == 'processing') next = 'ready';
                      if (order.status == 'ready') next = 'completed';

                      await ref.read(cashierProvider.notifier).advanceStatus(order.id, next);
                    },
                    child: Text(
                      _getButtonActionLabel(order.status),
                      style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 12, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _getButtonActionLabel(String status) {
    switch (status) {
      case 'pending_confirmation':
        return 'Terima Pesanan';
      case 'accepted':
        return 'Mulai Diproses';
      case 'processing':
        return 'Siap Disajikan';
      case 'ready':
        return 'Selesaikan & Bayar';
      default:
        return 'Perbarui';
    }
  }

  Widget _buildStatusBadge(String status) {
    Color bg = AppColors.surfaceVariant;
    Color fg = AppColors.textPrimary;

    if (status == 'completed') {
      bg = AppColors.successLight;
      fg = AppColors.success;
    } else if (status == 'processing' || status == 'ready') {
      bg = const Color(0xFFFFF3E0);
      fg = const Color(0xFFE65100);
    } else if (status == 'cancelled') {
      bg = AppColors.errorLight;
      fg = AppColors.error;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(
        AppUtils.orderStatusLabel(status),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }

  void _showReceiptModal(BuildContext context, OrderModel order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Text('STRUK PEMBAYARAN DIGITAL', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w800, fontSize: 15, letterSpacing: 1.2)),
            Text(order.placeName, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
            Text(order.placeAddress ?? 'Lokasi Mitra NONGKI', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            const Divider(thickness: 1, color: AppColors.border),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('No. Order: #${order.orderNumber}', style: AppTextStyles.caption),
                Text(AppUtils.formatDate(order.createdAt), style: AppTextStyles.caption),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tipe: ${order.diningOption == "dine_in" ? "Dine In" : "Takeaway"}', style: AppTextStyles.caption),
                Text('Status: ${order.paymentStatus == "paid" ? "LUNAS (CASH)" : "MENUNGGU BAYAR"}', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
            const Divider(thickness: 1, color: AppColors.border),
            const SizedBox(height: 8),
            ...order.items.map(
              (it) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${it.quantity}x ${it.name}', style: AppTextStyles.bodyMedium),
                    Text(AppUtils.formatRupiah(it.subtotal), style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            const Divider(thickness: 1, color: AppColors.border),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal:', style: AppTextStyles.bodyMedium),
                Text(AppUtils.formatRupiah(order.subtotal), style: AppTextStyles.bodyMedium),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Biaya Layanan Platform:', style: AppTextStyles.bodyMedium),
                Text(AppUtils.formatRupiah(order.serviceFee), style: AppTextStyles.bodyMedium),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('TOTAL BAYAR:', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w800, fontSize: 16)),
                Text(
                  AppUtils.formatRupiah(order.total),
                  style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.primaryDark),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Terima kasih telah bertransaksi di ${order.placeName}.', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
            Text('Didukung oleh Ekosistem Digital NONGKI', style: AppTextStyles.caption.copyWith(fontSize: 10, color: AppColors.textSecondary)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDark),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Tutup Struk', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
