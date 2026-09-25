/// Biomechanical error detected during movement evaluation.
class TechniqueError {
  final String title;
  final String description;
  final String? severity; // e.g. 'high', 'medium', 'low'

  const TechniqueError({
    required this.title,
    required this.description,
    this.severity,
  });

  factory TechniqueError.fromJson(dynamic json) {
    if (json is String) {
      return TechniqueError(
        title: json,
        description: 'Improper movement pattern detected during execution.',
      );
    }
    final map = json as Map<String, dynamic>;
    return TechniqueError(
      title: (map['title'] ?? map['error'] ?? map['name'] ?? '') as String,
      description: (map['description'] ?? map['detail'] ?? map['message'] ?? '') as String,
      severity: map['severity'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'severity': severity,
    };
  }
}
