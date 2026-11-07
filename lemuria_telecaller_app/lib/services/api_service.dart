import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/lead_model.dart';
import '../models/telecaller_model.dart';

class ApiService {
  static const String baseUrl = 'https://dev.lemuriavawo.org';

  String? _authToken;
  Telecaller? _currentTelecaller;

  String? get token => _authToken;
  Telecaller? get currentTelecaller => _currentTelecaller;
  bool get isAuthenticated => _authToken != null;

  void setAuth(String token, Telecaller telecaller) {
    _authToken = token;
    _currentTelecaller = telecaller;
  }

  Map<String, String> _headers({bool json = true}) {
    final Map<String, String> h = {};
    if (json) h['Content-Type'] = 'application/json';
    if (_authToken != null) h['Authorization'] = 'Bearer $_authToken';
    return h;
  }

  /// 1. Telecaller Authentication
  Future<Map<String, dynamic>> login(String username, String pin) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/mobile/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username.trim(), 'pin': pin.trim()}),
      );

      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['ok'] == true) {
        _authToken = data['token'];
        _currentTelecaller = Telecaller.fromJson(data['telecaller']);
        return {'success': true, 'telecaller': _currentTelecaller};
      }
      return {'success': false, 'error': data['error'] ?? 'Login failed'};
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  /// 2. Fetch Assigned CRM Leads with Date, Telecaller, & Reason Filters
  Future<List<Lead>> fetchLeads({
    String? startDate,
    String? endDate,
    String? telecaller,
    String? status,
    String? reason,
    String? searchQuery,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (startDate != null && startDate.isNotEmpty) queryParams['startDate'] = startDate;
      if (endDate != null && endDate.isNotEmpty) queryParams['endDate'] = endDate;
      if (telecaller != null && telecaller != 'all') queryParams['telecaller'] = telecaller;
      if (status != null && status != 'all') queryParams['status'] = status;
      if (reason != null && reason != 'all') queryParams['reason'] = reason;
      if (searchQuery != null && searchQuery.isNotEmpty) queryParams['q'] = searchQuery;

      final uri = Uri.parse('$baseUrl/api/mobile/leads').replace(queryParameters: queryParams);
      final res = await http.get(uri, headers: _headers());

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['ok'] == true && data['leads'] is List) {
          return (data['leads'] as List).map((l) => Lead.fromJson(l)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Fetch leads error: $e');
      return [];
    }
  }

  /// 3. Start Call Session
  Future<String?> startCallSession(String phoneNumber) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/mobile/call/start'),
        headers: _headers(),
        body: jsonEncode({'phoneNumber': phoneNumber}),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['callSessionId'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 4. Mandatory Recording Upload
  Future<String?> uploadMandatoryRecording(String audioBase64) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/mobile/call/upload-recording'),
        headers: _headers(),
        body: jsonEncode({'audioBase64': audioBase64}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['ok'] == true) {
          return data['recordingFileName'];
        }
      }
      return null;
    } catch (e) {
      print('Upload recording error: $e');
      return null;
    }
  }

  /// 5. Submit 19-Column Lead Disposition & Append Timeline
  Future<bool> submitDisposition({
    required String phoneNumber,
    required String customerName,
    required String status,
    required String newStatus,
    required String reasonForContact,
    required String details,
    String altNumber = '',
    String location = 'Chennai',
    String remark = '',
    String varmaVisitorNote = '',
    int? sNo,
    required String recordingFileName,
    required int durationSeconds,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/mobile/lead/disposition'),
        headers: _headers(),
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'customerName': customerName,
          'status': status,
          'newStatus': newStatus,
          'reasonForContact': reasonForContact,
          'details': details,
          'altNumber': altNumber,
          'location': location,
          'remark': remark,
          'varmaVisitorNote': varmaVisitorNote,
          'sNo': sNo,
          'recordingFileName': recordingFileName,
          'durationSeconds': durationSeconds,
        }),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['ok'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 6. 1-Click WhatsApp Action
  Future<bool> sendWhatsAppAction({
    required String phoneNumber,
    required String actionType,
    required String patientName,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/mobile/whatsapp/send-action'),
        headers: _headers(),
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'actionType': actionType,
          'patientName': patientName,
        }),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['ok'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  void logout() {
    _authToken = null;
    _currentTelecaller = null;
  }
}

final apiService = ApiService();
