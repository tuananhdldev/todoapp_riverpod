
import 'package:uuid/uuid.dart';


class Todo{
  final String id;
  final String description;
  final bool completed;

  Todo({
    required this.id,
    required this.description ,
     this.completed = false});
  @override
  String toString() {
    return 'Todo(description: $description, completed: $completed )';
  }
}
