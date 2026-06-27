import 'package:flutter_test/flutter_test.dart';
import 'package:student_task_app/main.dart';

void main() {
  testWidgets('login screen shows the main controls', (tester) async {
    await tester.pumpWidget(const StudentTaskApp());

    expect(find.text('StudyTask'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
    expect(find.text('Create an account'), findsOneWidget);
  });
}
