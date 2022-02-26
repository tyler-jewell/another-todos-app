import 'package:todos_repository/todos_repository.dart';

enum TodosViewFilter { all, activeOnly, completedOnly }

extension TodosViewFilterX on TodosViewFilter {
  bool apply(Todo todo) {
    switch (this) {
      case TodosViewFilter.all:
        return true;
      case TodosViewFilter.activeOnly:
        return !todo.isComplete;
      case TodosViewFilter.completedOnly:
        return todo.isComplete;
    }
  }

  Iterable<Todo> applyAll(Iterable<Todo> todos) {
    return todos.where(apply);
  }
}
