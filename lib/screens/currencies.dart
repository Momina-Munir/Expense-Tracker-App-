class AppCurrency {
  final String code;
  final String symbol;
  final String country;
  final String flag;

  const AppCurrency({
    required this.code,
    required this.symbol,
    required this.country,
    required this.flag,
  });

  String format(double amount) =>
      '$symbol ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
}

const List<AppCurrency> kCurrencies = [
  AppCurrency(code: 'PKR', symbol: '₨', country: 'Pakistan', flag: '🇵🇰'),
  AppCurrency(code: 'USD', symbol: '\$', country: 'United States', flag: '🇺🇸'),
  AppCurrency(code: 'EUR', symbol: '€', country: 'Europe', flag: '🇪🇺'),
  AppCurrency(code: 'GBP', symbol: '£', country: 'United Kingdom', flag: '🇬🇧'),
  AppCurrency(code: 'AED', symbol: 'د.إ', country: 'UAE', flag: '🇦🇪'),
  AppCurrency(code: 'SAR', symbol: '﷼', country: 'Saudi Arabia', flag: '🇸🇦'),
  AppCurrency(code: 'INR', symbol: '₹', country: 'India', flag: '🇮🇳'),
  AppCurrency(code: 'CAD', symbol: 'C\$', country: 'Canada', flag: '🇨🇦'),
  AppCurrency(code: 'AUD', symbol: 'A\$', country: 'Australia', flag: '🇦🇺'),
  AppCurrency(code: 'TRY', symbol: '₺', country: 'Turkey', flag: '🇹🇷'),
  AppCurrency(code: 'CNY', symbol: '¥', country: 'China', flag: '🇨🇳'),
  AppCurrency(code: 'JPY', symbol: '¥', country: 'Japan', flag: '🇯🇵'),
  AppCurrency(code: 'MYR', symbol: 'RM', country: 'Malaysia', flag: '🇲🇾'),
  AppCurrency(code: 'QAR', symbol: 'QR', country: 'Qatar', flag: '🇶🇦'),
  AppCurrency(code: 'KWD', symbol: 'KD', country: 'Kuwait', flag: '🇰🇼'),
];