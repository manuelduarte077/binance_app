import 'dart:convert';

import 'package:binance_app/data/models/cripto_response.dart';
import 'package:binance_app/repositories/cripto_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final criptoControllerProvider = Provider((ref) {
  final criptoRepository = ref.watch(criptoRepositoryProvider);

  return CriptoController(criptoRepository: criptoRepository);
});

class CriptoController {
  final CriptoRepository _criptoRepository;

  CriptoController({required CriptoRepository criptoRepository})
      : _criptoRepository = criptoRepository;

  /// Get the cripto list
  /// Returns a list of [Symbol]
  Future<List<Symbol>> getCripto() async {
    final response = await _criptoRepository.getCriptos();

    final data = jsonDecode(response.body);

    return CriptoModel.fromJson(data).symbols ?? [];
  }

  /// Get the cripto by symbol
  /// [symbol] is the symbol of the cripto
  Future<double> getPriceBySymbol(String symbol) async {
    final response = await _criptoRepository.getPriceBySymbol(symbol);

    final data = jsonDecode(response.body);

    final price = data['price'];

    return double.parse(price);
  }
}
