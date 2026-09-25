import 'package:flutter/material.dart';

/// Exercise model representing supported movements for technique evaluation.
class ExerciseModel {
  final String id;
  final String name;
  final String shortDescription;
  final String techniqueFocus;
  final IconData icon;
  final List<String> cameraGuidelines;
  final List<String> targetKeypoints;

  const ExerciseModel({
    required this.id,
    required this.name,
    required this.shortDescription,
    required this.techniqueFocus,
    required this.icon,
    required this.cameraGuidelines,
    required this.targetKeypoints,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: (json['id'] ?? json['exercise_type'] ?? '') as String,
      name: (json['name'] ?? json['exercise_name'] ?? '') as String,
      shortDescription: (json['description'] ?? json['short_description'] ?? '') as String,
      techniqueFocus: (json['technique_focus'] ?? '') as String,
      icon: _iconFromName((json['id'] ?? json['exercise_type'] ?? '').toString()),
      cameraGuidelines: (json['camera_guidelines'] as List?)?.map((e) => e.toString()).toList() ?? [],
      targetKeypoints: (json['target_keypoints'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'short_description': shortDescription,
      'technique_focus': techniqueFocus,
      'camera_guidelines': cameraGuidelines,
      'target_keypoints': targetKeypoints,
    };
  }

  static IconData _iconFromName(String name) {
    switch (name.toLowerCase()) {
      case 'squat':
        return Icons.accessibility_new_rounded;
      case 'push_up':
      case 'push-up':
      case 'pushup':
        return Icons.fitness_center_rounded;
      case 'bicep_curl':
      case 'bicep-curl':
      case 'bicepcurl':
        return Icons.sports_gymnastics_rounded;
      default:
        return Icons.sports_martial_arts_rounded;
    }
  }

  /// Initial three supported exercises for AI-Coach-Gym.
  static const List<ExerciseModel> supportedExercises = [
    ExerciseModel(
      id: 'squat',
      name: 'Squat',
      shortDescription: 'Compound lower-body movement targeting quadriceps, glutes, and core stability.',
      techniqueFocus: 'Analyze squat depth, knee alignment and spine posture.',
      icon: Icons.accessibility_new_rounded,
      cameraGuidelines: [
        'Place camera at hip level, 2.5-3 meters away.',
        'Record from a 45-degree front-diagonal or side angle.',
        'Ensure feet and hips are fully visible in the frame.',
      ],
      targetKeypoints: ['Hips', 'Knees', 'Ankles', 'Spine', 'Shoulders'],
    ),
    ExerciseModel(
      id: 'push_up',
      name: 'Push-up',
      shortDescription: 'Upper body pushing exercise focusing on chest, anterior deltoids, and triceps.',
      techniqueFocus: 'Analyze body alignment and elbow movement.',
      icon: Icons.fitness_center_rounded,
      cameraGuidelines: [
        'Place camera 45-degrees from side, near floor level.',
        'Keep entire body from head to heels in frame.',
        'Perform steady, controlled repetitions.',
      ],
      targetKeypoints: ['Shoulders', 'Elbows', 'Wrists', 'Hips', 'Ankles'],
    ),
    ExerciseModel(
      id: 'bicep_curl',
      name: 'Bicep Curl',
      shortDescription: 'Isolated pulling movement targeting the biceps brachii and forearm flexors.',
      techniqueFocus: 'Analyze elbow stability and movement control.',
      icon: Icons.sports_gymnastics_rounded,
      cameraGuidelines: [
        'Place camera directly in front or slightly to the side.',
        'Ensure upper arms and elbows remain clearly visible.',
        'Avoid torso sway and momentum.',
      ],
      targetKeypoints: ['Shoulders', 'Elbows', 'Wrists'],
    ),
  ];
}
