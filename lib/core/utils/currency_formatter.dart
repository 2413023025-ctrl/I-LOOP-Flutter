import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String formatRupiah(num amount) {
    if (amount <= 0) return 'Gratis (Rp 0)';
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatCurrency.format(amount);
  }

  static String formatShortDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}j lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}h lalu';
    } else {
      return DateFormat('d MMM y', 'id_ID').format(date);
    }
  }
}
