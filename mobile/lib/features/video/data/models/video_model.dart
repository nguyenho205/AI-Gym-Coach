import '../../../../core/constants/app_constants.dart';

/// Video model holding selected local video metadata or remote uploaded video reference.
class VideoModel {
  final int? id; // Assigned by backend after upload
  final String path;
  final String fileName;
  final int fileSizeBytes;
  final int durationSeconds;
  final String exerciseType;
  final DateTime selectedAt;
  final String? remoteUrl;

  const VideoModel({
    this.id,
    required this.path,
    required this.fileName,
    required this.fileSizeBytes,
    required this.durationSeconds,
    required this.exerciseType,
    required this.selectedAt,
    this.remoteUrl,
  });

  VideoModel copyWith({
    int? id,
    String? path,
    String? fileName,
    int? fileSizeBytes,
    int? durationSeconds,
    String? exerciseType,
    DateTime? selectedAt,
    String? remoteUrl,
  }) {
    return VideoModel(
      id: id ?? this.id,
      path: path ?? this.path,
      fileName: fileName ?? this.fileName,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      exerciseType: exerciseType ?? this.exerciseType,
      selectedAt: selectedAt ?? this.selectedAt,
      remoteUrl: remoteUrl ?? this.remoteUrl,
    );
  }

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['video_id'] is int
          ? json['video_id'] as int
          : (json['id'] is int ? json['id'] as int : null),
      path: (json['file_path'] ?? json['path'] ?? '') as String,
      fileName: (json['file_name'] ?? (json['file_path'] != null ? json['file_path'].toString().split('/').last : 'video.mp4')) as String,
      fileSizeBytes: (json['file_size'] as num?)?.toInt() ?? 0,
      durationSeconds: (json['duration'] as num?)?.toInt() ?? 0,
      exerciseType: (json['exercise_type'] ?? 'squat') as String,
      selectedAt: json['upload_time'] != null
          ? DateTime.tryParse(json['upload_time'].toString()) ?? DateTime.now()
          : DateTime.now(),
      remoteUrl: json['url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'video_id': id,
      'path': path,
      'file_path': path,
      'file_name': fileName,
      'file_size': fileSizeBytes,
      'duration': durationSeconds,
      'exercise_type': exerciseType,
      'upload_time': selectedAt.toIso8601String(),
      'url': remoteUrl,
    };
  }

  /// Validates format, size, and duration against [AppConstants].
  static String? validateVideo({
    required String filePath,
    required int fileSizeBytes,
    required int durationSeconds,
  }) {
    final ext = filePath.split('.').last.toLowerCase();
    if (!AppConstants.supportedVideoFormats.contains(ext)) {
      return 'Unsupported format .$ext. Please select a .mp4 or .mov video.';
    }

    if (fileSizeBytes > AppConstants.maxVideoFileSizeBytes) {
      return 'File size exceeds maximum allowed limit (100 MB).';
    }

    if (durationSeconds > AppConstants.maxVideoDurationSeconds) {
      return 'Video is ${durationSeconds}s. Maximum allowed duration is ${AppConstants.maxVideoDurationSeconds} seconds.';
    }

    return null;
  }
}
