import 'package:flutter/material.dart';

class LeadStatusConfig {
  static const List<String> allNewStatuses = [
    'Wrong number (WN)',
    'Not reachable(NR)',
    'Call not attended(NA)',
    'Not explained correctly-(NEC)',
    'On Discussion-(OD)',
    'Needs only Followup-(NOF)',
    'Need time for closing',
    'Not Interest(NI)',
    'Closed',
  ];

  static const List<String> allMainStatuses = [
    'Not interested',
    'call or chat later',
    'interested',
    'Discuss',
    'Joined',
    'fees call',
  ];

  static const List<String> allContactReasons = [
    'Therapy',
    'Varma class',
    'Diploma class',
    'Summer camp',
    'Ground class',
    'University Exam',
    'Material',
    'Demo class',
  ];

  static Color getNewStatusBgColor(String status) {
    switch (status) {
      case 'Wrong number (WN)':
        return const Color(0xFF7F1D1D); // Dark Wine / Maroon
      case 'Not reachable(NR)':
        return const Color(0xFFDBEAFE); // Soft Light Blue
      case 'Call not attended(NA)':
        return const Color(0xFFFEF08A); // Soft Golden Yellow
      case 'Not explained correctly-(NEC)':
        return const Color(0xFFFFE4E6); // Light Peach Red
      case 'On Discussion-(OD)':
        return const Color(0xFFF3E8FF); // Soft Lavender
      case 'Needs only Followup-(NOF)':
        return const Color(0xFFBAE6FD); // Sky Blue
      case 'Need time for closing':
        return const Color(0xFFFEF9C3); // Soft Amber
      case 'Not Interest(NI)':
        return const Color(0xFFFFE4E6); // Light Coral
      case 'Closed':
        return const Color(0xFF2E7D32); // Forest Green
      default:
        return const Color(0xFFE2E8F0);
    }
  }

  static Color getNewStatusTextColor(String status) {
    switch (status) {
      case 'Wrong number (WN)':
      case 'Closed':
        return Colors.white;
      case 'Not reachable(NR)':
        return const Color(0xFF1E40AF);
      case 'Call not attended(NA)':
        return const Color(0xFF854D0E);
      case 'Not explained correctly-(NEC)':
        return const Color(0xFF9F1239);
      case 'On Discussion-(OD)':
        return const Color(0xFF6B21A8);
      case 'Needs only Followup-(NOF)':
        return const Color(0xFF0369A1);
      case 'Need time for closing':
        return const Color(0xFF713F12);
      case 'Not Interest(NI)':
        return const Color(0xFF991B1B);
      default:
        return const Color(0xFF334155);
    }
  }

  static Color getMainStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'joined':
      case 'interested':
        return const Color(0xFF16A34A);
      case 'discuss':
      case 'call or chat later':
        return const Color(0xFFC5A059);
      case 'fees call':
        return const Color(0xFF2563EB);
      case 'not interested':
      default:
        return const Color(0xFFDC2626);
    }
  }
}

class LeadInteraction {
  final String id;
  final String date;
  final String telecaller;
  final String reasonForContact;
  final String details;
  final String newStatus;
  final String status;
  final int followUpCount;
  final int durationSeconds;
  final String? audioFileName;

  LeadInteraction({
    required this.id,
    required this.date,
    required this.telecaller,
    required this.reasonForContact,
    required this.details,
    required this.newStatus,
    required this.status,
    required this.followUpCount,
    this.durationSeconds = 0,
    this.audioFileName,
  });

