import 'package:flutter/material.dart';
import 'task.dart';
import 'status.dart';
//import 'task_actions.dart';
import 'task_tile.dart';

class OngoingPage extends StatelessWidget {
  final List<Task> tasks;
  final void Function(Task) onEditTask;
  final void Function(Task) onToggleStatus;

  const OngoingPage({
    required this.tasks,
    required this.onEditTask,
    required this.onToggleStatus,
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
      ),
    );
  }
}