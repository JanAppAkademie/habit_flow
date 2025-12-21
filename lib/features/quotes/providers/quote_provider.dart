import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/quote_repository.dart';
import '../models/quote.dart';

final dioProvider = Provider<Dio>((ref) {
  return Dio();
});

final quoteRepositoryProvider = Provider<QuoteRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return QuoteRepository(dio);
});

final quoteProvider = AsyncNotifierProvider<QuoteNotifier, Quote>(
  QuoteNotifier.new,
);

class QuoteNotifier extends AsyncNotifier<Quote> {
  @override
  Future<Quote> build() async {
    final repository = ref.watch(quoteRepositoryProvider);
    return repository.fetchRandomQuote();
  }

  Future<void> refreshQuote() async {
    final repository = ref.read(quoteRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(repository.fetchRandomQuote);
  }
}
