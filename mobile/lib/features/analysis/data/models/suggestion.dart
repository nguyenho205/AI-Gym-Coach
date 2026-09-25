/// Actionable coaching cue or technique suggestion.
class Suggestion {
  final String title;
  final String description;
  final String? focusArea;

  const Suggestion({
    required this.title,
    required this.description,
    this.focusArea,
  });

  factory Suggestion.fromJson(dynamic json) {
    if (json is String) {
      return Suggestion(
        title: json,
        description: 'Implement this cue during subsequent repetitions.',
      );
    }
    final map = json as Map<String, dynamic>;
    return Suggestion(
      title: (map['title'] ?? map['suggestion'] ?? '') as String,
      description: (map['description'] ?? map['detail'] ?? '') as String,
      focusArea: map['focus_area'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'focus_area': focusArea,
    };
  }
}
