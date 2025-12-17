import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/splash/quote_api.dart';


final quoteProvider = FutureProvider<Quote>((ref) async {
  return await QuoteApi.fetchRandomQuote();
});
