import 'priority.dart';
import 'status.dart';

class Task {
  String? id;
  String _title;
  String _description;
  TaskStatus _status;
  PriorityLabel _priority = PriorityLabel.low;
  DateTime _date;

  Task({
    this.id,
    required String title,
    required String description,
    TaskStatus status = TaskStatus.ongoing,
    required PriorityLabel priority,
    required DateTime date,
  })  : _title = title,
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

  Map<String, dynamic> toMap() {
    return {
      'title': _title,
      'description': _description,
      'status': _status.name,
      'priority': _priority.name,
      'date': _date.toIso8601String(),
    };
  }

  static Task fromMap(Map<String, dynamic> map, String documentId) {
    return Task(
      id: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      status: TaskStatus.values.firstWhere((e) => e.name == map['status']),
      priority: PriorityLabel.values.firstWhere((e) => e.name == map['priority']),
      date: DateTime.parse(map['date']),
    );
  }
}
