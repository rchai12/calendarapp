import 'package:flutter/material.dart';
import 'task.dart';
import 'status.dart';
import 'task_tile.dart';

class PendingPage extends StatelessWidget {
  final List<Task> tasks;
  final void Function(Task) onEditTask;
  final void Function(Task) onToggleStatus;
  final void Function(Task) onDeleteTask;
  final String userId;

  const PendingPage({
    required this.tasks, 
    required this.onEditTask,
    required this.onToggleStatus,
    required this.onDeleteTask,
    required this.userId,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    final pendingTasks = tasks.where((task) => task.status == TaskStatus.pending).toList();
    return ListView.builder(
      itemCount: pendingTasks.length,
      itemBuilder: (context, index) => 
      TaskTile(
        task: pendingTasks[index],
        onEditTask: onEditTask,
        onToggleStatus: onToggleStatus,
        onDeleteTask: onDeleteTask,
        userId: userId,
      ),
    );
  }
}