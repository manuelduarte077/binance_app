import 'dart:async';
import 'dart:convert';

import 'package:binance_app/presentation/shared/extensions/build_context.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:binance_app/data/models/cripto_response.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class DetailScreen extends ConsumerStatefulWidget {
  const DetailScreen({super.key, required this.symbol});

  static const String routeName = '/detail';

  final Symbol symbol;

  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends ConsumerState<DetailScreen> {
  List<FlSpot> listBarData = [];
  WebSocketChannel? channel;

  @override
  void initState() {
    super.initState();

    listBarData = [];

    _getData(widget.symbol.symbol!);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: context.theme.scaffoldBackgroundColor,
        title: Text('Detalles de ${widget.symbol.symbol}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: FutureBuilder(
                future: _getData(widget.symbol.symbol!),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Something went wrong!',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  return SizedBox(
                    width: double.infinity,
                    height: 350,
                    child: LineChart(
                      LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                            spots: listBarData,
                            isCurved: true,
                            barWidth: 4,
                            isStrokeCapRound: true,
                            belowBarData: BarAreaData(
                              show: true,
                            ),
                          ),
                        ],
                        titlesData: const FlTitlesData(show: false),
                        gridData: FlGridData(
                          show: true,
                          drawHorizontalLine: true,
                          horizontalInterval: 1,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: context.theme.colorScheme.primary
                                .withOpacity(0.3),
                            strokeWidth: 1,
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(
                            color: context.theme.colorScheme.primary
                                .withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
          ),

          ///
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Symbol: ${widget.symbol.symbol}',
              style: TextStyle(
                color: context.theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<WebSocketChannel> _getData(String symbol) async {
    final wsUrl = Uri.parse(
        'wss://stream.binance.com:443/ws/${symbol.toLowerCase()}@avgPrice');
    final channel = WebSocketChannel.connect(wsUrl);

    await channel.ready;

    channel.stream.listen((data) {
      final message = jsonDecode(data as String);
      final eventTime = message['E'] as int;
      final averagePrice = double.parse(message['w'] as String);

      if (mounted) {
        setState(() {
          listBarData.add(FlSpot(
            eventTime.toDouble(),
            averagePrice,
          ));
        });
      }
    });

    return channel;
  }
}
