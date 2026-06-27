import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:student_task_app/main.dart';
import 'package:student_task_app/services/api_service.dart';

void main() {
  testWidgets('capture application screens', (tester) async {
    await tester.runAsync(() async {
      await _loadFont('Roboto', 'test/fonts/Roboto-Regular.ttf');
      await _loadFont('MaterialIcons', 'test/fonts/MaterialIcons-Regular.otf');
    });
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    ApiService.client = MockClient((request) async {
      final endpoint = request.url.pathSegments.last;
      if (endpoint == 'login.php') {
        return _json({
          'success': true,
          'message': 'Login successful.',
          'data': {
            'id': 1,
            'name': 'Sample Student',
            'email': 'student@example.com',
          },
        });
      }
      if (endpoint == 'get_tasks.php') {
        return _json({
          'success': true,
          'message': 'Tasks retrieved successfully.',
          'data': [
            {
              'id': 1,
              'user_id': 1,
              'title': 'Complete mobile app report',
              'description':
                  'Prepare the project report and add application screenshots.',
              'course': 'STTPK2143',
              'deadline': '2026-06-28',
              'status': 'In Progress',
            },
            {
              'id': 2,
              'user_id': 1,
              'title': 'Revise database chapter',
              'description':
                  'Review SQLite relationships, keys, and CRUD queries.',
              'course': 'Database Systems',
              'deadline': '2026-06-25',
              'status': 'Pending',
            },
          ],
        });
      }
      return _json({
        'success': true,
        'message': 'Operation completed.',
        'data': null,
      });
    });

    await tester.pumpWidget(const StudentTaskApp());
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/01_login.png'),
    );

    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/02_dashboard.png'),
    );

    await tester.tap(find.text('Complete mobile app report'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/03_task_details.png'),
    );

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add task'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/04_add_task.png'),
    );
  });
}

Future<void> _loadFont(String family, String path) async {
  final bytes = await File(path).readAsBytes();
  final loader = FontLoader(family)
    ..addFont(Future.value(ByteData.sublistView(bytes)));
  await loader.load();
}

http.Response _json(Map<String, dynamic> body) => http.Response(
  jsonEncode(body),
  200,
  headers: {'content-type': 'application/json'},
);
