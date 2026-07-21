import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════════
// MODELS
// ═══════════════════════════════════════════════════════════════════

/// Pitch status overview shown on the dashboard.
class PitchStatus {
  final String title;
  final String status; // 'Active', 'Draft', 'Under Review'
  final int totalViews;
  final int uniqueInvestors;
  final double fundingRaised;
  final double fundingGoal;
  final double engagementRate;

  const PitchStatus({
    required this.title,
    required this.status,
    required this.totalViews,
    required this.uniqueInvestors,
    required this.fundingRaised,
    required this.fundingGoal,
    required this.engagementRate,
  });
}

/// A record of an investor viewing the founder's pitch.
class InvestorView {
  final String id;
  final String name;
  final String firm;
  final String action; // 'Viewed Pitch Deck', 'Downloaded Summary', etc.
  final DateTime time;
  final String avatarInitial;
  final Color avatarColor;

  const InvestorView({
    required this.id,
    required this.name,
    required this.firm,
    required this.action,
    required this.time,
    required this.avatarInitial,
    required this.avatarColor,
  });
}

/// An app notification for the founder.
class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime time;
  final bool isRead;
  final String icon; // 'view', 'message', 'alert', 'success'

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    this.isRead = false,
    this.icon = 'view',
  });
}

/// A step in the pitch submission wizard.
class PitchStep {
  final int index;
  final String title;
  final String subtitle;
  final IconData icon;

  const PitchStep({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

/// A media file for upload.
class MediaFile {
  final String id;
  final String name;
  final String type; // 'pdf', 'video', 'doc'
  final String description;
  final int maxSizeMB;
  final String? selectedFileName;
  final String? filePath;
  final bool isUploaded;
  final double uploadProgress;

  const MediaFile({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.maxSizeMB,
    this.selectedFileName,
    this.filePath,
    this.isUploaded = false,
    this.uploadProgress = 0.0,
  });

  MediaFile copyWith({
    String? selectedFileName,
    String? filePath,
    bool? isUploaded,
    double? uploadProgress,
  }) {
    return MediaFile(
      id: id,
      name: name,
      type: type,
      description: description,
      maxSizeMB: maxSizeMB,
      selectedFileName: selectedFileName ?? this.selectedFileName,
      filePath: filePath ?? this.filePath,
      isUploaded: isUploaded ?? this.isUploaded,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }
}

/// A document in the Virtual Data Room.
class VdrDocument {
  final String id;
  final String name;
  final String category; // 'Financial', 'Legal', 'Technical', 'Corporate'
  final String fileType; // 'pdf', 'xlsx', 'docx', 'pptx'
  final double sizeMB;
  final DateTime uploadedAt;
  final bool isLocked;
  final int viewCount;

  const VdrDocument({
    required this.id,
    required this.name,
    required this.category,
    required this.fileType,
    required this.sizeMB,
    required this.uploadedAt,
    this.isLocked = true,
    this.viewCount = 0,
  });

  VdrDocument copyWith({bool? isLocked}) {
    return VdrDocument(
      id: id,
      name: name,
      category: category,
      fileType: fileType,
      sizeMB: sizeMB,
      uploadedAt: uploadedAt,
      isLocked: isLocked ?? this.isLocked,
      viewCount: viewCount,
    );
  }
}


