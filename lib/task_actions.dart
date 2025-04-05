import 'task.dart';
import 'status.dart';
import 'priority.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskActions {

  static void toggleStatus(Task task) async {
    final nextIndex = (task.status.index + 1) % TaskStatus.values.length;
    task.setStatus(TaskStatus.values[nextIndex]);
    await updateTaskInFirestore(task);
  }

  static Future<void> deleteTask(List<Task> tasks, Task task) async {
    try {
      if (task.id != null) {
        await FirebaseFirestore.instance.collection('tasks').doc(task.id).delete();
      }
      tasks.remove(task);
    } catch (e) {
      print('Error deleting task: $e');
    }
  }

  static void updateTask(Task oldTask, Task newTask, List<Task> taskList) {
    final index = taskList.indexOf(oldTask);
    if (index != -1) taskList[index] = newTask;
  }

  static Future<void> showAddTaskDialog(BuildContext context, Function(Task) onAdd, DateTime initialDate, TaskStatus defaultStatus, String userId) async {
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
            onPressed: () async {
              final task = Task(
                title: titleController.text,
                description: descController.text,
                status: selectedStatus,
                priority: selectedPriority,
                date: selectedDate,
                userId: userId,
              );
              final docRef = await FirebaseFirestore.instance.collection('tasks').add(task.toMap());
              task.id = docRef.id;
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
            onPressed: () async {
            final updatedTask = Task(
              id: task.id,
              title: titleController.text,
              description: descController.text,
              status: selectedStatus,
              priority: selectedPriority,
              date: selectedDate,
              userId: task.userId,
            );
            onEdit(updatedTask);
            await updateTaskInFirestore(updatedTask);
            Navigator.pop(ctx);
          },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  static Future<List<Task>> loadTasksFromFirestore(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Task(
        id: doc.id,
        title: data['title'],
        description: data['description'],
        status: TaskStatus.values.firstWhere((e) => e.name == data['status']),
        priority: PriorityLabel.values.firstWhere((e) => e.name == data['priority']),
        date: DateTime.parse(data['date']),
        userId: data['userId'],
      );
    }).toList();
  }


  static Future<void> updateTaskInFirestore(Task task) async {
    final docRef = FirebaseFirestore.instance.collection('tasks').doc(task.id);
    await docRef.update(task.toMap());
  }

}