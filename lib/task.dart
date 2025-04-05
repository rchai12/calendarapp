import 'priority.dart';
import 'status.dart';

class Task {
  String _title;
  String _description;
  TaskStatus _status;
  PriorityLabel _priority = PriorityLabel.low;
  DateTime _date;

  Task({required String title, required String description, TaskStatus status = TaskStatus.ongoing, required PriorityLabel priority, required DateTime date,})  
      : _title = title,
        _description = description,
        _status = status,
        _priority = priority,
        _date = date;

  String get title => _title;
  String get description => _description;
  TaskStatus get status => _status;
  PriorityLabel get priority => _priority;
  DateTime get date => _date; 

  void setTitle(String title) => _title = title;
  void setDescription(String description) => _description = description;
  void setPriority(PriorityLabel priority) => _priority = priority;
  void setStatus(TaskStatus status) => _status = status;
  void setDate(DateTime date) => _date = DateTime(date.year, date.month, date.day);
}