import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

enum TaskStatus { 
  ongoing('Ongoing', Colors.green),
  pending('Pending', Colors.limeAccent), 
  completed('Completed', Colors.blueGrey);
  
  const TaskStatus(this.label, this.color);
  final String label;
  final Color color;

  static final List<DropdownMenuItem<TaskStatus>> items = UnmodifiableListView<DropdownMenuItem<TaskStatus>>(
    values.map<DropdownMenuItem<TaskStatus>>(
      (TaskStatus status) => DropdownMenuItem<TaskStatus>(
        value: status,
        child: Text(
          status.label,
          style: TextStyle(color: status.color),
        ),
      ),
    ),
  );
}