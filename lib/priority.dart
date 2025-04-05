import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

enum PriorityLabel {
  low('Low', Colors.blue),
  medium('Medium', Colors.orange),
  high('High', Colors.pink);

  const PriorityLabel(this.label, this.color);
  final String label;
  final Color color;

  static final List<DropdownMenuItem<PriorityLabel>> items = UnmodifiableListView<DropdownMenuItem<PriorityLabel>>(
    values.map<DropdownMenuItem<PriorityLabel>>(
      (PriorityLabel priority) => DropdownMenuItem<PriorityLabel>(
        value: priority,
        child: Text(
          priority.label,
          style: TextStyle(color: priority.color),
        ),
      ),
    ),
  );
}