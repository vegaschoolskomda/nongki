import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../data/models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/admin_provider.dart';

class AdminControlScreen extends ConsumerStatefulWidget {
  const AdminControlScreen({super.key});

  @override
  ConsumerState<AdminControlScreen> createState() => _AdminControlScreenState();
}

class _AdminControlScreenState extends ConsumerState<AdminControlScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _userSearchQuery = '';
  String _selectedRoleFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);
    final authState = ref.watch(authProvider);
    final usersAsync = ref.watch(allUsersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        titleSpacing: 16,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.white),
          onPressed: () => context.go('/'),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.shield_outlined, color: Color(0xFFF7EFE9), size: 18),
                const SizedBox(width: 8),
                Text(
                  'Admin & Developer Control',
                  style: AppTextStyles.headingSmall.copyWith(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
            const Text(
              'Pusat Pengawasan Seluruh Ekosistem NONGKI',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          // View As / Role Preview Action Button
          PopupMenuButton<String>(
            icon: const Icon(Icons.preview_rounded, color: Colors.white),
            tooltip: 'Mode Pratinjau Tampilan (View As)',
            onSelected: (role) {
              if (role == 'clear') {
                ref.read(authProvider.notifier).clearPreviewRole();
              } else {
                ref.read(authProvider.notifier).setPreviewRole(role);
                if (role == 'customer') context.go('/');
                if (role == 'merchant') context.go('/merchant-dashboard');
                if (role == 'cashier') context.go('/cashier-dashboard');
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                enabled: false,
                child: Text('PRATINJAU PERAN (VIEW AS):', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11)),
              ),
              const PopupMenuItem(
                value: 'customer',
                child: Text('Lihat sebagai Pelanggan (Customer)'),
              ),
              const PopupMenuItem(
                value: 'merchant',
                child: Text('Lihat sebagai Pemilik Toko (Merchant)'),
              ),
              const PopupMenuItem(
                value: 'cashier',
                child: Text('Lihat sebagai Kasir (Cashier)'),
              ),
              if (authState.isInPreviewMode)
                const PopupMenuItem(
                  value: 'clear',
                  child: Text('Kembali ke Admin Penuh', style: TextStyle(color: AppColors.primary)),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'Segarkan Data',
            onPressed: () => ref.read(adminProvider.notifier).refreshData(),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            tooltip: 'Keluar Admin',
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: const Color(0xFFE67E22),
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: 12),
          tabs: [
            const Tab(text: 'Ringkasan'),
            Tab(text: 'Pengguna (${adminState.stats.totalUsers})'),
            Tab(text: 'Verifikasi Toko (${adminState.stats.pendingStores})'),
            Tab(text: 'Kategori (${adminState.categories.length})'),
            Tab(text: 'Pesanan (${adminState.orders.length})'),
            const Tab(text: 'Audit Log'),
          ],
        ),
      ),
      body: adminState.isLoading
          ? Center(child: LoadingIndicator(message: 'Sinkronisasi database platform...'))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(adminState),
                _buildUsersTab(usersAsync),
                _buildStoresTab(adminState),
                _buildCategoriesTab(adminState),
                _buildOrdersTab(adminState),
                _buildAuditLogTab(adminState),
              ],
            ),
    );
  }

  // ─── TAB 1: RINGKASAN OVERVIEW ─────────────────────────────────────────────
  Widget _buildOverviewTab(AdminState state) {
    final stats = state.stats;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── DEVELOPER APP SWITCHER (Akses Cepat Semua Halaman) ─────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3E2723), Color(0xFF5D4037)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Color(0x22000000), blurRadius: 10, offset: Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE67E22),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.dashboard_customize_rounded, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Developer Control Center',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Beralih dan pantau seluruh halaman aplikasi secara langsung',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white24, height: 1),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _buildDevShortcutButton(
                        icon: Icons.person_outline_rounded,
                        label: 'Halaman User',
                        subtitle: 'Cari kafe & order',
                        onTap: () {
                          ref.read(authProvider.notifier).setPreviewRole('customer');
                          context.go('/');
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildDevShortcutButton(
                        icon: Icons.storefront_outlined,
                        label: 'Kelola Toko',
                        subtitle: 'Edit menu & stok',
                        onTap: () {
                          ref.read(authProvider.notifier).setPreviewRole('merchant');
                          context.go('/merchant-dashboard');
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildDevShortcutButton(
                        icon: Icons.point_of_sale_rounded,
                        label: 'Halaman Kasir',
                        subtitle: 'Proses pesanan',
                        onTap: () {
                          ref.read(authProvider.notifier).setPreviewRole('cashier');
                          context.go('/cashier-dashboard');
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const Text('Metrik Ekosistem Platform', style: AppTextStyles.headingSmall),
          const SizedBox(height: 12),

          // 2x3 KPI Grid
          Row(
            children: [
              Expanded(
                child: _buildKpiCard(
                  title: 'Total Pengguna',
                  value: stats.totalUsers.toString(),
                  subtitle: '${stats.totalCustomers} Customer, ${stats.totalMerchants} Mitra',
                  icon: Icons.people_outline_rounded,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildKpiCard(
                  title: 'Toko Terdaftar',
                  value: stats.totalStores.toString(),
                  subtitle: '${stats.activeStores} Aktif, ${stats.pendingStores} Pending',
                  icon: Icons.storefront_outlined,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildKpiCard(
                  title: 'Menunggu Verifikasi',
                  value: stats.pendingStores.toString(),
                  subtitle: stats.pendingStores > 0 ? 'Perlu tindakan segera' : 'Semua toko diverifikasi',
                  icon: Icons.pending_actions_rounded,
                  color: stats.pendingStores > 0 ? const Color(0xFFD35400) : AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildKpiCard(
                  title: 'Total Pesanan',
                  value: stats.totalOrders.toString(),
                  subtitle: 'Di seluruh mitra kafe',
                  icon: Icons.receipt_long_outlined,
                  color: const Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildKpiCard(
                  title: 'Volume Transaksi',
                  value: AppUtils.formatRupiah(stats.totalRevenue),
                  subtitle: 'Total omzet ekosistem',
                  icon: Icons.payments_outlined,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildKpiCard(
                  title: 'Akun Kasir',
                  value: stats.totalCashiers.toString(),
                  subtitle: 'Petugas kasir aktif',
                  icon: Icons.point_of_sale_rounded,
                  color: const Color(0xFF8A5A36),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Quick Action: Pending Verifications
          if (stats.pendingStores > 0) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFFB300)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notification_important_outlined, color: Color(0xFFF57F17), size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${stats.pendingStores} Toko Baru Menunggu Verifikasi',
                          style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFFF57F17)),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Buka tab "Verifikasi Toko" untuk menyetujui atau menolak pendaftaran mitra.',
                          style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Color(0xFF5D4037)),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF57F17),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: Size.zero,
                    ),
                    onPressed: () => _tabController.animateTo(2),
                    child: const Text('Periksa', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Recent Activity Stream snippet
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Aktivitas Sistem Terkini', style: AppTextStyles.headingSmall),
              TextButton(
                onPressed: () => _tabController.animateTo(5),
                child: const Text('Lihat Semua Log', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...state.logs.take(4).map(
                (log) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.bolt_outlined, size: 16, color: AppColors.primary),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(log.action, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                                Text(AppUtils.formatDate(log.timestamp), style: AppTextStyles.caption.copyWith(fontSize: 10)),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(log.details, style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
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
              Text(title, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w800, fontSize: 18, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTextStyles.caption.copyWith(fontSize: 10, color: AppColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDevShortcutButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 9,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── TAB 2: KELOLA PENGGUNA ───────────────────────────────────────────────
  Widget _buildUsersTab(AsyncValue<List<UserModel>> usersAsync) {
    return usersAsync.when(
      loading: () => Center(child: LoadingIndicator(message: 'Memuat data pengguna...')),
      error: (e, _) => Center(child: Text('Gagal memuat pengguna: $e')),
      data: (users) {
        var filtered = users.where((u) {
          final matchesSearch = u.name.toLowerCase().contains(_userSearchQuery.toLowerCase()) ||
              u.email.toLowerCase().contains(_userSearchQuery.toLowerCase()) ||
              u.username.toLowerCase().contains(_userSearchQuery.toLowerCase());

          if (_selectedRoleFilter == 'Semua') return matchesSearch;
          return matchesSearch && u.role.toLowerCase() == _selectedRoleFilter.toLowerCase();
        }).toList();

        return Column(
          children: [
            // Filter Bar
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                children: [
                  CustomTextField(
                    hintText: 'Cari nama, email, atau username...',
                    prefixIcon: Icons.search,
                    onChanged: (val) => setState(() => _userSearchQuery = val),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['Semua', 'customer', 'merchant', 'cashier', 'admin'].map((role) {
                        final isSel = _selectedRoleFilter.toLowerCase() == role.toLowerCase();
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(role.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: isSel ? FontWeight.w700 : FontWeight.w500)),
                            selected: isSel,
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(color: isSel ? Colors.white : AppColors.textPrimary),
                            onSelected: (_) => setState(() => _selectedRoleFilter = role),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Users List
            Expanded(
              child: filtered.isEmpty
                  ? const Center(child: Text('Tidak ada pengguna yang sesuai filter.'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: filtered.length,
                      separatorBuilder: (ctx, i) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final u = filtered[index];
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.surfaceVariant,
                                child: Text(
                                  u.name.isNotEmpty ? u.name[0].toUpperCase() : 'U',
                                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(u.name, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
                                        const SizedBox(width: 6),
                                        _buildRoleBadge(u.role),
                                      ],
                                    ),
                                    Text('@${u.username} • ${u.email}', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                                    if (u.storeName != null)
                                      Text('Toko: ${u.storeName}', style: AppTextStyles.caption.copyWith(color: AppColors.primaryDark, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                              // Active / Suspend Toggle
                              if (!u.isAdmin)
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textSecondary),
                                  onSelected: (val) {
                                    if (val == 'toggle') {
                                      ref.read(adminProvider.notifier).toggleUserStatus(u.id, u.status);
                                    }
                                  },
                                  itemBuilder: (ctx) => [
                                    PopupMenuItem(
                                      value: 'toggle',
                                      child: Text(
                                        u.status == 'active' ? 'Nonaktifkan Akun' : 'Aktifkan Akun',
                                        style: TextStyle(color: u.status == 'active' ? AppColors.error : AppColors.success),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRoleBadge(String role) {
    Color bg = AppColors.surfaceVariant;
    Color fg = AppColors.textPrimary;

    if (role == 'admin') {
      bg = const Color(0xFF2C3E50);
      fg = Colors.white;
    } else if (role == 'merchant') {
      bg = const Color(0xFFE8F5E9);
      fg = const Color(0xFF2E7D32);
    } else if (role == 'cashier') {
      bg = const Color(0xFFFFF3E0);
      fg = const Color(0xFFE65100);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(
        role.toUpperCase(),
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }

  // ─── TAB 3: VERIFIKASI TOKO ────────────────────────────────────────────────
  Widget _buildStoresTab(AdminState state) {
    final stores = state.stores;

    if (stores.isEmpty) {
      return const Center(child: Text('Belum ada data toko mitra.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: stores.length,
      separatorBuilder: (ctx, i) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final store = stores[index];
        final isPending = store.verificationStatus == 'pending';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isPending ? const Color(0xFFFFB300) : AppColors.border,
              width: isPending ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      store.name,
                      style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  _buildStoreVerificationBadge(store.verificationStatus),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Kategori: ${store.category} • ${store.address ?? "Lokasi belum diatur"}',
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
              ),
              if (store.description != null) ...[
                const SizedBox(height: 6),
                Text(store.description!, style: AppTextStyles.bodyMedium),
              ],
              const Divider(height: 20),

              // Action buttons
              if (isPending) ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => ref.read(adminProvider.notifier).verifyStore(store.id, false),
                        child: const Text('Tolak Pengajuan'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => ref.read(adminProvider.notifier).verifyStore(store.id, true),
                        child: const Text('Verifikasi & Aktifkan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Status Operasional: ${store.isOpen ? "Buka" : "Tutup"}',
                      style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
                    ),
                    TextButton(
                      onPressed: () {
                        final next = store.verificationStatus == 'verified' ? 'suspended' : 'verified';
                        ref.read(adminProvider.notifier).setStoreVerification(store.id, next);
                      },
                      child: Text(
                        store.verificationStatus == 'verified' ? 'Tangguhkan Toko' : 'Aktifkan Kembali',
                        style: TextStyle(
                          color: store.verificationStatus == 'verified' ? AppColors.error : AppColors.success,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStoreVerificationBadge(String status) {
    Color bg = AppColors.surfaceVariant;
    Color fg = AppColors.textPrimary;

    if (status == 'verified') {
      bg = AppColors.successLight;
      fg = AppColors.success;
    } else if (status == 'pending') {
      bg = const Color(0xFFFFF8E1);
      fg = const Color(0xFFF57F17);
    } else if (status == 'rejected' || status == 'suspended') {
      bg = AppColors.errorLight;
      fg = AppColors.error;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }

  // ─── TAB 4: KATEGORI KULINER ──────────────────────────────────────────────
  Widget _buildCategoriesTab(AdminState state) {
    final categories = state.categories;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah Kategori', style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.w700)),
        onPressed: () => _showAddCategoryDialog(context),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount: categories.length,
        separatorBuilder: (ctx, i) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final cat = categories[index];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.category_outlined, size: 18, color: AppColors.primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    cat.name,
                    style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                  onPressed: () => ref.read(adminProvider.notifier).deleteCategory(cat.id),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Tambah Kategori Kuliner', style: AppTextStyles.headingSmall),
        content: CustomTextField(
          label: 'Nama Kategori',
          hintText: 'Contoh: Gelato, Rooftop, Live Music',
          controller: ctrl,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                ref.read(adminProvider.notifier).addCategory(ctrl.text.trim());
              }
              Navigator.pop(ctx);
            },
            child: const Text('Tambah', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ─── TAB 5: PESANAN PLATFORM ──────────────────────────────────────────────
  Widget _buildOrdersTab(AdminState state) {
    final orders = state.orders;

    if (orders.isEmpty) {
      return const Center(child: Text('Belum ada pesanan di platform.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      separatorBuilder: (ctx, i) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final order = orders[index];
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
                  Text('Order #${order.orderNumber}', style: const TextStyle(fontWeight: FontWeight.w700)),
                  _buildStatusBadge(order.status),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Toko: ${order.placeName} • Waktu: ${AppUtils.formatDate(order.createdAt)}',
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
              ),
              const Divider(height: 16),
              ...order.items.map(
                (it) => Text('${it.quantity}x ${it.name} (${AppUtils.formatRupiah(it.subtotal)})', style: AppTextStyles.caption),
              ),
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Pembayaran:', style: TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    AppUtils.formatRupiah(order.total),
                    style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primaryDark),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(6)),
      child: Text(
        AppUtils.orderStatusLabel(status),
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
      ),
    );
  }

  // ─── TAB 6: AUDIT LOG ─────────────────────────────────────────────────────
  Widget _buildAuditLogTab(AdminState state) {
    final logs = state.logs;

    if (logs.isEmpty) {
      return const Center(child: Text('Belum ada catatan aktivitas.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: logs.length,
      separatorBuilder: (ctx, i) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final log = logs[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      log.action,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                    ),
                  ),
                  Text(AppUtils.formatDate(log.timestamp), style: AppTextStyles.caption.copyWith(fontSize: 10)),
                ],
              ),
              const SizedBox(height: 6),
              Text(log.details, style: AppTextStyles.bodyMedium),
              const SizedBox(height: 4),
              Text('Aktor: ${log.actorName} (${log.actorRole})', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        );
      },
    );
  }
}
