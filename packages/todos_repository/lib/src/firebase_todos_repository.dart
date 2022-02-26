import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todos_repository/todos_repository.dart';

/// Firebase Firestore Todos repository
class FirebaseTodosRepository implements TodosRepository {
  /// The collection reference for the todos
  final todoCollection =
      FirebaseFirestore.instance.collection('todos').withConverter<Todo>(
            fromFirestore: (snapshot, _) => Todo.fromJson(snapshot.data()!),
            toFirestore: (todo, _) => todo.toJson(),
          );

  @override
  Future<void> addNewTodo(Todo todo) {
    return todoCollection.add(todo);
  }

  @override
  Future<void> deleteTodo(Todo todo) async {
    return todoCollection.doc(todo.id).delete();
  }

  @override
  Stream<List<Todo>> todos() {
    return todoCollection.snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => doc.data()).toList(),
        );
  }

  @override
  Future<void> updateTodo(Todo todo) {
    return todoCollection.doc(todo.id).update(todo.toJson());
  }

  @override
  Future<int> clearCompleted() async {
    final snapshot =
        await todoCollection.where('isComplete', isEqualTo: true).get();

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }

    return snapshot.docs.length;
  }

  @override
  Future<int> completeAll() async {
    final snapshot =
        await todoCollection.where('isComplete', isEqualTo: false).get();

    for (final doc in snapshot.docs) {
      await doc.reference.update({'isComplete': true});
    }

    return snapshot.docs.length;
  }
}
