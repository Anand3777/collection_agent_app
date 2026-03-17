import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class SmartFloService {
  // Update this to your Spring Boot server URL
  static const String baseUrl = 'http://95.216.197.57:8080/api/v1';
  
  /// Initiate a Click-to-Call using WebSocket connection
  Future<Map<String, dynamic>> initiateCall({
    required String customerNumber,
    required String agentNumber,
    String? customData,
  }) async {
    try {
      print('[SmartFlo] Initiating call via backend API...');
      print('[SmartFlo] Customer: $customerNumber, Agent: $agentNumber');
      print('[SmartFlo] Custom Data: $customData');

      final url = Uri.parse('$baseUrl/smartflo/initiate-call');

      final body = jsonEncode({
        'customer_number': customerNumber,
        'agent_number': agentNumber,
        if (customData != null) 'custom_data': customData,
      });

      final resp = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      );

      print('[SmartFlo] Response status: ${resp.statusCode}');
      print('[SmartFlo] Response body: ${resp.body}');

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final data = jsonDecode(resp.body);
        return {
          'success': true,
          'call_id': data['call_id'] ?? data['callId'] ?? data['request_id'],
          'message': data['message'] ?? data['message'] ?? data['ai_message'] ?? data['data'] ?? '',
          'raw': data,
        };
      } else {
        final error = jsonDecode(resp.body);
        return {
          'success': false,
          'error': error['error'] ?? error['message'] ?? 'Call initiation failed',
          'message': error['message'] ?? '',
          'raw': error,
        };
      }
    } catch (e) {
      print('[SmartFlo] Exception: $e');
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Failed to initiate WebSocket call',
      };
    }
  }

  /// Get call status by call ID
  Future<Map<String, dynamic>> getCallStatus(String callId) async {
    try {
      final url = Uri.parse('$baseUrl/smartflo/call-status/$callId');
      
      print('[SmartFlo] Getting call status for: $callId');

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'status': data['status'],
          'data': data,
        };
      } else {
        return {
          'success': false,
          'error': 'Call not found',
        };
      }
    } catch (e) {
      print('[SmartFlo] Exception: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Initiate Click-to-Call using support API with minimal payload
  /// This uses the click_to_call_support endpoint with just customer_number
  Future<Map<String, dynamic>> initiateSupportCall({
    required String customerNumber,
  }) async {
    try {
      // Clean phone number: remove +, spaces, and non-digits
      String cleanedNumber = customerNumber.replaceAll(RegExp(r'[^0-9]'), '');
      
      // If number starts with country code (91 for India), keep last 10 digits
      if (cleanedNumber.length > 12) {
        cleanedNumber = cleanedNumber.substring(cleanedNumber.length - 10);
      }
      
      print('[SmartFlo] Initiating support call via backend API...');
      print('[SmartFlo] Customer: $customerNumber (cleaned: $cleanedNumber)');

      final url = Uri.parse('$baseUrl/smartflo/click_to_call_support');

      final body = jsonEncode({
        'async': 1,
        'customer_number': cleanedNumber,
      });

      final resp = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      );

      print('[SmartFlo] Response status: ${resp.statusCode}');
      print('[SmartFlo] Response body: ${resp.body}');

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final data = jsonDecode(resp.body);
        return {
          'success': true,
          'ref_id': data['refId'] ?? data['ref_id'] ?? data['call_id'],
          'message': data['message'] ?? 'Call initiated successfully',
          'raw': data,
        };
      } else {
        final error = jsonDecode(resp.body);
        return {
          'success': false,
          'error': error['error'] ?? error['message'] ?? 'Call initiation failed',
          'message': error['message'] ?? '',
          'raw': error,
        };
      }
    } catch (e) {
      print('[SmartFlo] Exception: $e');
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Failed to initiate support call',
      };
    }
  }

  /// Check service health
  Future<bool> checkHealth() async {
    try {
      final url = Uri.parse('$baseUrl/smartflo/health');
      final response = await http.get(url);
      return response.statusCode == 200;
    } catch (e) {
      print('[SmartFlo] Health check failed: $e');
      return false;
    }
  }

  /// Get list of all users for collection
  Future<Map<String, dynamic>> getUsers({
    String? status,
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'pageSize': pageSize.toString(),
        if (status != null) 'status': status,
      };

      final url = Uri.parse('$baseUrl/users').replace(queryParameters: queryParams);

      print('[SmartFlo] Fetching users from: $url');

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
        },
      );

      print('[SmartFlo] Response status: ${response.statusCode}');
      print('[SmartFlo] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        List<User> users = [];
        if (data['data'] is List) {
          users = (data['data'] as List)
              .map((userJson) => User.fromJson(userJson))
              .toList();
        }

        return {
          'success': true,
          'users': users,
          'total': data['total'] ?? users.length,
          'page': data['page'] ?? page,
          'pageSize': data['pageSize'] ?? pageSize,
          'message': data['message'] ?? 'Users fetched successfully',
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Failed to fetch users',
          'message': error['message'] ?? 'Unknown error occurred',
          'users': [],
        };
      }
    } catch (e) {
      print('[SmartFlo] Exception: $e');
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Network error or server unavailable',
        'users': [],
      };
    }
  }

  /// Get user details by ID
  Future<Map<String, dynamic>> getUserById(String userId) async {
    try {
      final url = Uri.parse('$baseUrl/users/$userId');

      print('[SmartFlo] Fetching user details for: $userId');

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
        },
      );

      print('[SmartFlo] Response status: ${response.statusCode}');
      print('[SmartFlo] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = User.fromJson(data['data'] ?? data);

        return {
          'success': true,
          'user': user,
          'message': data['message'] ?? 'User fetched successfully',
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Failed to fetch user',
          'message': error['message'] ?? 'Unknown error occurred',
        };
      }
    } catch (e) {
      print('[SmartFlo] Exception: $e');
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Network error or server unavailable',
      };
    }
  }
}
