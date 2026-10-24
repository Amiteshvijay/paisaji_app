class LegalDocumentVersionModel {
  final String version;
  final String content;
  final String contentFormat;
  final String effectiveDate;
  final String lastUpdatedDate;
  final String publishedByName;
  final String changelog;
  final String contentHash;

  LegalDocumentVersionModel({
    required this.version,
    required this.content,
    required this.contentFormat,
    required this.effectiveDate,
    required this.lastUpdatedDate,
    required this.publishedByName,
    required this.changelog,
    required this.contentHash,
  });

  factory LegalDocumentVersionModel.fromJson(Map<String, dynamic> json) {
    return LegalDocumentVersionModel(
      version: json['version']?.toString() ?? '1.0',
      content: json['content']?.toString() ?? '',
      contentFormat: json['content_format']?.toString() ?? 'MARKDOWN',
      effectiveDate: json['effective_date']?.toString() ?? '',
      lastUpdatedDate: json['last_updated_date']?.toString() ?? '',
      publishedByName: json['published_by_name']?.toString() ?? 'Compliance Officer',
      changelog: json['changelog']?.toString() ?? '',
      contentHash: json['content_hash']?.toString() ?? '',
    );
  }
}

class LegalDocumentModel {
  final String id;
  final String documentKey;
  final String title;
  final String slug;
  final String category;
  final String shortDescription;
  final int sortOrder;
  final LegalDocumentVersionModel? currentVersion;

  LegalDocumentModel({
    required this.id,
    required this.documentKey,
    required this.title,
    required this.slug,
    required this.category,
    required this.shortDescription,
    required this.sortOrder,
    this.currentVersion,
  });

  factory LegalDocumentModel.fromJson(Map<String, dynamic> json) {
    final curMap = json['current_version'];
    return LegalDocumentModel(
      id: json['id']?.toString() ?? '',
      documentKey: json['document_key']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      category: json['category']?.toString() ?? 'CORE',
      shortDescription: json['short_description']?.toString() ?? '',
      sortOrder: json['sort_order'] is int ? json['sort_order'] : int.tryParse(json['sort_order']?.toString() ?? '1') ?? 1,
      currentVersion: curMap is Map<String, dynamic> ? LegalDocumentVersionModel.fromJson(curMap) : null,
    );
  }
}

class ComplianceContactModel {
  final String role;
  final String officerName;
  final String officialEmail;
  final String phone;
  final String officeAddress;
  final String supportHours;
  final int escalationLevel;

  ComplianceContactModel({
    required this.role,
    required this.officerName,
    required this.officialEmail,
    required this.phone,
    required this.officeAddress,
    required this.supportHours,
    required this.escalationLevel,
  });

  factory ComplianceContactModel.fromJson(Map<String, dynamic> json) {
    return ComplianceContactModel(
      role: json['role']?.toString() ?? 'Grievance Redressal Officer',
      officerName: json['officer_name']?.toString() ?? 'Compliance Officer',
      officialEmail: json['official_email']?.toString() ?? 'grievance@zeokash.com',
      phone: json['phone']?.toString() ?? '+91 8860996616',
      officeAddress: json['office_address']?.toString() ?? '',
      supportHours: json['support_hours']?.toString() ?? 'Monday to Friday, 10:00 AM – 06:00 PM IST',
      escalationLevel: json['escalation_level'] is int ? json['escalation_level'] : 1,
    );
  }
}
