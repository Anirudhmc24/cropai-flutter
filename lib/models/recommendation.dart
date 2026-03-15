class Recommendation {
  final int    rank;
  final String crop;
  final double score;
  final double avgPrice;
  final double priceRiseProbability;
  final String advice;
  final String riskLevel;
  final int    dataPoints;

  Recommendation({
    required this.rank,
    required this.crop,
    required this.score,
    required this.avgPrice,
    required this.priceRiseProbability,
    required this.advice,
    required this.riskLevel,
    required this.dataPoints,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      rank:                 json['rank']       ?? 0,
      crop:                 json['crop']       ?? '',
      score:                (json['score']     ?? 0).toDouble(),
      avgPrice:             (json['avg_price'] ?? 0).toDouble(),
      priceRiseProbability: (json['price_rise_probability'] ?? 0).toDouble(),
      advice:               json['advice']     ?? '',
      riskLevel:            json['risk_level'] ?? 'Medium',
      dataPoints:           json['data_points'] ?? 0,
    );
  }
}

class CalendarEntry {
  final int    month;
  final String monthName;
  final String bestCrop;
  final double score;

  CalendarEntry({
    required this.month,
    required this.monthName,
    required this.bestCrop,
    required this.score,
  });

  factory CalendarEntry.fromJson(Map<String, dynamic> json) {
    return CalendarEntry(
      month:     json['month']      ?? 0,
      monthName: json['month_name'] ?? '',
      bestCrop:  json['best_crop']  ?? '',
      score:     (json['score']     ?? 0).toDouble(),
    );
  }
}