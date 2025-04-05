import 'package:flutter/material.dart';
import 'task.dart';
import 'status.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final bool isCompleted;
  final void Function(Task) onEditTask;
  final void Function(Task) onToggleStatus;
  final void Function(Task) onDeleteTask;
  final String userId;

  const TaskTile({
    required this.task, 
    this.isCompleted = false, 
    required this.onEditTask,
    required this.onToggleStatus,
    required this.onDeleteTask,
    required this.userId,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(task.id ?? 'default_key'),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        onDeleteTask(task);
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      child: ListTile(
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
      ),
    );
  }
}