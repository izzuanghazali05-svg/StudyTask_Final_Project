import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/task.dart';

class ApiException implements Exception {
  ApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

class ApiService {
  static http.Client client = http.Client();

  // Android Emulator: 10.0.2.2. Web: localhost.
  // For a physical phone, replace this host with the computer's local IP.
  static String baseUrl =
      const String.fromEnvironment('API_BASE_URL', defaultValue: '').isNotEmpty
      ? const String.fromEnvironment('API_BASE_URL')
      : (kIsWeb
            ? 'http://localhost/student_task_api'
            : 'http://10.0.2.2/student_task_api');

  static Future<Map<String, dynamic>> _post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await client
          .post(
            Uri.parse('$baseUrl/$endpoint'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode >= 400 || decoded['success'] != true) {
        throw ApiException(decoded['message']?.toString() ?? 'Request failed.');
      }
      return decoded;
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Cannot connect to the server. Check the API URL.');
    }
  }

  static Future<Map<String, dynamic>> login(String email, String password) =>
      _post('login.php', {'email': email, 'password': password});

  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) => _post('register.php', {
    'name': name,
    'email': email,
    'password': password,
  });

  static Future<List<AcademicTask>> getTasks(int userId) async {
    final result = await _post('get_tasks.php', {'user_id': userId});
    return (result['data'] as List<dynamic>? ?? [])
        .map((item) => AcademicTask.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<String> addTask(int userId, Map<String, dynamic> task) async {
    final result = await _post('add_task.php', {'user_id': userId, ...task});
    return result['message'].toString();
  }

  static Future<String> updateTask(
    int userId,
    int taskId,
    Map<String, dynamic> task,
  ) async {
    final result = await _post('update_task.php', {
      'user_id': userId,
      'id': taskId,
      ...task,
    });
    return result['message'].toString();
  }

  static Future<String> deleteTask(int userId, int taskId) async {
    final result = await _post('delete_task.php', {
      'user_id': userId,
      'id': taskId,
    });
    return result['message'].toString();
  }
}
