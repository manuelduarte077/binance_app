import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

// Provider for the CriptoRepository
final criptoRepositoryProvider = Provider((ref) => CriptoRepository());

/// A class that fetches cryptocurrency data from the Binance API.
class CriptoRepository {
  /// Fetches a list of cryptocurrencies from the Binance API.
  Future<http.Response> getCriptos() async {
    final url = Uri.parse('https://api.binance.com/api/v3/exchangeInfo');
    final response = await http.get(url);

    return response;
  }

  /// Fetches the price of a cryptocurrency by its symbol from the Binance API.
  Future<http.Response> getPriceBySymbol(String symbol) async {
    final url =
        Uri.parse('https://api.binance.com/api/v3/avgPrice?symbol=$symbol');
    final response = await http.get(url);

    return response;
  }
}
