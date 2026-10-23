import 'package:dio/dio.dart';

class CurrencyApi {
  static const String _baseUrl =
      'https://api.exchangerate-api.com/v4/latest/EGP';
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  Future<Map<String, double>> getExchangeRates() async {
    try {
      final response = await _dio.get(_baseUrl);

      if (response.statusCode == 200) {
        final rates = response.data['rates'] as Map<String, dynamic>;

        final List<String> targetCurrencies = [
          'USD',
          'EUR',
          'GBP',
          'SAR',
          'AED',
          'KWD'
        ];

        final Map<String, double> result = {};
        for (var currency in targetCurrencies) {
          if (rates.containsKey(currency)) {
            result[currency] = (rates[currency] as num).toDouble();
          }
        }
        return result;
      } else {
        throw Exception('فشل في تحميل البيانات');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw Exception('مفيش اتصال بالإنترنت');
      }
      throw Exception('خطأ في الاتصال: ${e.message}');
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع');
    }
  }
}
