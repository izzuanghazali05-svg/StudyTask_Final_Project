class AcademicTask {
  const AcademicTask({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.course,
    required this.deadline,
    required this.status,
  });

  final int id;
  final int userId;
  final String title;
  final String description;
  final String course;
  final DateTime deadline;
  final String status;

  factory AcademicTask.fromJson(Map<String, dynamic> json) => AcademicTask(
    id: int.parse(json['id'].toString()),
    userId: int.parse(json['user_id'].toString()),
    title: json['title']?.toString() ?? '',
    description: json['description']?.toString() ?? '',
    course: json['course']?.toString() ?? '',
    deadline: DateTime.parse(json['deadline'].toString()),
    status: json['status']?.toString() ?? 'Pending',
  );
}
