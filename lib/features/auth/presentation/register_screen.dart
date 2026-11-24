import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  int _selectedRoleIndex = 0; // 0: Pengguna (Customer), 1: Pemilik Toko (Merchant)

  // Customer Form
  final _customerFormKey = GlobalKey<FormState>();
  final _custNameController = TextEditingController();
  final _custUsernameController = TextEditingController();
  final _custEmailController = TextEditingController();
  final _custPasswordController = TextEditingController();
  final _custConfirmPasswordController = TextEditingController();

  // Merchant Form
  final _merchantFormKey = GlobalKey<FormState>();
  final _merchOwnerController = TextEditingController();
  final _merchStoreController = TextEditingController();
  final _merchPhoneController = TextEditingController();
  final _merchEmailController = TextEditingController();
  final _merchUsernameController = TextEditingController();
  final _merchAddressController = TextEditingController();
  final _merchDescController = TextEditingController();
  final _merchPasswordController = TextEditingController();
  final _merchConfirmPasswordController = TextEditingController();
  String _selectedCategory = 'Kafe';

  final List<String> _businessCategories = const [
    'Kafe',
    'Coffee Shop',
    'Kedai',
    'Working Space',
    'Restoran',
    'Dessert & Bakery',
  ];

  @override
  void dispose() {
    _custNameController.dispose();
    _custUsernameController.dispose();
    _custEmailController.dispose();
    _custPasswordController.dispose();
    _custConfirmPasswordController.dispose();

    _merchOwnerController.dispose();
    _merchStoreController.dispose();
    _merchPhoneController.dispose();
    _merchEmailController.dispose();
    _merchUsernameController.dispose();
    _merchAddressController.dispose();
    _merchDescController.dispose();
    _merchPasswordController.dispose();
    _merchConfirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegisterCustomer() async {
    if (!_customerFormKey.currentState!.validate()) return;
    if (_custPasswordController.text != _custConfirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Konfirmasi kata sandi tidak cocok.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final success = await ref.read(authProvider.notifier).registerCustomer(
          name: _custNameController.text.trim(),
          username: _custUsernameController.text.trim(),
          email: _custEmailController.text.trim(),
          password: _custPasswordController.text,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Akun Pengguna berhasil dibuat. Selamat datang di NONGKI!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.go('/');
    }
  }

  Future<void> _handleRegisterMerchant() async {
    if (!_merchantFormKey.currentState!.validate()) return;
    if (_merchPasswordController.text != _merchConfirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Konfirmasi kata sandi tidak cocok.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final success = await ref.read(authProvider.notifier).registerMerchant(
          ownerName: _merchOwnerController.text.trim(),
          storeName: _merchStoreController.text.trim(),
          category: _selectedCategory,
          phone: _merchPhoneController.text.trim(),
          email: _merchEmailController.text.trim(),
          username: _merchUsernameController.text.trim(),
          address: _merchAddressController.text.trim(),
          description: _merchDescController.text.trim(),
          password: _merchPasswordController.text,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pendaftaran Mitra Toko berhasil diajukan. Status toko: Menunggu Verifikasi.'),
          backgroundColor: AppColors.success,
        ),
      );
      context.go('/merchant-dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border, width: 1.2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/logo/logo_icon.png',
                        height: 28,
                        width: 28,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'NONGKI',
                        style: AppTextStyles.headingSmall.copyWith(
                          color: AppColors.primaryDark,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'Buat Akun Baru',
                style: AppTextStyles.headingLarge.copyWith(color: AppColors.primaryDark),
              ),
              const SizedBox(height: 6),
              Text(
                'Pilih peran pendaftaran sesuai kebutuhanmu.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),

              // Segmented Role Selector
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedRoleIndex = 0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedRoleIndex == 0 ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _selectedRoleIndex == 0
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.06),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_outline_rounded,
                                size: 18,
                                color: _selectedRoleIndex == 0 ? AppColors.primaryDark : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Pengguna',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: _selectedRoleIndex == 0 ? FontWeight.w700 : FontWeight.w500,
                                  color: _selectedRoleIndex == 0 ? AppColors.primaryDark : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedRoleIndex = 1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedRoleIndex == 1 ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _selectedRoleIndex == 1
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.06),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.storefront_outlined,
                                size: 18,
                                color: _selectedRoleIndex == 1 ? AppColors.primaryDark : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Pemilik Toko',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: _selectedRoleIndex == 1 ? FontWeight.w700 : FontWeight.w500,
                                  color: _selectedRoleIndex == 1 ? AppColors.primaryDark : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Error display
              if (authState.error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          authState.error!,
                          style: AppTextStyles.caption.copyWith(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Role 0: Customer Registration Form
              if (_selectedRoleIndex == 0) ...[
                Form(
                  key: _customerFormKey,
                  child: Column(
                    children: [
                      CustomTextField(
                        label: 'Nama Lengkap',
                        hintText: 'Masukkan nama lengkap kamu',
                        prefixIcon: Icons.badge_outlined,
                        controller: _custNameController,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Nama lengkap wajib diisi.';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        label: 'Username',
                        hintText: 'Contoh: vegaspot',
                        prefixIcon: Icons.alternate_email_rounded,
                        controller: _custUsernameController,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Username wajib diisi.';
                          if (val.trim().contains(' ')) return 'Username tidak boleh ada spasi.';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        label: 'Email',
                        hintText: 'nama@email.com',
                        prefixIcon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        controller: _custEmailController,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Email wajib diisi.';
                          if (!val.contains('@')) return 'Format email tidak valid.';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        label: 'Kata Sandi',
                        hintText: 'Minimal 6 karakter',
                        prefixIcon: Icons.lock_outline_rounded,
                        isPassword: true,
                        controller: _custPasswordController,
                        validator: (val) {
                          if (val == null || val.length < 6) return 'Kata sandi minimal 6 karakter.';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        label: 'Konfirmasi Kata Sandi',
                        hintText: 'Ulangi kata sandi kamu',
                        prefixIcon: Icons.lock_outline_rounded,
                        isPassword: true,
                        controller: _custConfirmPasswordController,
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Konfirmasi kata sandi wajib diisi.';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: 'Daftar sebagai Pengguna',
                        isLoading: authState.isLoading,
                        onPressed: _handleRegisterCustomer,
                      ),
                    ],
                  ),
                ),
              ],

              // Role 1: Merchant Registration Form
              if (_selectedRoleIndex == 1) ...[
                Form(
                  key: _merchantFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: AppColors.primaryDark, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Toko kamu akan diverifikasi oleh tim NONGKI setelah pendaftaran.',
                                style: AppTextStyles.caption.copyWith(color: AppColors.primaryDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Nama Pemilik Usaha',
                        hintText: 'Nama lengkap pemilik kafe',
                        prefixIcon: Icons.person_outline_rounded,
                        controller: _merchOwnerController,
                        validator: (val) => val == null || val.trim().isEmpty ? 'Nama pemilik wajib diisi.' : null,
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        label: 'Nama Toko / Kafe',
                        hintText: 'Contoh: Es Coklat Impian',
                        prefixIcon: Icons.storefront_outlined,
                        controller: _merchStoreController,
                        validator: (val) => val == null || val.trim().isEmpty ? 'Nama toko wajib diisi.' : null,
                      ),
                      const SizedBox(height: 14),
                      // Kategori Usaha
                      Text('Kategori Usaha', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCategory,
                            isExpanded: true,
                            items: _businessCategories
                                .map((cat) => DropdownMenuItem(
                                      value: cat,
                                      child: Text(cat, style: AppTextStyles.bodyMedium),
                                    ))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedCategory = val);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        label: 'Nomor Telepon / WhatsApp',
                        hintText: '081234567890',
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        controller: _merchPhoneController,
                        validator: (val) => val == null || val.trim().isEmpty ? 'Nomor telepon wajib diisi.' : null,
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        label: 'Email Usaha',
                        hintText: 'toko@domain.com',
                        prefixIcon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        controller: _merchEmailController,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Email wajib diisi.';
                          if (!val.contains('@')) return 'Format email tidak valid.';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        label: 'Username Akun Toko',
                        hintText: 'Contoh: coklatimpian',
                        prefixIcon: Icons.alternate_email_rounded,
                        controller: _merchUsernameController,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Username toko wajib diisi.';
                          if (val.trim().contains(' ')) return 'Username tidak boleh ada spasi.';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        label: 'Alamat Toko',
                        hintText: 'Jalan, Nomor, Kelurahan, Kecamatan',
                        prefixIcon: Icons.location_on_outlined,
                        controller: _merchAddressController,
                        validator: (val) => val == null || val.trim().isEmpty ? 'Alamat toko wajib diisi.' : null,
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        label: 'Deskripsi Singkat Toko',
                        hintText: 'Ceritakan konsep tempat dan menu khas toko kamu',
                        prefixIcon: Icons.description_outlined,
                        maxLines: 2,
                        controller: _merchDescController,
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        label: 'Kata Sandi',
                        hintText: 'Minimal 6 karakter',
                        prefixIcon: Icons.lock_outline_rounded,
                        isPassword: true,
                        controller: _merchPasswordController,
                        validator: (val) => val == null || val.length < 6 ? 'Kata sandi minimal 6 karakter.' : null,
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        label: 'Konfirmasi Kata Sandi',
                        hintText: 'Ulangi kata sandi kamu',
                        prefixIcon: Icons.lock_outline_rounded,
                        isPassword: true,
                        controller: _merchConfirmPasswordController,
                        validator: (val) => val == null || val.isEmpty ? 'Konfirmasi kata sandi wajib diisi.' : null,
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: 'Daftar sebagai Pemilik Toko',
                        isLoading: authState.isLoading,
                        onPressed: _handleRegisterMerchant,
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),
              // Footer link to login
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sudah punya akun? ',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/login'),
                      child: Text(
                        'Masuk di sini',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    ref.read(authProvider.notifier).loginAsGuest();
                    context.go('/');
                  },
                  icon: const Icon(Icons.explore_outlined, size: 16, color: AppColors.textSecondary),
                  label: const Text(
                    'Masuk sebagai Tamu (Mode Terbatas)',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
