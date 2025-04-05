import 'package:flutter/material.dart';
import 'task.dart';
import 'status.dart';
//import 'task_actions.dart';
import 'task_tile.dart';

class CompletedPage extends StatelessWidget {
  final List<Task> tasks;
  final void Function(Task) onEditTask;
  final void Function(Task) onToggleStatus;

  const CompletedPage({
    required this.tasks,
    required this.onEditTask,
    required this.onToggleStatus,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    final completedTasks = tasks.where((task) => task.status == TaskStatus.completed).toList();
    return ListView.builder(
      itemCount: completedTasks.length,
      itemBuilder: (context, index) => 
        TaskTile(
          task: completedTasks[index],
          isCompleted: true,
          onEditTask: onEditTask,
          onToggleStatus: onToggleStatus,
        ),
    );
  }
}
