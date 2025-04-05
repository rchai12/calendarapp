import 'package:flutter/material.dart';
import 'task.dart';
import 'status.dart';
import 'task_tile.dart';

class OngoingPage extends StatelessWidget {
  final List<Task> tasks;
  final void Function(Task) onEditTask;
  final void Function(Task) onToggleStatus;
  final void Function(Task) onDeleteTask;
  final String userId;

  const OngoingPage({
    required this.tasks,
    required this.onEditTask,
    required this.onToggleStatus,
    required this.onDeleteTask,
    required this.userId,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    final ongoingTasks = tasks.where((task) => task.status == TaskStatus.ongoing).toList();
    return ListView.builder(
      itemCount: ongoingTasks.length,
      itemBuilder: (context, index) => 
      TaskTile(
        task: ongoingTasks[index],
        onEditTask: onEditTask,
        onToggleStatus: onToggleStatus,
        onDeleteTask: onDeleteTask,
        userId: userId,
      ),
    );
  }
}