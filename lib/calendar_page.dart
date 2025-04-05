import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'task.dart';
import 'status.dart';
import 'task_tile.dart';

class CalendarPage extends StatefulWidget {
  final DateTime selectedDate;
  final void Function(DateTime) onDateSelected;
  final List<Task> tasks;
  final Map<DateTime, List<Task>> tasksByDate;
  final void Function(Task) onEditTask;
  final void Function(Task) onToggleStatus;
  final void Function(Task) onDeleteTask;
  final String userId;

  const CalendarPage({
    required this.selectedDate,
    required this.onDateSelected,
    required this.tasks,
    required this.tasksByDate,
    required this.onEditTask,
    required this.onToggleStatus,
    required this.onDeleteTask,
    required this.userId,
    super.key,
  });

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  @override
  Widget build(BuildContext context) {
    final filteredTasks = widget.tasks
        .where((task) => isSameDay(task.date, widget.selectedDate) && task.status != TaskStatus.completed)
        .toList();

    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime(1900, 1, 1),
          lastDay: DateTime(2101),
          focusedDay: widget.selectedDate,
          selectedDayPredicate: (day) => isSameDay(day, widget.selectedDate),
          onDaySelected: (selectedDay, focusedDay) {
            widget.onDateSelected(selectedDay);
          },
          eventLoader: (day) {
            final dateOnly = DateTime(day.year, day.month, day.day);
            return widget.tasksByDate[dateOnly] ?? [];
          },
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              final normalizedDate = DateTime(date.year, date.month, date.day);
              if (widget.tasksByDate.containsKey(normalizedDate) && widget.tasksByDate[normalizedDate]!.isNotEmpty) {
                return Positioned(
                  bottom: 1,
                  child: CircleAvatar(
                    radius: 5,
                    backgroundColor: Colors.green,
                  ),
                );
              }
              return SizedBox.shrink();
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredTasks.length,
            itemBuilder: (context, index) {
              final task = filteredTasks[index];
              return TaskTile(
                task: task,
                onEditTask: widget.onEditTask,
                onToggleStatus: widget.onToggleStatus,
                onDeleteTask: widget.onDeleteTask,
                userId: widget.userId,
              );
            },
          ),
        ),
      ],
    );
  }
}