import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';

class PriceTrendScreen extends StatefulWidget {
  const PriceTrendScreen({super.key});

  @override
  State<PriceTrendScreen> createState() => _PriceTrendScreenState();
}

class _PriceTrendScreenState extends State<PriceTrendScreen> {
  List<Map<String, dynamic>> _trend = [];
  bool   _loading = true;
  String _error   = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments
        as Map<String, dynamic>;
    _loadTrend(args['district'], args['commodity']);
  }

  Future<void> _loadTrend(String district, String commodity) async {
    try {
      final data = await ApiService.getPriceTrend(
        district:  district,
        commodity: commodity,
      );
      setState(() { _trend = data; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments
        as Map<String, dynamic>;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: Text('${args['commodity']} — ${args['district']}'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text(_error))
              : _buildChart(),
    );
  }

  Widget _buildChart() {
    if (_trend.isEmpty) {
      return const Center(child: Text('No trend data available'));
    }

    final spots = _trend.asMap().entries.map((e) {
      return FlSpot(
        e.key.toDouble(),
        double.parse(e.value['avg_price'].toString()),
      );
    }).toList();

    final maxPrice = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final minPrice = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            height: 300,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (maxPrice - minPrice) / 5,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Colors.green.shade50,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval:   12,
                      getTitlesWidget: (val, meta) {
                        final idx = val.toInt();
                        if (idx >= 0 && idx < _trend.length) {
                          return Text(
                            '${_trend[idx]['year']}',
                            style: const TextStyle(fontSize: 10),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles:  true,
                      reservedSize: 50,
                      getTitlesWidget: (val, meta) => Text(
                        '₹${val.toInt()}',
                        style: const TextStyle(fontSize: 9),
                      ),
                    ),
                  ),
                  topTitles:   const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots:         spots,
                    isCurved:      true,
                    color:         const Color(0xFF2E7D32),
                    barWidth:      2,
                    dotData:       const FlDotData(show: false),
                    belowBarData:  BarAreaData(
                      show:  true,
                      color: const Color(0xFF2E7D32).withOpacity(0.1),
                    ),
                  ),
                ],
                minY: (minPrice * 0.9).roundToDouble(),
                maxY: (maxPrice * 1.1).roundToDouble(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryCards(),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    if (_trend.isEmpty) return const SizedBox.shrink();
    final prices = _trend
        .map((t) => double.parse(t['avg_price'].toString()))
        .toList();
    final avg = prices.reduce((a, b) => a + b) / prices.length;
    final max = prices.reduce((a, b) => a > b ? a : b);
    final min = prices.reduce((a, b) => a < b ? a : b);

    return Row(
      children: [
        _summaryCard('Average', '₹${avg.toStringAsFixed(0)}', Colors.blue),
        const SizedBox(width: 8),
        _summaryCard('Peak',    '₹${max.toStringAsFixed(0)}', Colors.green),
        const SizedBox(width: 8),
        _summaryCard('Lowest',  '₹${min.toStringAsFixed(0)}', Colors.orange),
      ],
    );
  }

  Widget _summaryCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:        Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            const SizedBox(height: 4),
            Text(value,
              style: TextStyle(
                color:      color,
                fontWeight: FontWeight.bold,
                fontSize:   16,
              )),
          ],
        ),
      ),
    );
  }
}