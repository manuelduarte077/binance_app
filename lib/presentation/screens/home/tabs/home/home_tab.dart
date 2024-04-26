import 'package:binance_app/presentation/screens/home/provider/cripto_provider.dart';
import 'package:binance_app/presentation/shared/extensions/build_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final criptoController = ref.read(criptoControllerProvider);

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: context.theme.scaffoldBackgroundColor,
        title: Text(
          'Home',
          style: TextStyle(
            color: context.theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
      ),
      body: FutureBuilder(
        future: criptoController.getCripto(),
        builder: (context, snapshot) {
          snapshot.data;

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Something went wrong!',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          if (snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final criptos = snapshot.data!;

          return ListView.builder(
            itemCount: 50,
            itemBuilder: (context, index) {
              final symbol = criptos[index];

              return Hero(
                tag: 'card$index',
                transitionOnUserGestures: true,
                child: Card(
                  color: context.theme.cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  margin: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      ListTile(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            '/detail',
                            arguments: symbol,
                          );
                        },
                        title: Text(
                          symbol.symbol ?? 'N/A',
                          style: TextStyle(
                            color: context.theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          symbol.status ?? 'N/A',
                          style: TextStyle(
                            color: context.theme.colorScheme.secondary,
                          ),
                        ),
                        trailing: FutureBuilder(
                          future:
                              criptoController.getPriceBySymbol(symbol.symbol!),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return const Text(
                                'N/A',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              );
                            }

                            if (snapshot.data == null) {
                              return const CircularProgressIndicator();
                            }

                            final price = snapshot.data!;

                            return Text(
                              '\$$price',
                              style: TextStyle(
                                color: context.theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
