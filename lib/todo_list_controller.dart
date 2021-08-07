import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:to_do_list_rivepod/todo_model.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class TodoListController extends StateNotifier<List<Todo>> {
  TodoListController([List<Todo>? initialTodos]) : super(initialTodos ?? []);

  void add(String description) {
    state = [
      ...state,
      Todo(
        id: _uuid.v4(),
        description: description,
      )
    ];
  }

  void toggle(String id) {
    state = [
      for (final todo in state)
        if (todo.id == id)
          Todo(
              id: todo.id,
              completed: !todo.completed,
              description: todo.description)
        else
          todo
    ];
  }

  void edit({required String id, required String description}) {


    state = [
      for (final todo in state)
        if (todo.id == id)
          Todo(
              id: todo.id,
              completed: todo.completed,
              description: description)
        else
          todo
    ];
  }

  void remove(Todo target)
  {

        //state.remove(target);
     state = state.where((todo) => todo.id != target.id).toList();
  }
}
