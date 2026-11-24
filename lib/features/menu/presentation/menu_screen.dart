import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/models/menu_item_model.dart';
import '../../../data/models/place_model.dart';
import '../../../providers/places_provider.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/auth_provider.dart';

class MenuScreen extends ConsumerStatefulWidget {
  final String placeId;

  const MenuScreen({super.key, required this.placeId});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  String _selectedCategory = 'Semua';

  final List<String> _categories = ['Semua', 'Kopi', 'Non-Kopi', 'Makanan'];

  void _handleAddItem(MenuItemModel item, PlaceModel place) {
    final authState = ref.read(authProvider);
    if (!authState.canOrderOnline) {
      _showGuestRestrictedDialog();
      return;
    }

    final cartNotifier = ref.read(cartProvider.notifier);

    // Cek apakah ada keranjang dari tempat berbeda
    if (cartNotifier.isDifferentPlace(place.id)) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Ganti Tempat Nongki?', style: AppTextStyles.headingSmall),
          content: Text(
            'Keranjangmu saat ini berisi menu dari tempat lain. Sesuai aturan NONGKI, satu pesanan hanya bisa dari 1 tempat. Kosongkan keranjang sebelumnya?',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () {
                Navigator.pop(ctx);
                cartNotifier.addItem(item, place, forceReplace: true);
              },
              child: const Text('Ganti & Tambah', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    } else {
      cartNotifier.addItem(item, place);
    }
  }

  void _showGuestRestrictedDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.lock_outline_rounded, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Perlu Akun untuk Pesan',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          'Sebagai tamu, Anda dapat mencari kafe dan melihat menu. Untuk memesan secara online, silakan daftar akun baru atau masuk ke akun Anda.',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.push('/login');
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Masuk', style: TextStyle(color: AppColors.primary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.push('/register');
            },
            child: const Text('Daftar Sekarang', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final placeAsync = ref.watch(placeDetailProvider(widget.placeId));
    final menuAsync = ref.watch(placeMenuProvider(widget.placeId));
    final cartState = ref.watch(cartProvider);

    return placeAsync.when(
      data: (place) {
        if (place == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const EmptyStateWidget(
              icon: Icons.error_outline,
              title: 'Tempat tidak ditemukan',
              message: 'Gagal memuat tempat.',
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  place.name,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Text(
                  'Daftar Menu & Pesan',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Badge(
                  isLabelVisible: cartState.isNotEmpty,
                  label: Text('${cartState.totalItemsCount}'),
                  backgroundColor: const Color(0xFFE67E22),
                  child: const Icon(Icons.shopping_bag_outlined),
                ),
                onPressed: () => context.push('/cart'),
              ),
            ],
          ),
          body: Column(
            children: [
              // ── Category filter chips ─────────────────────────────────
              Container(
                height: 52,
                color: AppColors.surface,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _categories.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = _selectedCategory == cat;

                    return FilterChip(
                      label: Text(cat),
                      selected: isSelected,
                      labelStyle: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                      backgroundColor: AppColors.background,
                      selectedColor: AppColors.primary,
                      showCheckmark: false,
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : AppColors.border,
                        width: 0.9,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = cat;
                        });
                      },
                    );
                  },
                ),
              ),

