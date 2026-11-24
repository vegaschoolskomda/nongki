import 'package:intl/intl.dart';

class AppUtils {
  AppUtils._();

  /// Format harga ke Rupiah
  static String formatCurrency(int amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  /// Alias format rupiah
  static String formatRupiah(int amount) => formatCurrency(amount);

  /// Format tanggal ke format Indonesia
  static String formatDate(DateTime date) {
    try {
      final formatter = DateFormat('d MMMM yyyy', 'id_ID');
      return formatter.format(date);
    } catch (_) {
      try {
        final fallback = DateFormat('d MMMM yyyy');
        return fallback.format(date);
      } catch (_) {
        return '${date.day}/${date.month}/${date.year}';
      }
    }
  }

  /// Format tanggal + waktu
  static String formatDateTime(DateTime date) {
    try {
      final formatter = DateFormat('d MMM yyyy, HH:mm', 'id_ID');
      return formatter.format(date);
    } catch (_) {
      try {
        final fallback = DateFormat('d MMM yyyy, HH:mm');
        return fallback.format(date);
      } catch (_) {
        final h = date.hour.toString().padLeft(2, '0');
        final m = date.minute.toString().padLeft(2, '0');
        return '${date.day}/${date.month}/${date.year}, $h:$m';
      }
    }
  }

  /// Format waktu singkat
  static String formatTime(DateTime date) {
    try {
      final formatter = DateFormat('HH:mm', 'id_ID');
      return formatter.format(date);
    } catch (_) {
      final h = date.hour.toString().padLeft(2, '0');
      final m = date.minute.toString().padLeft(2, '0');
      return '$h:$m';
    }
  }

  /// Truncate text
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Rating label
  static String ratingLabel(double rating) {
    if (rating >= 4.5) return 'Luar Biasa';
    if (rating >= 4.0) return 'Sangat Baik';
    if (rating >= 3.5) return 'Baik';
    if (rating >= 3.0) return 'Cukup';
    return 'Perlu Perbaikan';
  }

  /// Order status label
  static String orderStatusLabel(String status) {
    switch (status) {
      case 'pending_confirmation':
      case 'pending_payment':
      case 'pending':
        return 'Menunggu Konfirmasi';
      case 'accepted':
        return 'Pesanan Diterima';
      case 'processing':
        return 'Sedang Diproses';
      case 'ready':
        return 'Siap Disajikan';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      case 'failed':
        return 'Gagal';
      default:
        return 'Diproses';
    }
  }

  /// Validate email
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Validate phone
  static bool isValidPhone(String phone) {
    return RegExp(r'^(\+62|62|0)8[1-9][0-9]{6,10}$').hasMatch(phone);
  }

  /// Validate password (min 8 chars)
  static bool isValidPassword(String password) {
    return password.length >= 8;
  }
}

