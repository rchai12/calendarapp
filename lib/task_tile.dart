import 'package:flutter/material.dart';
import 'task.dart';
import 'status.dart';
//import 'priority.dart';
//import 'task_actions.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final bool isCompleted;
  final void Function(Task) onEditTask;
  final void Function(Task) onToggleStatus;

  const TaskTile({
    required this.task, 
    this.isCompleted = false, 
    required this.onEditTask,
    required this.onToggleStatus,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: IconButton(
        icon: Icon(
          task.status == TaskStatus.completed
              ? Icons.check_circle
              : Icons.radio_button_unchecked,
        ),
        onPressed: () => onToggleStatus(task),
      ),
      title: Text(
        task.title,
        style: TextStyle(
          decoration:
              isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Priority: ${task.priority.label}', style: TextStyle(color: task.priority.color)),
          Text('Status: ${task.status.label}', style: TextStyle(color: task.status.color)),
        ],
      ),
      onTap: () {
        onEditTask(task);
      },
    );
  }
}