// lib/core/utils/date_formatter.dart
import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  static String formatDateLong(DateTime date) {
    return DateFormat('EEEE, dd MMMM yyyy', 'es').format(date);
  }

  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays > 0) {
      return 'En ${difference.inDays} días';
    } else if (difference.inDays == 0) {
      if (difference.inHours > 0) {
        return 'En ${difference.inHours} horas';
      } else if (difference.inMinutes > 0) {
        return 'En ${difference.inMinutes} minutos';
      } else {
        return 'Ahora';
      }
    } else {
      return 'Hace ${difference.inDays.abs()} días';
    }
  }
}