  factory LeadInteraction.fromJson(Map<String, dynamic> json) {
    return LeadInteraction(
      id: json['id'] ?? '',
      date: json['date'] ?? '',
      telecaller: json['telecaller'] ?? '',
      reasonForContact: json['reasonForContact'] ?? 'Therapy',
      details: json['details'] ?? '',
      newStatus: json['newStatus'] ?? 'On Discussion-(OD)',
      status: json['status'] ?? 'interested',
      followUpCount: json['followUpCount'] ?? 1,
      durationSeconds: json['durationSeconds'] ?? 0,
      audioFileName: json['audioFileName'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date,
    'telecaller': telecaller,
    'reasonForContact': reasonForContact,
    'details': details,
    'newStatus': newStatus,
    'status': status,
    'followUpCount': followUpCount,
    'durationSeconds': durationSeconds,
    'audioFileName': audioFileName,
  };
}

class Lead {
  final String id;
  final int sNo;
  final String customerName;
  final String phoneNumber;
  final String altNumber;
  final String source;
  final String leadsReason;
  final String reasonForContact;
  final int followUpCount;
  final String details;
  final String newStatus;
  final String location;
  final String telecaller;
  final String newLeads;
  final String remark;
  final String status;
  final String varmaVisitorNote;
  final String enteredBy;
  final String leadDate;
  final String callDate;
  final int durationSeconds;
  final String? audioFileName;
  final List<LeadInteraction> interactions;

  Lead({
    required this.id,
    this.sNo = 1,
    required this.customerName,
    required this.phoneNumber,
    this.altNumber = '',
    this.source = 'Face book',
    this.leadsReason = 'Therapy',
    this.reasonForContact = 'Therapy',
    this.followUpCount = 1,
    this.details = '',
    this.newStatus = 'On Discussion-(OD)',
    this.location = 'Chennai',
    this.telecaller = 'Sudha',
    this.newLeads = 'Active',
    this.remark = '',
    this.status = 'interested',
    this.varmaVisitorNote = '',
    this.enteredBy = 'Priya',
    this.leadDate = '',
    this.callDate = '',
    this.durationSeconds = 0,
    this.audioFileName,
    this.interactions = const [],
  });

  // Backward compatibility getters
  String get painSummary => details.isNotEmpty ? details : '$reasonForContact consultation';
  String get outcome => newStatus;
  String get outcomeLabel => newStatus;
  String get recommendedNextAction => remark.isNotEmpty ? remark : 'Follow up for $reasonForContact';
  String? get transcriptPreview => details.isNotEmpty ? details : null;
  String get lastContactedAt => callDate.isNotEmpty ? callDate : leadDate;
  String get assignedRep => telecaller;
  int get painLevel => followUpCount;

  bool get isHotLead =>
      status.toLowerCase() == 'joined' ||
      status.toLowerCase() == 'interested' ||
      status.toLowerCase() == 'discuss' ||
      newStatus == 'Closed' ||
      newStatus == 'Needs only Followup-(NOF)' ||
      newStatus == 'Need time for closing';

  factory Lead.fromJson(Map<String, dynamic> json) {
    var rawList = json['interactions'];
    List<LeadInteraction> inters = [];
    if (rawList is List) {
      inters = rawList.map((i) => LeadInteraction.fromJson(i)).toList();
    }

    return Lead(
      id: json['id'] ?? 'lead_${json['sNo'] ?? 1}_${json['phoneNumber'] ?? ''}',
      sNo: json['sNo'] is int ? json['sNo'] : int.tryParse('${json['sNo']}') ?? 1,
      customerName: (json['customerName'] != null && json['customerName'].toString().trim().isNotEmpty)
          ? json['customerName'].toString().trim()
          : (json['name'] != null && json['name'].toString().trim().isNotEmpty)
              ? json['name'].toString().trim()
              : (json['phoneNumber'] ?? 'Patient'),
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      altNumber: json['altNumber']?.toString() ?? '',
      source: json['source']?.toString() ?? 'Face book',
      leadsReason: json['leadsReason']?.toString() ?? 'Therapy',
      reasonForContact: json['reasonForContact']?.toString() ?? 'Therapy',
      followUpCount: json['followUpCount'] is int
          ? json['followUpCount']
          : int.tryParse('${json['followUpCount']}') ?? 1,
      details: json['details']?.toString() ?? '',
      newStatus: json['newStatus']?.toString() ?? 'On Discussion-(OD)',
      location: json['location']?.toString() ?? 'Chennai',
      telecaller: json['telecaller']?.toString() ?? 'Sudha',
      newLeads: json['newLeads']?.toString() ?? 'Active',
      remark: json['remark']?.toString() ?? '',
      status: json['status']?.toString() ?? 'interested',
      varmaVisitorNote: json['varmaVisitorNote']?.toString() ?? '',
      enteredBy: json['enteredBy']?.toString() ?? 'Priya',
      leadDate: json['leadDate']?.toString() ?? '',
      callDate: json['callDate']?.toString() ?? '',
      durationSeconds: json['durationSeconds'] is int
          ? json['durationSeconds']
          : int.tryParse('${json['durationSeconds']}') ?? 0,
      audioFileName: json['audioFileName']?.toString(),
      interactions: inters,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'sNo': sNo,
    'customerName': customerName,
    'phoneNumber': phoneNumber,
    'altNumber': altNumber,
    'source': source,
    'leadsReason': leadsReason,
    'reasonForContact': reasonForContact,
    'followUpCount': followUpCount,
    'details': details,
    'newStatus': newStatus,
    'location': location,
    'telecaller': telecaller,
    'newLeads': newLeads,
    'remark': remark,
    'status': status,
    'varmaVisitorNote': varmaVisitorNote,
    'enteredBy': enteredBy,
    'leadDate': leadDate,
    'callDate': callDate,
    'durationSeconds': durationSeconds,
    'audioFileName': audioFileName,
    'interactions': interactions.map((i) => i.toJson()).toList(),
  };
}
