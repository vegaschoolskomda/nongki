import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../data/models/menu_item_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/merchant_provider.dart';

class MerchantDashboardScreen extends ConsumerStatefulWidget {
  const MerchantDashboardScreen({super.key});

  @override
  ConsumerState<MerchantDashboardScreen> createState() => _MerchantDashboardScreenState();
}

class _MerchantDashboardScreenState extends ConsumerState<MerchantDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final merchantState = ref.watch(merchantProvider);

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
              merchantState.store?.name ?? 'Dashboard Mitra UMKM',
              style: AppTextStyles.headingSmall.copyWith(fontSize: 16),
            ),
            Text(
              'Pengelolaan Toko & Operasional Usaha',
              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            tooltip: 'Perbarui Data',
            onPressed: () => ref.read(merchantProvider.notifier).refreshData(),
          ),
          IconButton(
            icon: const Icon(Icons.home_outlined, color: AppColors.primary),
            tooltip: 'Halaman Utama',
            onPressed: () => context.go('/'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primaryDark,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 13),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: 13),
          tabs: const [
            Tab(text: 'Toko Saya'),
            Tab(text: 'Menu & Harga'),
            Tab(text: 'Pesanan Masuk'),
            Tab(text: 'Karyawan Kasir'),
            Tab(text: 'Laporan Penjualan'),
          ],
        ),
      ),
      body: merchantState.isLoading
          ? Center(child: LoadingIndicator(message: 'Memuat data usaha...'))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildStoreTab(merchantState),
                _buildMenuTab(merchantState),
                _buildOrdersTab(merchantState),
                _buildCashierTab(merchantState),
                _buildReportTab(merchantState),
              ],
            ),
    );
  }

  // ─── TAB 1: TOKO SAYA ───────────────────────────────────────────────────────
  Widget _buildStoreTab(MerchantState state) {
    final store = state.store;
    if (store == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.storefront_outlined, size: 64, color: AppColors.textSecondary),
              const SizedBox(height: 12),
              const Text('Data toko belum terhubung.', style: AppTextStyles.headingSmall),
              const SizedBox(height: 8),
              const Text(
                'Akun Anda belum memiliki data toko yang terdaftar.',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Perbarui Data',
                onPressed: () => ref.read(merchantProvider.notifier).refreshData(),
              ),
            ],
          ),
        ),
      );
    }

    final isPending = store.isPendingVerification;
    final isVerified = store.isVerified;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Verification status banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isPending
                  ? const Color(0xFFFFF8E1)
                  : (isVerified ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE)),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isPending
                    ? const Color(0xFFFFB300)
                    : (isVerified ? const Color(0xFF4CAF50) : const Color(0xFFE53935)),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isPending ? Icons.pending_actions_rounded : (isVerified ? Icons.verified_rounded : Icons.block_rounded),
                  color: isPending
                      ? const Color(0xFFF57F17)
                      : (isVerified ? const Color(0xFF2E7D32) : const Color(0xFFC62828)),
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isPending
                            ? 'Status: Menunggu Verifikasi Admin'
                            : (isVerified ? 'Toko Terverifikasi Resmi' : 'Status: ${store.verificationStatus}'),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: isPending
                              ? const Color(0xFFF57F17)
                              : (isVerified ? const Color(0xFF2E7D32) : const Color(0xFFC62828)),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isPending
                            ? 'Pengajuan toko Anda sedang ditinjau oleh Administrator NONGKI.'
                            : 'Toko kamu aktif dan tampil di katalog rekomendasi kuliner.',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Store open/close switch card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: store.isOpen ? AppColors.successLight : AppColors.errorLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    store.isOpen ? Icons.door_sliding_outlined : Icons.door_front_door_outlined,
                    color: store.isOpen ? AppColors.success : AppColors.error,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store.isOpen ? 'Toko Sedang Buka' : 'Toko Sedang Tutup',
                        style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        store.isOpen ? 'Pelanggan dapat memesan menu sekarang.' : 'Pelanggan tidak dapat membuat pesanan baru.',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: store.isOpen,
                  activeThumbColor: AppColors.success,
                  onChanged: (val) {
                    ref.read(merchantProvider.notifier).updateStoreInfo(isOpen: val);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Store Information Details Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Informasi Profil Toko', style: AppTextStyles.headingSmall),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
                      tooltip: 'Edit Profil Toko',
                      onPressed: () => _showEditStoreDialog(context, store),
                    ),
                  ],
                ),
                const Divider(height: 24),
                _buildInfoRow('Nama Toko', store.name),
                _buildInfoRow('Kategori', store.category),
                _buildInfoRow('Alamat', store.address ?? 'Belum diisi'),
                _buildInfoRow('Jam Operasional', store.openingHours ?? '09:00 - 22:00 WIB'),
                _buildInfoRow('Estimasi Harga', store.priceRange),
                _buildInfoRow('Rating Toko', '${store.rating ?? 4.5} (${store.reviewCount} ulasan)'),
                const SizedBox(height: 8),
                Text('Deskripsi Toko:', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  store.description ?? 'Belum ada deskripsi toko.',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Preview button: Open customer detail screen for this place
          CustomButton(
            text: 'Lihat Tampilan Toko di Katalog Pelanggan',
            type: ButtonType.outlined,
            icon: Icons.preview_rounded,
            onPressed: () => context.push('/place/${store.id}'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditStoreDialog(BuildContext context, store) {
    final nameCtrl = TextEditingController(text: store.name);
    final categoryCtrl = TextEditingController(text: store.category);
    final addressCtrl = TextEditingController(text: store.address ?? '');
    final hoursCtrl = TextEditingController(text: store.openingHours ?? '09:00 - 22:00 WIB');
    final descCtrl = TextEditingController(text: store.description ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Profil Toko', style: AppTextStyles.headingSmall),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(label: 'Nama Toko', controller: nameCtrl),
              const SizedBox(height: 12),
              CustomTextField(label: 'Kategori Usaha', controller: categoryCtrl),
              const SizedBox(height: 12),
              CustomTextField(label: 'Alamat', controller: addressCtrl),
              const SizedBox(height: 12),
              CustomTextField(label: 'Jam Operasional', controller: hoursCtrl),
              const SizedBox(height: 12),
              CustomTextField(label: 'Deskripsi Toko', controller: descCtrl, maxLines: 2),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(ctx);
              await ref.read(merchantProvider.notifier).updateStoreInfo(
                    name: nameCtrl.text.trim(),
                    category: categoryCtrl.text.trim(),
                    address: addressCtrl.text.trim(),
                    openingHours: hoursCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                  );
              if (mounted) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Profil toko berhasil diperbarui!')),
                );
              }
            },
            child: const Text('Simpan Perubahan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ─── TAB 2: MENU & HARGA ───────────────────────────────────────────────────
  Widget _buildMenuTab(MerchantState state) {
    final menus = state.menus;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah Menu', style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.w700)),
        onPressed: () => _showAddMenuDialog(context),
      ),
      body: menus.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.restaurant_menu_rounded, size: 56, color: AppColors.textSecondary),
                    const SizedBox(height: 12),
                    const Text('Belum ada menu di toko ini.', style: AppTextStyles.headingSmall),
                    const SizedBox(height: 8),
                    const Text('Klik tombol Tambah Menu untuk menambahkan menu andalanmu.', textAlign: TextAlign.center),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: menus.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = menus[index];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: 64,
                          height: 64,
                          color: AppColors.surfaceVariant,
                          child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                              ? Image.network(
                                  item.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, st) => const Icon(Icons.fastfood_outlined, color: AppColors.primary),
                                )
                              : const Icon(Icons.fastfood_outlined, color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    item.name,
                                    style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.accent,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item.category,
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primaryDark),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppUtils.formatRupiah(item.price),
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: AppColors.primaryDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  'Stok: ${item.stok ?? 0} ${item.satuanStok ?? "porsi"}',
                                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: item.isAvailable ? AppColors.successLight : AppColors.errorLight,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    item.isAvailable ? 'Tersedia' : 'Habis',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: item.isAvailable ? AppColors.success : AppColors.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textSecondary),
                        onSelected: (val) {
                          if (val == 'edit') {
                            _showEditMenuDialog(context, item);
                          } else if (val == 'toggle') {
                            ref.read(merchantProvider.notifier).updateMenuItem(
                                  item.copyWith(isAvailable: !item.isAvailable),
                                );
                          } else if (val == 'delete') {
                            _confirmDeleteMenu(context, item);
                          }
                        },
                        itemBuilder: (ctx) => [
                          const PopupMenuItem(value: 'edit', child: Text('Ubah Harga / Stok')),
                          PopupMenuItem(
                            value: 'toggle',
                            child: Text(item.isAvailable ? 'Tandai Habis' : 'Tandai Tersedia'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Hapus Menu', style: TextStyle(color: AppColors.error)),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  void _showAddMenuDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final stokCtrl = TextEditingController(text: '50');
    final photoCtrl = TextEditingController();
    String category = 'Kopi';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Tambah Menu Baru', style: AppTextStyles.headingSmall),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(label: 'Nama Makanan / Minuman', controller: nameCtrl),
                const SizedBox(height: 12),
                Text('Kategori Menu', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: category,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'Kopi', child: Text('Kopi')),
                        DropdownMenuItem(value: 'Non-Kopi', child: Text('Non-Kopi')),
                        DropdownMenuItem(value: 'Makanan', child: Text('Makanan')),
                        DropdownMenuItem(value: 'Camilan', child: Text('Camilan')),
                      ],
                      onChanged: (val) {
                        if (val != null) setDialogState(() => category = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Harga Jual (Rp)',
                  hintText: 'Contoh: 18000',
                  keyboardType: TextInputType.number,
                  controller: priceCtrl,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Stok Awal',
                  hintText: 'Contoh: 50',
                  keyboardType: TextInputType.number,
                  controller: stokCtrl,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'URL Foto Menu (Opsional)',
                  hintText: 'https://... (Kosongkan jika ingin foto otomatis)',
                  controller: photoCtrl,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Deskripsi Singkat',
                  hintText: 'Bahan, rasa, atau catatan sajian',
                  maxLines: 2,
                  controller: descCtrl,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty || priceCtrl.text.trim().isEmpty) return;
                final price = int.tryParse(priceCtrl.text.trim()) ?? 0;
                final stok = int.tryParse(stokCtrl.text.trim()) ?? 50;

                final messenger = ScaffoldMessenger.of(context);
                Navigator.pop(ctx);
                await ref.read(merchantProvider.notifier).addMenuItem(
                      name: nameCtrl.text.trim(),
                      category: category,
                      price: price,
                      stok: stok,
                      description: descCtrl.text.trim(),
                      imageUrl: photoCtrl.text.trim().isNotEmpty ? photoCtrl.text.trim() : null,
                    );
                if (mounted) {
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Menu baru berhasil ditambahkan!')),
                  );
                }
              },
              child: const Text('Simpan Menu', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditMenuDialog(BuildContext context, MenuItemModel item) {
    final nameCtrl = TextEditingController(text: item.name);
    final priceCtrl = TextEditingController(text: item.price.toString());
    final stokCtrl = TextEditingController(text: (item.stok ?? 0).toString());
    final photoCtrl = TextEditingController(text: item.imageUrl ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Ubah Harga & Stok Menu', style: AppTextStyles.headingSmall),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(label: 'Nama Menu', controller: nameCtrl),
              const SizedBox(height: 12),
              CustomTextField(label: 'Harga (Rp)', keyboardType: TextInputType.number, controller: priceCtrl),
              const SizedBox(height: 12),
              CustomTextField(label: 'Stok', keyboardType: TextInputType.number, controller: stokCtrl),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'URL Foto Menu (Opsional)',
                hintText: 'https://...',
                controller: photoCtrl,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              final newPrice = int.tryParse(priceCtrl.text.trim()) ?? item.price;
              final newStok = int.tryParse(stokCtrl.text.trim()) ?? item.stok;

              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(ctx);
              await ref.read(merchantProvider.notifier).updateMenuItem(
                    item.copyWith(
                      name: nameCtrl.text.trim(),
                      price: newPrice,
                      stok: newStok,
                      imageUrl: photoCtrl.text.trim().isNotEmpty ? photoCtrl.text.trim() : item.imageUrl,
                    ),
                  );
              if (mounted) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Perubahan menu tersimpan di database.')),
                );
              }
            },
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteMenu(BuildContext context, MenuItemModel item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Menu', style: AppTextStyles.headingSmall),
        content: Text('Apakah Anda yakin ingin menghapus "${item.name}" dari daftar menu?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(ctx);
              await ref.read(merchantProvider.notifier).deleteMenuItem(item.id);
              if (mounted) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Menu berhasil dihapus.')),
                );
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ─── TAB 3: PESANAN MASUK ──────────────────────────────────────────────────
  Widget _buildOrdersTab(MerchantState state) {
    final orders = state.orders;

    if (orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.receipt_long_outlined, size: 56, color: AppColors.textSecondary),
              const SizedBox(height: 12),
              const Text('Belum ada pesanan masuk.', style: AppTextStyles.headingSmall),
              const SizedBox(height: 8),
              const Text('Pesanan dari pelanggan yang memilih tokomu akan muncul di sini secara real time.'),
            ],
          ),
        ),
      );
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
                  Text(
                    'Order #${order.orderNumber}',
                    style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  _buildStatusChip(order.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Pelanggan: ${order.diningOption == "dine_in" ? "Dine In" : "Takeaway"} ${order.tableNumber != null ? "(Meja ${order.tableNumber})" : ""}',
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
                  const Text('Total Pembayaran:', style: TextStyle(fontWeight: FontWeight.w700)),
                  Text(
                    AppUtils.formatRupiah(order.total),
                    style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primaryDark, fontSize: 15),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Order status advance action button
              if (order.status != 'completed' && order.status != 'cancelled') ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () async {
                      String next = 'accepted';
                      if (order.status == 'accepted') next = 'processing';
                      if (order.status == 'processing') next = 'ready';
                      if (order.status == 'ready') next = 'completed';

                      await ref.read(merchantProvider.notifier).updateOrderStatus(order.id, next);
                    },
                    child: Text(
                      _getNextStatusButtonLabel(order.status),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  String _getNextStatusButtonLabel(String status) {
    switch (status) {
      case 'pending_confirmation':
        return 'Terima Pesanan Ini';
      case 'accepted':
        return 'Mulai Proses Masak / Seduh';
      case 'processing':
        return 'Tandai Siap Disajikan';
      case 'ready':
        return 'Selesaikan Pesanan';
      default:
        return 'Perbarui Status';
    }
  }

  Widget _buildStatusChip(String status) {
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
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }

  // ─── TAB 4: KARYAWAN KASIR ────────────────────────────────────────────────
  Widget _buildCashierTab(MerchantState state) {
    final cashiers = state.cashiers;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add_outlined, color: Colors.white),
        label: const Text('Buat Akun Kasir', style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.w700)),
        onPressed: () => _showAddCashierDialog(context),
      ),
      body: cashiers.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.point_of_sale_outlined, size: 56, color: AppColors.textSecondary),
                    const SizedBox(height: 12),
                    const Text('Belum ada akun kasir.', style: AppTextStyles.headingSmall),
                    const SizedBox(height: 8),
                    const Text(
                      'Buat akun kasir khusus agar karyawan toko Anda dapat memproses pesanan dan mencetak struk.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: cashiers.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final cashier = cashiers[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.badge_outlined, color: AppColors.primary),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(cashier.name, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
                            Text('@${cashier.username}', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: cashier.status == 'active' ? AppColors.successLight : AppColors.errorLight,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                cashier.status == 'active' ? 'Aktif' : 'Nonaktif',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: cashier.status == 'active' ? AppColors.success : AppColors.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: cashier.status == 'active',
                        activeThumbColor: AppColors.success,
                        onChanged: (val) {
                          ref.read(authProvider.notifier).setUserStatus(
                                cashier.id,
                                val ? 'active' : 'suspended',
                              );
                          ref.read(merchantProvider.notifier).refreshData();
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  void _showAddCashierDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final usernameCtrl = TextEditingController();
    final passCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Buat Akun Kasir Baru', style: AppTextStyles.headingSmall),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(label: 'Nama Karyawan', controller: nameCtrl),
            const SizedBox(height: 12),
            CustomTextField(label: 'Username Kasir', controller: usernameCtrl),
            const SizedBox(height: 12),
            CustomTextField(label: 'Password / PIN', isPassword: true, controller: passCtrl),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty || usernameCtrl.text.trim().isEmpty || passCtrl.text.isEmpty) return;

              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(ctx);
              final ok = await ref.read(merchantProvider.notifier).createCashier(
                    name: nameCtrl.text.trim(),
                    username: usernameCtrl.text.trim(),
                    password: passCtrl.text,
                  );
              if (ok && mounted) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Akun kasir berhasil dibuat!')),
                );
              }
            },
            child: const Text('Buat Akun', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ─── TAB 5: LAPORAN PENJUALAN ─────────────────────────────────────────────
  Widget _buildReportTab(MerchantState state) {
    final orders = state.orders;
    int totalRevenue = 0;
    int completedOrders = 0;
    final Map<String, int> menuSales = {};

    for (final o in orders) {
      if (o.status == 'completed' || o.paymentStatus == 'paid') {
        totalRevenue += o.total;
        completedOrders++;
        for (final it in o.items) {
          menuSales[it.name] = (menuSales[it.name] ?? 0) + it.quantity;
        }
      }
    }

    final topMenus = menuSales.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: 'Total Pendapatan',
                  value: AppUtils.formatRupiah(totalRevenue),
                  icon: Icons.payments_outlined,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  title: 'Pesanan Selesai',
                  value: '$completedOrders Pesanan',
                  icon: Icons.check_circle_outline,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Top selling items
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Menu Paling Laris', style: AppTextStyles.headingSmall),
                const SizedBox(height: 12),
                if (topMenus.isEmpty)
                  const Text('Belum ada transaksi selesai untuk dihitung.')
                else
                  ...topMenus.take(5).map(
                        (entry) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(entry.key, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                              Text(
                                '${entry.value} terjual',
                                style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                              ),
                            ],
                          ),
                        ),
                      ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Business note
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.primaryDark, size: 20),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Data di atas bersumber langsung dari transaksi toko Anda di ekosistem NONGKI.',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.primaryDark),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 10),
          Text(title, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w800, fontSize: 16, color: color),
          ),
        ],
      ),
    );
  }
}
