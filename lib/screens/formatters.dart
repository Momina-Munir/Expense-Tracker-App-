import 'package:intl/intl.dart';

class AppFormat {
  static String currency(double amount) {
    return 'Rs ${NumberFormat('#,##0').format(amount)}';
  }

  static String date(DateTime d) => DateFormat('dd MMM yyyy').format(d);
  static String monthYear(DateTime d) => DateFormat('MMMM yyyy').format(d);
  static String shortMonth(DateTime d) => DateFormat('MMM').format(d);
}