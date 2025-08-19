import 'package:cloud_firestore/cloud_firestore.dart';

enum ReportStatus { open, resolved }

class Report {
  final String id;
  final String reporterId;
  final String reportedVendorId;
  final String reportedVendorName;
  final String reason;
  final String details;
  final Timestamp timestamp;
  ReportStatus status;

  Report({
    required this.id,
    required this.reporterId,
    required this.reportedVendorId,
    required this.reportedVendorName,
    required this.reason,
    required this.details,
    required this.timestamp,
    this.status = ReportStatus.open,
  });

  Map<String, dynamic> toMap() {
    return {
      'reporterId': reporterId,
      'reportedVendorId': reportedVendorId,
      'reportedVendorName': reportedVendorName,
      'reason': reason,
      'details': details,
      'timestamp': timestamp,
      'status': status.toString().split('.').last,
    };
  }

  factory Report.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Report(
      id: doc.id,
      reporterId: data['reporterId'] ?? '',
      reportedVendorId: data['reportedVendorId'] ?? '',
      reportedVendorName: data['reportedVendorName'] ?? '',
      reason: data['reason'] ?? 'No reason provided',
      details: data['details'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      status: ReportStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => ReportStatus.open,
      ),
    );
  }
}
