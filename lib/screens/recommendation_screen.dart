import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/crop_provider.dart';
import '../models/recommendation.dart';

class RecommendationScreen extends StatelessWidget {
  const RecommendationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: const Text('Crop Recommendations'),
      ),
      body: Consumer<CropProvider>(
        builder: (ctx, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error.isNotEmpty) {
            return Center(child: Text(provider.error));
          }
          if (provider.recommendations.isEmpty) {
            return const Center(
              child: Text('No recommendations available for this selection.'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(provider),
                const SizedBox(height: 16),
                ...provider.recommendations.map(
                  (r) => _buildRecommendationCard(context, r, provider)),
                const SizedBox(height: 16),
                _buildCalendar(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(CropProvider provider) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.white70, size: 18),
          const SizedBox(width: 6),
          Text(provider.selectedDistrict,
            style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const Spacer(),
          const Icon(Icons.calendar_today, color: Colors.white70, size: 18),
          const SizedBox(width: 6),
          Text(months[provider.selectedMonth - 1],
            style: const TextStyle(color: Colors.white, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(
      BuildContext context, Recommendation rec, CropProvider provider) {
    final color = rec.score >= 75
        ? Colors.green
        : rec.score >= 50
            ? Colors.orange
            : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: color.shade100),
        boxShadow: [
          BoxShadow(
            color:       Colors.black.withOpacity(0.04),
            blurRadius:  8,
            offset:      const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width:  40, height: 40,
                decoration: BoxDecoration(
                  color:        color.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text('${rec.rank}',
                    style: TextStyle(
                      color:      color.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize:   18,
                    )),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(rec.crop,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18)),
                    Text('Avg price: ₹${rec.avgPrice.toStringAsFixed(0)}/quintal',
                      style: TextStyle(
                        color: Colors.grey.shade600, fontSize: 13)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${rec.score.toStringAsFixed(1)}',
                    style: TextStyle(
                      color:      color.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize:   24,
                    )),
                  Text('/ 100',
                    style: TextStyle(
                      color: Colors.grey.shade500, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value:           rec.score / 100,
              backgroundColor: color.shade50,
              valueColor:      AlwaysStoppedAnimation(color.shade400),
              minHeight:       6,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _infoChip(
                '${rec.priceRiseProbability.toStringAsFixed(0)}% price rise',
                Icons.trending_up,
                rec.priceRiseProbability >= 50
                    ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 8),
              _infoChip(
                '${rec.riskLevel} risk',
                Icons.warning_amber,
                rec.riskLevel == 'Low'
                    ? Colors.green
                    : rec.riskLevel == 'Medium'
                        ? Colors.orange : Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(rec.advice,
            style: TextStyle(
              color: Colors.grey.shade700, fontSize: 13,
              fontStyle: FontStyle.italic,
            )),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => Navigator.pushNamed(
              context, '/price-trend',
              arguments: {
                'district':  provider.selectedDistrict,
                'commodity': rec.crop,
              },
            ),
            icon: const Icon(Icons.show_chart, size: 16),
            label: const Text('View price trend'),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color:        color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label,
            style: TextStyle(
              fontSize: 12, color: color,
              fontWeight: FontWeight.w500,
            )),
        ],
      ),
    );
  }

  Widget _buildCalendar(CropProvider provider) {
    if (provider.calendar.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Full Year Calendar',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap:  true,
          physics:     const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount:   3,
            childAspectRatio: 3.0,
            crossAxisSpacing: 8,
            mainAxisSpacing:  8,
          ),
          itemCount:   provider.calendar.length,
          itemBuilder: (ctx, i) {
            final entry = provider.calendar[i];
            final isCurrentMonth =
                entry.month == DateTime.now().month;
            return Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isCurrentMonth
                    ? const Color(0xFF2E7D32)
                    : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isCurrentMonth
                      ? const Color(0xFF2E7D32)
                      : Colors.green.shade100),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(entry.monthName,
                    style: TextStyle(
                      fontSize:   11,
                      color:      isCurrentMonth
                                      ? Colors.white70 : Colors.grey,
                    )),
                  Text(entry.bestCrop,
                    style: TextStyle(
                      fontSize:   12,
                      fontWeight: FontWeight.bold,
                      color:      isCurrentMonth
                                      ? Colors.white
                                      : const Color(0xFF2E7D32),
                    ),
                    overflow:   TextOverflow.ellipsis,
                    maxLines:   1,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}