              // ── Menu items list ───────────────────────────────────────
              Expanded(
                child: menuAsync.when(
                  data: (items) {
                    final filteredItems = _selectedCategory == 'Semua'
                        ? items
                        : items.where((i) {
                            final c = i.category.toLowerCase().trim();
                            final sel = _selectedCategory.toLowerCase().trim();
                            if (c == sel) return true;
                            if (sel == 'makanan' && (c == 'camilan' || c == 'snack' || c.contains('makan'))) return true;
                            if (sel == 'kopi' && c.contains('kopi') && !c.contains('non')) return true;
                            if (sel == 'non-kopi' && (c.contains('non') || c == 'minuman' || c == 'teh')) return true;
                            return false;
                          }).toList();

                    final displayItems = filteredItems.isNotEmpty ? filteredItems : items;

                    if (displayItems.isEmpty) {
                      return EmptyStateWidget(
                        icon: Icons.coffee_outlined,
                        title: 'Menu belum tersedia',
                        message: 'Belum ada menu yang didaftarkan untuk tempat ini.',
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                      itemCount: displayItems.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = displayItems[index];
                        final qtyInCart = ref.watch(cartProvider.notifier).getQuantity(item.id);

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.border.withValues(alpha: 0.7),
                              width: 0.8,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x06000000),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Food/Beverage Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: SizedBox(
                                  width: 82,
                                  height: 82,
                                  child: item.imageUrl != null
                                      ? CachedNetworkImage(
                                          imageUrl: item.imageUrl!,
                                          fit: BoxFit.cover,
                                          placeholder: (c, u) => Container(color: AppColors.accent),
                                          errorWidget: (c, u, e) => Container(
                                            color: AppColors.accent,
                                            child: const Icon(
                                              Icons.local_cafe_rounded,
                                              color: AppColors.primary,
                                              size: 32,
                                            ),
                                          ),
                                        )
                                      : Container(
                                          color: AppColors.accent,
                                          child: const Icon(
                                            Icons.local_cafe_rounded,
                                            color: AppColors.primary,
                                            size: 32,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Info & details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (item.description != null && item.description!.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        item.description!,
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 11,
                                          color: AppColors.textSecondary,
                                          height: 1.3,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                    const SizedBox(height: 6),
                                    Text(
                                      AppUtils.formatCurrency(item.price),
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    if (item.stok != null) ...[
                                      const SizedBox(height: 3),
                                      Text(
                                        'Stok: ${item.stok} ${item.satuanStok ?? 'porsi'}',
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 11,
                                          color: Color(0xFF27AE60),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              // Add Button / Quantity Stepper
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: !item.isAvailable
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.border,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text('Habis', style: AppTextStyles.caption),
                                      )
                                    : qtyInCart == 0
                                        ? SizedBox(
                                            height: 34,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppColors.primary,
                                                elevation: 0,
                                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(17),
                                                ),
                                              ),
                                              onPressed: () => _handleAddItem(item, place),
                                              child: const Text(
                                                '+ Tambah',
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          )
                                        : Container(
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF7EFE9),
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(
                                                color: AppColors.primary.withValues(alpha: 0.3),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    ref
                                                        .read(cartProvider.notifier)
                                                        .updateQuantity(item.id, qtyInCart - 1);
                                                  },
                                                  borderRadius: BorderRadius.circular(16),
                                                  child: const Padding(
                                                    padding: EdgeInsets.all(6),
                                                    child: Icon(Icons.remove,
                                                        size: 16, color: AppColors.primary),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                                  child: Text(
                                                    '$qtyInCart',
                                                    style: const TextStyle(
                                                      fontFamily: 'Poppins',
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w700,
                                                      color: AppColors.primary,
                                                    ),
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () => _handleAddItem(item, place),
                                                  borderRadius: BorderRadius.circular(16),
                                                  child: Container(
                                                    margin: const EdgeInsets.all(2),
                                                    padding: const EdgeInsets.all(4),
                                                    decoration: const BoxDecoration(
                                                      color: AppColors.primary,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Icon(Icons.add,
                                                        size: 14, color: Colors.white),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const BrandedLoadingWidget(message: 'Memuat menu pilihan...'),
                  error: (e, _) => EmptyStateWidget(
                    icon: Icons.error_outline,
                    title: 'Gagal memuat menu',
                    message: e.toString(),
                  ),
                ),
              ),
            ],
          ),

          // ── Bottom sticky bar when cart is not empty ─────────────────
          bottomSheet: cartState.isNotEmpty
              ? Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(
                      top: BorderSide(color: AppColors.border, width: 0.6),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x15000000),
                        blurRadius: 12,
                        offset: Offset(0, -3),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${cartState.totalItemsCount} Menu Dipilih',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              AppUtils.formatCurrency(cartState.subtotal),
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SizedBox(
                            height: 46,
                            child: ElevatedButton.icon(
                              onPressed: () => context.push('/cart'),
                              icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                              label: const Text(
                                'Lihat Keranjang',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(23),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : null,
        );
      },
      loading: () => const Scaffold(
        body: BrandedLoadingWidget(message: 'Memuat informasi tempat...'),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(e.toString())),
      ),
    );
  }
}
