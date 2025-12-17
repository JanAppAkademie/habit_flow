import 'package:dio/dio.dart';

class Quote {
  final String quote;
  final String author;

  Quote({required this.quote, required this.author});

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      quote: json['quote'] ?? '',
      author: json['author'] ?? '',
    );
  }
}

class QuoteApi {
  static final _dio = Dio();
  static const _baseUrl = 'https://dummyjson.com/quotes/random';

  static Future<Quote> fetchRandomQuote() async {
    final response = await _dio.get(_baseUrl);
    if (response.statusCode == 200) {
      return Quote.fromJson(response.data);
    } else {
      throw Exception('Failed to load quote');
    }
  }
}
