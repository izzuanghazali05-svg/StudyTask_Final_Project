import 'package:flutter/material.dart';

import '../models/task.dart';
import '../services/api_service.dart';

class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({super.key, required this.userId, this.task});
  final int userId;
  final AcademicTask? task;

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _key = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _course;
  late final TextEditingController _description;
  late DateTime _deadline;
  late String _status;
  bool _saving = false;

  bool get _editing => widget.task != null;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _title = TextEditingController(text: task?.title ?? '');
    _course = TextEditingController(text: task?.course ?? '');
    _description = TextEditingController(text: task?.description ?? '');
    _deadline = task?.deadline ?? DateTime.now().add(const Duration(days: 7));
    _status = task?.status ?? 'Pending';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  Future<void> _save() async {
    if (!_key.currentState!.validate()) return;
    setState(() => _saving = true);
    final data = {
      'title': _title.text.trim(),
      'course': _course.text.trim(),
      'description': _description.text.trim(),
      'deadline': _deadline.toIso8601String().substring(0, 10),
      'status': _status,
    };
    try {
      final message = _editing
          ? await ApiService.updateTask(widget.userId, widget.task!.id, data)
          : await ApiService.addTask(widget.userId, data);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _course.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(_editing ? 'Edit Task' : 'Add Task')),
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _key,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _title,
                      decoration: const InputDecoration(
                        labelText: 'Task title',
                      ),
                      validator: (v) => (v?.trim().length ?? 0) < 3
                          ? 'Enter at least 3 characters.'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _course,
                      decoration: const InputDecoration(
                        labelText: 'Course / subject',
                      ),
                      validator: (v) => (v?.trim().isEmpty ?? true)
                          ? 'Enter a course.'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _description,
                      minLines: 3,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                      validator: (v) => (v?.trim().isEmpty ?? true)
                          ? 'Enter a description.'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: _status,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: const ['Pending', 'In Progress', 'Completed']
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                      onChanged: (value) => setState(() => _status = value!),
                    ),
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_month),
                      label: Text('Deadline: ${_date(_deadline)}'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: const Icon(Icons.save),
                      label: Text(_saving ? 'Saving...' : 'Save task'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  String _date(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}
