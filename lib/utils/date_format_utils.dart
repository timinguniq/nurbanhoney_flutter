import 'package:intl/intl.dart';

const DEFAULT_DATE_FORMAT = 'yyyy-MM-dd HH:mm';

/// Formats a date string from "YYYY-MM-DDT..." format to "YYYY.MM.DD"
String formatToYYYYMMDD(String dateString) {
  try {
    final inputArray = dateString.split('T')[0].split('-');
    return '${inputArray[0]}.${inputArray[1]}.${inputArray[2]}';
  } catch (e) {
    print('formatToYYYYMMDD error: $e');
    return '';
  }
}

/// Formats a date string to a custom format using the intl package
String formatDate(String dateString, String format) {
  try {
    final date = DateTime.parse(dateString);
    final formatter = DateFormat(format);
    return formatter.format(date);
  } catch (e) {
    print('formatDate error: $e');
    return '';
  }
}