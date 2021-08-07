import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';
import 'todo_model.dart';
import 'todo_list_controller.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

//start initial

//some keys used for testing
final addTodoKey = UniqueKey();
final activeFilterKey = UniqueKey();
final completeFilterKey = UniqueKey();
final allFilterKey = UniqueKey();

final todoListProvider =
    StateNotifierProvider<TodoListController, List<Todo>>((ref) {
  return TodoListController([
    Todo(id: 'todo-0', description: 'learn flutter'),
    Todo(id: 'todo-1', description: 'read book'),
    Todo(id: 'todo-2', description: 'writing content'),
    Todo(id: 'todo-3', description: 'learning english'),
  ]);
});

enum TodoListFilter { all, active, completed }

final todoListFilter = StateProvider((_) => TodoListFilter.all);

final uncompletedTodoCount = Provider<int>((ref) {
  return ref.watch(todoListProvider).where((todo) => !todo.completed).length;
});

final filteredTodos = Provider<List<Todo>>((ref) {
  final filter = ref.watch(todoListFilter);
  final todos = ref.watch(todoListProvider);
  switch (filter.state) {
    case TodoListFilter.completed:
      return todos.where((todo) => todo.completed).toList();
    case TodoListFilter.active:
      return todos.where((todo) => !todo.completed).toList();
    default:
      return todos;
  }
});

//end initial

void main() {
  runApp(ProviderScope(child: MyApp()));
}

//ui
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends HookConsumerWidget {
  const Home({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(filteredTodos);
    final newTodoController = useTextEditingController();
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: ListView(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          children: [
            Text(
              'todos'.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.deepPurple),
            ),
            TextField(
              key: addTodoKey,
              controller: newTodoController,
              decoration: InputDecoration(labelText: 'What needs to be done?'),
              onSubmitted: (value) {
              ref.read(todoListProvider.notifier).add(value);
              newTodoController.clear();
              },
            ),
            SizedBox(
              height: 42,
            ),
            ToolBar(),
            if(todos.isNotEmpty) const Divider(height: 0,),


            for(var td in todos) ...[
               Divider(height: 0,),
              Dismissible(
                key: ValueKey(td.id),
                onDismissed: (_){
                  ref.read(todoListProvider.notifier).remove(td);
                },
                child: ProviderScope(
                  overrides: [
                    _currentTodo.overrideWithValue(td)
                  ],
                  child: TodoItem(),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}

class ToolBar extends HookConsumerWidget {
  const ToolBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(todoListFilter);

    Color? textColorFor(TodoListFilter value) {
      return filter.state == value ? Colors.blue : Colors.grey;
    }

    return Material(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: Text(
            '${ref.watch(uncompletedTodoCount).toString()} items left',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Theme.of(context).textTheme.caption!.color),
          )),
          Tooltip(
            key: allFilterKey,
            message: 'All todos',
            child: TextButton(
              onPressed: () => filter.state = TodoListFilter.all,
              child: Text(
                'All',
                style: TextStyle(color: textColorFor(TodoListFilter.all)),
              ),
            ),
          ),
          Tooltip(
            key: activeFilterKey,
            message: 'Only uncompleted todos',
            child: TextButton(
              onPressed: () => filter.state = TodoListFilter.active,
              child: Text(
                'Active',
                style: TextStyle(color: textColorFor(TodoListFilter.active)),
              ),
            ),
          ),
          Tooltip(
            key: completeFilterKey,
            message: 'Only completed todos',
            child: TextButton(
              onPressed: () => filter.state = TodoListFilter.completed,
              child: Text(
                'Complete',
                style: TextStyle(color: textColorFor(TodoListFilter.completed)),
              ),
            ),
          )
        ],
      ),
    );
  }
}

final _currentTodo = Provider<Todo>((ref)=> throw UnimplementedError());

class TodoItem extends HookConsumerWidget {
  const TodoItem({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todo = ref.watch(_currentTodo);
    final itemFocusNode = useFocusNode();
    //listen to focus chances
    useListenable(itemFocusNode);
    final isFocused =  itemFocusNode.hasFocus;
    final textEditingController = useTextEditingController();
    final textFieldFocusNode = useFocusNode();
    return Material(
      color: Colors.white,
      elevation: 6,
      child: Focus(
        focusNode: itemFocusNode,
        onFocusChange: (focused){
          if(focused)
            {
              textEditingController.text = todo.description;
            }else
              {
                ref.read(todoListProvider.notifier)
                    .edit(id:todo.id, description: textEditingController.text);
              }
        },
        child: ListTile(
          onTap: (){
            itemFocusNode.requestFocus();
            textFieldFocusNode.requestFocus();
          },
          leading: Checkbox(
            value: todo.completed,
            onChanged: (value)=>
            ref.read(todoListProvider.notifier).toggle(todo.id)
            ,
          ),
          title: isFocused?
             TextField(
               autofocus: true,
               focusNode: textFieldFocusNode,
               controller: textEditingController,
             ): Text(todo.description) ,

        ),
      ),
    );
  }
}