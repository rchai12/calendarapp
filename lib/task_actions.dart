import 'task.dart';
import 'status.dart';
import 'priority.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskActions {
  static void toggleStatus(Task task) {
    final nextIndex = (task.status.index + 1) % TaskStatus.values.length;
    task.setStatus(TaskStatus.values[nextIndex]);
  }

  static void deleteTask(List<Task> tasks, Task task) {
    tasks.remove(task);
  }

  static void updateTask(Task oldTask, Task newTask, List<Task> taskList) {
    final index = taskList.indexOf(oldTask);
    if (index != -1) taskList[index] = newTask;
  }

  static Future<void> showAddTaskDialog(BuildContext context, Function(Task) onAdd, DateTime initialDate, TaskStatus defaultStatus) async {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    TaskStatus selectedStatus = defaultStatus;
    PriorityLabel selectedPriority = PriorityLabel.low;
    DateTime selectedDate = DateTime(initialDate.year, initialDate.month, initialDate.day);

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add New Task'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: descController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              DropdownButtonFormField<PriorityLabel>(
                value: selectedPriority,
                items: PriorityLabel.items,
                onChanged: (value) {
                  if (value != null) {
                    selectedPriority = value;
                  }
                },
                decoration: InputDecoration(labelText: 'Priority'),
              ),
              DropdownButtonFormField<TaskStatus>(
                value: selectedStatus,
                items: TaskStatus.items,
                onChanged: (value) {
                  if (value != null) {
                    selectedStatus = value;
                  }
                },
                decoration: InputDecoration(labelText: 'Status'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) selectedDate = DateTime(picked.year, picked.month, picked.day);
                },
                child: Text('Select Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final task = Task(
                title: titleController.text,
                description: descController.text,
                status: selectedStatus,
                priority: selectedPriority,
                date: selectedDate,
              );
              onAdd(task);
              Navigator.pop(ctx);
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  static Future<void> showEditTaskDialog(BuildContext context, Task task, Function(Task) onEdit) async {
    final titleController = TextEditingController(text: task.title);
    final descController = TextEditingController(text: task.description);
    TaskStatus selectedStatus = task.status;
    PriorityLabel selectedPriority = task.priority;
    DateTime selectedDate = DateTime(task.date.year, task.date.month, task.date.day);

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit Task'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: descController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              DropdownButtonFormField<PriorityLabel>(
                value: selectedPriority,
                items: PriorityLabel.items,
                onChanged: (value) {
                  if (value != null) {
                    selectedPriority = value;
                  }
                },
                decoration: InputDecoration(labelText: 'Priority'),
              ),
              DropdownButtonFormField<TaskStatus>(
                value: selectedStatus,
                items: TaskStatus.items,
                onChanged: (value) {
                  if (value != null) {
                    selectedStatus = value;
                  }
                },
                decoration: InputDecoration(labelText: 'Status'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) selectedDate = DateTime(picked.year, picked.month, picked.day);
                },
                child: Text('Select Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final updatedTask = Task(
                title: titleController.text,
                description: descController.text,
                status: selectedStatus,
                priority: selectedPriority,
                date: selectedDate,
              );
              onEdit(updatedTask);
              Navigator.pop(ctx);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
}
  /*static void addTask(Map<DateTime, List<Task>> tasksByDate, Task task) {
    final date = task.date;
    if (!tasksByDate.containsKey(date)) {
      tasksByDate[date] = [];
    }
    tasksByDate[date]?.add(task);
    _sortTasksByPriority(tasksByDate, date);
  }

  static void deleteTask(Map<DateTime, List<Task>> tasksByDate, DateTime date, int index) {
    final taskList = tasksByDate[date];
    if (taskList != null && index >= 0 && index < taskList.length) {
      taskList.removeAt(index);
      if (taskList.isEmpty) {
        tasksByDate.remove(date);
      }
    }
  }

  static void editTask(Map<DateTime, List<Task>> tasksByDate, DateTime date, int index, Task updatedTask) {
    if (tasksByDate.containsKey(date)) {
      tasksByDate[date]?[index] = updatedTask;
      _sortTasksByPriority(tasksByDate, date);
    }
  }

  static void toggleStatus(Map<DateTime, List<Task>> tasksByDate, DateTime date, int index) {
    final taskList = tasksByDate[date];
    if (taskList != null && index >= 0 && index < taskList.length) {
      final task = taskList[index];
      task.setStatus(TaskStatus.values[(task.status.index + 1) % TaskStatus.values.length]);
      _sortTasksByPriority(tasksByDate, date);
    }
  }

  static void _sortTasksByPriority(Map<DateTime, List<Task>> tasksByDate, DateTime date) {
    tasksByDate[date]?.sort((a, b) => b.priority.index.compareTo(a.priority.index));
  }*/
