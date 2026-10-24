import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zeokash/core/network/api_client.dart';
import 'package:zeokash/features/legal/data/legal_document_model.dart';

final legalRepositoryProvider = Provider<LegalRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return LegalRepository(dio);
});

final legalDocumentListProvider = FutureProvider<List<LegalDocumentModel>>((ref) async {
  final repo = ref.watch(legalRepositoryProvider);
  return repo.fetchLegalDocuments();
});

final legalDocumentDetailProvider = FutureProvider.family<LegalDocumentModel, String>((ref, slug) async {
  final repo = ref.watch(legalRepositoryProvider);
  return repo.fetchLegalDocumentDetail(slug);
});

final complianceContactsProvider = FutureProvider<List<ComplianceContactModel>>((ref) async {
  final repo = ref.watch(legalRepositoryProvider);
  return repo.fetchComplianceContacts();
});

class LegalRepository {
  final Dio _dio;

  LegalRepository(this._dio);

  Future<List<LegalDocumentModel>> fetchLegalDocuments() async {
    final prefs = await SharedPreferences.getInstance();
    const cacheKey = 'cached_legal_document_list';

    try {
      final response = await _dio.get('/legal/');
      final data = response.data;
      if (data != null && data['success'] == true && data['data'] is List) {
        final list = (data['data'] as List)
            .map((item) => LegalDocumentModel.fromJson(item as Map<String, dynamic>))
            .toList();
        await prefs.setString(cacheKey, jsonEncode(data['data']));
        return list;
      }
    } catch (_) {
      final cachedJson = prefs.getString(cacheKey);
      if (cachedJson != null) {
        final List decoded = jsonDecode(cachedJson);
        return decoded
            .map((item) => LegalDocumentModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    }
    return _fallbackDocumentList();
  }

  Future<LegalDocumentModel> fetchLegalDocumentDetail(String slug) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'cached_legal_doc_$slug';

    try {
      final response = await _dio.get('/legal/$slug/');
      final data = response.data;
      if (data != null && data['success'] == true && data['data'] != null) {
        final doc = LegalDocumentModel.fromJson(data['data'] as Map<String, dynamic>);
        await prefs.setString(cacheKey, jsonEncode(data['data']));
        return doc;
      }
    } catch (_) {
      final cachedJson = prefs.getString(cacheKey);
      if (cachedJson != null) {
        final decoded = jsonDecode(cachedJson) as Map<String, dynamic>;
        return LegalDocumentModel.fromJson(decoded);
      }
    }
    return _fallbackDocumentDetail(slug);
  }

  Future<List<ComplianceContactModel>> fetchComplianceContacts() async {
    try {
      final response = await _dio.get('/legal/contacts/');
      final data = response.data;
      if (data != null && data['success'] == true && data['data'] is List) {
        return (data['data'] as List)
            .map((item) => ComplianceContactModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [
      ComplianceContactModel(
        role: 'Grievance Redressal Officer',
        officerName: 'Principal Grievance Officer',
        officialEmail: 'grievance@zeokash.com',
        phone: '+91 8860996616',
        officeAddress: 'ZeoKash Technologies Private Limited, Sector 62, Noida, Uttar Pradesh - 201309',
        supportHours: 'Monday to Friday, 10:00 AM – 06:00 PM IST',
        escalationLevel: 1,
      ),
    ];
  }

  Future<bool> recordAcceptance(String documentSlug, {String version = '1.0', String source = 'MOBILE_APP'}) async {
    try {
      final res = await _dio.post('/legal/acceptances/', data: {
        'document_slug': documentSlug,
        'version': version,
        'acceptance_source': source,
        'consent_context': 'EXPLICIT_CHECKBOX',
      });
      return res.data?['success'] == true;
    } catch (_) {
      return false;
    }
  }

  List<LegalDocumentModel> _fallbackDocumentList() {
    return [
      LegalDocumentModel(id: '1', documentKey: 'terms_and_conditions', title: 'Terms & Conditions', slug: 'terms-and-conditions', category: 'CORE', shortDescription: 'Governing platform rules and service conditions.', sortOrder: 1),
      LegalDocumentModel(id: '2', documentKey: 'privacy_policy', title: 'Privacy Policy', slug: 'privacy-policy', category: 'PRIVACY', shortDescription: 'Data privacy disclosures and protections.', sortOrder: 2),
      LegalDocumentModel(id: '3', documentKey: 'refund_cancellation_policy', title: 'Refund & Cancellation Policy', slug: 'refund-cancellation-policy', category: 'TRANSACTION', shortDescription: 'Failed recharges, reversals and refund timelines.', sortOrder: 3),
      LegalDocumentModel(id: '4', documentKey: 'grievance_redressal_policy', title: 'Grievance Redressal Policy', slug: 'grievance-redressal', category: 'GRIEVANCE', shortDescription: 'Customer complaint resolution and officer contacts.', sortOrder: 4),
      LegalDocumentModel(id: '5', documentKey: 'user_agreement', title: 'User Agreement', slug: 'user-agreement', category: 'CORE', shortDescription: 'Account covenant, MPIN security and binding.', sortOrder: 5),
      LegalDocumentModel(id: '6', documentKey: 'payment_gateway_terms', title: 'Payment Gateway Terms', slug: 'payment-gateway-terms', category: 'TRANSACTION', shortDescription: 'UPI and electronic payment processing terms.', sortOrder: 6),
      LegalDocumentModel(id: '7', documentKey: 'partner_bank_disclosures', title: 'Partner Bank Disclosures', slug: 'partner-bank-disclosures', category: 'FINANCIAL', shortDescription: 'Regulatory disclosures on financial product discovery.', sortOrder: 7),
    ];
  }

  LegalDocumentModel _fallbackDocumentDetail(String slug) {
    final list = _fallbackDocumentList();
    final doc = list.firstWhere((d) => d.slug == slug, orElse: () => list.first);
    return LegalDocumentModel(
      id: doc.id,
      documentKey: doc.documentKey,
      title: doc.title,
      slug: doc.slug,
      category: doc.category,
      shortDescription: doc.shortDescription,
      sortOrder: doc.sortOrder,
      currentVersion: LegalDocumentVersionModel(
        version: '1.0',
        content: '# ${doc.title}\n\nPlease visit our official portal or check your internet connection to view the latest live version.\n\nFor assistance, contact **support@zeokash.com**.',
        contentFormat: 'MARKDOWN',
        effectiveDate: 'October 2026',
        lastUpdatedDate: 'October 2026',
        publishedByName: 'Compliance Officer',
        changelog: 'Initial publication.',
        contentHash: '',
      ),
    );
  }
}
