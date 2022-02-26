import 'package:meta/meta.dart';

/// {@template todo}
/// A single todo object.
///
/// Contains a [title], [description] and [id], in addition to a [isComplete]
/// flag.
///
/// {@endtemplate}
@immutable
class Todo {
  /// [Todo] constructor.
  const Todo({
    required this.title,
    required this.description,
    this.isComplete = false,
    required this.id,
  });

  /// Converts [Map] object into a [Todo].
  Todo.fromJson(Map<String, Object?> json)
      : this(
          isComplete: json['isComplete']! as bool,
          id: json['id']! as String,
          description: json['description']! as String,
          title: json['title']! as String,
        );

  /// Whether the todo is completed.
  ///
  /// Defaults to `false`.
  final bool isComplete;

  /// The unique identifier of the todo.
  ///
  /// Cannot be empty.
  final String id;

  /// The description of the todo.
  ///
  /// Defaults to an empty string.
  final String description;

  /// The title of the todo.
  ///
  /// Note that the title may be empty.
  final String title;

  /// Converts this [Todo] object into a [Map].
  Map<String, Object?> toJson() {
    return {
      'isComplete': isComplete,
      'id': id,
      'description': description,
      'title': title,
    };
  }

  /// Returns a copy of this [Todo] with the given [title].
  Todo copyWith({
    bool? isComplete,
    String? id,
    String? description,
    String? title,
  }) {
    return Todo(
      isComplete: isComplete ?? this.isComplete,
      id: id ?? this.id,
      description: description ?? this.description,
      title: title ?? this.title,
    );
  }
}
