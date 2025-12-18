import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/quote_api.dart';


final quoteFetchRandom = FutureProvider<Quote>((ref) async {
  return await QuoteApi.fetchRandomQuote();
});
