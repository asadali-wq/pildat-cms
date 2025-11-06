class DashboardStats {
  final int totalContacts;
  final int activityLogs;
  final int activeContacts;
  final int categories;

  DashboardStats({
    required this.totalContacts,
    required this.activityLogs,
    required this.activeContacts,
    required this.categories,
  });

  // This converts the JSON from your API into an object
  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    // We use .toString() to safely handle nulls or existing ints,
    // and int.parse() to convert the string to an integer.
    // We use ?? '0' as a fallback in case the value is null.
    return DashboardStats(
      totalContacts: int.parse(json['totalContacts']?.toString() ?? '0'),
      activityLogs: int.parse(json['activityLogs']?.toString() ?? '0'),
      activeContacts: int.parse(json['activeContacts']?.toString() ?? '0'),
      categories: int.parse(json['categories']?.toString() ?? '0'),
    );
  }
}