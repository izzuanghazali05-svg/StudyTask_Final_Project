import 'package:flutter/material.dart';

import '../models/task.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'task_detail_screen.dart';
import 'task_form_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({
    super.key,
    required this.userId,
    required this.userName,
  });
  final int userId;
  final String userName;

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<AcademicTask> _tasks = [];
  bool _loading = true;
  String _filter = 'All';

  List<AcademicTask> get _visibleTasks {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _tasks.where((task) {
      if (_filter == 'All') return true;
      if (_filter == 'Overdue') {
        return task.deadline.isBefore(today) && task.status != 'Completed';
      }
      if (_filter == 'Due in 7 days') {
        return !task.deadline.isBefore(today) &&
            task.deadline.isBefore(today.add(const Duration(days: 8))) &&
            task.status != 'Completed';
      }
      return task.status == _filter;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final tasks = await ApiService.getTasks(widget.userId);
      if (mounted) setState(() => _tasks = tasks);
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openForm([AcademicTask? task]) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TaskFormScreen(userId: widget.userId, task: task),
      ),
    );
    if (changed == true) _load();
  }

  Color _statusColor(String status) => switch (status) {
    'Completed' => Colors.green,
    'In Progress' => Colors.orange,
    _ => Colors.blueGrey,
  };

  @override
  Widget build(BuildContext context) {
    final tasks = _visibleTasks;
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Academic Tasks'),
        actions: [
          IconButton(
            tooltip: 'Log out',
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (_) => false,
            ),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add task'),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: LayoutBuilder(
          builder: (context, constraints) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: constraints.maxWidth > 700
                  ? (constraints.maxWidth - 700) / 2
                  : 16,
              vertical: 16,
            ),
            children: [
              Text(
                'Hello, ${widget.userName}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_tasks.where((t) => t.status != 'Completed').length} task(s) still need attention.',
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Icon(Icons.filter_list),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _filter,
                      decoration: const InputDecoration(
                        labelText: 'Filter tasks',
                        isDense: true,
                      ),
                      items:
                          const [
                                'All',
                                'Pending',
                                'In Progress',
                                'Completed',
                                'Due in 7 days',
                                'Overdue',
                              ]
                              .map(
                                (value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(value),
                                ),
                              )
                              .toList(),
                      onChanged: (value) => setState(() => _filter = value!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.all(48),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (tasks.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(28),
                    child: Column(
                      children: [
                        Icon(Icons.task_alt, size: 44),
                        SizedBox(height: 10),
                        Text('No tasks match this filter.'),
                      ],
                    ),
                  ),
                )
              else
                ...tasks.map(
                  (task) => Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      title: Text(
                        task.title,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(task.course),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                Chip(
                                  avatar: Icon(
                                    Icons.circle,
                                    size: 11,
                                    color: _statusColor(task.status),
                                  ),
                                  label: Text(task.status),
                                  visualDensity: VisualDensity.compact,
                                ),
                                Chip(
                                  avatar: const Icon(Icons.event, size: 16),
                                  label: Text(_date(task.deadline)),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        final changed = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TaskDetailScreen(
                              userId: widget.userId,
                              task: task,
                            ),
                          ),
                        );
                        if (changed == true) _load();
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 82),
            ],
          ),
        ),
      ),
    );
  }

  String _date(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}
