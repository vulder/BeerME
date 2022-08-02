class StatisticsDto {
  const StatisticsDto({
    required this.today,
    required this.week,
    required this.month,
    required this.total,
  });

  final int today;
  final int week;
  final int month;
  final int total;

  static StatisticsDto fromJson(Map<String, dynamic> json) {
    return StatisticsDto(
      today: json['today'],
      week: json['week'],
      month: json['month'],
      total: json['total'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'today': today,
      'week': week,
      'month': month,
      'total': total,
    };
  }
}
