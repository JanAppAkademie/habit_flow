import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_flow/core/services/quote_api.dart';



final quoteFetchRandom = FutureProvider<Quote>((ref) async {
  return await QuoteApi.fetchRandomQuote();
});
