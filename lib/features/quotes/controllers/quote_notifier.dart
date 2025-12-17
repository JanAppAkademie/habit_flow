import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_flow/features/quotes/data/quote_service.dart';
import 'package:habit_flow/features/quotes/models/quote.dart';

final quoteServiceProvider = Provider<QuoteService>((ref) {
  return QuoteService();
});

final quoteProvider = FutureProvider.autoDispose<Quote>((ref) async {
  final service = ref.watch(quoteServiceProvider);
  return service.fetchRandomQuote();
});
