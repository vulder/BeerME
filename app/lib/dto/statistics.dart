class StatisticsDto {
  const StatisticsDto({
    required this.today,
    required this.week,
    required this.month,
    required this.total,
    required this.unpaid,
  });

  final int today;
  final int week;
  final int month;
  final int total;
  final int unpaid;

  static StatisticsDto fromJson(Map<String, dynamic> json) {
    return StatisticsDto(
      today: json['today'],
      week: json['week'],
      month: json['month'],
      total: json['total'],
      unpaid: json['unpaid'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'today': today,
      'week': week,
      'month': month,
      'total': total,
      'unpaid': unpaid,
    };
  }
}
