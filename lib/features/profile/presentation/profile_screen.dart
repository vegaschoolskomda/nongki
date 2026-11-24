import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/order_provider.dart';
import '../../../providers/favorites_provider.dart';
import '../../../providers/points_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isGuest = authState.isGuest;
    final orderState = ref.watch(orderProvider);
    final favIds = ref.watch(favoritesProvider);
    final pointsState = ref.watch(pointsProvider);

    final totalOrders = orderState.orders.length;
    final totalFavorites = favIds.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil Saya'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── User Profile Header Card ────────────────────────────────
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
                    color: Color(0x28000000),
                    blurRadius: 14,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: user != null
                  ? Column(
                      children: [
                        Row(
                          children: [
                            // Avatar with warm border
                            Container(
                              width: 62,
                              height: 62,
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: Center(
                                child: Text(
                                  user.name.isNotEmpty
                                      ? user.name.substring(0, 1).toUpperCase()
                                      : 'U',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.name,
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    user.email,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                      color: Colors.white.withValues(alpha: 0.8),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE67E22),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      user.role == 'admin'
                                          ? 'Administrator Platform'
                                          : (user.role == 'merchant'
                                              ? 'Mitra Pemilik Toko'
                                              : (user.role == 'cashier' ? 'Kasir Operasional' : 'Member Nongki')),
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
                            ),
                            IconButton(
                              onPressed: () => context.push('/edit-profile'),
                              icon: const Icon(Icons.edit_outlined,
                                  color: Colors.white, size: 20),
                              tooltip: 'Edit Profil',
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),
                        const Divider(color: Colors.white24, height: 1),
                        const SizedBox(height: 14),

                        // Stats counters
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem('Pesanan', '$totalOrders'),
                            Container(width: 1, height: 28, color: Colors.white24),
                            _buildStatItem('Favorit', '$totalFavorites'),
                            Container(width: 1, height: 28, color: Colors.white24),
                            _buildStatItem('Poin', '${pointsState.balance}'),
                          ],
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Container(
                          width: 62,
                          height: 62,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
                          ),
                          child: const Icon(
                            Icons.person_outline_rounded,
                            size: 32,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          isGuest ? 'Mode Tamu' : 'Selamat Datang di NONGKI',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isGuest
                              ? 'Kamu sedang menjelajahi NONGKI sebagai tamu. Daftar untuk memesan dan menyimpan favorit.'
                              : 'Masuk atau daftar untuk menyimpan tempat favorit dan memantau status pesananmu.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.85),
                            height: 1.4,
                          ),
                        ),
                        if (isGuest) ...[ 
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Fitur terbatas — Eksplorasi saja',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 42,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: AppColors.primaryDark,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(21),
                                    ),
                                  ),
                                  onPressed: () => context.push('/login'),
                                  child: const Text(
                                    'Masuk',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: SizedBox(
                                height: 42,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: const BorderSide(color: Colors.white54, width: 1.5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(21),
                                    ),
                                  ),
                                  onPressed: () => context.push('/register'),
                                  child: const Text(
                                    'Daftar',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 24),

            // ─── Menu: Akun & Aktivitas ───────────────────────────────────
            if (user != null) ...[
              _buildSectionHeader('AKUN & AKTIVITAS'),
              _buildMenuItem(
                icon: Icons.person_outline_rounded,
                title: 'Edit Data Diri',
                subtitle: 'Ubah nama dan nomor kontak',
                onTap: () => context.push('/edit-profile'),
              ),
              _buildMenuItem(
                icon: Icons.receipt_long_outlined,
                title: 'Riwayat Pesanan',
                subtitle: 'Daftar semua pesanan kafe',
                onTap: () => context.push('/orders-tab'),
              ),
              _buildMenuItem(
                icon: Icons.favorite_border_rounded,
                title: 'Tempat Favorit',
                subtitle: 'Kafe yang kamu simpan',
                onTap: () => context.push('/favorites-tab'),
              ),
              const SizedBox(height: 20),
            ],

            // ─── Menu: Fitur Eksklusif ────────────────────────────────────
            if (user != null) ...[ 
              _buildSectionHeader('FITUR EKSKLUSIF'),
              _buildMenuItem(
                icon: Icons.casino_outlined,
                title: 'Nongki Roulette',
                subtitle: 'Rekomendasi tempat acak sesuai budget',
                onTap: () => context.push('/roulette'),
              ),
              _buildMenuItem(
                icon: Icons.swipe_rounded,
                title: 'Swipe & Discover',
                subtitle: 'Jelajahi kafe dengan gestur kartu',
                onTap: () => context.push('/swipe'),
              ),
              _buildMenuItem(
                icon: Icons.stars_rounded,
                title: 'Nongki Points',
                subtitle: 'Saldo ${pointsState.balance} poin: lihat reward',
                onTap: () => context.push('/points'),
              ),
              const SizedBox(height: 20),
            ],

            // ─── Menu Khusus Merchant ────────────────────────────────────
            if (user != null && (authState.isMerchant || authState.isAdmin)) ...[
              _buildSectionHeader('PENGELOLAAN USAHA UMKM'),
              _buildMenuItem(
                icon: Icons.storefront_rounded,
                title: 'Dashboard Toko Saya',
                subtitle: 'Atur profil toko, menu, dan operasional kasir',
                onTap: () => context.push('/merchant-dashboard'),
              ),
              const SizedBox(height: 20),
            ],

            // ─── Menu Khusus Kasir ──────────────────────────────────────
            if (user != null && (authState.isCashier || authState.isAdmin)) ...[
              _buildSectionHeader('OPERASIONAL KASIR'),
              _buildMenuItem(
                icon: Icons.point_of_sale_rounded,
                title: 'Dashboard Kasir POS',
                subtitle: 'Kelola pesanan masuk dan cetak struk',
                onTap: () => context.push('/cashier-dashboard'),
              ),
              const SizedBox(height: 20),
            ],

            // ─── Menu Khusus Admin / Developer ───────────────────────────
            if (user != null && (authState.isAdmin || authState.user?.isAdmin == true)) ...[
              _buildSectionHeader('KONTROL SISTEM DEVELOPER'),
              _buildMenuItem(
                icon: Icons.admin_panel_settings_rounded,
                title: 'Admin & Developer Control Center',
                subtitle: 'Pusat kendali seluruh pengguna, toko, dan platform',
                onTap: () => context.push('/admin'),
              ),
              const SizedBox(height: 20),
            ],

            // ─── Menu: Informasi & Bantuan ───────────────────────────────
            _buildSectionHeader('INFORMASI & BANTUAN'),
            _buildMenuItem(
              icon: Icons.help_outline_rounded,
              title: 'Pusat Bantuan & Pertanyaan',
              subtitle: 'Solusi pemesanan dan panduan aplikasi',
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    title: const Text('Bantuan NONGKI',
                        style: AppTextStyles.headingSmall),
                    content: const Text(
                      'Butuh bantuan terkait pemesanan atau ingin mendaftarkan kafe kamu? Hubungi tim support kami di support@nongki.dev atau WhatsApp 0812-3456-7890.',
                      style: AppTextStyles.bodyMedium,
                    ),
                    actions: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Mengerti',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.info_outline_rounded,
              title: 'Tentang NONGKI',
              subtitle: 'Versi ${AppConstants.appVersion}',
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: AppConstants.appName,
                  applicationVersion: AppConstants.appVersion,
                  applicationLegalese: '© 2026 NONGKI App. Hak Cipta Dilindungi.',
                  children: const [
                    SizedBox(height: 12),
                    Text(
                      'NONGKI adalah aplikasi yang membantu sobat nongkrong mencari coffee shop terbaik, membandingkan menu sesuai budget, dan memesan dengan praktis.',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // ─── Logout Button ───────────────────────────────────────────
            if (user != null) ...[
              CustomButton(
                text: 'Keluar dari Akun',
                type: ButtonType.outlined,
                icon: Icons.logout_rounded,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      title: const Text('Konfirmasi Keluar',
                          style: AppTextStyles.headingSmall),
                      content: const Text(
                        'Apakah kamu yakin ingin keluar dari akun NONGKI?',
                        style: AppTextStyles.bodyMedium,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Batal'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                          ),
                          onPressed: () async {
                            Navigator.pop(ctx);
                            await ref.read(authProvider.notifier).logout();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Berhasil keluar dari akun.'),
                                ),
                              );
                            }
                          },
                          child: const Text('Keluar',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.75),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7), width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
