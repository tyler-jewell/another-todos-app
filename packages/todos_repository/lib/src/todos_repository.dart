import 'dart:async';

import 'package:todos_repository/todos_repository.dart';

/// Absract TodosRepository
abstract class TodosRepository {
  /// Add a new [Todo] to the repository
  Future<void> addNewTodo(Todo todo);

  /// Delete a [Todo] from the repository
  Future<void> deleteTodo(Todo todo);

  /// Get all [Todo]s from the repository
  Stream<List<Todo>> todos();

  /// Update a [Todo] from the repository
  Future<void> updateTodo(Todo todo);

  /// Deletes all completed todos.
  ///
  /// Returns the number of deleted todos.
  Future<int> clearCompleted();

  /// Sets the `isComplete` state of all todos to the given value.
  ///
  /// Returns the number of updated todos.
  Future<int> completeAll();
}
