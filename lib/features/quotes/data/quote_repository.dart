import 'package:dio/dio.dart';

import '../models/quote.dart';

class QuoteRepository {
  QuoteRepository(this._dio);

  final Dio _dio;

  Future<Quote> fetchRandomQuote() async {
    final response = await _dio.get('https://dummyjson.com/quotes/random');
    final data = response.data as Map<String, dynamic>;
    return Quote.fromJson(data);
  }
}
